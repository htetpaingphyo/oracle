exec pk_stat_reports.pr_del_x_data;
exec pk_stat_reports.pr_pop_x_data_rc_date('01-APR-2017', '31-DEC-2017');

select * from 
(
select  int_claim_no, int_initimate_dt, int_date_loss, a.int_prs_name, int_policy_no, prs_name, pol_policy_no,
(select pin_char_value from uw_t_pol_information where pin_description ='VEHICLE TYPE' and pin_prs_seq_no = prs_seq_no) VEHICLE_TYPE,
(select pin_char_value from uw_t_pol_information where pin_description ='TYPE OF BODY' and pin_prs_seq_no = prs_seq_no)  TYPE_OF_BODY,
(select pin_number_value from uw_t_pol_information where pin_description ='CUBIC CAPACITY (C.C.)' and pin_prs_seq_no = prs_seq_no) ENGINE_CAPACITY,
(select SUM (pln_pay_amount) from py_t_paylink where pln_ref_no1 = int_claim_no and pln_amount_payable = 0) CLAIM_PAID_AMT
from uw_T_pol_risks ,uw_T_policies ,cl_T_intimation a
where prs_plc_pol_seq_no = pol_seq_no
and int_policy_no = pol_policy_no 
--and prs_name =int_prs_name
and prs_r_seq = int_prs_r_seq
and prs_seq_no in (
    select pin_prs_seq_no from uw_t_pol_information
    where pin_description ='CUBIC CAPACITY (C.C.)' 
    and pin_number_value > 4000
)
and prs_seq_no in (
    select pin_prs_seq_no 
    from uw_t_pol_information
    where pin_description = 'TYPE OF BODY' 
    and pin_char_value in ('TRUCK')
)
and prs_seq_no in (
    select pin_prs_seq_no 
    from uw_t_pol_information
    where pin_description = 'VEHICLE TYPE' 
    and pin_char_value ='CT'
)
and trunc(int_date_loss) > '01-APR-2017'
) where claim_paid_amt <> 0