SELECT * FROM  (
    SELECT 
        distinct pol_policy_no, 
        pol_bparty_bss_code, 
        pol_bparty_code, 
        pol_sum_insured, 
        pol_premium, 
        int_prs_name, 
        (SELECT 
            NVL(pk_cm_r_reference_two.fn_get_description(pif_rft_code,''||UPPER(NVL(pin_char_value,pin_number_value))||''), UPPER(NVL(pin_char_value,pin_number_value))) VALUE
            FROM uw_t_pol_information a, uw_m_prod_information b
            WHERE A.pin_pif_seq_no = b.pif_seq_no
            AND A.pin_pif_prd_code = b.pif_prd_code
            AND b.PIF_PRINTED_IN_RECEIPT = 'Y'
            AND A.pin_description IN ('MAKE')
            AND pin_prs_seq_no = PRS_SEQ_NO
        ) AS MAKE
        ,(SELECT 
            NVL(pk_cm_r_reference_two.fn_get_description(pif_rft_code,''||UPPER(NVL(pin_char_value,pin_number_value))||''), UPPER(NVL(pin_char_value,pin_number_value))) VALUE
            FROM uw_t_pol_information a, uw_m_prod_information b
            WHERE A.pin_pif_seq_no = b.pif_seq_no
            AND A.pin_pif_prd_code = b.pif_prd_code
            AND b.PIF_PRINTED_IN_RECEIPT = 'Y'
            AND A.pin_description IN ('VEHICLE TYPE')
            AND pin_prs_seq_no = PRS_SEQ_NO
        ) AS VEHICLE_TYPE,
        req_requisition_no,
        req_amount requisition_amt,
        (pln_pay_amount-pln_amount_payable) actual_paid_amt,
        pln_pay_date,
        pmt_voucher_date,
        req_int_seq,
        int_claim_no,
        int_seq_no,
        int_policy_no,
        int_initimate_dt,
        int_date_loss
from  cl_t_requisition, cl_t_intimation, py_t_paylink, py_m_payment, uw_T_policies, uw_T_pol_risks
where req_int_seq = int_seq_no
and req_requisition_no not like '%DM%'
and pln_ref_no5 =req_requisition_no 
and int_policy_no  = pol_policy_no
and int_prs_name  = prs_name
and pol_seq_no = prs_plc_pol_Seq_no
and trunc (pln_pay_date) > to_date('01-JUL-2018','DD-MON-YYYY')
and trunc (pln_pay_date) < to_date('31-JUN-2018','DD-MON-YYYY')
--and req_requisition_no='RQ/YGN/MCC/18000280'
and pln_ref_no1 = int_claim_no
--and int_prs_name='9N/4718(YGN)'
)
group by pol_policy_no, pol_bparty_bss_code, pol_bparty_code, pol_sum_insured, pol_premium, int_prs_name, req_requisition_no, requisition_amt, 
actual_paid_amt, pln_pay_date, pmt_voucher_date, req_int_seq, int_claim_no, int_seq_no, int_policy_no, int_initimate_dt, int_date_loss, make, vehicle_type 
order by int_initimate_dt desc;