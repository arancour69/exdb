source: http://www.securityfocus.com/bid/8201/info

PHP is prone to an issue that may allow programs to bypass Safe Mode by calling external files in restricted directories using include() and require().

The problem is known to occur when the safe_mode_include_dir PHP directive is not defined. A logic error reportedly exists which could result in PHP failing to run a security check when attempting to access a file via an include() or require() call, potentially bypassing the Safe Mode model. This could allow unauthorized access or policy bypass in environments that use Safe Mode, such as in cases where a web server resource is shared by multiple users.

This issue is reported to exist in PHP versions 4.3.0 and later. 

<?
echo("trying to read /etc/passwd");
include("/etc/passwd");
?> 