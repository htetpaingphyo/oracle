create or replace view sicl.vw_mcg_uw2 
(
    POL_POLICY_NO, POL_SUM_INSURED, RECEIPT_NO, "_75MIL", BTW75MIL_300MIL, BTW300MIL_1000MIL, ABV1000MIL, TOTAL_PREMIUM, STAMP_FEE, REMARK, 
    CONSTRAINT PK_MCG_UW2_POLICY PRIMARY KEY (POL_POLICY_NO) DISABLE NOVALIDATE
)
as
select 
    distinct pol_policy_no, pol_sum_insured, y.receipt_no || ', ' || to_char(y.settlement_date, 'DD-MON-YYYY') "RECEIPT_NO",   
    (select sum(pol_transaction_amount) from pol_data where pol_policy_no=x.pol_policy_no and pol_sum_insured <= 75000000) "_75MIL",
    (select sum(pol_transaction_amount) from pol_data where pol_policy_no=x.pol_policy_no and pol_sum_insured > 75000000 and pol_sum_insured < 300000000) "BTW75MIL_300MIL",
    (select sum(pol_transaction_amount) from pol_data where pol_policy_no=x.pol_policy_no and pol_sum_insured > 300000000 and pol_sum_insured < 1000000000) "BTW300MIL_1000MIL",
    (select sum(pol_transaction_amount) from pol_data where pol_policy_no=x.pol_policy_no and pol_sum_insured >= 1000000000) "ABV1000MIL",
    ( select pol_transaction_amount + round(pol_sum_insured * 0.01 / 100, 2) from pol_data 
      where pol_policy_no=x.pol_policy_no 
      and pol_trans_effect_date = (select max(pol_trans_effect_date) from pol_data where pol_policy_no=x.pol_policy_no)
    ) "TOTAL_PREMIUM", 
    ( select round(pol_sum_insured * 0.01 / 100, 2) from pol_data 
      where pol_policy_no=x.pol_policy_no 
      and pol_trans_effect_date = (select max(pol_trans_effect_date) from pol_data where pol_policy_no=x.pol_policy_no)
    ) "STAMP_FEE",
    case x.pol_prd_code when 'MCG' then 'MARINE CARGO' else 'INLAND TRANSIT' end "REMARK"
from pol_data x, rc_data y
where x.pol_policy_no = y.policy_no
and x.pol_seq_no = y.pol_seq_no
and pol_cla_code='MR' 
order by pol_policy_no;