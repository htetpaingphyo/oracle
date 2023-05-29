#!/usr/bin/sh

### Setup Oracle Home ###
. /home/oracle/db12env

### Variables ###
dbUser=itower
dbPass=itower
dbDir=BACKUP

ftpIp=192.168.1.38
ftpUser=dbback
ftpPass=iTower@123

### Cleaning ###
cd /backup
rm -vf *
echo -e "Cleaning all backup files completed."

### Starting backup ###
echo -e "Starting data pump export for itower..."
expdp $dbUser/$dbPass directory=$dbDir dumpfile=expdp_itower.dmp logfile=expdp_itower.log schemas=itower
echo -e "Data pump export completed."

### Archiving backup files ###
echo -e "Archiving backup files..."
tar -czvf itower_$(date +%Y%m%d).tar.gz expdp_itower.dmp expdp_itower.log
rm -vf expdp_itower.dmp expdp_itower.log
echo -e "Archiving completed."

### Moving to file server ###
echo -e "Moving to $ftpIp"
ftp -in $ftpIp << EOF
user $ftpUser $ftpPass
binary
mput itower_$(date +%Y%m%d).tar.gz
EOF
echo -e "Moving archive file completed."


