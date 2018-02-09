create or replace view sicl.vw_mcg_rc
as
select 
    distinct pol_policy_no, 
    (select receipt_no /*listagg(receipt_no, ', ') within group (order by policy_no)*/ from rc_data 
        where policy_no = x.pol_policy_no
        and settlement_date=(select max(settlement_date) from rc_data where policy_no=x.pol_policy_no)
    ) "RECEIPT", 
    x.cus_name, x.pol_sum_insured, 
    (select sum(pol_transaction_amount) from pol_data 
        where pol_policy_no=x.pol_policy_no 
    ) "PREMIUM", 
    x.agent_name,
    case x.pol_prd_code when 'MCG' then 'MARINE CARGO' else 'INLAND TRANSIT' end "PRODUCT"
from pol_data x 
where x.pol_prd_code in ('MCG','MIT') 
and x.pol_policy_no like '%YGN%' 
order by 1;