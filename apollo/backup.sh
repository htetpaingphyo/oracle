ftpuser=dbback
ftppass=Operator@2020
ftpip=192.168.1.66
bkpdir=/backup/differentials

. /home/oracle/db12env

echo -e "start backing up..."
rman target / log=/backup/backup.log << EOS
run 
{
    allocate channel ch1 device type disk format '/backup/differentials/%d_INC1_%T.bkp';
    backup incremental level 1 database;
    release channel ch1;   	
}
EOS
echo -e "backup finished."

cd $bkpdir

#echo -e "clearing ITOWER_INC1_$(date +%Y%m%d).zip"
#rm -rf ITOWER_INC1_$(date +%Y%m%d).zip

echo -e "creating archive..."
tar -czvf ITOWER_INC1_$(date +%Y%m%d).tar.gz ITOWER_INC1_$(date +%Y%m%d).bkp

echo -e "attempting to send ITOWER_INC1_$(date +%Y%m%d).zip to 192.168.1.66"
ftp -in $ftpip << EOF
user $ftpuser $ftppass
binary
mput ITOWER_INC1_$(date +%Y%m%d).tar.gz
EOF
echo -e "moving archive completed!"

echo -e "cleaning archive file..."
rm -f ITOWER_INC1_$(date +%Y%m%d).tar.gz

echo -e "completed."
