
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 a7 00 00 00       	call   8000d8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 0c             	sub    $0xc,%esp
  80003d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800040:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800043:	83 ff 01             	cmp    $0x1,%edi
  800046:	7e 26                	jle    80006e <umain+0x3a>
  800048:	8d 5e 04             	lea    0x4(%esi),%ebx
  80004b:	83 ec 08             	sub    $0x8,%esp
  80004e:	68 e0 1d 80 00       	push   $0x801de0
  800053:	ff 76 04             	pushl  0x4(%esi)
  800056:	e8 a7 01 00 00       	call   800202 <strcmp>
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	85 c0                	test   %eax,%eax
  800060:	75 0c                	jne    80006e <umain+0x3a>
		nflag = 1;
		argc--;
  800062:	4f                   	dec    %edi
  800063:	89 de                	mov    %ebx,%esi
  800065:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  80006c:	eb 07                	jmp    800075 <umain+0x41>
  80006e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800075:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007a:	eb 36                	jmp    8000b2 <umain+0x7e>
		argv++;
	}
	for (i = 1; i < argc; i++) {
		if (i > 1)
  80007c:	83 fb 01             	cmp    $0x1,%ebx
  80007f:	7e 14                	jle    800095 <umain+0x61>
			write(1, " ", 1);
  800081:	83 ec 04             	sub    $0x4,%esp
  800084:	6a 01                	push   $0x1
  800086:	68 e3 1d 80 00       	push   $0x801de3
  80008b:	6a 01                	push   $0x1
  80008d:	e8 ee 08 00 00       	call   800980 <write>
  800092:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800095:	83 ec 0c             	sub    $0xc,%esp
  800098:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009b:	e8 9c 00 00 00       	call   80013c <strlen>
  8000a0:	83 c4 0c             	add    $0xc,%esp
  8000a3:	50                   	push   %eax
  8000a4:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000a7:	6a 01                	push   $0x1
  8000a9:	e8 d2 08 00 00       	call   800980 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000ae:	43                   	inc    %ebx
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	39 df                	cmp    %ebx,%edi
  8000b4:	7f c6                	jg     80007c <umain+0x48>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8000ba:	75 14                	jne    8000d0 <umain+0x9c>
		write(1, "\n", 1);
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	6a 01                	push   $0x1
  8000c1:	68 f3 1e 80 00       	push   $0x801ef3
  8000c6:	6a 01                	push   $0x1
  8000c8:	e8 b3 08 00 00       	call   800980 <write>
  8000cd:	83 c4 10             	add    $0x10,%esp
}
  8000d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d3:	5b                   	pop    %ebx
  8000d4:	5e                   	pop    %esi
  8000d5:	5f                   	pop    %edi
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8000e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8000e3:	e8 ff 05 00 00       	call   8006e7 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000f4:	c1 e0 07             	shl    $0x7,%eax
  8000f7:	29 d0                	sub    %edx,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 f6                	test   %esi,%esi
  800105:	7e 07                	jle    80010e <libmain+0x36>
		binaryname = argv[0];
  800107:	8b 03                	mov    (%ebx),%eax
  800109:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	53                   	push   %ebx
  800112:	56                   	push   %esi
  800113:	e8 1c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800118:	e8 0b 00 00 00       	call   800128 <exit>
  80011d:	83 c4 10             	add    $0x10,%esp
}
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	c9                   	leave  
  800126:	c3                   	ret    
	...

00800128 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  80012e:	6a 00                	push   $0x0
  800130:	e8 d1 05 00 00       	call   800706 <sys_env_destroy>
  800135:	83 c4 10             	add    $0x10,%esp
}
  800138:	c9                   	leave  
  800139:	c3                   	ret    
	...

0080013c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	8b 55 08             	mov    0x8(%ebp),%edx
  800142:	b8 00 00 00 00       	mov    $0x0,%eax
  800147:	eb 01                	jmp    80014a <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800149:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80014a:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80014e:	75 f9                	jne    800149 <strlen+0xd>
		n++;
	return n;
}
  800150:	c9                   	leave  
  800151:	c3                   	ret    

00800152 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800158:	8b 55 0c             	mov    0xc(%ebp),%edx
  80015b:	b8 00 00 00 00       	mov    $0x0,%eax
  800160:	eb 01                	jmp    800163 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800162:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800163:	39 d0                	cmp    %edx,%eax
  800165:	74 06                	je     80016d <strnlen+0x1b>
  800167:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80016b:	75 f5                	jne    800162 <strnlen+0x10>
		n++;
	return n;
}
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800175:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800178:	8a 01                	mov    (%ecx),%al
  80017a:	88 02                	mov    %al,(%edx)
  80017c:	42                   	inc    %edx
  80017d:	41                   	inc    %ecx
  80017e:	84 c0                	test   %al,%al
  800180:	75 f6                	jne    800178 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800182:	8b 45 08             	mov    0x8(%ebp),%eax
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	53                   	push   %ebx
  80018b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80018e:	53                   	push   %ebx
  80018f:	e8 a8 ff ff ff       	call   80013c <strlen>
	strcpy(dst + len, src);
  800194:	ff 75 0c             	pushl  0xc(%ebp)
  800197:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 cf ff ff ff       	call   80016f <strcpy>
	return dst;
}
  8001a0:	89 d8                	mov    %ebx,%eax
  8001a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8001af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ba:	eb 0c                	jmp    8001c8 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8001bc:	8a 02                	mov    (%edx),%al
  8001be:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001c1:	80 3a 01             	cmpb   $0x1,(%edx)
  8001c4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001c7:	41                   	inc    %ecx
  8001c8:	39 d9                	cmp    %ebx,%ecx
  8001ca:	75 f0                	jne    8001bc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001cc:	89 f0                	mov    %esi,%eax
  8001ce:	5b                   	pop    %ebx
  8001cf:	5e                   	pop    %esi
  8001d0:	c9                   	leave  
  8001d1:	c3                   	ret    

008001d2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8001da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8001e0:	85 c9                	test   %ecx,%ecx
  8001e2:	75 04                	jne    8001e8 <strlcpy+0x16>
  8001e4:	89 f0                	mov    %esi,%eax
  8001e6:	eb 14                	jmp    8001fc <strlcpy+0x2a>
  8001e8:	89 f0                	mov    %esi,%eax
  8001ea:	eb 04                	jmp    8001f0 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8001ec:	88 10                	mov    %dl,(%eax)
  8001ee:	40                   	inc    %eax
  8001ef:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8001f0:	49                   	dec    %ecx
  8001f1:	74 06                	je     8001f9 <strlcpy+0x27>
  8001f3:	8a 13                	mov    (%ebx),%dl
  8001f5:	84 d2                	test   %dl,%dl
  8001f7:	75 f3                	jne    8001ec <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8001f9:	c6 00 00             	movb   $0x0,(%eax)
  8001fc:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8001fe:	5b                   	pop    %ebx
  8001ff:	5e                   	pop    %esi
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	eb 02                	jmp    80020f <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  80020d:	42                   	inc    %edx
  80020e:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80020f:	8a 02                	mov    (%edx),%al
  800211:	84 c0                	test   %al,%al
  800213:	74 04                	je     800219 <strcmp+0x17>
  800215:	3a 01                	cmp    (%ecx),%al
  800217:	74 f4                	je     80020d <strcmp+0xb>
  800219:	0f b6 c0             	movzbl %al,%eax
  80021c:	0f b6 11             	movzbl (%ecx),%edx
  80021f:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	53                   	push   %ebx
  800227:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80022d:	8b 55 10             	mov    0x10(%ebp),%edx
  800230:	eb 03                	jmp    800235 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800232:	4a                   	dec    %edx
  800233:	41                   	inc    %ecx
  800234:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800235:	85 d2                	test   %edx,%edx
  800237:	75 07                	jne    800240 <strncmp+0x1d>
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	eb 14                	jmp    800254 <strncmp+0x31>
  800240:	8a 01                	mov    (%ecx),%al
  800242:	84 c0                	test   %al,%al
  800244:	74 04                	je     80024a <strncmp+0x27>
  800246:	3a 03                	cmp    (%ebx),%al
  800248:	74 e8                	je     800232 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80024a:	0f b6 d0             	movzbl %al,%edx
  80024d:	0f b6 03             	movzbl (%ebx),%eax
  800250:	29 c2                	sub    %eax,%edx
  800252:	89 d0                	mov    %edx,%eax
}
  800254:	5b                   	pop    %ebx
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800260:	eb 05                	jmp    800267 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800262:	38 ca                	cmp    %cl,%dl
  800264:	74 0c                	je     800272 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800266:	40                   	inc    %eax
  800267:	8a 10                	mov    (%eax),%dl
  800269:	84 d2                	test   %dl,%dl
  80026b:	75 f5                	jne    800262 <strchr+0xb>
  80026d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	8b 45 08             	mov    0x8(%ebp),%eax
  80027a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  80027d:	eb 05                	jmp    800284 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  80027f:	38 ca                	cmp    %cl,%dl
  800281:	74 07                	je     80028a <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800283:	40                   	inc    %eax
  800284:	8a 10                	mov    (%eax),%dl
  800286:	84 d2                	test   %dl,%dl
  800288:	75 f5                	jne    80027f <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	8b 7d 08             	mov    0x8(%ebp),%edi
  800295:	8b 45 0c             	mov    0xc(%ebp),%eax
  800298:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  80029b:	85 db                	test   %ebx,%ebx
  80029d:	74 36                	je     8002d5 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80029f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002a5:	75 29                	jne    8002d0 <memset+0x44>
  8002a7:	f6 c3 03             	test   $0x3,%bl
  8002aa:	75 24                	jne    8002d0 <memset+0x44>
		c &= 0xFF;
  8002ac:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8002af:	89 d6                	mov    %edx,%esi
  8002b1:	c1 e6 08             	shl    $0x8,%esi
  8002b4:	89 d0                	mov    %edx,%eax
  8002b6:	c1 e0 18             	shl    $0x18,%eax
  8002b9:	89 d1                	mov    %edx,%ecx
  8002bb:	c1 e1 10             	shl    $0x10,%ecx
  8002be:	09 c8                	or     %ecx,%eax
  8002c0:	09 c2                	or     %eax,%edx
  8002c2:	89 f0                	mov    %esi,%eax
  8002c4:	09 d0                	or     %edx,%eax
  8002c6:	89 d9                	mov    %ebx,%ecx
  8002c8:	c1 e9 02             	shr    $0x2,%ecx
  8002cb:	fc                   	cld    
  8002cc:	f3 ab                	rep stos %eax,%es:(%edi)
  8002ce:	eb 05                	jmp    8002d5 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002d0:	89 d9                	mov    %ebx,%ecx
  8002d2:	fc                   	cld    
  8002d3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8002d5:	89 f8                	mov    %edi,%eax
  8002d7:	5b                   	pop    %ebx
  8002d8:	5e                   	pop    %esi
  8002d9:	5f                   	pop    %edi
  8002da:	c9                   	leave  
  8002db:	c3                   	ret    

008002dc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	57                   	push   %edi
  8002e0:	56                   	push   %esi
  8002e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8002e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8002ea:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8002ec:	39 c6                	cmp    %eax,%esi
  8002ee:	73 36                	jae    800326 <memmove+0x4a>
  8002f0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8002f3:	39 d0                	cmp    %edx,%eax
  8002f5:	73 2f                	jae    800326 <memmove+0x4a>
		s += n;
		d += n;
  8002f7:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8002fa:	f6 c2 03             	test   $0x3,%dl
  8002fd:	75 1b                	jne    80031a <memmove+0x3e>
  8002ff:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800305:	75 13                	jne    80031a <memmove+0x3e>
  800307:	f6 c1 03             	test   $0x3,%cl
  80030a:	75 0e                	jne    80031a <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  80030c:	8d 7e fc             	lea    -0x4(%esi),%edi
  80030f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800312:	c1 e9 02             	shr    $0x2,%ecx
  800315:	fd                   	std    
  800316:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800318:	eb 09                	jmp    800323 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80031a:	8d 7e ff             	lea    -0x1(%esi),%edi
  80031d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800320:	fd                   	std    
  800321:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800323:	fc                   	cld    
  800324:	eb 20                	jmp    800346 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800326:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80032c:	75 15                	jne    800343 <memmove+0x67>
  80032e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800334:	75 0d                	jne    800343 <memmove+0x67>
  800336:	f6 c1 03             	test   $0x3,%cl
  800339:	75 08                	jne    800343 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  80033b:	c1 e9 02             	shr    $0x2,%ecx
  80033e:	fc                   	cld    
  80033f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800341:	eb 03                	jmp    800346 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800343:	fc                   	cld    
  800344:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800346:	5e                   	pop    %esi
  800347:	5f                   	pop    %edi
  800348:	c9                   	leave  
  800349:	c3                   	ret    

0080034a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80034d:	ff 75 10             	pushl  0x10(%ebp)
  800350:	ff 75 0c             	pushl  0xc(%ebp)
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	e8 81 ff ff ff       	call   8002dc <memmove>
}
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	53                   	push   %ebx
  800361:	83 ec 04             	sub    $0x4,%esp
  800364:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800367:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  80036a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80036d:	eb 1b                	jmp    80038a <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  80036f:	8a 1a                	mov    (%edx),%bl
  800371:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800374:	8a 19                	mov    (%ecx),%bl
  800376:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800379:	74 0d                	je     800388 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  80037b:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  80037f:	0f b6 c3             	movzbl %bl,%eax
  800382:	29 c2                	sub    %eax,%edx
  800384:	89 d0                	mov    %edx,%eax
  800386:	eb 0d                	jmp    800395 <memcmp+0x38>
		s1++, s2++;
  800388:	42                   	inc    %edx
  800389:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80038a:	48                   	dec    %eax
  80038b:	83 f8 ff             	cmp    $0xffffffff,%eax
  80038e:	75 df                	jne    80036f <memcmp+0x12>
  800390:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800395:	83 c4 04             	add    $0x4,%esp
  800398:	5b                   	pop    %ebx
  800399:	c9                   	leave  
  80039a:	c3                   	ret    

0080039b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	03 55 10             	add    0x10(%ebp),%edx
  8003a9:	eb 05                	jmp    8003b0 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8003ab:	38 08                	cmp    %cl,(%eax)
  8003ad:	74 05                	je     8003b4 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003af:	40                   	inc    %eax
  8003b0:	39 d0                	cmp    %edx,%eax
  8003b2:	72 f7                	jb     8003ab <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003b4:	c9                   	leave  
  8003b5:	c3                   	ret    

