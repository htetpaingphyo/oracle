select 
    distinct x.pol_policy_no "CERTIFICATE_NO", cus_name "CUSTOMER",
    (select sum(prs_sum_insured) from uw_t_pol_risks where prs_nic_no <> ' ' and prs_policy_no = x.pol_policy_no) "SUM_INSURED", 
    pol_transaction_amount "PREMIUM", commission_amt "COMMISSION", x.agent_name "AGENT", 
    rc.receipt_no || ' (' || to_char(rc.settlement_date, 'DD-MON-YYYY') ||  ')'  "RECEIPT_VOU_NO", x.pol_transaction_type "REMARK", x.commission_amt
from pol_data x, pol_risk_info y, rc_data rc
where x.pol_policy_no = y.pol_policy_no
and x.pol_policy_no = rc.policy_no
and x.pol_prd_code = 'LST';
/* and x.pol_policy_no='AMI/YGN/LSB/17000001'; */