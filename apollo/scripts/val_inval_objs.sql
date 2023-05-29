col owner for a32;

prompt
prompt invalid_objects >>>

select owner,count(*) invalid_objects from dba_objects where status='INVALID' group by owner order by 1;

prompt
prompt valid_objects >>>

select owner,count(*) invalid_objects from dba_objects where status='VALID' group by owner order by 1;
