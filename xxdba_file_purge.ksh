#!/bin/ksh
#===========================================================================================================================
# Script        : xxdba_file_purge.ksh
# Author        : Vie303@gmail.com
# Written       : 2018.1023
# Purpose       : Purge old files that may no longer be relevant to recovery disk space.
#                 Files are purged based on RETENTION_DAYS
#
# ------------ Inputs           
#
# ------------ Output   
#
# ------------ PREREQ
#               xxdba_file_purge.cfg    : Configuration file containing relevant file details
#               -------------------------------------------------------------------------------------------------------------------------------
#               Module:ExecuteFlag:Server:Owner:Directory:File_Types:RetentionDays
#               -------------------------------------------------------------------------------------------------------------------------------
#               #PURGE:Y:dfw-oda-p11:oracle:/u01/app/oracle/diag/rdbms/*/*/trace:*.trc,*.trm,*.log:31   
#               #PURGE:Y:dfw-oda-p11:oracle:/u01/app/oracle/product/12.1.0.2/dbhome_1/log/*/*:*.log:31
#               #PURGE:Y:dfw-oda-p11:oracle:/u01/app/oracle/product/12.1.0.2/dbhome_1/*/log:*.trc,*.log:31
#               #PURGE:Y:dfw-oda-p11:oracle:/cloudfs/bin/gg_12.3/dirdat/*:*.*:2 
#               #PURGE:Y:dfw-oda-p11:grid:/u01/app/12.1.0.2/grid*/rdbms/audit:*.aud:31
#               
#               #PURGE:Y:dfw-oda-p12:oracle:/u01/app/oracle/diag/rdbms/*/*/trace:*.trc,*.trm,*.log:31
#               #PURGE:Y:dfw-oda-p12:oracle:/u01/app/oracle/product/12.1.0.2/dbhome_1/log/*/*:*.log:31
#               #PURGE:Y:dfw-oda-p12:oracle:/u01/app/oracle/product/12.1.0.2/dbhome_1/*/log:*.trc,*.log:31
#               #PURGE:Y:dfw-oda-p11:grid:/u01/app/12.1.0.2/grid*/rdbms/audit:*.aud:31
#
#               find  $PURGE_DIR -type f \( -name  "$PURGE_FILE" \)  -ctime +${DAYS}  -exec rm -f {} \;
#
# ------------ USAGE Example
#               xxdba_file_purge.ksh
#
#===========================================================================================================================
# Modification History                  Description
# -----------------------------         ------------------------------------------------------------------------------------
# 2018.1023   vie303@gmail.com          Initial Creation
# 2018.1030   vie303@gmail.com          Include RORATE LOG Logic
#===========================================================================================================================

# --------------------------------------------------------------------------------------------------------------------------
# Global Variable Setting
# Directories
# --------------------------------------------------------------------------------------------------------------------------
export DBA_HOME=/cloudfs/dba
export SQL_DIR=${DBA_HOME}/sql
export BIN_DIR=${DBA_HOME}/bin
export CFG_DIR=${DBA_HOME}/cfg
export TMP_DIR=${DBA_HOME}/tmp
export LOG_DIR=${DBA_HOME}/log
export DBA_SCRIPTS=${DBA_HOME}/scripts


#  DBA Home
export DBA_SQL=${DBA_HOME}/sql
export DBA_BIN=${DBA_HOME}/bin
export DBA_TMP=${DBA_HOME}/tmp
export DBA_LOG=${DBA_HOME}/log
export DBA_SCRIPTS=${DBA_HOME}/scripts

#  Toolbox Home
export TB_HOME=$DBA_HOME/xxdba_toolbox
export TB_BIN=$TB_HOME/bin
export TB_CFG=$TB_HOME/cfg
export TB_LOG=$TB_HOME/log
export TB_HTML=$TB_HOME/html
export TB_SQL=$TB_HOME/sql
export TB_TMP=$TB_HOME/tmp


TB_HOME=${DBA_HOME}/xxdba_toolbox
DBA_BU_DIR=${TB_HOME}/dba_backup
DBA_MON_DIR=${TB_HOME}/dba_monitor
DBA_ALERT_DIR=${TB_HOME}/dba_alert
DBA_SPLUNK_DIR=${TB_HOME}/dba_splunk
DBA_SUPPORT_DIR=${TB_HOME}/dba_support
DBA_SUPPORT_RESULT=${DBA_SUPPORT_DIR}/support_result
DBA_SUPPORT_SQL=${DBA_SUPPORT_DIR}/support_sql

