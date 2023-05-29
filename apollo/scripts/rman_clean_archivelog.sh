#!/bin/bash
# Date Created  : 06-10-2019
# Purpose       : Clean unnecessory archive log files.
# Creator       : HTET PAING
# Role		: Sr. DBA

. /home/oracle/db12env

rman target / log=/home/oracle/scripts/clean_archivelog.log @/home/oracle/scripts/clean_archivelog.sql
