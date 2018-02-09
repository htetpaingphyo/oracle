create or replace view vw_lhi_pol_info
as
select
    distinct x.pol_policy_no "POLICY_NO", x.prs_name "USERNAME", 
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENEFICIARY NRC NO') "NRC", 
    to_char(x.pol_period_from, 'DD-MON-YYYY') "PERIOD_FROM", to_char(x.pol_period_to, 'DD-MON-YYYY') "PERIOD_TO",  
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BASIS') "TYPE",
    1 AS "BASIC",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'ADDITIONAL UNITS') "ADDITIONAL",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'OPTION 1 UNITS') "OPT1",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'OPTION 2 UNITS') "OPT2",
    (select distinct(ppr_premium) from pol_risk_perils where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and prl_description = 'BASIC COVER') "BASIC_COVER",
    (select distinct(ppr_premium) from pol_risk_perils where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and prl_description = 'DEATH DUE TO ACCIDENT') "ACCIDENT_DEATH",
    (select distinct(ppr_premium) from pol_risk_perils where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and prl_description = 'CANCER/MYOCARDIAL INFARCT/ STROKE') "CANCER",
    (select distinct(ppr_premium) from pol_risk_perils where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and prl_description = 'SURGICAL CASH') "SURGICAL",
    (select distinct(ppr_premium) from pol_risk_perils where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and prl_description = 'TOTAL PERMANENT DISABILITY') "DISABILITY",
    (select distinct(ppr_premium) from pol_risk_perils where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and prl_description = 'HOSPITAL CASH DUE TO DISEASE OR ACCIDENT') "DISEASE",
    (select distinct(ppr_premium) from pol_risk_perils where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and prl_description = 'MISCARRIAGE') "MISCARRIAGE",
    (select distinct(ppr_premium) from pol_risk_perils where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and prl_description = 'DEATH DUE TO DISEASE') "DISEASE_DEATH",
    (select sum(ppr_sum_insured) from pol_risk_perils where pol_policy_no = y.pol_policy_no group by pol_policy_no) "MAX_BENEFICIARY"
from pol_risk_info x, pol_risk_perils y
where x.pol_policy_no = y.pol_policy_no
and x.pol_prd_code = 'LHI'
order by x.pol_policy_no;