008003b6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	57                   	push   %edi
  8003ba:	56                   	push   %esi
  8003bb:	53                   	push   %ebx
  8003bc:	83 ec 04             	sub    $0x4,%esp
  8003bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003c5:	eb 01                	jmp    8003c8 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8003c7:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003c8:	8a 01                	mov    (%ecx),%al
  8003ca:	3c 20                	cmp    $0x20,%al
  8003cc:	74 f9                	je     8003c7 <strtol+0x11>
  8003ce:	3c 09                	cmp    $0x9,%al
  8003d0:	74 f5                	je     8003c7 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  8003d2:	3c 2b                	cmp    $0x2b,%al
  8003d4:	75 0a                	jne    8003e0 <strtol+0x2a>
		s++;
  8003d6:	41                   	inc    %ecx
  8003d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8003de:	eb 17                	jmp    8003f7 <strtol+0x41>
	else if (*s == '-')
  8003e0:	3c 2d                	cmp    $0x2d,%al
  8003e2:	74 09                	je     8003ed <strtol+0x37>
  8003e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8003eb:	eb 0a                	jmp    8003f7 <strtol+0x41>
		s++, neg = 1;
  8003ed:	8d 49 01             	lea    0x1(%ecx),%ecx
  8003f0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8003f7:	85 f6                	test   %esi,%esi
  8003f9:	74 05                	je     800400 <strtol+0x4a>
  8003fb:	83 fe 10             	cmp    $0x10,%esi
  8003fe:	75 1a                	jne    80041a <strtol+0x64>
  800400:	8a 01                	mov    (%ecx),%al
  800402:	3c 30                	cmp    $0x30,%al
  800404:	75 10                	jne    800416 <strtol+0x60>
  800406:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80040a:	75 0a                	jne    800416 <strtol+0x60>
		s += 2, base = 16;
  80040c:	83 c1 02             	add    $0x2,%ecx
  80040f:	be 10 00 00 00       	mov    $0x10,%esi
  800414:	eb 04                	jmp    80041a <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800416:	85 f6                	test   %esi,%esi
  800418:	74 07                	je     800421 <strtol+0x6b>
  80041a:	bf 00 00 00 00       	mov    $0x0,%edi
  80041f:	eb 13                	jmp    800434 <strtol+0x7e>
  800421:	3c 30                	cmp    $0x30,%al
  800423:	74 07                	je     80042c <strtol+0x76>
  800425:	be 0a 00 00 00       	mov    $0xa,%esi
  80042a:	eb ee                	jmp    80041a <strtol+0x64>
		s++, base = 8;
  80042c:	41                   	inc    %ecx
  80042d:	be 08 00 00 00       	mov    $0x8,%esi
  800432:	eb e6                	jmp    80041a <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800434:	8a 11                	mov    (%ecx),%dl
  800436:	88 d3                	mov    %dl,%bl
  800438:	8d 42 d0             	lea    -0x30(%edx),%eax
  80043b:	3c 09                	cmp    $0x9,%al
  80043d:	77 08                	ja     800447 <strtol+0x91>
			dig = *s - '0';
  80043f:	0f be c2             	movsbl %dl,%eax
  800442:	8d 50 d0             	lea    -0x30(%eax),%edx
  800445:	eb 1c                	jmp    800463 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800447:	8d 43 9f             	lea    -0x61(%ebx),%eax
  80044a:	3c 19                	cmp    $0x19,%al
  80044c:	77 08                	ja     800456 <strtol+0xa0>
			dig = *s - 'a' + 10;
  80044e:	0f be c2             	movsbl %dl,%eax
  800451:	8d 50 a9             	lea    -0x57(%eax),%edx
  800454:	eb 0d                	jmp    800463 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800456:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800459:	3c 19                	cmp    $0x19,%al
  80045b:	77 15                	ja     800472 <strtol+0xbc>
			dig = *s - 'A' + 10;
  80045d:	0f be c2             	movsbl %dl,%eax
  800460:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800463:	39 f2                	cmp    %esi,%edx
  800465:	7d 0b                	jge    800472 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800467:	41                   	inc    %ecx
  800468:	89 f8                	mov    %edi,%eax
  80046a:	0f af c6             	imul   %esi,%eax
  80046d:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800470:	eb c2                	jmp    800434 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800472:	89 f8                	mov    %edi,%eax

	if (endptr)
  800474:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800478:	74 05                	je     80047f <strtol+0xc9>
		*endptr = (char *) s;
  80047a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047d:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  80047f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800483:	74 04                	je     800489 <strtol+0xd3>
  800485:	89 c7                	mov    %eax,%edi
  800487:	f7 df                	neg    %edi
}
  800489:	89 f8                	mov    %edi,%eax
  80048b:	83 c4 04             	add    $0x4,%esp
  80048e:	5b                   	pop    %ebx
  80048f:	5e                   	pop    %esi
  800490:	5f                   	pop    %edi
  800491:	c9                   	leave  
  800492:	c3                   	ret    
	...

00800494 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	57                   	push   %edi
  800498:	56                   	push   %esi
  800499:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80049a:	b8 01 00 00 00       	mov    $0x1,%eax
  80049f:	bf 00 00 00 00       	mov    $0x0,%edi
  8004a4:	89 fa                	mov    %edi,%edx
  8004a6:	89 f9                	mov    %edi,%ecx
  8004a8:	89 fb                	mov    %edi,%ebx
  8004aa:	89 fe                	mov    %edi,%esi
  8004ac:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004ae:	5b                   	pop    %ebx
  8004af:	5e                   	pop    %esi
  8004b0:	5f                   	pop    %edi
  8004b1:	c9                   	leave  
  8004b2:	c3                   	ret    

008004b3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004b3:	55                   	push   %ebp
  8004b4:	89 e5                	mov    %esp,%ebp
  8004b6:	57                   	push   %edi
  8004b7:	56                   	push   %esi
  8004b8:	53                   	push   %ebx
  8004b9:	83 ec 04             	sub    $0x4,%esp
  8004bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004c2:	bf 00 00 00 00       	mov    $0x0,%edi
  8004c7:	89 f8                	mov    %edi,%eax
  8004c9:	89 fb                	mov    %edi,%ebx
  8004cb:	89 fe                	mov    %edi,%esi
  8004cd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004cf:	83 c4 04             	add    $0x4,%esp
  8004d2:	5b                   	pop    %ebx
  8004d3:	5e                   	pop    %esi
  8004d4:	5f                   	pop    %edi
  8004d5:	c9                   	leave  
  8004d6:	c3                   	ret    

008004d7 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	57                   	push   %edi
  8004db:	56                   	push   %esi
  8004dc:	53                   	push   %ebx
  8004dd:	83 ec 0c             	sub    $0xc,%esp
  8004e0:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e3:	b8 0d 00 00 00       	mov    $0xd,%eax
  8004e8:	bf 00 00 00 00       	mov    $0x0,%edi
  8004ed:	89 f9                	mov    %edi,%ecx
  8004ef:	89 fb                	mov    %edi,%ebx
  8004f1:	89 fe                	mov    %edi,%esi
  8004f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8004f5:	85 c0                	test   %eax,%eax
  8004f7:	7e 17                	jle    800510 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004f9:	83 ec 0c             	sub    $0xc,%esp
  8004fc:	50                   	push   %eax
  8004fd:	6a 0d                	push   $0xd
  8004ff:	68 ef 1d 80 00       	push   $0x801def
  800504:	6a 23                	push   $0x23
  800506:	68 0c 1e 80 00       	push   $0x801e0c
  80050b:	e8 28 0f 00 00       	call   801438 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800510:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800513:	5b                   	pop    %ebx
  800514:	5e                   	pop    %esi
  800515:	5f                   	pop    %edi
  800516:	c9                   	leave  
  800517:	c3                   	ret    

00800518 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
  80051b:	57                   	push   %edi
  80051c:	56                   	push   %esi
  80051d:	53                   	push   %ebx
  80051e:	8b 55 08             	mov    0x8(%ebp),%edx
  800521:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800524:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800527:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80052a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80052f:	be 00 00 00 00       	mov    $0x0,%esi
  800534:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800536:	5b                   	pop    %ebx
  800537:	5e                   	pop    %esi
  800538:	5f                   	pop    %edi
  800539:	c9                   	leave  
  80053a:	c3                   	ret    

0080053b <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
  80053e:	57                   	push   %edi
  80053f:	56                   	push   %esi
  800540:	53                   	push   %ebx
  800541:	83 ec 0c             	sub    $0xc,%esp
  800544:	8b 55 08             	mov    0x8(%ebp),%edx
  800547:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80054a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054f:	bf 00 00 00 00       	mov    $0x0,%edi
  800554:	89 fb                	mov    %edi,%ebx
  800556:	89 fe                	mov    %edi,%esi
  800558:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80055a:	85 c0                	test   %eax,%eax
  80055c:	7e 17                	jle    800575 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	50                   	push   %eax
  800562:	6a 0a                	push   $0xa
  800564:	68 ef 1d 80 00       	push   $0x801def
  800569:	6a 23                	push   $0x23
  80056b:	68 0c 1e 80 00       	push   $0x801e0c
  800570:	e8 c3 0e 00 00       	call   801438 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800575:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800578:	5b                   	pop    %ebx
  800579:	5e                   	pop    %esi
  80057a:	5f                   	pop    %edi
  80057b:	c9                   	leave  
  80057c:	c3                   	ret    

0080057d <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80057d:	55                   	push   %ebp
  80057e:	89 e5                	mov    %esp,%ebp
  800580:	57                   	push   %edi
  800581:	56                   	push   %esi
  800582:	53                   	push   %ebx
  800583:	83 ec 0c             	sub    $0xc,%esp
  800586:	8b 55 08             	mov    0x8(%ebp),%edx
  800589:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80058c:	b8 09 00 00 00       	mov    $0x9,%eax
  800591:	bf 00 00 00 00       	mov    $0x0,%edi
  800596:	89 fb                	mov    %edi,%ebx
  800598:	89 fe                	mov    %edi,%esi
  80059a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80059c:	85 c0                	test   %eax,%eax
  80059e:	7e 17                	jle    8005b7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005a0:	83 ec 0c             	sub    $0xc,%esp
  8005a3:	50                   	push   %eax
  8005a4:	6a 09                	push   $0x9
  8005a6:	68 ef 1d 80 00       	push   $0x801def
  8005ab:	6a 23                	push   $0x23
  8005ad:	68 0c 1e 80 00       	push   $0x801e0c
  8005b2:	e8 81 0e 00 00       	call   801438 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8005b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005ba:	5b                   	pop    %ebx
  8005bb:	5e                   	pop    %esi
  8005bc:	5f                   	pop    %edi
  8005bd:	c9                   	leave  
  8005be:	c3                   	ret    

008005bf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8005bf:	55                   	push   %ebp
  8005c0:	89 e5                	mov    %esp,%ebp
  8005c2:	57                   	push   %edi
  8005c3:	56                   	push   %esi
  8005c4:	53                   	push   %ebx
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8005cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005ce:	b8 08 00 00 00       	mov    $0x8,%eax
  8005d3:	bf 00 00 00 00       	mov    $0x0,%edi
  8005d8:	89 fb                	mov    %edi,%ebx
  8005da:	89 fe                	mov    %edi,%esi
  8005dc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	7e 17                	jle    8005f9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	50                   	push   %eax
  8005e6:	6a 08                	push   $0x8
  8005e8:	68 ef 1d 80 00       	push   $0x801def
  8005ed:	6a 23                	push   $0x23
  8005ef:	68 0c 1e 80 00       	push   $0x801e0c
  8005f4:	e8 3f 0e 00 00       	call   801438 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8005f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fc:	5b                   	pop    %ebx
  8005fd:	5e                   	pop    %esi
  8005fe:	5f                   	pop    %edi
  8005ff:	c9                   	leave  
  800600:	c3                   	ret    

00800601 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800601:	55                   	push   %ebp
  800602:	89 e5                	mov    %esp,%ebp
  800604:	57                   	push   %edi
  800605:	56                   	push   %esi
  800606:	53                   	push   %ebx
  800607:	83 ec 0c             	sub    $0xc,%esp
  80060a:	8b 55 08             	mov    0x8(%ebp),%edx
  80060d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800610:	b8 06 00 00 00       	mov    $0x6,%eax
  800615:	bf 00 00 00 00       	mov    $0x0,%edi
  80061a:	89 fb                	mov    %edi,%ebx
  80061c:	89 fe                	mov    %edi,%esi
  80061e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800620:	85 c0                	test   %eax,%eax
  800622:	7e 17                	jle    80063b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800624:	83 ec 0c             	sub    $0xc,%esp
  800627:	50                   	push   %eax
  800628:	6a 06                	push   $0x6
  80062a:	68 ef 1d 80 00       	push   $0x801def
  80062f:	6a 23                	push   $0x23
  800631:	68 0c 1e 80 00       	push   $0x801e0c
  800636:	e8 fd 0d 00 00       	call   801438 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80063b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063e:	5b                   	pop    %ebx
  80063f:	5e                   	pop    %esi
  800640:	5f                   	pop    %edi
  800641:	c9                   	leave  
  800642:	c3                   	ret    

00800643 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800643:	55                   	push   %ebp
  800644:	89 e5                	mov    %esp,%ebp
  800646:	57                   	push   %edi
  800647:	56                   	push   %esi
  800648:	53                   	push   %ebx
  800649:	83 ec 0c             	sub    $0xc,%esp
  80064c:	8b 55 08             	mov    0x8(%ebp),%edx
  80064f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800652:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800655:	8b 7d 14             	mov    0x14(%ebp),%edi
  800658:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80065b:	b8 05 00 00 00       	mov    $0x5,%eax
  800660:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800662:	85 c0                	test   %eax,%eax
  800664:	7e 17                	jle    80067d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800666:	83 ec 0c             	sub    $0xc,%esp
  800669:	50                   	push   %eax
  80066a:	6a 05                	push   $0x5
  80066c:	68 ef 1d 80 00       	push   $0x801def
  800671:	6a 23                	push   $0x23
  800673:	68 0c 1e 80 00       	push   $0x801e0c
  800678:	e8 bb 0d 00 00       	call   801438 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80067d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800680:	5b                   	pop    %ebx
  800681:	5e                   	pop    %esi
  800682:	5f                   	pop    %edi
  800683:	c9                   	leave  
  800684:	c3                   	ret    