BASE_DIR=${TB_HOME}
ENV_DIR=${TB_HOME}/env
PSAFE_DIR=${TB_HOME}/psafe
CONF_DIR=${TB_HOME}/cfg
HTML_DIR=${TB_HOME}/html
TB_BIN=${TB_HOME}/bin
SQL_DIR=${TB_HOME}/sql
# LOG_DIR=${TB_HOME}/log
MON_LOG_DIR=${DBA_MON_DIR}/log
BU_LOG_DIR=${DBA_BU_DIR}/log
ALERT_LOG_DIR=${DBA_ALERT_DIR}/log
SPLUNK_LOG_DIR=${DBA_SPLUNK_DIR}/log
RMAN_CMDFILE_DIR=${DBA_BU_DIR}/rman_cmdfile
TMP_DIR=${TB_HOME}/tmp

PURGE_CFG=${CFG_DIR}/xxdba_file_purge.cfg               # Purge Configuration File

# --------------------
# Variable Assignment
# --------------------
HOSTNAME=$(uname -n)
TIMESTAMP=$(date +"%Y%m%d_%H:%M")
YEAR_MM=$(date +"%Y_%m")
YEAR_MM_WEEK=$(date +"%Y_%m_%V")
USERNAME=$LOGNAME
PROGRAM=$(basename $0)
BASEPROGRAM=${PROGRAM%.ksh}
PROGRAM_LOG=$LOG_DIR/${PROGRAM}_${TIMESTAMP}.log
MAIL_BODY=$TB_LOG/${PROGRAM}_${TIMESTAMP}.mailbody
SQL_QUOTES=$TB_LOG/${PROGRAM}_${TIMESTAMP}.sqlquotes

alias TEE_PLOG='tee -a $PROGRAM_LOG'


# ------------------------------------
# Get Encryption Key for Password Safe:
# Setting environment for local OEMREP1

# where KEY is stored.
# ------------------------------------
. $DBA_HOME/setENV



#---------------------------------------BEGIN
# Usage
#--------------------------------------------
function usage {
echo "  FUNC($0) ...begin" | TEE_PLOG

 echo "\n  !!! Invalid $1 (( $2 )) !!!"                                         | TEE_PLOG
 echo "\n  Usage\t: ${PROGRAM} <CLIENT> <MODULE>"                               | TEE_PLOG
 echo "\n Exiting ..."                                                          | TEE_PLOG
 exit 1
echo "  FUNC($0) .....end" | TEE_PLOG
}



#-----------------------------------------END



#---------------------------------------BEGIN
# Function: PURGE
#--------------------------------------------
function purge_func {
echo "  FUNC($0) ...begin" | TEE_PLOG

for PURGE_DETAILS in `grep "^#PURGE:Y:${HOSTNAME}:${USERNAME}" $PURGE_CFG `
do

 export PURGE_DIR=`echo $PURGE_DETAILS | awk -F: '{print $5}' `
 export PURGE_FILES=`echo $PURGE_DETAILS | awk -F: '{print $6}' `
 export PURGE_DAYS=`echo $PURGE_DETAILS | awk -F: '{print $7}' `
 let    FILE_TYPES=`echo $PURGE_FILES | awk -F, '{print NF }' `
 echo "  PURGE_DETAILS  : $PURGE_DETAILS "              | TEE_PLOG
 echo "    PURGE_DIR    : $PURGE_DIR "                  | TEE_PLOG
 echo "    PURGE_FILES  : $PURGE_FILES "                | TEE_PLOG
 echo "    PURGE_DAYS   : $PURGE_DAYS "                 | TEE_PLOG
 echo "    FILE_TYPES   : $FILE_TYPES "                 | TEE_PLOG

 # -----------------------------------------------------------------------------------
 # Generate FIND and REMOVE command based on PURGE DETAILS
 # -----------------------------------------------------------------------------------
 case $FILE_TYPES in 
        1) FILE_FILTER="-name \"$PURGE_FILES\"" ;;
        2) FILE_FILTER1=`echo $PURGE_FILES | awk -F, '{print $1}'` ;
           FILE_FILTER2=`echo $PURGE_FILES | awk -F, '{print $2}'` ;
           FILE_FILTER="-name \"$FILE_FILTER1\" -o -name \"$FILE_FILTER2\" ";;
        3) FILE_FILTER1=`echo $PURGE_FILES | awk -F, '{print $1}'` ;
           FILE_FILTER2=`echo $PURGE_FILES | awk -F, '{print $2}'` ;
           FILE_FILTER3=`echo $PURGE_FILES | awk -F, '{print $3}'` ;
           FILE_FILTER="-name \"$FILE_FILTER1\" -o -name \"$FILE_FILTER2\" -o -name \"$FILE_FILTER3\"  ";;
        *) FILE_FILTER="-name \"*.*\"" ;;
 esac


 export FIND_PRINT=`echo "find ${PURGE_DIR} -type f \( $FILE_FILTER \) -ctime +${PURGE_DAYS} -print "`
 export FIND_REMOVE=`echo "find ${PURGE_DIR} -type f \( $FILE_FILTER \) -ctime +${PURGE_DAYS} -exec rm -f {} \; "`

 echo "   FIND_PRINT   : $FIND_PRINT "          | TEE_PLOG
 echo "   FIND_REMOVE  : $FIND_REMOVE "         | TEE_PLOG
 echo " ----------------------------------------------------------------------------------- " | TEE_PLOG
 echo " - REMOVING FILES  " | TEE_PLOG
 echo " ----------------------------------------------------------------------------------- " | TEE_PLOG

 # -----------------------------------------------------------------------------------
 # Executing FIND Command
 # -----------------------------------------------------------------------------------
 echo $FIND_PRINT | sh  | TEE_PLOG
 echo $FIND_REMOVE | sh  | TEE_PLOG
 echo " ----------------------------------------------------------------------------------- " | TEE_PLOG

