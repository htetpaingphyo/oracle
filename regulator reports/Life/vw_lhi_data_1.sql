create or replace view vw_lhi_data 
(
    POLICY_NO, POLICY_DATE, POLICY_HOLDER, DN_NO, DN_DATE, RC_NO, RC_DATE, GENDER, DOB, AGE, NIC, OCCUPATION, ADDRESS, PAYMENT, PREMIUM, TRANS_TYPE, 
    CONSTRAINT PK_LHI_DATA_POLICY PRIMARY KEY (POLICY_NO) DISABLE NOVALIDATE
)
as
select
    distinct x.pol_policy_no "POLICY_NO", 
    to_char(x.pol_period_from, 'DD-MON-YYYY')||' to '||to_char(x.pol_period_to, 'DD-MON-YYYY') "POLICY_DATE", 
    x.prs_name "POLICY_HOLDER", 
    y."DEBit_NOTE_NO" "DN_NO", y.DEBIT_NOTE_DATE "DN_DATE", y.receipt_no "RC_NO", y.settlement_date "RC_DATE",     
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'GENDER') "GENDER", 
    --(select listagg(to_char(date_of_birth, 'DD-MON-YYYY'), ', ') within group (order by pol_policy_no)  from pol_risks where pol_prd_code='LHI' and pol_policy_no = x.pol_policy_no) "DOB",
    to_char(date_of_birth, 'DD-MON-YYYY') "DOB", 
    --(select listagg(floor(months_between(sysdate, date_of_birth)/12), ', ') within group (order by pol_policy_no) from pol_risks where pol_prd_code='LHI' and pol_policy_no = x.pol_policy_no) "AGE",
    floor(months_between(sysdate, date_of_birth)/12) "AGE", 
    --(select listagg(nic_no, ', ') within group (order by pol_policy_no) from pol_risks where pol_prd_code='LHI' and pol_policy_no = x.pol_policy_no) "NIC",
    nic_no "NIC",  
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'OCCUPATION') "OCCUPATION", 
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENEFICIARY ADDRESS') "ADDRESS",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BASIS') "PAYMENT", 
    (select sum(ppr_premium) from pol_risk_perils where pol_policy_no = x.pol_policy_no) "PREMIUM", 
    (select distinct(pol_transaction_type) from pol_data where pol_policy_no=x.pol_policy_no) "TRANS_TYPE"
from pol_risks x, rc_data y
where x.pol_policy_no=y.policy_no 
and x.pol_prd_code='LHI' 
and to_char(x.pol_trans_effect_date, 'MON') = to_char(y.settlement_date, 'MON');
/*where pol_policy_no='AMI/YGN/LHI/17000007';*/