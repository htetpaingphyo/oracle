#!/bin/bash
# Date Created  : 14-08-2017
# Purpose       : Export Dump Script
# Creator       : Sampath (Info-Ins)
# Modifier	: Htet Paing (AMI)
# Role          : DBA

ORACLE_HOME=/vol0/app/oracle/ oduct/12.1.0.2/db_1
export ORACLE_HOME
export PATH=$ORACLE_HOME/bin:$PATH
ORACLE_SID=SICL; export ORACLE_SID

expdp system/sysmgr DIRECTORY=datapump DUMPFILE=expdp_full_sicl_$(date +%Y%m%d)  LOGFILE=expdp_full_sicl_$(date +%Y%m%d).log FULL=Y

rm -f /vol2/backup/*

find expdp_full_sicl_* -mtime +1 -exec rm -f {} \;

chmod -R 775 /vol2/Backup/*
