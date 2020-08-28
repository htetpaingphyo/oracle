select 
    distinct x.pol_policy_no "POLICY NO.", w.int_claim_no "CLAIM NO.", w.int_initimate_dt "REPORT DATE", w.int_date_loss "LOSS DATE", w.int_prs_name "REG NO.", 
    (select distinct(info_value)  from pol_risk_info where pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and pin_description = 'MAKE') MAKE, 
    (select distinct(info_value)  from pol_risk_info where pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and pin_description = 'MODEL') MODEL,
    (select distinct(info_value)  from pol_risk_info where pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and pin_description = 'VEHICLE TYPE') VEHICLE, 
    (select distinct(info_value)  from pol_risk_info where pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and pin_description = 'TYPE OF BODY') TYPE, 
    (select distinct(info_value)  from pol_risk_info where pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and pin_description = 'WINDSCREEN SI') WINDSCREEN, 
    w.int_contact_per "INSURED NAME", w.int_driver_name "DRIVER NAME", w.int_sum_insured "SUM INSURED", w.int_loss_remarks "REMARK" 
from cl_t_intimation w, pol_risk_info x
where w.int_policy_no = x.pol_policy_no
and w.int_prs_name = x.prs_name
and x.pol_prd_code='MCC'
order by w.int_initimate_dt desc;