done    

echo "  FUNC($0) .....end" | TEE_PLOG
}
#-----------------------------------------END

#---------------------------------------BEGIN
# Function: ROTATE_LOG
# File will be rotated weekly with WEEK number of 52 weeks
#--------------------------------------------
function rotate_func {
echo "  FUNC($0) ...begin" | TEE_PLOG

for ROTATE_DETAILS in `grep "^#ROTATE:Y:${HOSTNAME}:${USERNAME}" $PURGE_CFG `
do

 export ROTATE_DIR=`echo $ROTATE_DETAILS | awk -F: '{print $5}' `
 export ROTATE_FILE=`echo $ROTATE_DETAILS | awk -F: '{print $6}' `
 export NEW_FILE=${ROTATE_FILE}_${YEAR_MM_WEEK}
 export FULL_FILE=${ROTATE_DIR}/${ROTATE_FILE}
 export FULL_NEW_FILE=${ROTATE_DIR}/${NEW_FILE}

 echo "  ROTATE_DETAILS  : $ROTATE_DETAILS "            | TEE_PLOG
 echo "   ROTATE_DIR     : $ROTATE_DIR "                        | TEE_PLOG
 echo "   ROTATE_FILE    : $ROTATE_FILE "               | TEE_PLOG
 echo "   NEW_FILE       : $NEW_FILE "                  | TEE_PLOG
 echo "   ROTATING FILE  : $ROTATE_FILE to $NEW_FILE "   | TEE_PLOG
 echo "   FULL_FILE      : $FULL_FILE "                 | TEE_PLOG
 echo "   FULL_NEW_FILE  : $FULL_NEW_FILE "             | TEE_PLOG



 # -----------------------------------------------------------------------------------
 # Generate FIND and REMOVE command based on ROTATE DETAILS
 # -----------------------------------------------------------------------------------
 echo " ----------------------------------------------------------------------------------- " | TEE_PLOG
 echo " ----------------------------------------------------------------------------------- " | TEE_PLOG
 mv $FULL_FILE $FULL_NEW_FILE
 cat /dev/null >  $FULL_FILE 
 ls -al $FULL_FILE
 ls -al $FULL_NEW_FILE

done    

echo "  FUNC($0) .....end" | TEE_PLOG
}
#-----------------------------------------END



# --------------------------------------------------------------------------------
# Main Function: 
# --------------------------------------------------------------------------------
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ $0 MAIN Program BEGIN +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


if test $# -lt 1
then
        SEVERITY=5
        usage                                           #function call ********
        exit_func $SEVERITY "Usage Error"
fi


# -----------------------------------------------------------------------------------
# Process According to LOGNAME and HOSTNAME 
# and ONLY if FLAG=Y
# -----------------------------------------------------------------------------------
export MODULE=$1


echo " MODILE           : $USERNAME "                           | TEE_PLOG
echo " USERNAME         : $USERNAME "                           | TEE_PLOG
echo " HOSTHAME         : $HOSTNAME "                           | TEE_PLOG


case $MODULE in 
 PURGE|purge|Purge)     purge_func ;;
 ROTATE|rotate|Rotate)  rotate_func ;;
 *)                     purge_func;;
esac 

