prompt
prompt check_invalid_indices.sql. Developed by htetpaing (htet.paing.phyo@panasiatower.net) >>>

select
	owner, index_name, index_type, table_owner, table_name 
from dba_indexes 
where status = 'INVALID';