00800685 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	57                   	push   %edi
  800689:	56                   	push   %esi
  80068a:	53                   	push   %ebx
  80068b:	83 ec 0c             	sub    $0xc,%esp
  80068e:	8b 55 08             	mov    0x8(%ebp),%edx
  800691:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800694:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800697:	b8 04 00 00 00       	mov    $0x4,%eax
  80069c:	bf 00 00 00 00       	mov    $0x0,%edi
  8006a1:	89 fe                	mov    %edi,%esi
  8006a3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	7e 17                	jle    8006c0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006a9:	83 ec 0c             	sub    $0xc,%esp
  8006ac:	50                   	push   %eax
  8006ad:	6a 04                	push   $0x4
  8006af:	68 ef 1d 80 00       	push   $0x801def
  8006b4:	6a 23                	push   $0x23
  8006b6:	68 0c 1e 80 00       	push   $0x801e0c
  8006bb:	e8 78 0d 00 00       	call   801438 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8006c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c3:	5b                   	pop    %ebx
  8006c4:	5e                   	pop    %esi
  8006c5:	5f                   	pop    %edi
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006ce:	b8 0b 00 00 00       	mov    $0xb,%eax
  8006d3:	bf 00 00 00 00       	mov    $0x0,%edi
  8006d8:	89 fa                	mov    %edi,%edx
  8006da:	89 f9                	mov    %edi,%ecx
  8006dc:	89 fb                	mov    %edi,%ebx
  8006de:	89 fe                	mov    %edi,%esi
  8006e0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8006e2:	5b                   	pop    %ebx
  8006e3:	5e                   	pop    %esi
  8006e4:	5f                   	pop    %edi
  8006e5:	c9                   	leave  
  8006e6:	c3                   	ret    

008006e7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	57                   	push   %edi
  8006eb:	56                   	push   %esi
  8006ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006ed:	b8 02 00 00 00       	mov    $0x2,%eax
  8006f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8006f7:	89 fa                	mov    %edi,%edx
  8006f9:	89 f9                	mov    %edi,%ecx
  8006fb:	89 fb                	mov    %edi,%ebx
  8006fd:	89 fe                	mov    %edi,%esi
  8006ff:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800701:	5b                   	pop    %ebx
  800702:	5e                   	pop    %esi
  800703:	5f                   	pop    %edi
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	57                   	push   %edi
  80070a:	56                   	push   %esi
  80070b:	53                   	push   %ebx
  80070c:	83 ec 0c             	sub    $0xc,%esp
  80070f:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800712:	b8 03 00 00 00       	mov    $0x3,%eax
  800717:	bf 00 00 00 00       	mov    $0x0,%edi
  80071c:	89 f9                	mov    %edi,%ecx
  80071e:	89 fb                	mov    %edi,%ebx
  800720:	89 fe                	mov    %edi,%esi
  800722:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800724:	85 c0                	test   %eax,%eax
  800726:	7e 17                	jle    80073f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800728:	83 ec 0c             	sub    $0xc,%esp
  80072b:	50                   	push   %eax
  80072c:	6a 03                	push   $0x3
  80072e:	68 ef 1d 80 00       	push   $0x801def
  800733:	6a 23                	push   $0x23
  800735:	68 0c 1e 80 00       	push   $0x801e0c
  80073a:	e8 f9 0c 00 00       	call   801438 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5f                   	pop    %edi
  800745:	c9                   	leave  
  800746:	c3                   	ret    
	...

00800748 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	8b 45 08             	mov    0x8(%ebp),%eax
  80074e:	05 00 00 00 30       	add    $0x30000000,%eax
  800753:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80075b:	ff 75 08             	pushl  0x8(%ebp)
  80075e:	e8 e5 ff ff ff       	call   800748 <fd2num>
  800763:	83 c4 04             	add    $0x4,%esp
  800766:	c1 e0 0c             	shl    $0xc,%eax
  800769:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	53                   	push   %ebx
  800774:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800777:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  80077c:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80077e:	89 d0                	mov    %edx,%eax
  800780:	c1 e8 16             	shr    $0x16,%eax
  800783:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80078a:	a8 01                	test   $0x1,%al
  80078c:	74 10                	je     80079e <fd_alloc+0x2e>
  80078e:	89 d0                	mov    %edx,%eax
  800790:	c1 e8 0c             	shr    $0xc,%eax
  800793:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80079a:	a8 01                	test   $0x1,%al
  80079c:	75 09                	jne    8007a7 <fd_alloc+0x37>
			*fd_store = fd;
  80079e:	89 0b                	mov    %ecx,(%ebx)
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a5:	eb 19                	jmp    8007c0 <fd_alloc+0x50>
			return 0;
  8007a7:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8007ad:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8007b3:	75 c7                	jne    80077c <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8007b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8007bb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8007c0:	5b                   	pop    %ebx
  8007c1:	c9                   	leave  
  8007c2:	c3                   	ret    

008007c3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8007c9:	83 f8 1f             	cmp    $0x1f,%eax
  8007cc:	77 35                	ja     800803 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8007ce:	c1 e0 0c             	shl    $0xc,%eax
  8007d1:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8007d7:	89 d0                	mov    %edx,%eax
  8007d9:	c1 e8 16             	shr    $0x16,%eax
  8007dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8007e3:	a8 01                	test   $0x1,%al
  8007e5:	74 1c                	je     800803 <fd_lookup+0x40>
  8007e7:	89 d0                	mov    %edx,%eax
  8007e9:	c1 e8 0c             	shr    $0xc,%eax
  8007ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8007f3:	a8 01                	test   $0x1,%al
  8007f5:	74 0c                	je     800803 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8007f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fa:	89 10                	mov    %edx,(%eax)
  8007fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800801:	eb 05                	jmp    800808 <fd_lookup+0x45>
	return 0;
  800803:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800810:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800813:	50                   	push   %eax
  800814:	ff 75 08             	pushl  0x8(%ebp)
  800817:	e8 a7 ff ff ff       	call   8007c3 <fd_lookup>
  80081c:	83 c4 08             	add    $0x8,%esp
  80081f:	85 c0                	test   %eax,%eax
  800821:	78 0e                	js     800831 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
  800826:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800829:	89 50 04             	mov    %edx,0x4(%eax)
  80082c:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	83 ec 04             	sub    $0x4,%esp
  80083a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800840:	ba 00 00 00 00       	mov    $0x0,%edx
  800845:	eb 0e                	jmp    800855 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800847:	3b 08                	cmp    (%eax),%ecx
  800849:	75 09                	jne    800854 <dev_lookup+0x21>
			*dev = devtab[i];
  80084b:	89 03                	mov    %eax,(%ebx)
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
  800852:	eb 31                	jmp    800885 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800854:	42                   	inc    %edx
  800855:	8b 04 95 98 1e 80 00 	mov    0x801e98(,%edx,4),%eax
  80085c:	85 c0                	test   %eax,%eax
  80085e:	75 e7                	jne    800847 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800860:	a1 04 40 80 00       	mov    0x804004,%eax
  800865:	8b 40 48             	mov    0x48(%eax),%eax
  800868:	83 ec 04             	sub    $0x4,%esp
  80086b:	51                   	push   %ecx
  80086c:	50                   	push   %eax
  80086d:	68 1c 1e 80 00       	push   $0x801e1c
  800872:	e8 62 0c 00 00       	call   8014d9 <cprintf>
	*dev = 0;
  800877:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80087d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800882:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  800885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	83 ec 14             	sub    $0x14,%esp
  800891:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800894:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800897:	50                   	push   %eax
  800898:	ff 75 08             	pushl  0x8(%ebp)
  80089b:	e8 23 ff ff ff       	call   8007c3 <fd_lookup>
  8008a0:	83 c4 08             	add    $0x8,%esp
  8008a3:	85 c0                	test   %eax,%eax
  8008a5:	78 55                	js     8008fc <fstat+0x72>
  8008a7:	83 ec 08             	sub    $0x8,%esp
  8008aa:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8008ad:	50                   	push   %eax
  8008ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b1:	ff 30                	pushl  (%eax)
  8008b3:	e8 7b ff ff ff       	call   800833 <dev_lookup>
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	85 c0                	test   %eax,%eax
  8008bd:	78 3d                	js     8008fc <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8008bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8008c2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c6:	75 07                	jne    8008cf <fstat+0x45>
  8008c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008cd:	eb 2d                	jmp    8008fc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008cf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008d2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008d9:	00 00 00 
	stat->st_isdir = 0;
  8008dc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008e3:	00 00 00 
	stat->st_dev = dev;
  8008e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8008e9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ef:	83 ec 08             	sub    $0x8,%esp
  8008f2:	53                   	push   %ebx
  8008f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8008f6:	ff 50 14             	call   *0x14(%eax)
  8008f9:	83 c4 10             	add    $0x10,%esp
}
  8008fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ff:	c9                   	leave  
  800900:	c3                   	ret    

00800901 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	53                   	push   %ebx
  800905:	83 ec 14             	sub    $0x14,%esp
  800908:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80090b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80090e:	50                   	push   %eax
  80090f:	53                   	push   %ebx
  800910:	e8 ae fe ff ff       	call   8007c3 <fd_lookup>
  800915:	83 c4 08             	add    $0x8,%esp
  800918:	85 c0                	test   %eax,%eax
  80091a:	78 5f                	js     80097b <ftruncate+0x7a>
  80091c:	83 ec 08             	sub    $0x8,%esp
  80091f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800922:	50                   	push   %eax
  800923:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800926:	ff 30                	pushl  (%eax)
  800928:	e8 06 ff ff ff       	call   800833 <dev_lookup>
  80092d:	83 c4 10             	add    $0x10,%esp
  800930:	85 c0                	test   %eax,%eax
  800932:	78 47                	js     80097b <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800934:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800937:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80093b:	75 21                	jne    80095e <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80093d:	a1 04 40 80 00       	mov    0x804004,%eax
  800942:	8b 40 48             	mov    0x48(%eax),%eax
  800945:	83 ec 04             	sub    $0x4,%esp
  800948:	53                   	push   %ebx
  800949:	50                   	push   %eax
  80094a:	68 3c 1e 80 00       	push   $0x801e3c
  80094f:	e8 85 0b 00 00       	call   8014d9 <cprintf>
  800954:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800959:	83 c4 10             	add    $0x10,%esp
  80095c:	eb 1d                	jmp    80097b <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80095e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800961:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  800965:	75 07                	jne    80096e <ftruncate+0x6d>
  800967:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80096c:	eb 0d                	jmp    80097b <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80096e:	83 ec 08             	sub    $0x8,%esp
  800971:	ff 75 0c             	pushl  0xc(%ebp)
  800974:	50                   	push   %eax
  800975:	ff 52 18             	call   *0x18(%edx)
  800978:	83 c4 10             	add    $0x10,%esp
}
  80097b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	53                   	push   %ebx
  800984:	83 ec 14             	sub    $0x14,%esp
  800987:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80098a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80098d:	50                   	push   %eax
  80098e:	53                   	push   %ebx
  80098f:	e8 2f fe ff ff       	call   8007c3 <fd_lookup>
  800994:	83 c4 08             	add    $0x8,%esp
  800997:	85 c0                	test   %eax,%eax
  800999:	78 62                	js     8009fd <write+0x7d>
  80099b:	83 ec 08             	sub    $0x8,%esp
  80099e:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8009a1:	50                   	push   %eax
  8009a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a5:	ff 30                	pushl  (%eax)
  8009a7:	e8 87 fe ff ff       	call   800833 <dev_lookup>
  8009ac:	83 c4 10             	add    $0x10,%esp
  8009af:	85 c0                	test   %eax,%eax
  8009b1:	78 4a                	js     8009fd <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8009b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8009ba:	75 21                	jne    8009dd <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8009bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8009c1:	8b 40 48             	mov    0x48(%eax),%eax
  8009c4:	83 ec 04             	sub    $0x4,%esp
  8009c7:	53                   	push   %ebx
  8009c8:	50                   	push   %eax
  8009c9:	68 5d 1e 80 00       	push   $0x801e5d
  8009ce:	e8 06 0b 00 00       	call   8014d9 <cprintf>
  8009d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8009d8:	83 c4 10             	add    $0x10,%esp
  8009db:	eb 20                	jmp    8009fd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8009dd:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8009e0:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8009e4:	75 07                	jne    8009ed <write+0x6d>
  8009e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8009eb:	eb 10                	jmp    8009fd <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8009ed:	83 ec 04             	sub    $0x4,%esp
  8009f0:	ff 75 10             	pushl  0x10(%ebp)
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	50                   	push   %eax
  8009f7:	ff 52 0c             	call   *0xc(%edx)
  8009fa:	83 c4 10             	add    $0x10,%esp
}
  8009fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    

00800a02 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	53                   	push   %ebx
  800a06:	83 ec 14             	sub    $0x14,%esp
  800a09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a0f:	50                   	push   %eax
  800a10:	53                   	push   %ebx
  800a11:	e8 ad fd ff ff       	call   8007c3 <fd_lookup>
  800a16:	83 c4 08             	add    $0x8,%esp
  800a19:	85 c0                	test   %eax,%eax
  800a1b:	78 67                	js     800a84 <read+0x82>
  800a1d:	83 ec 08             	sub    $0x8,%esp
  800a20:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800a23:	50                   	push   %eax
  800a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a27:	ff 30                	pushl  (%eax)
  800a29:	e8 05 fe ff ff       	call   800833 <dev_lookup>
  800a2e:	83 c4 10             	add    $0x10,%esp
  800a31:	85 c0                	test   %eax,%eax
  800a33:	78 4f                	js     800a84 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a35:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a38:	8b 42 08             	mov    0x8(%edx),%eax
  800a3b:	83 e0 03             	and    $0x3,%eax
  800a3e:	83 f8 01             	cmp    $0x1,%eax
  800a41:	75 21                	jne    800a64 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a43:	a1 04 40 80 00       	mov    0x804004,%eax
  800a48:	8b 40 48             	mov    0x48(%eax),%eax
  800a4b:	83 ec 04             	sub    $0x4,%esp
  800a4e:	53                   	push   %ebx
  800a4f:	50                   	push   %eax
  800a50:	68 7a 1e 80 00       	push   $0x801e7a
  800a55:	e8 7f 0a 00 00       	call   8014d9 <cprintf>
  800a5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800a5f:	83 c4 10             	add    $0x10,%esp
  800a62:	eb 20                	jmp    800a84 <read+0x82>
	}
	if (!dev->dev_read)
  800a64:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800a67:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  800a6b:	75 07                	jne    800a74 <read+0x72>
  800a6d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800a72:	eb 10                	jmp    800a84 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800a74:	83 ec 04             	sub    $0x4,%esp
  800a77:	ff 75 10             	pushl  0x10(%ebp)
  800a7a:	ff 75 0c             	pushl  0xc(%ebp)
  800a7d:	52                   	push   %edx
  800a7e:	ff 50 08             	call   *0x8(%eax)
  800a81:	83 c4 10             	add    $0x10,%esp
}
  800a84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a87:	c9                   	leave  
  800a88:	c3                   	ret    

