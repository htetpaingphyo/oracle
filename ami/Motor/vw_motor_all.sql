create or replace view sicl.vw_motor_data
as
select * from vw_mcp_data
union all
select * from vw_mcc_data
union all
select * from vw_mfc_data
union all
select * from vw_mfp_data 
union all
select * from vw_mch_data;