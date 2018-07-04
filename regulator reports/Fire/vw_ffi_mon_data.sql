/** BEGIN-OF-QUERY **/
create or replace view vw_ffi_monthly
(
	POLICY, CUSTOMER, AGENT, ADDR, SI_BUILDING, RATING, PREMIUM, NCB, COMMISSION, NET_PRE, OCCUPATION, TYPE, IS_AUTH, BRANCH, 
	CONSTRAINT PK_FFI_MON_POLICY PRIMARY KEY(POLICY) DISABLE NOVALIDATE
)
as
select 
    distinct x.pol_policy_no "POLICY", cus_name "CUSTOMER", agent_name "AGENT", cus_address "ADDR", pol_sum_insured "SI_BUILDING",
    (   select  
        /*listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no)*/
        listagg(decode(prl_description, 'BASIC COVER', 'BC',
                            'STORM, TYPHOON, HURRICANE, TEMPEST', 'VST',
                            'WAR RISK', 'WAR',
                            'AIRCRAFT DAMAGE', 'AD',
                            'EXPLOSION', 'EXP',
                            'RIOT STRIKE AND MALICIOUS DAMAGE', 'RSM',
                            'EARTH-QUAKE FIRE, FIRE AND SHOCK DMG CAUSED BY EQ', 'EQ',
                            'IMPACT DAMAGE', 'ID',
                            'SPONTANEOUS COMBUSTION', 'SC',
                            'FLOOD AND INUNDATION', 'FL',
                            'BURGLARY', 'BUR',
                            'SL') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no)
        from pol_risk_perils where pol_policy_no=x.pol_policy_no 
        -- group by pol_policy_no
    ) "RATING",
    nvl(pol_transaction_amount, 0) "PREMIUM",
    (   select 
        listagg(ppr_premium, ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no and prl_description = 'NO CLAIM BONUS' 
        group by pol_policy_no
    ) "NCB", 
    nvl(commission_amt, 0) "COMMISSION", 
    (nvl(pol_transaction_amount, 0) - nvl(commission_amt, 0)) net_pre, 
    (   select 
        listagg(info_value, ', ') within group (order by pol_policy_no)  
        from pol_risk_info 
        where pol_policy_no = x.pol_policy_no and pin_description='OCCUPATION OF THE BUILDING' 
        group by pol_policy_no
    ) "OCCUPATION",
    pol_transaction_type "TYPE", 
    (   select decode(max(pol_authorized_date), null, 'N', max(pol_authorized_date), 'Y') 
        from uw_t_policies 
        where pol_policy_no=x.pol_policy_no group by pol_policy_no
    ) "IS_AUTH", 
    (   
        select distinct pol_created_branch from uw_t_policies where pol_policy_no=x.pol_policy_no
    ) "BRANCH"
from pol_data x  
where x.pol_prd_code in ('FFI','FSD','FCS') 
-- and x.pol_policy_no like '%YGN%' 
and x.pol_marketing_executive_code not in ('ATSO','FNI','GWI','GGIP','IKBZ','MYNIN','YIG') 
order by 1;
/** END-OF-QUERY **/