00800a89 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	57                   	push   %edi
  800a8d:	56                   	push   %esi
  800a8e:	53                   	push   %ebx
  800a8f:	83 ec 0c             	sub    $0xc,%esp
  800a92:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a95:	8b 75 10             	mov    0x10(%ebp),%esi
  800a98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a9d:	eb 21                	jmp    800ac0 <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a9f:	83 ec 04             	sub    $0x4,%esp
  800aa2:	89 f0                	mov    %esi,%eax
  800aa4:	29 d0                	sub    %edx,%eax
  800aa6:	50                   	push   %eax
  800aa7:	8d 04 17             	lea    (%edi,%edx,1),%eax
  800aaa:	50                   	push   %eax
  800aab:	ff 75 08             	pushl  0x8(%ebp)
  800aae:	e8 4f ff ff ff       	call   800a02 <read>
		if (m < 0)
  800ab3:	83 c4 10             	add    $0x10,%esp
  800ab6:	85 c0                	test   %eax,%eax
  800ab8:	78 0e                	js     800ac8 <readn+0x3f>
			return m;
		if (m == 0)
  800aba:	85 c0                	test   %eax,%eax
  800abc:	74 08                	je     800ac6 <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800abe:	01 c3                	add    %eax,%ebx
  800ac0:	89 da                	mov    %ebx,%edx
  800ac2:	39 f3                	cmp    %esi,%ebx
  800ac4:	72 d9                	jb     800a9f <readn+0x16>
  800ac6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800ac8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800acb:	5b                   	pop    %ebx
  800acc:	5e                   	pop    %esi
  800acd:	5f                   	pop    %edi
  800ace:	c9                   	leave  
  800acf:	c3                   	ret    

00800ad0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	83 ec 20             	sub    $0x20,%esp
  800ad8:	8b 75 08             	mov    0x8(%ebp),%esi
  800adb:	8a 45 0c             	mov    0xc(%ebp),%al
  800ade:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ae1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae4:	50                   	push   %eax
  800ae5:	56                   	push   %esi
  800ae6:	e8 5d fc ff ff       	call   800748 <fd2num>
  800aeb:	89 04 24             	mov    %eax,(%esp)
  800aee:	e8 d0 fc ff ff       	call   8007c3 <fd_lookup>
  800af3:	89 c3                	mov    %eax,%ebx
  800af5:	83 c4 08             	add    $0x8,%esp
  800af8:	85 c0                	test   %eax,%eax
  800afa:	78 05                	js     800b01 <fd_close+0x31>
  800afc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800aff:	74 0d                	je     800b0e <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800b01:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800b05:	75 48                	jne    800b4f <fd_close+0x7f>
  800b07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b0c:	eb 41                	jmp    800b4f <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800b0e:	83 ec 08             	sub    $0x8,%esp
  800b11:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b14:	50                   	push   %eax
  800b15:	ff 36                	pushl  (%esi)
  800b17:	e8 17 fd ff ff       	call   800833 <dev_lookup>
  800b1c:	89 c3                	mov    %eax,%ebx
  800b1e:	83 c4 10             	add    $0x10,%esp
  800b21:	85 c0                	test   %eax,%eax
  800b23:	78 1c                	js     800b41 <fd_close+0x71>
		if (dev->dev_close)
  800b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b28:	8b 40 10             	mov    0x10(%eax),%eax
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	75 07                	jne    800b36 <fd_close+0x66>
  800b2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b34:	eb 0b                	jmp    800b41 <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  800b36:	83 ec 0c             	sub    $0xc,%esp
  800b39:	56                   	push   %esi
  800b3a:	ff d0                	call   *%eax
  800b3c:	89 c3                	mov    %eax,%ebx
  800b3e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800b41:	83 ec 08             	sub    $0x8,%esp
  800b44:	56                   	push   %esi
  800b45:	6a 00                	push   $0x0
  800b47:	e8 b5 fa ff ff       	call   800601 <sys_page_unmap>
  800b4c:	83 c4 10             	add    $0x10,%esp
	return r;
}
  800b4f:	89 d8                	mov    %ebx,%eax
  800b51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	c9                   	leave  
  800b57:	c3                   	ret    

00800b58 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b5e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b61:	50                   	push   %eax
  800b62:	ff 75 08             	pushl  0x8(%ebp)
  800b65:	e8 59 fc ff ff       	call   8007c3 <fd_lookup>
  800b6a:	83 c4 08             	add    $0x8,%esp
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	78 10                	js     800b81 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800b71:	83 ec 08             	sub    $0x8,%esp
  800b74:	6a 01                	push   $0x1
  800b76:	ff 75 fc             	pushl  -0x4(%ebp)
  800b79:	e8 52 ff ff ff       	call   800ad0 <fd_close>
  800b7e:	83 c4 10             	add    $0x10,%esp
}
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800b88:	83 ec 08             	sub    $0x8,%esp
  800b8b:	6a 00                	push   $0x0
  800b8d:	ff 75 08             	pushl  0x8(%ebp)
  800b90:	e8 4a 03 00 00       	call   800edf <open>
  800b95:	89 c6                	mov    %eax,%esi
  800b97:	83 c4 10             	add    $0x10,%esp
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	78 1b                	js     800bb9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800b9e:	83 ec 08             	sub    $0x8,%esp
  800ba1:	ff 75 0c             	pushl  0xc(%ebp)
  800ba4:	50                   	push   %eax
  800ba5:	e8 e0 fc ff ff       	call   80088a <fstat>
  800baa:	89 c3                	mov    %eax,%ebx
	close(fd);
  800bac:	89 34 24             	mov    %esi,(%esp)
  800baf:	e8 a4 ff ff ff       	call   800b58 <close>
  800bb4:	89 de                	mov    %ebx,%esi
  800bb6:	83 c4 10             	add    $0x10,%esp
	return r;
}
  800bb9:	89 f0                	mov    %esi,%eax
  800bbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	c9                   	leave  
  800bc1:	c3                   	ret    

00800bc2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 1c             	sub    $0x1c,%esp
  800bcb:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800bce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bd1:	50                   	push   %eax
  800bd2:	ff 75 08             	pushl  0x8(%ebp)
  800bd5:	e8 e9 fb ff ff       	call   8007c3 <fd_lookup>
  800bda:	89 c3                	mov    %eax,%ebx
  800bdc:	83 c4 08             	add    $0x8,%esp
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	0f 88 bd 00 00 00    	js     800ca4 <dup+0xe2>
		return r;
	close(newfdnum);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	57                   	push   %edi
  800beb:	e8 68 ff ff ff       	call   800b58 <close>

	newfd = INDEX2FD(newfdnum);
  800bf0:	89 f8                	mov    %edi,%eax
  800bf2:	c1 e0 0c             	shl    $0xc,%eax
  800bf5:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  800bfb:	ff 75 f0             	pushl  -0x10(%ebp)
  800bfe:	e8 55 fb ff ff       	call   800758 <fd2data>
  800c03:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800c05:	89 34 24             	mov    %esi,(%esp)
  800c08:	e8 4b fb ff ff       	call   800758 <fd2data>
  800c0d:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800c10:	89 d8                	mov    %ebx,%eax
  800c12:	c1 e8 16             	shr    $0x16,%eax
  800c15:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800c1c:	83 c4 14             	add    $0x14,%esp
  800c1f:	a8 01                	test   $0x1,%al
  800c21:	74 36                	je     800c59 <dup+0x97>
  800c23:	89 da                	mov    %ebx,%edx
  800c25:	c1 ea 0c             	shr    $0xc,%edx
  800c28:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800c2f:	a8 01                	test   $0x1,%al
  800c31:	74 26                	je     800c59 <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800c33:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800c3a:	83 ec 0c             	sub    $0xc,%esp
  800c3d:	25 07 0e 00 00       	and    $0xe07,%eax
  800c42:	50                   	push   %eax
  800c43:	ff 75 e0             	pushl  -0x20(%ebp)
  800c46:	6a 00                	push   $0x0
  800c48:	53                   	push   %ebx
  800c49:	6a 00                	push   $0x0
  800c4b:	e8 f3 f9 ff ff       	call   800643 <sys_page_map>
  800c50:	89 c3                	mov    %eax,%ebx
  800c52:	83 c4 20             	add    $0x20,%esp
  800c55:	85 c0                	test   %eax,%eax
  800c57:	78 30                	js     800c89 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800c59:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c5c:	89 d0                	mov    %edx,%eax
  800c5e:	c1 e8 0c             	shr    $0xc,%eax
  800c61:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	25 07 0e 00 00       	and    $0xe07,%eax
  800c70:	50                   	push   %eax
  800c71:	56                   	push   %esi
  800c72:	6a 00                	push   $0x0
  800c74:	52                   	push   %edx
  800c75:	6a 00                	push   $0x0
  800c77:	e8 c7 f9 ff ff       	call   800643 <sys_page_map>
  800c7c:	89 c3                	mov    %eax,%ebx
  800c7e:	83 c4 20             	add    $0x20,%esp
  800c81:	85 c0                	test   %eax,%eax
  800c83:	78 04                	js     800c89 <dup+0xc7>
		goto err;
  800c85:	89 fb                	mov    %edi,%ebx
  800c87:	eb 1b                	jmp    800ca4 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800c89:	83 ec 08             	sub    $0x8,%esp
  800c8c:	56                   	push   %esi
  800c8d:	6a 00                	push   $0x0
  800c8f:	e8 6d f9 ff ff       	call   800601 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800c94:	83 c4 08             	add    $0x8,%esp
  800c97:	ff 75 e0             	pushl  -0x20(%ebp)
  800c9a:	6a 00                	push   $0x0
  800c9c:	e8 60 f9 ff ff       	call   800601 <sys_page_unmap>
  800ca1:	83 c4 10             	add    $0x10,%esp
	return r;
}
  800ca4:	89 d8                	mov    %ebx,%eax
  800ca6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	c9                   	leave  
  800cad:	c3                   	ret    

00800cae <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 04             	sub    $0x4,%esp
  800cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	53                   	push   %ebx
  800cbe:	e8 95 fe ff ff       	call   800b58 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800cc3:	43                   	inc    %ebx
  800cc4:	83 c4 10             	add    $0x10,%esp
  800cc7:	83 fb 20             	cmp    $0x20,%ebx
  800cca:	75 ee                	jne    800cba <close_all+0xc>
		close(i);
}
  800ccc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ccf:	c9                   	leave  
  800cd0:	c3                   	ret    
  800cd1:	00 00                	add    %al,(%eax)
	...

00800cd4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	89 c3                	mov    %eax,%ebx
  800cdb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800cdd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800ce4:	75 12                	jne    800cf8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	6a 01                	push   $0x1
  800ceb:	e8 08 0d 00 00       	call   8019f8 <ipc_find_env>
  800cf0:	a3 00 40 80 00       	mov    %eax,0x804000
  800cf5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800cf8:	6a 07                	push   $0x7
  800cfa:	68 00 50 80 00       	push   $0x805000
  800cff:	53                   	push   %ebx
  800d00:	ff 35 00 40 80 00    	pushl  0x804000
  800d06:	e8 32 0d 00 00       	call   801a3d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d0b:	83 c4 0c             	add    $0xc,%esp
  800d0e:	6a 00                	push   $0x0
  800d10:	56                   	push   %esi
  800d11:	6a 00                	push   $0x0
  800d13:	e8 7a 0d 00 00       	call   801a92 <ipc_recv>
}
  800d18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	c9                   	leave  
  800d1e:	c3                   	ret    

00800d1f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d25:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d2f:	e8 a0 ff ff ff       	call   800cd4 <fsipc>
}
  800d34:	c9                   	leave  
  800d35:	c3                   	ret    

00800d36 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	8b 40 0c             	mov    0xc(%eax),%eax
  800d42:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d54:	b8 02 00 00 00       	mov    $0x2,%eax
  800d59:	e8 76 ff ff ff       	call   800cd4 <fsipc>
}
  800d5e:	c9                   	leave  
  800d5f:	c3                   	ret    

00800d60 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d66:	8b 45 08             	mov    0x8(%ebp),%eax
  800d69:	8b 40 0c             	mov    0xc(%eax),%eax
  800d6c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d71:	ba 00 00 00 00       	mov    $0x0,%edx
  800d76:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7b:	e8 54 ff ff ff       	call   800cd4 <fsipc>
}
  800d80:	c9                   	leave  
  800d81:	c3                   	ret    

00800d82 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	53                   	push   %ebx
  800d86:	83 ec 04             	sub    $0x4,%esp
  800d89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8f:	8b 40 0c             	mov    0xc(%eax),%eax
  800d92:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d97:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9c:	b8 05 00 00 00       	mov    $0x5,%eax
  800da1:	e8 2e ff ff ff       	call   800cd4 <fsipc>
  800da6:	85 c0                	test   %eax,%eax
  800da8:	78 2c                	js     800dd6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800daa:	83 ec 08             	sub    $0x8,%esp
  800dad:	68 00 50 80 00       	push   $0x805000
  800db2:	53                   	push   %ebx
  800db3:	e8 b7 f3 ff ff       	call   80016f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800db8:	a1 80 50 80 00       	mov    0x805080,%eax
  800dbd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800dc3:	a1 84 50 80 00       	mov    0x805084,%eax
  800dc8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800dce:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd3:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  800dd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd9:	c9                   	leave  
  800dda:	c3                   	ret    

00800ddb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	53                   	push   %ebx
  800ddf:	83 ec 08             	sub    $0x8,%esp
  800de2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	8b 40 0c             	mov    0xc(%eax),%eax
  800deb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  800df0:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800df6:	53                   	push   %ebx
  800df7:	ff 75 0c             	pushl  0xc(%ebp)
  800dfa:	68 08 50 80 00       	push   $0x805008
  800dff:	e8 d8 f4 ff ff       	call   8002dc <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800e04:	ba 00 00 00 00       	mov    $0x0,%edx
  800e09:	b8 04 00 00 00       	mov    $0x4,%eax
  800e0e:	e8 c1 fe ff ff       	call   800cd4 <fsipc>
  800e13:	83 c4 10             	add    $0x10,%esp
  800e16:	85 c0                	test   %eax,%eax
  800e18:	78 3d                	js     800e57 <devfile_write+0x7c>
		return r;
	assert(r <= n);
  800e1a:	39 c3                	cmp    %eax,%ebx
  800e1c:	73 19                	jae    800e37 <devfile_write+0x5c>
  800e1e:	68 a8 1e 80 00       	push   $0x801ea8
  800e23:	68 af 1e 80 00       	push   $0x801eaf
  800e28:	68 97 00 00 00       	push   $0x97
  800e2d:	68 c4 1e 80 00       	push   $0x801ec4
  800e32:	e8 01 06 00 00       	call   801438 <_panic>
	assert(r <= PGSIZE);
  800e37:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e3c:	7e 19                	jle    800e57 <devfile_write+0x7c>
  800e3e:	68 cf 1e 80 00       	push   $0x801ecf
  800e43:	68 af 1e 80 00       	push   $0x801eaf
  800e48:	68 98 00 00 00       	push   $0x98
  800e4d:	68 c4 1e 80 00       	push   $0x801ec4
  800e52:	e8 e1 05 00 00       	call   801438 <_panic>
	
	return r;
}
  800e57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e5a:	c9                   	leave  
  800e5b:	c3                   	ret    

