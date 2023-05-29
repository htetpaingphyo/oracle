run
{
	allocate channel ch1 device type disk format '/backup/%d_%T_%p.bkp';
	backup incremental level 0 database;
	release channel ch1;
}
