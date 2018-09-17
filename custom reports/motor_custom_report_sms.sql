exec pk_stat_reports.pr_del_x_data;

exec pk_stat_reports.pr_pop_x_data_rc_date('01-AUG-2017', '31-AUG-2017');

select 
    distinct x.pol_policy_no "POLICY NO.", x.pol_period_from "PERIOD FROM", x.pol_period_to "PERIOD TO",   
    (select distinct prs_name from pol_risk_perils where pol_seq_no=x.pol_seq_no and prs_name=x.prs_name) "VEHICLE NO",    
    (select distinct(info_value) from pol_risk_info where pol_seq_no=x.pol_seq_no and prs_name=x.prs_name and pin_description='MAKE') "MAKE", 
    (select distinct(info_value) from pol_risk_info where pol_seq_no=x.pol_seq_no and prs_name=x.prs_name and pin_description='TYPE OF BODY') "TYPE OF BODY", 
    (select distinct(info_value) from pol_risk_info where pol_seq_no=x.pol_seq_no and prs_name=x.prs_name and pin_description='MODEL') "MODEL", 
    (select ppr_sum_insured from pol_risk_perils where pol_seq_no=x.pol_seq_no and prs_name=x.prs_name and prl_description='SECTION I - LOSS OR DAMAGE') "SUM INSURED", 
    y.pol_transaction_amount "PREMIUM", y.pol_transaction_type "TRANSACTION TYPE",     
    decode(x.pol_prd_code, 
            'MCP', 'PRIVATE',
            'MCC', 'COMMERCIAL',
            'MFP', 'PRIVATE FLEET',
            'MFC', 'COMMERCIAL FLEET',
            'MCH', 'COMMERCIAL HYBRID'
        ) "PRODUCT TYPE"
from pol_risk_perils x, pol_data y
where x.pol_policy_no = y.pol_policy_no
and x.pol_prd_code in ('MCP','MCC','MFP','MFC','MCH');