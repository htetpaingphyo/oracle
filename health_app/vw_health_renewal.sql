EXEC PK_STAT_REPORTS.PR_DEL_X_DATA;

EXEC PK_STAT_REPORTS.PR_POP_X_DATA_LIFE_REN_NOTICE('01-SEP-2018', SYSDATE - 1);

select * from vw_health_renewal;

create or replace view vw_health_renewal
as
select 
    pol_policy_no policy_no, cus_indv_surname customer_name, prs_nic_no nic_no, to_char(pol_period_to, 'DD-MON-RRRR') policy_period, 
    pol_sum_insured sum_insured, pol_total_premium total_premium, basic payment_type 
from life_data order by pol_period_to asc;

