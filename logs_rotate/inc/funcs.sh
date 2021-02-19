#!/bin/bash
###----------------------------------------------------------------------------
### Script Name:    funcs.sh
### Description:    Functions for main script
###----------------------------------------------------------------------------

### Function to send email
### Argument $1) Email Subject
### Argument $2) Email Body
function EmailIt() {
    #cat "$2"|$EmailCmd -s "$1" -r $EmailFrom $EmailTo
    cat "$2"|$EmailCmd -s "$1" $EmailTo
}

## Function to pass back current time
function GetNow() {
    echo $(date +"%F %H:%M:%S")
}


### Check if NFS Is mounted or not, if not mount it.
### Argument $1) NFS Server Export
### Argument $2) NFS Mount path
### Returns 2 if unable to mount, 1 if able to mount, 0 if already
### Mounted.
function MountIt() {
    if [ $(mount|grep "$1"|wc -l) -ne 1 ]
    then
        mount $1 $2
        if [ $? -ne 0 ]
        then
            return 2
        else
            return 1
        fi
    else
        return 0
    fi
}
