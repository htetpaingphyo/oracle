select  pol_policy_no, int_claim_no, int_initimate_dt, int_date_loss, prs_name, int_loss_remarks, int_claimed_amt, 
nvl((select sum(pln_pay_amount) from py_t_paylink where pln_ref_no1 = int_claim_no and pln_amount_payable = 0), 0) claim_paid_amt, 
nvl((select SUM (ram_tot_payable) from cl_t_loss_report where ram_int_seq = INT_SEQ_no and nvl(ram_active_flag,'N') = 'Y'), 0) loss_report_amt 
from uw_T_pol_risks, uw_T_policies, cl_T_intimation a 
where prs_plc_pol_seq_no = pol_seq_no 
and int_policy_no = pol_policy_no 
--and prs_name=int_prs_name
and prs_r_seq = int_prs_r_seq 
and pol_cla_code in ('MT') 
and trunc(int_date_loss) > '01-APR-2017' 
order by 1;