chmod -R 775  $PROGRAM_LOG

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ $PROGRAM @$DBNAME (($MODULE)) END "
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo "$PROGRAM done at $(date +"%Y%m%d_%H:%M") "

exit


CONFIGURATION File: xxdba_file_purge.cfg


# -----------------------------------------------------------------------------------------------------
# Purge Details called by xxdba_file_purge.ksh
# 
# -- FORMAT --
# Module:ExecuteFlag:Server:Owner:Directory:File_Types:RetentionDays
#               
# -----------------------------------------------------------------------------------------------------
#PURGE:Y:dfw-oda-p11:oracle:/u01/app/oracle/diag/rdbms/*/*/trace:*.trc,*.trm,*.log:31   
#PURGE:Y:dfw-oda-p11:oracle:/u01/app/oracle/product/12.1.0.2/dbhome_1/log/*/*:*.log:31
#PURGE:Y:dfw-oda-p11:oracle:/u01/app/oracle/product/12.1.0.2/dbhome_1/*/log:*.trc,*.log:31
#PURGE:Y:dfw-oda-p11:oracle:/u01/app/oracle/admin/oda01*/adump:*.aud:7
#PURGE:Y:dfw-oda-p11:oracle:/cloudfs/bin/gg_12.3/dirdat/*:*:1  
#PURGE:Y:dfw-oda-p11:grid:/u01/app/12.1.0.2/grid*/rdbms/audit:*.aud:7
#PURGE:Y:dfw-oda-p11:grid:/u01/app/12.1.0.2/grid/log/dfw-oda-p1*/client:g*.log:31
#               
#PURGE:Y:dfw-oda-p12:oracle:/u01/app/oracle/diag/rdbms/*/*/trace:*.trc,*.trm,*.log:31
#PURGE:Y:dfw-oda-p12:oracle:/u01/app/oracle/product/12.1.0.2/dbhome_1/log/*/*:*.log:31
#PURGE:Y:dfw-oda-p12:oracle:/u01/app/oracle/product/12.1.0.2/dbhome_1/*/log:*.trc,*.log:31
#PURGE:Y:dfw-oda-p12:grid:/u01/app/12.1.0.2/grid*/rdbms/audit:*.aud:7
#PURGE:Y:dfw-oda-p12:grid:/u01/app/12.1.0.2/grid/log/dfw-oda-p1*/client:g*.log:31
#PURGE:Y:dfw-oda-p12:oracle:/u01/app/oracle/admin/oda01*/adump:*.aud:7

# -----------------------------------------------------------------------------------------------------
# Log Rotate
# -----------------------------------------------------------------------------------------------------
#ROTATE:Y:dfw-oda-p11:oracle:/u01/app/oracle/diag/rdbms/oda01p2/oda01p21/trace:drcoda01p21.log
#ROTATE:Y:dfw-oda-p11:oracle:/u01/app/oracle/diag/rdbms/oda01p2/oda01p21/trace:alert_oda01p21.log

#ROTATE:Y:dfw-oda-p12:oracle:/u01/app/oracle/diag/rdbms/oda01p2/oda01p22/trace:drcoda01p22.log
#ROTATE:Y:dfw-oda-p12:oracle:/u01/app/oracle/diag/rdbms/oda01p2/oda01p22/trace:alert_oda01p22.log




CRONTAB oracle@DFW-PDA-P11

oracle@dfw-oda-p11[oda01p21]/cloudfs/dba/bin$> crontab -l
# ---------------------------------------------------------------------
# CRONTAB format
# ---------------------------------------------------------------------
# * * * * * *
# | | | | | | 
# | | | | | +-- Year              (range: 1900-3000)
# | | | | +---- Day of the Week   (range: 1-7, 1 standing for Monday)
# | | | +------ Month of the Year (range: 1-12)
# | | +-------- Day of the Month  (range: 1-31)
# | +---------- Hour              (range: 0-23)
# +------------ Minute            (range: 0-59)
# ---------------------------------------------------------------------
 
# Monitoring jobs
10 * * * * /home/oracle/bin/asm_space_check.sh +ASM1 80 90 > /dev/null 2>&1
*/2 * * * * /home/oracle/bin/link2stby.sh stby01p2 > /dev/null 2>&1
*/10 * * * * /home/oracle/bin/longSess_check.sh oda01p2 15 > /dev/null 2>&1
 
# ---------------------------------------------------------------------
# Purge old files, Rotate old files
# 2018.1026     vie303@gmail.com
# ---------------------------------------------------------------------
0 22 * * * /cloudfs/dba/bin/xxdba_file_purge.ksh PURGE > /dev/null 2>&1
0 0 1 * * /cloudfs/dba/bin/xxdba_file_purge.ksh ROTATE > /dev/null 2>&1
 
