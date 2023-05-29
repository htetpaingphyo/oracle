col tablespace_name for a30;
col file_name for a60;
col autoextensible for a15;
set lines 235;

select 
	tablespace_name, 
	file_name, 
	round(bytes/1024/1024/1024, 2) "Size(GB)", 
	round(maxbytes/1024/1024/1024, 2) "MaxSize(GB)", 
	autoextensible 
from dba_data_files 
order by 1;