00800e5c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	56                   	push   %esi
  800e60:	53                   	push   %ebx
  800e61:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
  800e67:	8b 40 0c             	mov    0xc(%eax),%eax
  800e6a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e6f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e75:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7a:	b8 03 00 00 00       	mov    $0x3,%eax
  800e7f:	e8 50 fe ff ff       	call   800cd4 <fsipc>
  800e84:	89 c3                	mov    %eax,%ebx
  800e86:	85 c0                	test   %eax,%eax
  800e88:	78 4c                	js     800ed6 <devfile_read+0x7a>
		return r;
	assert(r <= n);
  800e8a:	39 de                	cmp    %ebx,%esi
  800e8c:	73 16                	jae    800ea4 <devfile_read+0x48>
  800e8e:	68 a8 1e 80 00       	push   $0x801ea8
  800e93:	68 af 1e 80 00       	push   $0x801eaf
  800e98:	6a 7c                	push   $0x7c
  800e9a:	68 c4 1e 80 00       	push   $0x801ec4
  800e9f:	e8 94 05 00 00       	call   801438 <_panic>
	assert(r <= PGSIZE);
  800ea4:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  800eaa:	7e 16                	jle    800ec2 <devfile_read+0x66>
  800eac:	68 cf 1e 80 00       	push   $0x801ecf
  800eb1:	68 af 1e 80 00       	push   $0x801eaf
  800eb6:	6a 7d                	push   $0x7d
  800eb8:	68 c4 1e 80 00       	push   $0x801ec4
  800ebd:	e8 76 05 00 00       	call   801438 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ec2:	83 ec 04             	sub    $0x4,%esp
  800ec5:	50                   	push   %eax
  800ec6:	68 00 50 80 00       	push   $0x805000
  800ecb:	ff 75 0c             	pushl  0xc(%ebp)
  800ece:	e8 09 f4 ff ff       	call   8002dc <memmove>
  800ed3:	83 c4 10             	add    $0x10,%esp
	return r;
}
  800ed6:	89 d8                	mov    %ebx,%eax
  800ed8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800edb:	5b                   	pop    %ebx
  800edc:	5e                   	pop    %esi
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 1c             	sub    $0x1c,%esp
  800ee7:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800eea:	56                   	push   %esi
  800eeb:	e8 4c f2 ff ff       	call   80013c <strlen>
  800ef0:	83 c4 10             	add    $0x10,%esp
  800ef3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ef8:	7e 07                	jle    800f01 <open+0x22>
  800efa:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800eff:	eb 63                	jmp    800f64 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f01:	83 ec 0c             	sub    $0xc,%esp
  800f04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f07:	50                   	push   %eax
  800f08:	e8 63 f8 ff ff       	call   800770 <fd_alloc>
  800f0d:	89 c3                	mov    %eax,%ebx
  800f0f:	83 c4 10             	add    $0x10,%esp
  800f12:	85 c0                	test   %eax,%eax
  800f14:	78 4e                	js     800f64 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800f16:	83 ec 08             	sub    $0x8,%esp
  800f19:	56                   	push   %esi
  800f1a:	68 00 50 80 00       	push   $0x805000
  800f1f:	e8 4b f2 ff ff       	call   80016f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f27:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800f34:	e8 9b fd ff ff       	call   800cd4 <fsipc>
  800f39:	89 c3                	mov    %eax,%ebx
  800f3b:	83 c4 10             	add    $0x10,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	79 12                	jns    800f54 <open+0x75>
		fd_close(fd, 0);
  800f42:	83 ec 08             	sub    $0x8,%esp
  800f45:	6a 00                	push   $0x0
  800f47:	ff 75 f4             	pushl  -0xc(%ebp)
  800f4a:	e8 81 fb ff ff       	call   800ad0 <fd_close>
		return r;
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	eb 10                	jmp    800f64 <open+0x85>
	}

	return fd2num(fd);
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	ff 75 f4             	pushl  -0xc(%ebp)
  800f5a:	e8 e9 f7 ff ff       	call   800748 <fd2num>
  800f5f:	89 c3                	mov    %eax,%ebx
  800f61:	83 c4 10             	add    $0x10,%esp
}
  800f64:	89 d8                	mov    %ebx,%eax
  800f66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	c9                   	leave  
  800f6c:	c3                   	ret    
  800f6d:	00 00                	add    %al,(%eax)
	...

00800f70 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	56                   	push   %esi
  800f74:	53                   	push   %ebx
  800f75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f78:	83 ec 0c             	sub    $0xc,%esp
  800f7b:	ff 75 08             	pushl  0x8(%ebp)
  800f7e:	e8 d5 f7 ff ff       	call   800758 <fd2data>
  800f83:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f85:	83 c4 08             	add    $0x8,%esp
  800f88:	68 db 1e 80 00       	push   $0x801edb
  800f8d:	53                   	push   %ebx
  800f8e:	e8 dc f1 ff ff       	call   80016f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f93:	8b 46 04             	mov    0x4(%esi),%eax
  800f96:	2b 06                	sub    (%esi),%eax
  800f98:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f9e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800fa5:	00 00 00 
	stat->st_dev = &devpipe;
  800fa8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800faf:	30 80 00 
	return 0;
}
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fba:	5b                   	pop    %ebx
  800fbb:	5e                   	pop    %esi
  800fbc:	c9                   	leave  
  800fbd:	c3                   	ret    

00800fbe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	53                   	push   %ebx
  800fc2:	83 ec 0c             	sub    $0xc,%esp
  800fc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800fc8:	53                   	push   %ebx
  800fc9:	6a 00                	push   $0x0
  800fcb:	e8 31 f6 ff ff       	call   800601 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800fd0:	89 1c 24             	mov    %ebx,(%esp)
  800fd3:	e8 80 f7 ff ff       	call   800758 <fd2data>
  800fd8:	83 c4 08             	add    $0x8,%esp
  800fdb:	50                   	push   %eax
  800fdc:	6a 00                	push   $0x0
  800fde:	e8 1e f6 ff ff       	call   800601 <sys_page_unmap>
}
  800fe3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe6:	c9                   	leave  
  800fe7:	c3                   	ret    

00800fe8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	57                   	push   %edi
  800fec:	56                   	push   %esi
  800fed:	53                   	push   %ebx
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ff4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800ff6:	a1 04 40 80 00       	mov    0x804004,%eax
  800ffb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800ffe:	83 ec 0c             	sub    $0xc,%esp
  801001:	ff 75 f0             	pushl  -0x10(%ebp)
  801004:	e8 f3 0a 00 00       	call   801afc <pageref>
  801009:	89 c3                	mov    %eax,%ebx
  80100b:	89 3c 24             	mov    %edi,(%esp)
  80100e:	e8 e9 0a 00 00       	call   801afc <pageref>
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	39 c3                	cmp    %eax,%ebx
  801018:	0f 94 c0             	sete   %al
  80101b:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  80101e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801024:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  801027:	39 c6                	cmp    %eax,%esi
  801029:	74 1b                	je     801046 <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  80102b:	83 f9 01             	cmp    $0x1,%ecx
  80102e:	75 c6                	jne    800ff6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801030:	8b 42 58             	mov    0x58(%edx),%eax
  801033:	6a 01                	push   $0x1
  801035:	50                   	push   %eax
  801036:	56                   	push   %esi
  801037:	68 e2 1e 80 00       	push   $0x801ee2
  80103c:	e8 98 04 00 00       	call   8014d9 <cprintf>
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	eb b0                	jmp    800ff6 <_pipeisclosed+0xe>
	}
}
  801046:	89 c8                	mov    %ecx,%eax
  801048:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	c9                   	leave  
  80104f:	c3                   	ret    

00801050 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	53                   	push   %ebx
  801056:	83 ec 18             	sub    $0x18,%esp
  801059:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80105c:	56                   	push   %esi
  80105d:	e8 f6 f6 ff ff       	call   800758 <fd2data>
  801062:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801064:	8b 45 0c             	mov    0xc(%ebp),%eax
  801067:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80106a:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	eb 40                	jmp    8010b4 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801074:	b8 00 00 00 00       	mov    $0x0,%eax
  801079:	eb 40                	jmp    8010bb <devpipe_write+0x6b>
  80107b:	89 da                	mov    %ebx,%edx
  80107d:	89 f0                	mov    %esi,%eax
  80107f:	e8 64 ff ff ff       	call   800fe8 <_pipeisclosed>
  801084:	85 c0                	test   %eax,%eax
  801086:	75 ec                	jne    801074 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801088:	e8 3b f6 ff ff       	call   8006c8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80108d:	8b 53 04             	mov    0x4(%ebx),%edx
  801090:	8b 03                	mov    (%ebx),%eax
  801092:	83 c0 20             	add    $0x20,%eax
  801095:	39 c2                	cmp    %eax,%edx
  801097:	73 e2                	jae    80107b <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801099:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80109f:	79 05                	jns    8010a6 <devpipe_write+0x56>
  8010a1:	4a                   	dec    %edx
  8010a2:	83 ca e0             	or     $0xffffffe0,%edx
  8010a5:	42                   	inc    %edx
  8010a6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8010a9:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  8010ac:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8010b0:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010b3:	47                   	inc    %edi
  8010b4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010b7:	75 d4                	jne    80108d <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8010b9:	89 f8                	mov    %edi,%eax
}
  8010bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010be:	5b                   	pop    %ebx
  8010bf:	5e                   	pop    %esi
  8010c0:	5f                   	pop    %edi
  8010c1:	c9                   	leave  
  8010c2:	c3                   	ret    

008010c3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	57                   	push   %edi
  8010c7:	56                   	push   %esi
  8010c8:	53                   	push   %ebx
  8010c9:	83 ec 18             	sub    $0x18,%esp
  8010cc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8010cf:	57                   	push   %edi
  8010d0:	e8 83 f6 ff ff       	call   800758 <fd2data>
  8010d5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  8010d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8010dd:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	eb 41                	jmp    801128 <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8010e7:	89 f0                	mov    %esi,%eax
  8010e9:	eb 44                	jmp    80112f <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8010eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f0:	eb 3d                	jmp    80112f <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8010f2:	85 f6                	test   %esi,%esi
  8010f4:	75 f1                	jne    8010e7 <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8010f6:	89 da                	mov    %ebx,%edx
  8010f8:	89 f8                	mov    %edi,%eax
  8010fa:	e8 e9 fe ff ff       	call   800fe8 <_pipeisclosed>
  8010ff:	85 c0                	test   %eax,%eax
  801101:	75 e8                	jne    8010eb <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801103:	e8 c0 f5 ff ff       	call   8006c8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801108:	8b 03                	mov    (%ebx),%eax
  80110a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80110d:	74 e3                	je     8010f2 <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80110f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801114:	79 05                	jns    80111b <devpipe_read+0x58>
  801116:	48                   	dec    %eax
  801117:	83 c8 e0             	or     $0xffffffe0,%eax
  80111a:	40                   	inc    %eax
  80111b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80111f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801122:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  801125:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801127:	46                   	inc    %esi
  801128:	3b 75 10             	cmp    0x10(%ebp),%esi
  80112b:	75 db                	jne    801108 <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80112d:	89 f0                	mov    %esi,%eax
}
  80112f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80113d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801140:	50                   	push   %eax
  801141:	ff 75 08             	pushl  0x8(%ebp)
  801144:	e8 7a f6 ff ff       	call   8007c3 <fd_lookup>
  801149:	83 c4 10             	add    $0x10,%esp
  80114c:	85 c0                	test   %eax,%eax
  80114e:	78 18                	js     801168 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801150:	83 ec 0c             	sub    $0xc,%esp
  801153:	ff 75 fc             	pushl  -0x4(%ebp)
  801156:	e8 fd f5 ff ff       	call   800758 <fd2data>
  80115b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80115d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801160:	e8 83 fe ff ff       	call   800fe8 <_pipeisclosed>
  801165:	83 c4 10             	add    $0x10,%esp
}
  801168:	c9                   	leave  
  801169:	c3                   	ret    

0080116a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	57                   	push   %edi
  80116e:	56                   	push   %esi
  80116f:	53                   	push   %ebx
  801170:	83 ec 28             	sub    $0x28,%esp
  801173:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801176:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801179:	50                   	push   %eax
  80117a:	e8 f1 f5 ff ff       	call   800770 <fd_alloc>
  80117f:	89 c3                	mov    %eax,%ebx
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	0f 88 24 01 00 00    	js     8012b0 <pipe+0x146>
  80118c:	83 ec 04             	sub    $0x4,%esp
  80118f:	68 07 04 00 00       	push   $0x407
  801194:	ff 75 f0             	pushl  -0x10(%ebp)
  801197:	6a 00                	push   $0x0
  801199:	e8 e7 f4 ff ff       	call   800685 <sys_page_alloc>
  80119e:	89 c3                	mov    %eax,%ebx
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	0f 88 05 01 00 00    	js     8012b0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8011ab:	83 ec 0c             	sub    $0xc,%esp
  8011ae:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8011b1:	50                   	push   %eax
  8011b2:	e8 b9 f5 ff ff       	call   800770 <fd_alloc>
  8011b7:	89 c3                	mov    %eax,%ebx
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	0f 88 dc 00 00 00    	js     8012a0 <pipe+0x136>
  8011c4:	83 ec 04             	sub    $0x4,%esp
  8011c7:	68 07 04 00 00       	push   $0x407
  8011cc:	ff 75 ec             	pushl  -0x14(%ebp)
  8011cf:	6a 00                	push   $0x0
  8011d1:	e8 af f4 ff ff       	call   800685 <sys_page_alloc>
  8011d6:	89 c3                	mov    %eax,%ebx
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	0f 88 bd 00 00 00    	js     8012a0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8011e3:	83 ec 0c             	sub    $0xc,%esp
  8011e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8011e9:	e8 6a f5 ff ff       	call   800758 <fd2data>
  8011ee:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f0:	83 c4 0c             	add    $0xc,%esp
  8011f3:	68 07 04 00 00       	push   $0x407
  8011f8:	50                   	push   %eax
  8011f9:	6a 00                	push   $0x0
  8011fb:	e8 85 f4 ff ff       	call   800685 <sys_page_alloc>
  801200:	89 c3                	mov    %eax,%ebx
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	85 c0                	test   %eax,%eax
  801207:	0f 88 83 00 00 00    	js     801290 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80120d:	83 ec 0c             	sub    $0xc,%esp
  801210:	ff 75 ec             	pushl  -0x14(%ebp)
  801213:	e8 40 f5 ff ff       	call   800758 <fd2data>
  801218:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80121f:	50                   	push   %eax
  801220:	6a 00                	push   $0x0
  801222:	56                   	push   %esi
  801223:	6a 00                	push   $0x0
  801225:	e8 19 f4 ff ff       	call   800643 <sys_page_map>
  80122a:	89 c3                	mov    %eax,%ebx
  80122c:	83 c4 20             	add    $0x20,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	78 4f                	js     801282 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801233:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801239:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80123e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801241:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801248:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80124e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801251:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801253:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801256:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80125d:	83 ec 0c             	sub    $0xc,%esp
  801260:	ff 75 f0             	pushl  -0x10(%ebp)
  801263:	e8 e0 f4 ff ff       	call   800748 <fd2num>
  801268:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80126a:	83 c4 04             	add    $0x4,%esp
  80126d:	ff 75 ec             	pushl  -0x14(%ebp)
  801270:	e8 d3 f4 ff ff       	call   800748 <fd2num>
  801275:	89 47 04             	mov    %eax,0x4(%edi)
  801278:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	eb 2e                	jmp    8012b0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801282:	83 ec 08             	sub    $0x8,%esp
  801285:	56                   	push   %esi
  801286:	6a 00                	push   $0x0
  801288:	e8 74 f3 ff ff       	call   800601 <sys_page_unmap>
  80128d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801290:	83 ec 08             	sub    $0x8,%esp
  801293:	ff 75 ec             	pushl  -0x14(%ebp)
  801296:	6a 00                	push   $0x0
  801298:	e8 64 f3 ff ff       	call   800601 <sys_page_unmap>
  80129d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8012a0:	83 ec 08             	sub    $0x8,%esp
  8012a3:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a6:	6a 00                	push   $0x0
  8012a8:	e8 54 f3 ff ff       	call   800601 <sys_page_unmap>
  8012ad:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8012b0:	89 d8                	mov    %ebx,%eax
  8012b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b5:	5b                   	pop    %ebx
  8012b6:	5e                   	pop    %esi
  8012b7:	5f                   	pop    %edi
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    
	...

