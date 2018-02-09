run
{
    allocate channel ch3 device type disk format '/vol2/OraBackup/monthly_%d_%T_%u_%p';
    backup incremental level 0 database;
}
