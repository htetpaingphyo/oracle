col owner for a20;
col object_name for a45;

prompt
prompt check_invalid_objects.sql. Developed by htetpaing (htet.paing.phyo@panasiatower.net) >>>

select
	owner, object_type, object_name, status  
from dba_objects 
where status='INVALID' 
order by owner, object_type, object_name;
