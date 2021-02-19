#!/bin/bash
###----------------------------------------------------------------------------
### Script Name:    logs_rotate.sh
### Description:    This runs the logrotate and when finished will cycle
###                 through a list of archive log paths and run the 
###                 logs_archive.sh to move old log files to the Archive NFS
###                 path in the logs_paths.txt.
###----------------------------------------------------------------------------

ScriptDir=/usr/local/scripts/systems/logs_rotate
IncludePaths=$ScriptDir/inc/logs_paths.txt

## Run logrotate
/usr/sbin/logrotate /etc/logrotate.conf >/dev/null 2>&1
EXITVALUE=$?
if [ $EXITVALUE != 0 ]; then
    /usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"
fi

## Cycle through logs_paths.txt file and run logs_archive.sh on given paths.
for f in $(cat $IncludePaths)
do
    ArchiveLogs=$(echo "$f"|cut -d'|' -f1)
    ArchiveNFS=$(echo "$f"|cut -d'|' -f2)
    $ScriptDir/logs_archive.sh $ArchiveLogs $ArchiveNFS
done