008012bc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8012bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c4:	c9                   	leave  
  8012c5:	c3                   	ret    

008012c6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8012cc:	68 fa 1e 80 00       	push   $0x801efa
  8012d1:	ff 75 0c             	pushl  0xc(%ebp)
  8012d4:	e8 96 ee ff ff       	call   80016f <strcpy>
	return 0;
}
  8012d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012de:	c9                   	leave  
  8012df:	c3                   	ret    

008012e0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	57                   	push   %edi
  8012e4:	56                   	push   %esi
  8012e5:	53                   	push   %ebx
  8012e6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  8012ec:	be 00 00 00 00       	mov    $0x0,%esi
  8012f1:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  8012f7:	eb 2c                	jmp    801325 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8012f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012fc:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8012fe:	83 fb 7f             	cmp    $0x7f,%ebx
  801301:	76 05                	jbe    801308 <devcons_write+0x28>
  801303:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801308:	83 ec 04             	sub    $0x4,%esp
  80130b:	53                   	push   %ebx
  80130c:	03 45 0c             	add    0xc(%ebp),%eax
  80130f:	50                   	push   %eax
  801310:	57                   	push   %edi
  801311:	e8 c6 ef ff ff       	call   8002dc <memmove>
		sys_cputs(buf, m);
  801316:	83 c4 08             	add    $0x8,%esp
  801319:	53                   	push   %ebx
  80131a:	57                   	push   %edi
  80131b:	e8 93 f1 ff ff       	call   8004b3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801320:	01 de                	add    %ebx,%esi
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	89 f0                	mov    %esi,%eax
  801327:	3b 75 10             	cmp    0x10(%ebp),%esi
  80132a:	72 cd                	jb     8012f9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80132c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80132f:	5b                   	pop    %ebx
  801330:	5e                   	pop    %esi
  801331:	5f                   	pop    %edi
  801332:	c9                   	leave  
  801333:	c3                   	ret    

00801334 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80133a:	8b 45 08             	mov    0x8(%ebp),%eax
  80133d:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801340:	6a 01                	push   $0x1
  801342:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801345:	50                   	push   %eax
  801346:	e8 68 f1 ff ff       	call   8004b3 <sys_cputs>
  80134b:	83 c4 10             	add    $0x10,%esp
}
  80134e:	c9                   	leave  
  80134f:	c3                   	ret    

00801350 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801356:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80135a:	74 27                	je     801383 <devcons_read+0x33>
  80135c:	eb 05                	jmp    801363 <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80135e:	e8 65 f3 ff ff       	call   8006c8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801363:	e8 2c f1 ff ff       	call   800494 <sys_cgetc>
  801368:	89 c2                	mov    %eax,%edx
  80136a:	85 c0                	test   %eax,%eax
  80136c:	74 f0                	je     80135e <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 16                	js     801388 <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801372:	83 f8 04             	cmp    $0x4,%eax
  801375:	74 0c                	je     801383 <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  801377:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137a:	88 10                	mov    %dl,(%eax)
  80137c:	ba 01 00 00 00       	mov    $0x1,%edx
  801381:	eb 05                	jmp    801388 <devcons_read+0x38>
	return 1;
  801383:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801388:	89 d0                	mov    %edx,%eax
  80138a:	c9                   	leave  
  80138b:	c3                   	ret    

0080138c <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801392:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801395:	50                   	push   %eax
  801396:	e8 d5 f3 ff ff       	call   800770 <fd_alloc>
  80139b:	83 c4 10             	add    $0x10,%esp
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	78 3b                	js     8013dd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013a2:	83 ec 04             	sub    $0x4,%esp
  8013a5:	68 07 04 00 00       	push   $0x407
  8013aa:	ff 75 fc             	pushl  -0x4(%ebp)
  8013ad:	6a 00                	push   $0x0
  8013af:	e8 d1 f2 ff ff       	call   800685 <sys_page_alloc>
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 22                	js     8013dd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8013bb:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8013c0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8013c3:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  8013c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013c8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013cf:	83 ec 0c             	sub    $0xc,%esp
  8013d2:	ff 75 fc             	pushl  -0x4(%ebp)
  8013d5:	e8 6e f3 ff ff       	call   800748 <fd2num>
  8013da:	83 c4 10             	add    $0x10,%esp
}
  8013dd:	c9                   	leave  
  8013de:	c3                   	ret    

008013df <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013e8:	50                   	push   %eax
  8013e9:	ff 75 08             	pushl  0x8(%ebp)
  8013ec:	e8 d2 f3 ff ff       	call   8007c3 <fd_lookup>
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 11                	js     801409 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8013f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013fb:	8b 00                	mov    (%eax),%eax
  8013fd:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  801403:	0f 94 c0             	sete   %al
  801406:	0f b6 c0             	movzbl %al,%eax
}
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801411:	6a 01                	push   $0x1
  801413:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801416:	50                   	push   %eax
  801417:	6a 00                	push   $0x0
  801419:	e8 e4 f5 ff ff       	call   800a02 <read>
	if (r < 0)
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	78 0f                	js     801434 <getchar+0x29>
		return r;
	if (r < 1)
  801425:	85 c0                	test   %eax,%eax
  801427:	75 07                	jne    801430 <getchar+0x25>
  801429:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80142e:	eb 04                	jmp    801434 <getchar+0x29>
		return -E_EOF;
	return c;
  801430:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  801434:	c9                   	leave  
  801435:	c3                   	ret    
	...

00801438 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	53                   	push   %ebx
  80143c:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  80143f:	8d 45 14             	lea    0x14(%ebp),%eax
  801442:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801445:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80144b:	e8 97 f2 ff ff       	call   8006e7 <sys_getenvid>
  801450:	83 ec 0c             	sub    $0xc,%esp
  801453:	ff 75 0c             	pushl  0xc(%ebp)
  801456:	ff 75 08             	pushl  0x8(%ebp)
  801459:	53                   	push   %ebx
  80145a:	50                   	push   %eax
  80145b:	68 08 1f 80 00       	push   $0x801f08
  801460:	e8 74 00 00 00       	call   8014d9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801465:	83 c4 18             	add    $0x18,%esp
  801468:	ff 75 f8             	pushl  -0x8(%ebp)
  80146b:	ff 75 10             	pushl  0x10(%ebp)
  80146e:	e8 15 00 00 00       	call   801488 <vcprintf>
	cprintf("\n");
  801473:	c7 04 24 f3 1e 80 00 	movl   $0x801ef3,(%esp)
  80147a:	e8 5a 00 00 00       	call   8014d9 <cprintf>
  80147f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801482:	cc                   	int3   
  801483:	eb fd                	jmp    801482 <_panic+0x4a>
  801485:	00 00                	add    %al,(%eax)
	...

00801488 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801491:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  801498:	00 00 00 
	b.cnt = 0;
  80149b:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8014a2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8014a5:	ff 75 0c             	pushl  0xc(%ebp)
  8014a8:	ff 75 08             	pushl  0x8(%ebp)
  8014ab:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014b1:	50                   	push   %eax
  8014b2:	68 f0 14 80 00       	push   $0x8014f0
  8014b7:	e8 70 01 00 00       	call   80162c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8014bc:	83 c4 08             	add    $0x8,%esp
  8014bf:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8014c5:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8014cb:	50                   	push   %eax
  8014cc:	e8 e2 ef ff ff       	call   8004b3 <sys_cputs>
  8014d1:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8014d7:	c9                   	leave  
  8014d8:	c3                   	ret    

008014d9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014df:	8d 45 0c             	lea    0xc(%ebp),%eax
  8014e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8014e5:	50                   	push   %eax
  8014e6:	ff 75 08             	pushl  0x8(%ebp)
  8014e9:	e8 9a ff ff ff       	call   801488 <vcprintf>
	va_end(ap);

	return cnt;
}
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	53                   	push   %ebx
  8014f4:	83 ec 04             	sub    $0x4,%esp
  8014f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8014fa:	8b 03                	mov    (%ebx),%eax
  8014fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801503:	40                   	inc    %eax
  801504:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801506:	3d ff 00 00 00       	cmp    $0xff,%eax
  80150b:	75 1a                	jne    801527 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80150d:	83 ec 08             	sub    $0x8,%esp
  801510:	68 ff 00 00 00       	push   $0xff
  801515:	8d 43 08             	lea    0x8(%ebx),%eax
  801518:	50                   	push   %eax
  801519:	e8 95 ef ff ff       	call   8004b3 <sys_cputs>
		b->idx = 0;
  80151e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801524:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801527:	ff 43 04             	incl   0x4(%ebx)
}
  80152a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    
	...

00801530 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	57                   	push   %edi
  801534:	56                   	push   %esi
  801535:	53                   	push   %ebx
  801536:	83 ec 1c             	sub    $0x1c,%esp
  801539:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80153c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80153f:	8b 45 08             	mov    0x8(%ebp),%eax
  801542:	8b 55 0c             	mov    0xc(%ebp),%edx
  801545:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801548:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80154b:	8b 55 10             	mov    0x10(%ebp),%edx
  80154e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801551:	89 d6                	mov    %edx,%esi
  801553:	bf 00 00 00 00       	mov    $0x0,%edi
  801558:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80155b:	72 04                	jb     801561 <printnum+0x31>
  80155d:	39 c2                	cmp    %eax,%edx
  80155f:	77 3f                	ja     8015a0 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801561:	83 ec 0c             	sub    $0xc,%esp
  801564:	ff 75 18             	pushl  0x18(%ebp)
  801567:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80156a:	50                   	push   %eax
  80156b:	52                   	push   %edx
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	57                   	push   %edi
  801570:	56                   	push   %esi
  801571:	ff 75 e4             	pushl  -0x1c(%ebp)
  801574:	ff 75 e0             	pushl  -0x20(%ebp)
  801577:	e8 c0 05 00 00       	call   801b3c <__udivdi3>
  80157c:	83 c4 18             	add    $0x18,%esp
  80157f:	52                   	push   %edx
  801580:	50                   	push   %eax
  801581:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801584:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801587:	e8 a4 ff ff ff       	call   801530 <printnum>
  80158c:	83 c4 20             	add    $0x20,%esp
  80158f:	eb 14                	jmp    8015a5 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	ff 75 e8             	pushl  -0x18(%ebp)
  801597:	ff 75 18             	pushl  0x18(%ebp)
  80159a:	ff 55 ec             	call   *-0x14(%ebp)
  80159d:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8015a0:	4b                   	dec    %ebx
  8015a1:	85 db                	test   %ebx,%ebx
  8015a3:	7f ec                	jg     801591 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8015a5:	83 ec 08             	sub    $0x8,%esp
  8015a8:	ff 75 e8             	pushl  -0x18(%ebp)
  8015ab:	83 ec 04             	sub    $0x4,%esp
  8015ae:	57                   	push   %edi
  8015af:	56                   	push   %esi
  8015b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8015b6:	e8 ad 06 00 00       	call   801c68 <__umoddi3>
  8015bb:	83 c4 14             	add    $0x14,%esp
  8015be:	0f be 80 2b 1f 80 00 	movsbl 0x801f2b(%eax),%eax
  8015c5:	50                   	push   %eax
  8015c6:	ff 55 ec             	call   *-0x14(%ebp)
  8015c9:	83 c4 10             	add    $0x10,%esp
}
  8015cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015cf:	5b                   	pop    %ebx
  8015d0:	5e                   	pop    %esi
  8015d1:	5f                   	pop    %edi
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    

008015d4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8015d9:	83 fa 01             	cmp    $0x1,%edx
  8015dc:	7e 0e                	jle    8015ec <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8015de:	8b 10                	mov    (%eax),%edx
  8015e0:	8d 42 08             	lea    0x8(%edx),%eax
  8015e3:	89 01                	mov    %eax,(%ecx)
  8015e5:	8b 02                	mov    (%edx),%eax
  8015e7:	8b 52 04             	mov    0x4(%edx),%edx
  8015ea:	eb 22                	jmp    80160e <getuint+0x3a>
	else if (lflag)
  8015ec:	85 d2                	test   %edx,%edx
  8015ee:	74 10                	je     801600 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8015f0:	8b 10                	mov    (%eax),%edx
  8015f2:	8d 42 04             	lea    0x4(%edx),%eax
  8015f5:	89 01                	mov    %eax,(%ecx)
  8015f7:	8b 02                	mov    (%edx),%eax
  8015f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015fe:	eb 0e                	jmp    80160e <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  801600:	8b 10                	mov    (%eax),%edx
  801602:	8d 42 04             	lea    0x4(%edx),%eax
  801605:	89 01                	mov    %eax,(%ecx)
  801607:	8b 02                	mov    (%edx),%eax
  801609:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    

