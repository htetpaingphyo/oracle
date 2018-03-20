/** BEGIN-OF-QUERY **/
select 
    distinct x.pol_policy_no "POLICY", cus_name "CUSTOMER", agent_name "AGENT", cus_address "ADDR", pol_sum_insured "SI_BUILDING",
    (   select  
        listagg(regexp_replace(prl_description,'(^| )([^ ])([^ ])*','\2') || ':' || nvl(ppr_percentage, 0) || '%', ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_prd_code='FFI' and pol_policy_no=x.pol_policy_no 
        group by pol_policy_no
    ) "RATING",
    pol_transaction_amount "PREMIUM",
    (   select 
        listagg(ppr_premium, ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no and prl_description = 'NO CLAIM BONUS' 
        group by pol_policy_no
    ) "NCB", 
    commission_amt "COMMISSION", 
    (pol_transaction_amount - commission_amt) net_pre, 
    (   select 
        listagg(info_value, ', ') within group (order by pol_policy_no)  
        from pol_risk_info 
        where pol_policy_no = x.pol_policy_no and pin_description='OCCUPATION OF THE BUILDING' 
        group by pol_policy_no
    ) "OCCUPATION",
    pol_transaction_type "TYPE" 
from pol_risk_info x, pol_data y, pol_risk_perils z 
where x.pol_policy_no = y.pol_policy_no
and x.pol_policy_no = z.pol_policy_no
and x.pol_prd_code in ('FFI','FSD','FCS')
and x.pol_policy_no like '%YGN%'
order by 1;
/*and x.pol_policy_no='AMI/F-002651/0716/YGN';*/
/** END-OF-QUERY **/