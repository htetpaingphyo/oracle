run
{
    allocate channel ch1 device type disk format '/vol2/backup/full_sicl_%d_%T_%u_%p';
    backup incremental level 0 database;
}
