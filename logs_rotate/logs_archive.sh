#!/bin/bash
###----------------------------------------------------------------------------
### Script Name:    logs_archive.sh
### Description:    Moves logs older than defined days to NFS Log Backup share
###                 Must pass in Archive log path and Archive NFS path
###----------------------------------------------------------------------------

if [ $# -ne 2 ]
then
   echo "Incorrect number of arguments:"
   echo "  Usage:"
   echo "     logs_archive.sh [Archive Logs] [Archive NFS]"
   exit 5
fi

## Include Functios and Variables include scripts
ScriptDir=/usr/local/scripts/systems/logs_rotate
source $ScriptDir/inc/vars.sh
source $ScriptDir/inc/funcs.sh

#####################################################
#------------------- MAIN SCRIPT -------------------#
#####################################################

## Validate that the archive log path exists, if not exits.
if [ ! -d $LogPath ]
then
    echo "$(GetNow): Log path is missing: $LogPath. Please investigate!!!">>$RunLog
    EmailIt "${SysName}: $ScriptName - FAILURE" $RunLog
    exit
else
    echo "$(GetNow): Log path EXISTS: $LogPath">>$RunLog
fi

## Run mount function for Archive Logs NFS Repository
MountIt $ArchNFS $ArchNFSMount
RetVal=$?
case $RetVal in
    0) echo "$(GetNow): Archive Logs NFS Mount $ArchNFS to $ArchNFSMount is already mounted">>$RunLog
       ;;
    1) echo "$(GetNow): Archive Logs NFS Mount $ArchNFS to $ArchNFSMount mounted successfully">>$RunLog
       ;;
    2) echo "$(GetNow): Archive Logs NFS Mount $ArchNFS to $ArchNFSMount mount failed. Please Investigate!!!">>$RunLog
       EmailIt "${SysName}: ARCHIVE LOG FILES - FAILED" $RunLog
       exit
       ;;
    *) echo "$(GetNow): Archive Logs NFS Mount $ArchNFS to $ArchNFSMount returned an unknown code. Please Investigate!!!">>$RunLog
       EmailIt "${SysName}: ARCHIVE LOG FILES - FAILED" $RunLog
       exit
       ;;
esac

### Moves rotated logs older than 14 days to NFS Log Backup share
### Path to archive log files to. Archive path is /logbackup/YYYY/MM
ArchNFSPath=$ArchNFSMount/$SysName/$(date +"%Y/%m")
if [ ! -d $ArchNFSPath ]
then
    echo "$(GetNow): Creating folder - $ArchNFSPath">>$RunLog
    mkdir -p $ArchNFSPath
fi

## Find logs older that $ArchDays days and move them
cd $LogPath
find $LogPath -mtime +$ArchDays -type f -exec echo "{}">>$OldFileList \;

NumFiles=$(cat $OldFileList|wc -l)
if [ $NumFiles -gt 0 ]
then
    echo "$(GetNow): Found $NumFiles log files to archive">>$RunLog
    for f in $(cat $OldFileList)
    do
        cp $f $ArchNFSPath
        if [ $? -ne 0 ]
        then
            echo "$(GetNow): Copy of $f to $ArchNFSPath FAILED. Please investigate!!!">>$RunLog
            EmailIt "${SysName}: $ScriptName - FAILURE" $RunLog
            exit 3
        else
            echo "$(GetNow): Copy of $f to $ArchNFSPath SUCCESS">>$RunLog
        fi
        rm $f
        if [ $? -ne 0 ]
        then
            echo "$(GetNow): Removal of $f FAILED. Please investigate!!!">>$RunLog
            EmailIt "${SysName}: $ScriptName - FAILURE" $RunLog
            exit 2
        else
            echo "$(GetNow): Removal of $f SUCCESS">>$RunLog
        fi
    done
    echo "$(GetNow): $NumFiles log files successfully archived to $ArchNFSPath">>$RunLog
    #EmailIt "${SysName}: $ScriptName - SUCCESS" $RunLog
else
    echo "$(GetNow): No log files found ready archive to $ArchNFSPath">>$RunLog
    #EmailIt "${SysName}: $ScriptName - SUCCESS" $RunLog
fi

### Cleanup temp log files
if [ -f $RunLog ]
then
   rm $RunLog
fi
if [ -f $OldFileList ]
then
   rm $OldFileList
fi
### Unmount archive mount if mounted
if [ $(mount|grep "$ArchNFS"|wc -l) -eq 1 ]
then
    umount $ArchNFS
fi
