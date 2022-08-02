select 
    distinct x.pol_policy_no "POLICY_NO", cus_name "CUSTOMER", cus_name "BUSINESS_NAME",  
    cus_address "ADDRESS", 
    (select sum(prs_sum_insured) from uw_t_pol_risks where prs_nic_no <> ' ' and prs_policy_no = x.pol_policy_no) "SUM_INSURED",
    (select count(*) from uw_t_pol_risks where prs_nic_no <> ' ' and prs_policy_no = x.pol_policy_no) "INSURED_PERSON", 
    pol_transaction_amount "PREMIUM", /*pol_total_premium "TOTAL PREMIUM",*/ 
    commission_amt "COMMISSION", rc.receipt_no || ' (' || rc.settlement_date ||  ')'  "TR_CR", x.agent_name "AGENT"
from pol_data x, pol_risk_info y, rc_data rc
where x.pol_policy_no = y.pol_policy_no
and x.pol_policy_no = rc.policy_no
and x.pol_prd_code = 'LGL';
/* and x.pol_policy_no = 'AMI/LG/000105/0417/YGN'; */