00801610 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  801616:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  801619:	8b 11                	mov    (%ecx),%edx
  80161b:	3b 51 04             	cmp    0x4(%ecx),%edx
  80161e:	73 0a                	jae    80162a <sprintputch+0x1a>
		*b->buf++ = ch;
  801620:	8b 45 08             	mov    0x8(%ebp),%eax
  801623:	88 02                	mov    %al,(%edx)
  801625:	8d 42 01             	lea    0x1(%edx),%eax
  801628:	89 01                	mov    %eax,(%ecx)
}
  80162a:	c9                   	leave  
  80162b:	c3                   	ret    

0080162c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	57                   	push   %edi
  801630:	56                   	push   %esi
  801631:	53                   	push   %ebx
  801632:	83 ec 3c             	sub    $0x3c,%esp
  801635:	8b 75 08             	mov    0x8(%ebp),%esi
  801638:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80163b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80163e:	eb 1a                	jmp    80165a <vprintfmt+0x2e>
  801640:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  801643:	eb 15                	jmp    80165a <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801645:	84 c0                	test   %al,%al
  801647:	0f 84 15 03 00 00    	je     801962 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	57                   	push   %edi
  801651:	0f b6 c0             	movzbl %al,%eax
  801654:	50                   	push   %eax
  801655:	ff d6                	call   *%esi
  801657:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80165a:	8a 03                	mov    (%ebx),%al
  80165c:	43                   	inc    %ebx
  80165d:	3c 25                	cmp    $0x25,%al
  80165f:	75 e4                	jne    801645 <vprintfmt+0x19>
  801661:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801668:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80166f:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801676:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80167d:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  801681:	eb 0a                	jmp    80168d <vprintfmt+0x61>
  801683:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  80168a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  80168d:	8a 03                	mov    (%ebx),%al
  80168f:	0f b6 d0             	movzbl %al,%edx
  801692:	8d 4b 01             	lea    0x1(%ebx),%ecx
  801695:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  801698:	83 e8 23             	sub    $0x23,%eax
  80169b:	3c 55                	cmp    $0x55,%al
  80169d:	0f 87 9c 02 00 00    	ja     80193f <vprintfmt+0x313>
  8016a3:	0f b6 c0             	movzbl %al,%eax
  8016a6:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  8016ad:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8016b1:	eb d7                	jmp    80168a <vprintfmt+0x5e>
  8016b3:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8016b7:	eb d1                	jmp    80168a <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8016b9:	89 d9                	mov    %ebx,%ecx
  8016bb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8016c2:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8016c5:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8016c8:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8016cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8016cf:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8016d3:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8016d4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8016d7:	83 f8 09             	cmp    $0x9,%eax
  8016da:	77 21                	ja     8016fd <vprintfmt+0xd1>
  8016dc:	eb e4                	jmp    8016c2 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8016de:	8b 55 14             	mov    0x14(%ebp),%edx
  8016e1:	8d 42 04             	lea    0x4(%edx),%eax
  8016e4:	89 45 14             	mov    %eax,0x14(%ebp)
  8016e7:	8b 12                	mov    (%edx),%edx
  8016e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8016ec:	eb 12                	jmp    801700 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  8016ee:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8016f2:	79 96                	jns    80168a <vprintfmt+0x5e>
  8016f4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016fb:	eb 8d                	jmp    80168a <vprintfmt+0x5e>
  8016fd:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  801700:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801704:	79 84                	jns    80168a <vprintfmt+0x5e>
  801706:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801709:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80170c:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801713:	e9 72 ff ff ff       	jmp    80168a <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801718:	ff 45 d4             	incl   -0x2c(%ebp)
  80171b:	e9 6a ff ff ff       	jmp    80168a <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801720:	8b 55 14             	mov    0x14(%ebp),%edx
  801723:	8d 42 04             	lea    0x4(%edx),%eax
  801726:	89 45 14             	mov    %eax,0x14(%ebp)
  801729:	83 ec 08             	sub    $0x8,%esp
  80172c:	57                   	push   %edi
  80172d:	ff 32                	pushl  (%edx)
  80172f:	ff d6                	call   *%esi
			break;
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	e9 07 ff ff ff       	jmp    801640 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801739:	8b 55 14             	mov    0x14(%ebp),%edx
  80173c:	8d 42 04             	lea    0x4(%edx),%eax
  80173f:	89 45 14             	mov    %eax,0x14(%ebp)
  801742:	8b 02                	mov    (%edx),%eax
  801744:	85 c0                	test   %eax,%eax
  801746:	79 02                	jns    80174a <vprintfmt+0x11e>
  801748:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80174a:	83 f8 0f             	cmp    $0xf,%eax
  80174d:	7f 0b                	jg     80175a <vprintfmt+0x12e>
  80174f:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  801756:	85 d2                	test   %edx,%edx
  801758:	75 15                	jne    80176f <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80175a:	50                   	push   %eax
  80175b:	68 3c 1f 80 00       	push   $0x801f3c
  801760:	57                   	push   %edi
  801761:	56                   	push   %esi
  801762:	e8 6e 02 00 00       	call   8019d5 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	e9 d1 fe ff ff       	jmp    801640 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80176f:	52                   	push   %edx
  801770:	68 c1 1e 80 00       	push   $0x801ec1
  801775:	57                   	push   %edi
  801776:	56                   	push   %esi
  801777:	e8 59 02 00 00       	call   8019d5 <printfmt>
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	e9 bc fe ff ff       	jmp    801640 <vprintfmt+0x14>
  801784:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801787:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80178a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80178d:	8b 55 14             	mov    0x14(%ebp),%edx
  801790:	8d 42 04             	lea    0x4(%edx),%eax
  801793:	89 45 14             	mov    %eax,0x14(%ebp)
  801796:	8b 1a                	mov    (%edx),%ebx
  801798:	85 db                	test   %ebx,%ebx
  80179a:	75 05                	jne    8017a1 <vprintfmt+0x175>
  80179c:	bb 45 1f 80 00       	mov    $0x801f45,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8017a1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8017a5:	7e 66                	jle    80180d <vprintfmt+0x1e1>
  8017a7:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8017ab:	74 60                	je     80180d <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8017ad:	83 ec 08             	sub    $0x8,%esp
  8017b0:	51                   	push   %ecx
  8017b1:	53                   	push   %ebx
  8017b2:	e8 9b e9 ff ff       	call   800152 <strnlen>
  8017b7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8017ba:	29 c1                	sub    %eax,%ecx
  8017bc:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8017c6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8017c9:	eb 0f                	jmp    8017da <vprintfmt+0x1ae>
					putch(padc, putdat);
  8017cb:	83 ec 08             	sub    $0x8,%esp
  8017ce:	57                   	push   %edi
  8017cf:	ff 75 c4             	pushl  -0x3c(%ebp)
  8017d2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017d4:	ff 4d d8             	decl   -0x28(%ebp)
  8017d7:	83 c4 10             	add    $0x10,%esp
  8017da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017de:	7f eb                	jg     8017cb <vprintfmt+0x19f>
  8017e0:	eb 2b                	jmp    80180d <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017e2:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  8017e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017e9:	74 15                	je     801800 <vprintfmt+0x1d4>
  8017eb:	8d 42 e0             	lea    -0x20(%edx),%eax
  8017ee:	83 f8 5e             	cmp    $0x5e,%eax
  8017f1:	76 0d                	jbe    801800 <vprintfmt+0x1d4>
					putch('?', putdat);
  8017f3:	83 ec 08             	sub    $0x8,%esp
  8017f6:	57                   	push   %edi
  8017f7:	6a 3f                	push   $0x3f
  8017f9:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	eb 0a                	jmp    80180a <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  801800:	83 ec 08             	sub    $0x8,%esp
  801803:	57                   	push   %edi
  801804:	52                   	push   %edx
  801805:	ff d6                	call   *%esi
  801807:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80180a:	ff 4d d8             	decl   -0x28(%ebp)
  80180d:	8a 03                	mov    (%ebx),%al
  80180f:	43                   	inc    %ebx
  801810:	84 c0                	test   %al,%al
  801812:	74 1b                	je     80182f <vprintfmt+0x203>
  801814:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801818:	78 c8                	js     8017e2 <vprintfmt+0x1b6>
  80181a:	ff 4d dc             	decl   -0x24(%ebp)
  80181d:	79 c3                	jns    8017e2 <vprintfmt+0x1b6>
  80181f:	eb 0e                	jmp    80182f <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	57                   	push   %edi
  801825:	6a 20                	push   $0x20
  801827:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801829:	ff 4d d8             	decl   -0x28(%ebp)
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801833:	7f ec                	jg     801821 <vprintfmt+0x1f5>
  801835:	e9 06 fe ff ff       	jmp    801640 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80183a:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80183e:	7e 10                	jle    801850 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  801840:	8b 55 14             	mov    0x14(%ebp),%edx
  801843:	8d 42 08             	lea    0x8(%edx),%eax
  801846:	89 45 14             	mov    %eax,0x14(%ebp)
  801849:	8b 02                	mov    (%edx),%eax
  80184b:	8b 52 04             	mov    0x4(%edx),%edx
  80184e:	eb 20                	jmp    801870 <vprintfmt+0x244>
	else if (lflag)
  801850:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801854:	74 0e                	je     801864 <vprintfmt+0x238>
		return va_arg(*ap, long);
  801856:	8b 45 14             	mov    0x14(%ebp),%eax
  801859:	8d 50 04             	lea    0x4(%eax),%edx
  80185c:	89 55 14             	mov    %edx,0x14(%ebp)
  80185f:	8b 00                	mov    (%eax),%eax
  801861:	99                   	cltd   
  801862:	eb 0c                	jmp    801870 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  801864:	8b 45 14             	mov    0x14(%ebp),%eax
  801867:	8d 50 04             	lea    0x4(%eax),%edx
  80186a:	89 55 14             	mov    %edx,0x14(%ebp)
  80186d:	8b 00                	mov    (%eax),%eax
  80186f:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801870:	89 d1                	mov    %edx,%ecx
  801872:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  801874:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801877:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80187a:	85 c9                	test   %ecx,%ecx
  80187c:	78 0a                	js     801888 <vprintfmt+0x25c>
  80187e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801883:	e9 89 00 00 00       	jmp    801911 <vprintfmt+0x2e5>
				putch('-', putdat);
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	57                   	push   %edi
  80188c:	6a 2d                	push   $0x2d
  80188e:	ff d6                	call   *%esi
				num = -(long long) num;
  801890:	8b 55 c8             	mov    -0x38(%ebp),%edx
  801893:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801896:	f7 da                	neg    %edx
  801898:	83 d1 00             	adc    $0x0,%ecx
  80189b:	f7 d9                	neg    %ecx
  80189d:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	eb 6a                	jmp    801911 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8018aa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8018ad:	e8 22 fd ff ff       	call   8015d4 <getuint>
  8018b2:	89 d1                	mov    %edx,%ecx
  8018b4:	89 c2                	mov    %eax,%edx
  8018b6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8018bb:	eb 54                	jmp    801911 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8018c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8018c3:	e8 0c fd ff ff       	call   8015d4 <getuint>
  8018c8:	89 d1                	mov    %edx,%ecx
  8018ca:	89 c2                	mov    %eax,%edx
  8018cc:	bb 08 00 00 00       	mov    $0x8,%ebx
  8018d1:	eb 3e                	jmp    801911 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8018d3:	83 ec 08             	sub    $0x8,%esp
  8018d6:	57                   	push   %edi
  8018d7:	6a 30                	push   $0x30
  8018d9:	ff d6                	call   *%esi
			putch('x', putdat);
  8018db:	83 c4 08             	add    $0x8,%esp
  8018de:	57                   	push   %edi
  8018df:	6a 78                	push   $0x78
  8018e1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8018e3:	8b 55 14             	mov    0x14(%ebp),%edx
  8018e6:	8d 42 04             	lea    0x4(%edx),%eax
  8018e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8018ec:	8b 12                	mov    (%edx),%edx
  8018ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018f3:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	eb 14                	jmp    801911 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018fd:	8d 45 14             	lea    0x14(%ebp),%eax
  801900:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801903:	e8 cc fc ff ff       	call   8015d4 <getuint>
  801908:	89 d1                	mov    %edx,%ecx
  80190a:	89 c2                	mov    %eax,%edx
  80190c:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801911:	83 ec 0c             	sub    $0xc,%esp
  801914:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  801918:	50                   	push   %eax
  801919:	ff 75 d8             	pushl  -0x28(%ebp)
  80191c:	53                   	push   %ebx
  80191d:	51                   	push   %ecx
  80191e:	52                   	push   %edx
  80191f:	89 fa                	mov    %edi,%edx
  801921:	89 f0                	mov    %esi,%eax
  801923:	e8 08 fc ff ff       	call   801530 <printnum>
			break;
  801928:	83 c4 20             	add    $0x20,%esp
  80192b:	e9 10 fd ff ff       	jmp    801640 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801930:	83 ec 08             	sub    $0x8,%esp
  801933:	57                   	push   %edi
  801934:	52                   	push   %edx
  801935:	ff d6                	call   *%esi
			break;
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	e9 01 fd ff ff       	jmp    801640 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80193f:	83 ec 08             	sub    $0x8,%esp
  801942:	57                   	push   %edi
  801943:	6a 25                	push   $0x25
  801945:	ff d6                	call   *%esi
  801947:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80194a:	83 ea 02             	sub    $0x2,%edx
  80194d:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  801950:	8a 02                	mov    (%edx),%al
  801952:	4a                   	dec    %edx
  801953:	3c 25                	cmp    $0x25,%al
  801955:	75 f9                	jne    801950 <vprintfmt+0x324>
  801957:	83 c2 02             	add    $0x2,%edx
  80195a:	89 55 ec             	mov    %edx,-0x14(%ebp)
  80195d:	e9 de fc ff ff       	jmp    801640 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  801962:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801965:	5b                   	pop    %ebx
  801966:	5e                   	pop    %esi
  801967:	5f                   	pop    %edi
  801968:	c9                   	leave  
  801969:	c3                   	ret    

0080196a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	83 ec 18             	sub    $0x18,%esp
  801970:	8b 55 08             	mov    0x8(%ebp),%edx
  801973:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801976:	85 d2                	test   %edx,%edx
  801978:	74 37                	je     8019b1 <vsnprintf+0x47>
  80197a:	85 c0                	test   %eax,%eax
  80197c:	7e 33                	jle    8019b1 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80197e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801985:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801989:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80198c:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80198f:	ff 75 14             	pushl  0x14(%ebp)
  801992:	ff 75 10             	pushl  0x10(%ebp)
  801995:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801998:	50                   	push   %eax
  801999:	68 10 16 80 00       	push   $0x801610
  80199e:	e8 89 fc ff ff       	call   80162c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	eb 05                	jmp    8019b6 <vsnprintf+0x4c>
  8019b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019be:	8d 45 14             	lea    0x14(%ebp),%eax
  8019c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8019c4:	50                   	push   %eax
  8019c5:	ff 75 10             	pushl  0x10(%ebp)
  8019c8:	ff 75 0c             	pushl  0xc(%ebp)
  8019cb:	ff 75 08             	pushl  0x8(%ebp)
  8019ce:	e8 97 ff ff ff       	call   80196a <vsnprintf>
	va_end(ap);

	return rc;
}
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    

