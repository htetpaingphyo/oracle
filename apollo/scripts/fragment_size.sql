set lines 200;
col owner for a32;
col table_name for a32;

prompt
prompt check_table_fragmentation_size.sql. Developed by htetpaing (htet.paing.phyo@panasiatower.net) >>>

select 
    ut.owner, 
    ut.table_name, 
    round(ut.num_rows*ut.avg_row_len/1024/1024,2) "CALC_SIZE_MB", 
    round(us.bytes/1024/1024,2) "ALLOC_SIZE_MB", 
    round(us.bytes/(ut.num_rows*ut.avg_row_len),2) "TIMES_LARGER" 
from 
    dba_tables ut, 
    dba_segments us 
where (ut.num_rows > 0 and ut.avg_row_len > 0 and us.bytes > 0) 
    and ut.partitioned='NO' 
    and ut.iot_type is null 
    and ut.iot_name is null 
    and ut.table_name=us.segment_name 
    and round(us.bytes/1024/1024, 2) > 1024 
    and round(us.bytes/1024/1024, 2) > (round(ut.num_rows*ut.avg_row_len/1024/1024,2)*2) 
order by 4 desc;

