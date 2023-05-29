rman target / log=/home/oracle/scripts/restore.log << EOS
run {
    set newname for database to '/datafiles/oradata/%b';
    restore database;
    switch datafile all;
    recover database;
}
EOS

