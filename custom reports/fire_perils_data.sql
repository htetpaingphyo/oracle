exec pk_stat_reports.pr_del_x_data;

exec pk_stat_reports.pr_pop_x_data_rc_date('01-OCT-2017', '31-OCT-2017');

select * from fire_perils_report;

-- // TEST // --
create or replace view fire_perils_report as 
select 
    distinct x.pol_policy_no "POLICY_NO", 
    loc_province "STATE", 
    loc_district "DISTRICT",  
    loc_postal_code "TOWNSHIP",  
    loc_cyclone "VILLAGE_TRACK",  
    loc_earthqk "VILLAGE", 
    --loc_description "LOCATION", 
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
    ( select listagg(nvl(ppr_premium, 0), ', ') within group (order by pol_policy_no)
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='STORM, TYPHOON, HURRICANE, TEMPEST' 
    ) "VST", 
    ( select listagg(nvl(ppr_premium, 0), ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='WAR RISK' 
    ) "WAR", 
    ( select listagg(nvl(ppr_premium, 0), ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='AIRCRAFT DAMAGE' 
    ) "AD", 
    ( select listagg(nvl(ppr_premium, 0), ', ') within group (order by pol_policy_no)
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='NO CLAIM BONUS' ) "NCB", 
    ( select listagg(nvl(ppr_premium, 0), ', ') within group (order by pol_policy_no)
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='BASIC COVER' 
    ) "BC", 
    ( select listagg(nvl(ppr_premium, 0), ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='EXPLOSION' 
    ) "EXP", 
    ( select listagg(nvl(ppr_premium, 0), ', ') within group (order by pol_policy_no)
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='RIOT STRIKE AND MALICIOUS DAMAGE' 
    ) "RSM", 
    ( select listagg(nvl(ppr_premium, 0), ', ') within group (order by pol_policy_no)
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='EARTH-QUAKE FIRE, FIRE AND SHOCK DMG CAUSED BY EQ' 
    ) "EQ", 
    ( select listagg(nvl(ppr_premium, 0), ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='IMPACT DAMAGE' 
    ) "ID", 
    ( select listagg(nvl(ppr_premium, 0), ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='SPONTANEOUS COMBUSTION' 
    ) "SP", 
    ( select listagg(nvl(ppr_premium, 0), ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='FLOOD AND INUNDATION' 
    ) "FLOOD", 
    ( select listagg(nvl(ppr_premium, 0), ', ') within group (order by pol_policy_no)
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='BURGLARY' 
    ) "BUR", 
    ( select listagg(nvl(ppr_premium, 0), ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='SUBSIDENCE & LANDSLIDE' 
    ) "SL",  
    x.ppr_sum_insured "SUM_INSURED",  
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
    ( select listagg (info_value, ', ') within group (order by pol_policy_no) 
        from pol_risk_info 
        where pol_policy_no=x.pol_policy_no 
        and prs_name=x.prs_name 
        and pin_description='CLASS OF THE BUILDING' 
    ) "BUILDING CLASS", 
    ( select listagg (info_value, ', ') within group (order by pol_policy_no) 
        from pol_risk_info 
        where pol_policy_no=x.pol_policy_no 
        and prs_name=x.prs_name 
        and pin_description='OCCUPATION OF THE BUILDING' 
    ) "BUILDING OCCUPATION", 
    ( select listagg(commission_amt, ', ') within group (order by pol_policy_no) 
        from pol_data 
        where pol_policy_no=x.pol_policy_no 
        and pol_seq_no=x.pol_seq_no) "COMMISSION" 
from pol_risk_perils x, pol_data_locations y 
where x.pol_policy_no=y.pol_policy_no 
and pol_prd_code in ('FFI') /*, 'FCS', 'FSD'*/ 
order by 1;