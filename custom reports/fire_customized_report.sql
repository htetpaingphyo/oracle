select
    distinct x.pol_policy_no, 
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'WATER SENSITIVITY - MACHINERY') "MACHINERY",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'WATER SENSITIVITY - FURNITURE') "FURNITURE",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'FLOOR') "FLOOR",    
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'ROOF') "ROOF",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'CLASS OF THE MOST INFERIOR CONS. IN PROXIMITY') "PROXIMITY",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'CLASS OF THE BUILDING') "CLASS",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'OCCUPATION OF THE MOST INFERIOR CONS. IN PROXIMITY') "OCCUPATION",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'WALLS') "WALLS",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'WATER SENSITIVITY - STOCKS') "STOCKS",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'OCCUPATION OF THE BUILDING') "BUILDING",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'NO OF STOREYS') "STOREYS",
    (select distinct(info_value) from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_seq_no=x.prs_seq_no and prs_name = x.prs_name and pin_description = 'COLUMNS') "COLUMNS", 
    z.pol_period_from "EFFECTIVE FROM", z.pol_period_to "EFFECTIVE TO",  
    (   select 
        listagg(ppr_premium, ', ') within group (order by pol_policy_no) 
        from pol_risk_perils 
        where pol_policy_no = x.pol_policy_no and prl_description = 'NO CLAIM BONUS' 
        group by pol_policy_no
    ) "NCB",
    y.pol_sum_insured "SUM INSURED", y.commission_amt "COMMISSION", y.pol_transaction_type "REMARK" 
from pol_risk_info x, pol_data y, pol_risk_perils z
where x.pol_policy_no = y.pol_policy_no 
and x.pol_policy_no = z.pol_policy_no 
and x.pol_prd_code='FFI';