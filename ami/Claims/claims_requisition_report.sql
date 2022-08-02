select 
    int_policy_no, int_claim_no, int_initimate_dt, int_date_loss, int_inspection, int_estimate_amt, int_place_loss, int_cont_address, int_comments, int_claimed_amt, int_partial_pay, 
    int_loss_remarks, int_payable_amt, int_currency, int_contact_per, int_class_code, int_prod_code, int_sum_insured, int_period_from, int_period_to, int_branch_code, 
    int_prs_name, int_claims_paid, int_cancel_remark, int_cancel_date, int_total_loss, int_risk_sum_insured, int_intimated_date_of_loss, int_bss_code, int_accident_desc, 
    int_settled_premium, int_total_premium, req_amount, req_comments, req_pay_type
from cl_t_intimation a, cl_t_requisition b 
where a.int_seq_no = b.req_int_seq  
and a.int_policy_no like '%MCC%' 
and b.req_pay_type = 'P';