008019d5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8019db:	8d 45 14             	lea    0x14(%ebp),%eax
  8019de:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8019e1:	50                   	push   %eax
  8019e2:	ff 75 10             	pushl  0x10(%ebp)
  8019e5:	ff 75 0c             	pushl  0xc(%ebp)
  8019e8:	ff 75 08             	pushl  0x8(%ebp)
  8019eb:	e8 3c fc ff ff       	call   80162c <vprintfmt>
	va_end(ap);
  8019f0:	83 c4 10             	add    $0x10,%esp
}
  8019f3:	c9                   	leave  
  8019f4:	c3                   	ret    
  8019f5:	00 00                	add    %al,(%eax)
	...

008019f8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	53                   	push   %ebx
  8019fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8019ff:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a04:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  801a0b:	89 c8                	mov    %ecx,%eax
  801a0d:	c1 e0 07             	shl    $0x7,%eax
  801a10:	29 d0                	sub    %edx,%eax
  801a12:	89 c2                	mov    %eax,%edx
  801a14:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  801a1a:	8b 40 50             	mov    0x50(%eax),%eax
  801a1d:	39 d8                	cmp    %ebx,%eax
  801a1f:	75 0b                	jne    801a2c <ipc_find_env+0x34>
			return envs[i].env_id;
  801a21:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  801a27:	8b 40 40             	mov    0x40(%eax),%eax
  801a2a:	eb 0e                	jmp    801a3a <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a2c:	41                   	inc    %ecx
  801a2d:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  801a33:	75 cf                	jne    801a04 <ipc_find_env+0xc>
  801a35:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801a3a:	5b                   	pop    %ebx
  801a3b:	c9                   	leave  
  801a3c:	c3                   	ret    

00801a3d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	57                   	push   %edi
  801a41:	56                   	push   %esi
  801a42:	53                   	push   %ebx
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a4c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801a4f:	85 db                	test   %ebx,%ebx
  801a51:	75 05                	jne    801a58 <ipc_send+0x1b>
  801a53:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801a58:	56                   	push   %esi
  801a59:	53                   	push   %ebx
  801a5a:	57                   	push   %edi
  801a5b:	ff 75 08             	pushl  0x8(%ebp)
  801a5e:	e8 b5 ea ff ff       	call   800518 <sys_ipc_try_send>
		if (r == 0) {		//success
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	85 c0                	test   %eax,%eax
  801a68:	74 20                	je     801a8a <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801a6a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a6d:	75 07                	jne    801a76 <ipc_send+0x39>
			sys_yield();
  801a6f:	e8 54 ec ff ff       	call   8006c8 <sys_yield>
  801a74:	eb e2                	jmp    801a58 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  801a76:	83 ec 04             	sub    $0x4,%esp
  801a79:	68 20 22 80 00       	push   $0x802220
  801a7e:	6a 41                	push   $0x41
  801a80:	68 44 22 80 00       	push   $0x802244
  801a85:	e8 ae f9 ff ff       	call   801438 <_panic>
		}
	}
}
  801a8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5f                   	pop    %edi
  801a90:	c9                   	leave  
  801a91:	c3                   	ret    

00801a92 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	56                   	push   %esi
  801a96:	53                   	push   %ebx
  801a97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9d:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	75 05                	jne    801aa9 <ipc_recv+0x17>
  801aa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	50                   	push   %eax
  801aad:	e8 25 ea ff ff       	call   8004d7 <sys_ipc_recv>
	if (r < 0) {				
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	79 16                	jns    801acf <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  801ab9:	85 db                	test   %ebx,%ebx
  801abb:	74 06                	je     801ac3 <ipc_recv+0x31>
  801abd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801ac3:	85 f6                	test   %esi,%esi
  801ac5:	74 2c                	je     801af3 <ipc_recv+0x61>
  801ac7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801acd:	eb 24                	jmp    801af3 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  801acf:	85 db                	test   %ebx,%ebx
  801ad1:	74 0a                	je     801add <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801ad3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad8:	8b 40 74             	mov    0x74(%eax),%eax
  801adb:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  801add:	85 f6                	test   %esi,%esi
  801adf:	74 0a                	je     801aeb <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801ae1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae6:	8b 40 78             	mov    0x78(%eax),%eax
  801ae9:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  801aeb:	a1 04 40 80 00       	mov    0x804004,%eax
  801af0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801af3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	c9                   	leave  
  801af9:	c3                   	ret    
	...

00801afc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b02:	89 d0                	mov    %edx,%eax
  801b04:	c1 e8 16             	shr    $0x16,%eax
  801b07:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b0e:	a8 01                	test   $0x1,%al
  801b10:	74 20                	je     801b32 <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b12:	89 d0                	mov    %edx,%eax
  801b14:	c1 e8 0c             	shr    $0xc,%eax
  801b17:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b1e:	a8 01                	test   $0x1,%al
  801b20:	74 10                	je     801b32 <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b22:	c1 e8 0c             	shr    $0xc,%eax
  801b25:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b2c:	ef 
  801b2d:	0f b7 c0             	movzwl %ax,%eax
  801b30:	eb 05                	jmp    801b37 <pageref+0x3b>
  801b32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b37:	c9                   	leave  
  801b38:	c3                   	ret    
  801b39:	00 00                	add    %al,(%eax)
	...

00801b3c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	57                   	push   %edi
  801b40:	56                   	push   %esi
  801b41:	83 ec 28             	sub    $0x28,%esp
  801b44:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801b4b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801b52:	8b 45 10             	mov    0x10(%ebp),%eax
  801b55:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801b58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801b5b:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801b5d:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b62:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  801b65:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b68:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b6b:	85 ff                	test   %edi,%edi
  801b6d:	75 21                	jne    801b90 <__udivdi3+0x54>
    {
      if (d0 > n1)
  801b6f:	39 d1                	cmp    %edx,%ecx
  801b71:	76 49                	jbe    801bbc <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801b73:	f7 f1                	div    %ecx
  801b75:	89 c1                	mov    %eax,%ecx
  801b77:	31 c0                	xor    %eax,%eax
  801b79:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801b7c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801b7f:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801b82:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b85:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b88:	83 c4 28             	add    $0x28,%esp
  801b8b:	5e                   	pop    %esi
  801b8c:	5f                   	pop    %edi
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    
  801b8f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801b90:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801b93:	0f 87 97 00 00 00    	ja     801c30 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801b99:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801b9c:	83 f0 1f             	xor    $0x1f,%eax
  801b9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ba2:	75 34                	jne    801bd8 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ba4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801ba7:	72 08                	jb     801bb1 <__udivdi3+0x75>
  801ba9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801bac:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801baf:	77 7f                	ja     801c30 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801bb1:	b9 01 00 00 00       	mov    $0x1,%ecx
  801bb6:	31 c0                	xor    %eax,%eax
  801bb8:	eb c2                	jmp    801b7c <__udivdi3+0x40>
  801bba:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	74 79                	je     801c3c <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801bc3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801bc6:	89 fa                	mov    %edi,%edx
  801bc8:	f7 f1                	div    %ecx
  801bca:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bcf:	f7 f1                	div    %ecx
  801bd1:	89 c1                	mov    %eax,%ecx
  801bd3:	89 f0                	mov    %esi,%eax
  801bd5:	eb a5                	jmp    801b7c <__udivdi3+0x40>
  801bd7:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801bd8:	b8 20 00 00 00       	mov    $0x20,%eax
  801bdd:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  801be0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801be3:	89 fa                	mov    %edi,%edx
  801be5:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801be8:	d3 e2                	shl    %cl,%edx
  801bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bed:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801bf0:	d3 e8                	shr    %cl,%eax
  801bf2:	89 d7                	mov    %edx,%edi
  801bf4:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801bf6:	8b 75 f4             	mov    -0xc(%ebp),%esi
  801bf9:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801bfc:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801bfe:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801c01:	d3 e0                	shl    %cl,%eax
  801c03:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801c06:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801c09:	d3 ea                	shr    %cl,%edx
  801c0b:	09 d0                	or     %edx,%eax
  801c0d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c10:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801c13:	d3 ea                	shr    %cl,%edx
  801c15:	f7 f7                	div    %edi
  801c17:	89 d7                	mov    %edx,%edi
  801c19:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801c1c:	f7 e6                	mul    %esi
  801c1e:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c20:	39 d7                	cmp    %edx,%edi
  801c22:	72 38                	jb     801c5c <__udivdi3+0x120>
  801c24:	74 27                	je     801c4d <__udivdi3+0x111>
  801c26:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801c29:	31 c0                	xor    %eax,%eax
  801c2b:	e9 4c ff ff ff       	jmp    801b7c <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c30:	31 c9                	xor    %ecx,%ecx
  801c32:	31 c0                	xor    %eax,%eax
  801c34:	e9 43 ff ff ff       	jmp    801b7c <__udivdi3+0x40>
  801c39:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c3c:	b8 01 00 00 00       	mov    $0x1,%eax
  801c41:	31 d2                	xor    %edx,%edx
  801c43:	f7 75 f4             	divl   -0xc(%ebp)
  801c46:	89 c1                	mov    %eax,%ecx
  801c48:	e9 76 ff ff ff       	jmp    801bc3 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c50:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801c53:	d3 e0                	shl    %cl,%eax
  801c55:	39 f0                	cmp    %esi,%eax
  801c57:	73 cd                	jae    801c26 <__udivdi3+0xea>
  801c59:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c5c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801c5f:	49                   	dec    %ecx
  801c60:	31 c0                	xor    %eax,%eax
  801c62:	e9 15 ff ff ff       	jmp    801b7c <__udivdi3+0x40>
	...

00801c68 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	57                   	push   %edi
  801c6c:	56                   	push   %esi
  801c6d:	83 ec 30             	sub    $0x30,%esp
  801c70:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801c77:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801c7e:	8b 75 08             	mov    0x8(%ebp),%esi
  801c81:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c84:	8b 45 10             	mov    0x10(%ebp),%eax
  801c87:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801c8a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c8d:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801c8f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  801c92:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  801c95:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c98:	85 d2                	test   %edx,%edx
  801c9a:	75 1c                	jne    801cb8 <__umoddi3+0x50>
    {
      if (d0 > n1)
  801c9c:	89 fa                	mov    %edi,%edx
  801c9e:	39 f8                	cmp    %edi,%eax
  801ca0:	0f 86 c2 00 00 00    	jbe    801d68 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ca6:	89 f0                	mov    %esi,%eax
  801ca8:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  801caa:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  801cad:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801cb4:	eb 12                	jmp    801cc8 <__umoddi3+0x60>
  801cb6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cb8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801cbb:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  801cbe:	76 18                	jbe    801cd8 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801cc0:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  801cc3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801cc6:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cc8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801ccb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801cce:	83 c4 30             	add    $0x30,%esp
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    
  801cd5:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cd8:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  801cdc:	83 f0 1f             	xor    $0x1f,%eax
  801cdf:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801ce2:	0f 84 ac 00 00 00    	je     801d94 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ce8:	b8 20 00 00 00       	mov    $0x20,%eax
  801ced:	2b 45 dc             	sub    -0x24(%ebp),%eax
  801cf0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801cf3:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801cf6:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801cf9:	d3 e2                	shl    %cl,%edx
  801cfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801cfe:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801d01:	d3 e8                	shr    %cl,%eax
  801d03:	89 d6                	mov    %edx,%esi
  801d05:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  801d07:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d0a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801d0d:	d3 e0                	shl    %cl,%eax
  801d0f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801d12:	8b 7d f4             	mov    -0xc(%ebp),%edi
  801d15:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d17:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d1a:	d3 e0                	shl    %cl,%eax
  801d1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d1f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801d22:	d3 ea                	shr    %cl,%edx
  801d24:	09 d0                	or     %edx,%eax
  801d26:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801d29:	d3 ea                	shr    %cl,%edx
  801d2b:	f7 f6                	div    %esi
  801d2d:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801d30:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d33:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  801d36:	0f 82 8d 00 00 00    	jb     801dc9 <__umoddi3+0x161>
  801d3c:	0f 84 91 00 00 00    	je     801dd3 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d42:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801d45:	29 c7                	sub    %eax,%edi
  801d47:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d49:	89 f2                	mov    %esi,%edx
  801d4b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801d4e:	d3 e2                	shl    %cl,%edx
  801d50:	89 f8                	mov    %edi,%eax
  801d52:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801d55:	d3 e8                	shr    %cl,%eax
  801d57:	09 c2                	or     %eax,%edx
  801d59:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  801d5c:	d3 ee                	shr    %cl,%esi
  801d5e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  801d61:	e9 62 ff ff ff       	jmp    801cc8 <__umoddi3+0x60>
  801d66:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d68:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	74 15                	je     801d84 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d72:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d75:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7a:	f7 f1                	div    %ecx
  801d7c:	e9 29 ff ff ff       	jmp    801caa <__umoddi3+0x42>
  801d81:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d84:	b8 01 00 00 00       	mov    $0x1,%eax
  801d89:	31 d2                	xor    %edx,%edx
  801d8b:	f7 75 ec             	divl   -0x14(%ebp)
  801d8e:	89 c1                	mov    %eax,%ecx
  801d90:	eb dd                	jmp    801d6f <__umoddi3+0x107>
  801d92:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d94:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d97:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  801d9a:	72 19                	jb     801db5 <__umoddi3+0x14d>
  801d9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d9f:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  801da2:	76 11                	jbe    801db5 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  801da4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801da7:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  801daa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801dad:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801db0:	e9 13 ff ff ff       	jmp    801cc8 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801db5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbb:	2b 45 ec             	sub    -0x14(%ebp),%eax
  801dbe:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  801dc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801dc4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801dc7:	eb db                	jmp    801da4 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801dc9:	2b 45 cc             	sub    -0x34(%ebp),%eax
  801dcc:	19 f2                	sbb    %esi,%edx
  801dce:	e9 6f ff ff ff       	jmp    801d42 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dd3:	39 c7                	cmp    %eax,%edi
  801dd5:	72 f2                	jb     801dc9 <__umoddi3+0x161>
  801dd7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dda:	e9 63 ff ff ff       	jmp    801d42 <__umoddi3+0xda>
