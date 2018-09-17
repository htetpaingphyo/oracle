exec pk_stat_reports.pr_del_x_data;

exec pk_stat_reports.pr_pop_x_data_rc_date('01-JAN-2018', SYSDATE-1);

-- // TEST // --
create or replace view motor_perils_report as 
select 
    distinct x.pol_policy_no "POLICY_NO", 
    loc_province "STATE", 
    loc_district "DISTRICT", 
    loc_earthqk "TOWNSHIP",
    loc_cyclone "TOWN",    
    loc_postal_code "WARD",
    loc_description "LOCATION", 
    (select listagg(cus_name, ', ') within group (order by pol_policy_no)  
        from pol_data 
        where pol_policy_no=x.pol_policy_no 
        and pol_seq_no=x.pol_seq_no
    ) "CUS_NAME", 
    (select listagg(pol_transaction_type, ', ') within group (order by pol_policy_no) 
        from pol_data 
        where pol_policy_no=x.pol_policy_no 
        and pol_seq_no=x.pol_seq_no
    ) "POLICY_TYPE", 
    x.pol_period_from "PERIOD_FROM", 
    x.pol_period_to "PERIOD_TO", 
    x.pol_trans_effect_date "EFFECT_DATE", 
    x.prs_name "RISK_NAME",
    ( select ppr_sum_insured 
        from pol_risk_perils 
        where pol_seq_no=x.pol_seq_no 
        and prs_name=x.prs_name 
        and prl_description='SECTION I - LOSS OR DAMAGE'
    ) "SUM_INSURED", 
    ( select 
        distinct(info_value) 
        from pol_risk_info 
        where pol_seq_no=x.pol_seq_no 
        and prs_name=x.prs_name 
        and pin_description='WINDSCREEN SI'
    ) "WS_SI", 
    ( select 
        distinct(ppr_premium) 
        from pol_risk_perils 
        where pol_seq_no=x.pol_seq_no 
        and prs_name=x.prs_name 
        and prl_description='WAR RISK'
    ) "WAR_RISK", 
    ( select 
        distinct(ppr_premium) 
        from pol_risk_perils 
        where pol_seq_no=x.pol_seq_no 
        and prs_name=x.prs_name 
        and prl_description='ACTS OF GOD (NATURAL DISASTERS)'
    ) "AOG", 
    ( select 
        distinct(ppr_premium) 
        from pol_risk_perils 
        where pol_seq_no=x.pol_seq_no 
        and prs_name=x.prs_name 
        and prl_description='WINDSCREEN COVER'
    ) "WS_PREMIUM", 
    ( select 
        distinct(ppr_premium) 
        from pol_risk_perils 
        where pol_seq_no=x.pol_seq_no 
        and prs_name=x.prs_name 
        and prl_description='NIL EXCESS'
    ) "NIL_EXCESS", 
    ( select 
        distinct(ppr_premium) 
        from pol_risk_perils 
        where pol_seq_no=x.pol_seq_no 
        and prs_name=x.prs_name 
        and prl_description='THEFT'
    ) "THEFT",    
    ( select sum(ppr_premium) 
        from pol_risk_perils 
        where pol_policy_no=x.pol_policy_no 
        and prs_name=x.prs_name 
        group by prs_name 
    ) "RISK_PREMIUM", 
    ( select listagg(pol_transaction_amount, ', ') within group (order by pol_policy_no) 
        from pol_data 
        where pol_policy_no=x.pol_policy_no 
        and pol_seq_no=x.pol_seq_no) "NET_PREMIUM", 
    ( select listagg(pol_total_transaction_amount, ', ') within group (order by pol_policy_no)   
        from pol_data 
        where pol_policy_no=x.pol_policy_no 
        and pol_seq_no=x.pol_seq_no) "TOTAL_PREMIUM",
    ( select listagg(commission_amt, ', ') within group (order by pol_policy_no) 
        from pol_data 
        where pol_policy_no=x.pol_policy_no 
        and pol_seq_no=x.pol_seq_no) "COMMISSION" 
from pol_risk_perils x, pol_data_locations y 
where x.pol_policy_no=y.pol_policy_no 
and pol_prd_code in ('MCP', 'MCC', 'MFC', 'MFP', 'MCH') /*, 'FCS', 'FSD'*/ 
order by 1;