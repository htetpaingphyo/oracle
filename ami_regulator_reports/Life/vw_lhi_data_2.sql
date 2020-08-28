create or replace view vw_lhi_detail (
    POLICY_NO, "NAME", RELATION, DECLARATION_FACTS, DISEASE_AND_INJURY, DETAIL, BASIC_UNITS, ADDITIONAL_UNITS, OPTION_1_UNITS, OPTION_2_UNITS, MARKETER_NAME, MARKETER_TYPE, SELLING, COMMISSION, 
    CONSTRAINT PK_LHI_DETAIL PRIMARY KEY (POLICY_NO) DISABLE NOVALIDATE
)
as
select
    distinct x.pol_policy_no "POLICY_NO", 
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'NAME OF FATHER') "NAME", 
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BENFICIARY RELATION') "RELATION", 
    '' AS "DECLARATION_FACTS",
    '' AS "DISEASE_AND_INJURY",
    '' AS "DETAIL", 
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'BASIS') "BASIC_UNITS", 
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'ADDITIONAL UNITS') "ADDITIONAL_UNITS", 
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'OPTION 1 UNITS') "OPTION_1_UNITS", 
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'OPTION 2 UNITS') "OPTION_2_UNITS", 
    (select distinct(account_handler_name) from pol_data where pol_policy_no = x.pol_policy_no) "MARKETER_NAME", 
    (select distinct case (pol_bss_bss_code) when 'DIRE' then 'DIRECT' else pol_bss_bss_code end "M_TYPE" from pol_data where pol_policy_no = x.pol_policy_no) "MARKETER_TYPE", 
    'Individual Selling' AS "SELLING", 
    (select commission_amt from pol_data where pol_policy_no = x.pol_policy_no) "COMMISSION" 
from pol_risk_info x 
where x.pol_prd_code='LHI';