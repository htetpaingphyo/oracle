rman target / log=/backup/backup.log << EOS
run {
    backup database format '/backup/df_%U.bkp';
    backup current controlfile format '/backup/controlfile_%U.bkp';
}
EOS