# Check Data Guard log gaps
# 2-59/5 * * * * /home/oracle/bin/loggapp.sh oda01p2 > /dev/null 2>&1
 
# Backup jobs
#0 1 * * 0 /home/oracle/bin/rman_backup.sh -s oda01p21 -l 0 > /dev/null 2>&1
 
0 23 * * 0   /home/oracle/bin/rman_backup.sh -s oda01p21 -l 0 > /dev/null 2>&1
0 22 * * 1-6 /home/oracle/bin/rman_backup.sh -s oda01p21 -l 1 > /dev/null 2>&1
# 15 */4 * * * /home/oracle/bin/rman_backup.sh -s oda01p21 -l a > /dev/null 2>&1
15 3,6,12,18,22 * * * /home/oracle/bin/rman_backup.sh -s oda01p21 -l a > /dev/null 2>&1
 
# TCF speicific queries
0 0 * * * /home/oracle/d3/d3_tb_stats.sh > /dev/null 2>&1
#30 09 * * * /home/oracle/d3/idasusername.sh > /dev/null 2>&1
#00 09 * * * /home/oracle/d3/dupEbills.sh > /dev/null 2>&1
#09 00 * * * /home/oracle/d3/dcr-311a.sh > /dev/null oda01p21 2>&1


CRONTAB oracle@DFW-PDA-P12

oracle@dfw-oda-p12[oda01p22]/cloudfs/dba/bin$> crontab -l
# ---------------------------------------------------------------------
# CRONTAB format
# ---------------------------------------------------------------------
# * * * * * *
# | | | | | |
# | | | | | +-- Year              (range: 1900-3000)
# | | | | +---- Day of the Week   (range: 1-7, 1 standing for Monday)
# | | | +------ Month of the Year (range: 1-12)
# | | +-------- Day of the Month  (range: 1-31)
# | +---------- Hour              (range: 0-23)
# +------------ Minute            (range: 0-59)
# ---------------------------------------------------------------------
 
# Monitoring jobs
#10 * * * * /home/oracle/bin/asm_space_check.sh +ASM2 80 90 > /dev/null 2>&1
#*/2 * * * * /home/oracle/bin/link2stby.sh stby01p2 > /dev/null 2>&1
#*/10 * * * * /home/oracle/bin/longSess_check.sh oda01p2 15 > /dev/null 2>&1
 
# ---------------------------------------------------------------------
# Purge old files
# 2018.1026     vie303@gmail.com
# ---------------------------------------------------------------------
5 22 * * * /cloudfs/dba/bin/xxdba_file_purge.ksh PURGE > /dev/null 2>&1
0 0 1 * * /cloudfs/dba/bin/xxdba_file_purge.ksh ROTATE > /dev/null 2>&1
 
 
# Check Data Guard log gaps
#2-59/5 * * * * /home/oracle/bin/loggapp.sh oda01p2 > /dev/null 2>&1
 
# Backup jobs
#0 1 * * 0 /home/oracle/bin/rman_backup.sh -s oda01p22 -l 0 > /dev/null 2>&1
#0 1 * * 1-6 /home/oracle/bin/rman_backup.sh -s oda01p22 -l 1 > /dev/null 2>&1
#15 */8 * * * /home/oracle/bin/rman_backup.sh -s oda01p22 -l a > /dev/null 2>&1
 
# TCF specific queries
#30 09 * * * /home/oracle/d3/idasusername.sh > /dev/null 2>&1
#00 09 * * * /home/oracle/d3/dupEbills.sh > /dev/null 2>&1
 
# Below Disabled as no longer needed, per TCF. See RFC for DCR-332.  -sfranks
#51 18 * * * /home/oracle/d3/dsaas-559.sh > /dev/null 2>&1
 
 
CRONTAB grid@DFW-PDA-P11

# ---------------------------------------------------------------------
# Purge old files
# 2018.1026     vie303@gmail.com
# ---------------------------------------------------------------------
10 22 * * * /cloudfs/dba/bin/xxdba_file_purge.ksh PURGE > /dev/null 2>&1
 
CRONTAB grid@DFW-PDA-P12

# ---------------------------------------------------------------------
# Purge old files
# 2018.1026     vie303@gmail.com
# ---------------------------------------------------------------------
5 22 * * * /cloudfs/dba/bin/xxdba_file_purge.ksh PURGE > /dev/null 2>&1

