run
{
    allocate channel ch2 device type disk format '/vol2/OraBackup/weekly_%d_%T_%u_%p';
    backup incremental level 1 cumulative database;
}

