#!/bin/bash
###----------------------------------------------------------------------------
### Script Name:    vars.sh
### Description:    Variables for main script
###----------------------------------------------------------------------------

## Miscellaneous Variables
ScriptName=$(basename "$0" .sh)
SysName=$(hostname|cut -d. -f1)

### Number of days old to move archives
ArchDays=14

### Old files list
OldFileList=/tmp/${ScriptName}_oldfiles.txt
if [ -f $OldFileList ]
then
    rm $OldFileList
else
    touch $OldFileList
fi

## Actions Temp Log
RunLog=/tmp/${ScriptName}_run.log
if [ -f $RunLog ]
then
   rm $RunLog
fi

## Email Related
EmailCmd=/bin/mail
EmailTo="email@2.com"
EmailFrom="${ScriptName}@2.com"

## Archive Log path as defined by "olddir" in logrotate conf
LogPath=$1

## Archive Logs NFS and mount point
$NFS_Server = "NFS Server FQDN"
ArchNFS=$NFS_Server:$2
ArchNFSMount=/archivelogs
