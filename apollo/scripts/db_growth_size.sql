set lines 300;

prompt
prompt check_db_growth_size.sql. Developed by htetpaing (htet.paing.phyo@panasiatower.net) >>>

select 
	round(sum(used.bytes)/1024/1024) || 'MB' "DatabaseSize",
	round(free.p/1024/1024) || 'MB' "FreeSpace"
from (
	(select bytes from v$datafile) 
	union all 
	(select bytes from v$tempfile) 
	union all 
	(select bytes from v$log)
     ) used, (select sum(bytes) as p from dba_free_space) free group by free.p;
