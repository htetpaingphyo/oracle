prompt
prompt check_row_size_by_owner.sql. Developed by htetpaing (htet.paing.phyo@panasiatower.net) >>>

declare
    v_count integer;
begin

    for r in (select table_name, owner from all_tables where owner = '&SCHEMA_NAME') 
    loop
        execute immediate 'select count(*) from ' || r.table_name into v_count;
        INSERT INTO STATS_TABLE(TABLE_NAME,SCHEMA_NAME,RECORD_COUNT,CREATED) VALUES (r.table_name,r.owner,v_count,SYSDATE);
    end loop;

end;
