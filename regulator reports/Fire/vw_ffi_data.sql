/** BOQ **/
create or replace view vw_ffi_data
(
	POL_POLICY_NO, NAME, ADDR, BUILDING, MACHINERY, FURNITURE, STOCKS, FIRE, VST, WAR, AD, EXP, RSM, EQ, ID, SP, FLOOD, BUR, SL, PREMIUM, TR_CR, 
	CONSTRAINT PK_FFI_POLICY PRIMARY KEY (POL_POLICY_NO) DISABLE NOVALIDATE
)
as
select 
    distinct x.pol_policy_no, x.cus_name "NAME", x.cus_address "ADDR", 
    (select sum(nvl(declared_value,0)) from pol_inv where pol_policy_no = x.pol_policy_no and inventory_type='BUILDING') "BUILDING", 
    (select sum(nvl(declared_value,0)) from pol_inv where pol_policy_no = x.pol_policy_no and inventory_type='MACHINERY') "MACHINERY", 
    (select sum(nvl(declared_value,0)) from pol_inv where pol_policy_no = x.pol_policy_no and inventory_type='FURNITURE AND FITTINGS') "FURNITURE", 
    (select sum(nvl(declared_value,0)) from pol_inv where pol_policy_no = x.pol_policy_no and inventory_type='STOCKS') "STOCKS",
    (   select  
        /*listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no)*/
        listagg('BC:' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where prl_description='BASIC COVER' and pol_policy_no = x.pol_policy_no
    ) "FIRE", 
    (   select  
        /*listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no)*/
        listagg('VST:' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where prl_description='STORM, TYPHOON, HURRICANE, TEMPEST' and pol_policy_no = x.pol_policy_no
    ) "VST", 
    (   select  
        /*listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no)*/
        listagg('WAR:' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where prl_description='WAR RISK' and pol_policy_no = x.pol_policy_no
    ) "WAR", 
    (   select  
        /*listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no)*/
        listagg('AD:' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where prl_description='AIRCRAFT DAMAGE' and pol_policy_no = x.pol_policy_no
    ) "AD", 
    (   select  
        /*listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no)*/
        listagg('EXP:' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where prl_description='EXPLOSION' and pol_policy_no = x.pol_policy_no
    ) "EXP", 
    (   select  
        /*listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no)*/
        listagg('RSM:' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where prl_description='RIOT STRIKE AND MALICIOUS DAMAGE' and pol_policy_no = x.pol_policy_no
    ) "RSM", 
    (   select  
        /*listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no)*/
        listagg('EQ:' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where prl_description='EARTH-QUAKE FIRE, FIRE AND SHOCK DMG CAUSED BY EQ' and pol_policy_no = x.pol_policy_no
    ) "EQ", 
    (   select  
        /*listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no)*/
        listagg('ID:' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where prl_description='IMPACT DAMAGE' and pol_policy_no = x.pol_policy_no
    ) "ID", 
    (   select  
        /*listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no)*/
        listagg('SC:' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where prl_description='SPONTANEOUS COMBUSTION' and pol_policy_no = x.pol_policy_no
    ) "SP",  
    (   select  
        /*listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no)*/
        listagg('FL:' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where prl_description='FLOOD AND INUNDATION' and pol_policy_no = x.pol_policy_no
    ) "FLOOD",
    (   select  
        /*listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no)*/
        listagg('BUR:' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where prl_description='BURGLARY' and pol_policy_no = x.pol_policy_no
    ) "BUR",
    (   select  
        /*listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no)*/
        listagg('SL:' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where prl_description='SUBSIDENCE & LANDSLIDE' and pol_policy_no = x.pol_policy_no
    ) "SL",
    (select sum(nvl(pol_total_premium, 0)) from pol_data where pol_policy_no = x.pol_policy_no) "PREMIUM",
    (   select 
        /*listagg(receipt_no || ' : ' || settlement_date, ', ') within group (order by policy_no) "TR_CR_DATE"*/
        max("DEBit_NOTE_NO") 
        from rc_data 
        where policy_no = x.pol_policy_no 
    ) "TR_CR"
from pol_data x
where x.pol_prd_code in ('FFI','FSD','FCS') 
and x.pol_marketing_executive_code not in ('ATSO','FNI','GWI','GGIP','IKBZ','MYNIN','YIG')
order by x.pol_policy_no;
/** EOQ **/