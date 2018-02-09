select
    distinct x.pol_policy_no, y.pol_transaction_type, x.pol_endorsement_no, x.prs_name, x.pol_seq_no,
    y.cus_name, y.cus_address, y.pol_sum_insured, y.pol_total_premium, y.pol_bss_bss_code, y.pol_marketing_executive_code, 
    y.agent_name, y.account_handler_name, y.fin_interest, x.pol_period_from, x.pol_period_to,
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'VEHICLE NO') "VEHICLE NO",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'NO OF UNITS') "NO OF UNITS",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'NO OF PASSENGERS') "NO OF PASSENGERS", 
    rc.receipt_no, rc.SETTLEMENT_DATE
from pol_risk_info x, pol_data y, pol_risk_perils z, rc_data rc
where x.pol_policy_no = y.pol_policy_no
and x.pol_policy_no = z.pol_policy_no
and x.pol_policy_no = rc.policy_no
and x.pol_prd_code = 'LEX';