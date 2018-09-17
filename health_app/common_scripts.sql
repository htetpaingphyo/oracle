-- CLEAR VIEW --
exec pk_stat_reports.pr_del_x_data;

exec pk_stat_reports.pr_pop_x_data_rc_date('01-FEB-2018', '28-FEB-2018');

-- exec pk_stat_reports.pr_pop_x_data('01-DEC-2017', to_char(SYSDATE, 'DD-MON-YYYY'));

-- exec pk_stat_reports.pr_pop_x_data('01-SEP-2017', '30-SEP-2017');

-- select * from uw_pol_data where wrapper_date between '02-JUN-2017' and '30-JUN-2017';    //No longer used!

select * from pol_risk_info where pol_prd_code='MCP';

select * from pol_common_info where pol_prd_code='MCP';

select * from pol_risk_perils where pol_prd_code='MCP';

select * from pol_risks where pol_prd_code='MCP';

select * from pol_data_locations where pol_prd_code='MCP';

select * from claims_data where int_claim_no like '%LHI%';

select * from vu_claims where clm_claim_no like '%LHI%'; 

select * from rc_data;

select * from pol_inv;

select * from pol_data where pol_prd_code='MCP';

select * from uw_x_policies;

select * from uw_t_policies;

select * from uw_t_endorsements; 

select * from uw_h_policy_history;

select * from uw_h_endorsement_history;

select * from cl_t_intimation;

select * from rc_t_debit_settle;

select * from rc_t_deb_settl_det;

select * from rc_t_debit_note;

select * from cust_info;

select * from py_m_payment;

select object_name, object_type, created, status from user_objects where object_type='VIEW' and object_name like 'VW%';