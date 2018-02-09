/** BOQ **/
select 
    distinct x.pol_policy_no, x.cus_name "NAME", x.cus_address "ADDR", 
    (select sum(declared_value) from pol_inv where pol_policy_no = y.pol_policy_no and inventory_type='BUILDING' group by pol_policy_no) "BUILDING", 
    (select sum(declared_value) from pol_inv where pol_policy_no = y.pol_policy_no and inventory_type='MACHINERY' group by pol_policy_no) "MACHINERY", 
    (select sum(declared_value) from pol_inv where pol_policy_no = y.pol_policy_no and inventory_type='FURNITURE AND FITTINGS' group by pol_policy_no) "FURNITURE", 
    (select sum(declared_value) from pol_inv where pol_policy_no = y.pol_policy_no and inventory_type='STOCKS' group by pol_policy_no) "STOCKS",
    (   select  
        listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_prd_code='FFI' and prl_description='BASIC COVER' and pol_policy_no = x.pol_policy_no
        group by pol_policy_no
    ) "FIRE", 
    (   select  
        listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_prd_code='FFI' and prl_description='STORM, TYPHOON, HURRICANE, TEMPEST' and pol_policy_no = x.pol_policy_no
        group by pol_policy_no
    ) "VST", 
    (   select  
        listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_prd_code='FFI' and prl_description='WAR RISK' and pol_policy_no = x.pol_policy_no
        group by pol_policy_no
    ) "WAR", 
    (   select  
        listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_prd_code='FFI' and prl_description='AIRCRAFT DAMAGE' and pol_policy_no = x.pol_policy_no
        group by pol_policy_no
    ) "AD", 
    (   select  
        listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_prd_code='FFI' and prl_description='EXPLOSION' and pol_policy_no = x.pol_policy_no
        group by pol_policy_no
    ) "EXP", 
    (   select  
        listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_prd_code='FFI' and prl_description='RIOT STRIKE AND MALICIOUS DAMAGE' and pol_policy_no = x.pol_policy_no
        group by pol_policy_no
    ) "RSM", 
    (   select  
        listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_prd_code='FFI' and prl_description='EARTH-QUAKE FIRE, FIRE AND SHOCK DMG CAUSED BY EQ' and pol_policy_no = x.pol_policy_no
        group by pol_policy_no
    ) "EQ", 
    (   select  
        listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_prd_code='FFI' and prl_description='IMPACT DAMAGE' and pol_policy_no = x.pol_policy_no
        group by pol_policy_no
    ) "ID", 
    (   select  
        listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_prd_code='FFI' and prl_description='SPONTANEOUS COMBUSTION' and pol_policy_no = x.pol_policy_no
        group by pol_policy_no
    ) "SP",  
    (   select  
        listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_prd_code='FFI' and prl_description='FLOOD AND INUNDATION' and pol_policy_no = x.pol_policy_no
        group by pol_policy_no
    ) "FLOOD",
    (   select  
        listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_prd_code='FFI' and prl_description='BURGLARY' and pol_policy_no = x.pol_policy_no
        group by pol_policy_no
    ) "BUR",
    (   select  
        listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_prd_code='FFI' and prl_description='SUBSIDENCE & LANDSLIDE' and pol_policy_no = x.pol_policy_no
        group by pol_policy_no
    ) "SL",
    (select sum(pol_total_premium) from pol_data where pol_policy_no = y.pol_policy_no) "PREMIUM",
    (   select 
        listagg(receipt_no || ' : ' || settlement_date, ', ') within group (order by policy_no) "TR_CR_DATE"  
        from rc_data 
        where policy_no = x.pol_policy_no
        group by policy_no
    ) "TR_CR"
from pol_data x, pol_risk_perils y 
where x.pol_policy_no = y.pol_policy_no  
and y.pol_prd_code in ('FFI', 'FCS', 'FSD')
and x.pol_policy_no like '%MDY%';
/** EOQ **/