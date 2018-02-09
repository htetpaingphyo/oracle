exec pk_stat_reports.pr_del_x_data;

exec pk_stat_reports.pr_pop_x_data_rc_date('01-NOV-2017', '30-NOV-2017');

-- // TEST // --
create or replace view fire_perils_report as select 
    distinct x.pol_policy_no "POLICY NO", loc_province "STAGE", loc_district "DISTRICT", loc_postal_code "TOWNSHIP", loc_cyclone "VILLAGE_TRACK", loc_earthqk "VILLAGE",
    (select listagg(cus_name, ', ') within group (order by pol_policy_no) 
        from pol_data 
        where pol_policy_no=x.pol_policy_no 
        and pol_seq_no=x.pol_seq_no) "NAME",
    (select listagg(pol_transaction_type, ', ') within group (order by pol_policy_no) 
        from pol_data 
        where pol_policy_no=x.pol_policy_no 
        and pol_seq_no=x.pol_seq_no) "POLICY TYPE", 
    ( select listagg(ppr_premium, ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='STORM, TYPHOON, HURRICANE, TEMPEST' ) "VST", 
    ( select ppr_premium from pol_risk_perils where pol_policy_no = x.pol_policy_no and pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and prl_description='WAR RISK' ) "WAR", 
    ( select ppr_premium from pol_risk_perils where pol_policy_no = x.pol_policy_no and pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and prl_description='AIRCRAFT DAMAGE' ) "AD", 
    ( select listagg(ppr_premium, ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='NO CLAIM BONUS' ) "NCB", 
    ( select sum(ppr_premium) from pol_risk_perils where pol_policy_no = x.pol_policy_no and pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and prl_description='BASIC COVER' ) "BC", 
    ( select ppr_premium from pol_risk_perils where pol_policy_no = x.pol_policy_no and pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and prl_description='EXPLOSION' ) "EXP", 
    ( select listagg(ppr_premium, ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='RIOT STRIKE AND MALICIOUS DAMAGE' ) "RSM",
    ( select listagg(ppr_premium, ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='EARTH-QUAKE FIRE, FIRE AND SHOCK DMG CAUSED BY EQ' ) "EQ",  
    ( select ppr_premium from pol_risk_perils where pol_policy_no = x.pol_policy_no and pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and prl_description='IMPACT DAMAGE' ) "ID",
    ( select ppr_premium from pol_risk_perils where pol_policy_no = x.pol_policy_no and pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and prl_description='SPONTANEOUS COMBUSTION' ) "SP",
    ( select ppr_premium from pol_risk_perils where pol_policy_no = x.pol_policy_no and pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and prl_description='FLOOD AND INUNDATION' ) "FLOOD",
    ( select listagg(ppr_premium, ', ') within group (order by ppr_premium) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no 
        and pol_seq_no = x.pol_seq_no 
        and prs_name = x.prs_name 
        and prl_description='BURGLARY' ) "BUR",
    ( select ppr_premium from pol_risk_perils where pol_policy_no = x.pol_policy_no and pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and prl_description='SUBSIDENCE & LANDSLIDE' ) "SL", 
    ( select listagg(pol_transaction_amount, ', ') within group (order by pol_policy_no) 
        from pol_data 
        where pol_policy_no=x.pol_policy_no 
        and pol_seq_no=x.pol_seq_no) "BASIC PREMIUM",
    ( select listagg(pol_total_transaction_amount, ', ') within group (order by pol_policy_no) 
        from pol_data 
        where pol_policy_no=x.pol_policy_no 
        and pol_seq_no=x.pol_seq_no) "TOTAL PREMIUM",
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
from pol_risk_perils x, pol_data_locations y where x.pol_policy_no=y.pol_policy_no and pol_prd_code in ('FFI', 'FCS', 'FSD');