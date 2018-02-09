select
    distinct x.pol_policy_no, x.pol_endorsement_no, x.prs_name, x.pol_seq_no,
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENFICIARY RELATION') "BENFICIARY RELATION",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENEFICIARY 2 AGE') "BENEFICIARY 2 AGE",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'VEHICLE NO') "VEHICLE NO",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENEFICIARY AGE') "BENEFICIARY AGE",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENEFICIARY SHARE %') "BENEFICIARY SHARE %",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENEFICIARY 2 ADDRESS') "BENEFICIARY 2 ADDRESS",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENEFICARY 2 NAME') "BENEFICARY 2 NAME",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENEFICIARY 2 NRC') "BENEFICIARY 2 NRC",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENEFICIARY NRC NO') "BENEFICIARY NRC NO",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'NO OF UNITS') "NO OF UNITS",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENEFICIARY 2 RELATION') "BENEFICIARY 2 RELATION",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENEFICIARY NAME') "BENEFICIARY NAME",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENEFICIARY ADDRESS') "BENEFICIARY ADDRESS",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENEFICIARY 2 SHARE %') "BENEFICIARY 2 SHARE %"
from pol_risk_info x where pol_prd_code='LST';