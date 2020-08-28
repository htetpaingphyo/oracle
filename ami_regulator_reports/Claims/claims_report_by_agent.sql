select * from (
    select 
        distinct pol_policy_no policy_no, int_contact_per customer_name,    
        (select sfc_surname from sm_m_sales_force where sfc_code = pol_marketing_executive_code) agent_name,
        /*(select sfc_surname from sm_m_sales_force where sfc_code = pol_bparty_code) account_handler,*/
        pol_sum_insured sum_insured, pol_premium total_premium, int_prs_name vehicle_no, int_initimate_dt initimation_date, int_date_loss loss_date,
        (   select
                nvl(pk_cm_r_reference_two.fn_get_description(pif_rft_code,''|| upper(nvl(pin_char_value,pin_number_value))||''), upper(nvl(pin_char_value,pin_number_value))) value
            from uw_t_pol_information a, uw_m_prod_information b
            where a.pin_pif_seq_no = b.pif_seq_no
            and a.pin_pif_prd_code = b.pif_prd_code
            and b.PIF_PRINTED_IN_RECEIPT = 'Y'
            and a.pin_description IN ('VEHICLE TYPE')
            and pin_prs_seq_no = prs_seq_no
        ) as vehicle_type,
        req_amount requisition_amount,
        (pln_pay_amount - pln_amount_payable) actual_paid_amount, 
        pln_pay_date paid_date     
from  cl_t_requisition, cl_t_intimation, py_t_paylink, py_m_payment, uw_T_policies, uw_T_pol_risks, py_t_paydet
where req_int_seq = int_seq_no 
    and pol_marketing_executive_code = 'A0001'
    and req_requisition_no not like '%DM%'
    and pln_ref_no5 = req_requisition_no 
    and int_policy_no = pol_policy_no
    and int_prs_name = prs_name
    and pol_seq_no = prs_plc_pol_Seq_no
    and trunc (pmt_voucher_date) > to_date('01-JUL-2017','DD-MON-YYYY')
    and trunc (pmt_voucher_date) < to_date('31-JUL-2018','DD-MON-YYYY')
    and pln_ref_no1 = int_claim_no
    and pdt_ref_no1 = pln_ref_no5
    and pdt_tvoucher_no = pmt_tvoucher_no
)
group by policy_no, customer_name, agent_name, sum_insured, total_premium, vehicle_no, requisition_amount, 
actual_paid_amount, initimation_date, loss_date, vehicle_type, paid_date
order by initimation_date;