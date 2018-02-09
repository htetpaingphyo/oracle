run
{
    allocate channel ch1 device type disk format '/vol2/OraBackup/daily_%d_%T_%u_%p';
    backup incremental level 1 database;
}
