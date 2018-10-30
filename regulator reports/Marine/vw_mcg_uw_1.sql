create or replace view sicl.vw_mcg_uw1 
(
    POLICY, "DATE", NAME, CARGO, VESSEL_VEHICLE, VOYAGE, TRIP, SI, RATE, PREMIUM, TOTAL_PREMIUM, STAMP_FEE, REMARK, 
    CONSTRAINT PK_MCG_UW1_POLICY PRIMARY KEY (POLICY) DISABLE NOVALIDATE
)
as
select 
    distinct x.pol_policy_no "POLICY", 
    ( select max(settlement_date) from rc_data where policy_no=x.pol_policy_no) "DATE", 
    ( select distinct(cus_name) from pol_data where pol_policy_no=x.pol_policy_no) "NAME", 
    prs_name "CARGO", 
    ( select distinct(info_value) from pol_risk_info where pol_seq_no=x.pol_seq_no and pol_policy_no=x.pol_policy_no and prs_name=x.prs_name and pin_description='VESSEL NAME') || 
    ( select distinct(info_value) from pol_risk_info where pol_seq_no=x.pol_seq_no and pol_policy_no=x.pol_policy_no and prs_name=x.prs_name and pin_description='VEHICLE NO') "VESSEL_VEHICLE", 
    /*( select distinct(info_value) from pol_risk_info where pol_seq_no=x.pol_seq_no and pol_policy_no=x.pol_policy_no and prs_name=x.prs_name and pin_description='CARGO TYPE') "TYPE",*/
    ( select distinct(info_value) from pol_risk_info where pol_seq_no=x.pol_seq_no and pol_policy_no=x.pol_policy_no and prs_name=x.prs_name and pin_description='TYPE OF VOYAGE') "VOYAGE", 
    ( select distinct(info_value) from pol_common_info where pol_seq_no=x.pol_seq_no and pol_policy_no=x.pol_policy_no and pin_description in ('VOYAGE FROM','TRIP FROM')) || ' TO ' || 
    ( select distinct(info_value) from pol_common_info where pol_seq_no=x.pol_seq_no and pol_policy_no=x.pol_policy_no and pin_description in ('VOYAGE TO', 'TRIP TO')) "TRIP", 
    ( select pol_sum_insured from pol_data 
      where pol_policy_no=x.pol_policy_no
      and pol_trans_effect_date = (select max(pol_trans_effect_date) from pol_data where pol_policy_no=x.pol_policy_no)
    ) "SI", 
    ( select distinct(ppr_percentage) from pol_risk_perils where pol_policy_no=x.pol_policy_no and prl_description='BASIC COVER') "RATE", 
    ( select sum(pol_transaction_amount) from pol_data 
      where pol_policy_no=x.pol_policy_no
      group by pol_policy_no
      -- and pol_trans_effect_date = (select max(pol_trans_effect_date) from pol_data where pol_policy_no=x.pol_policy_no)
      /*
      *** Change instead of fetching pol_transaction_amount by max => pol_trans_effect_date to sum => pol_transaction_amount ***
      */
    ) "PREMIUM", 
    ( select (pol_transaction_amount + round((pol_sum_insured * 0.01 / 100), 2)) from pol_data 
      where pol_policy_no=x.pol_policy_no
      and pol_trans_effect_date = (select max(pol_trans_effect_date) from pol_data where pol_policy_no=x.pol_policy_no)
    ) "TOTAL_PREMIUM", 
    ( select round((pol_sum_insured * 0.01 / 100), 2) from pol_data 
      where pol_policy_no=x.pol_policy_no
      and pol_trans_effect_date = (select max(pol_trans_effect_date) from pol_data where pol_policy_no=x.pol_policy_no)
    ) "STAMP_FEE", 
    case x.pol_prd_code when 'MCG' then 'MARINE CARGO' else 'INLAND TRANSIT' end "REMARK" 
from pol_risk_info x
where pol_prd_code in ('MCG', 'MIT')
order by 1;