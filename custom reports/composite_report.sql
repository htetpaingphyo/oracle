select   
pol_seq_no,
pol_cla_code,
pol_prd_code,
pol_proposal_no,
pol_policy_no,
decode(pol_transaction_type, 'N', 'NEW BUSINESS', 'R', 'RENEWAL', 'A', 'ADDITIONAL ENDORSEMENT', 'S', 'SPECIAL ENDORSEMENT', 'F', 'REFUND') pol_transaction_type,
NVL(pol_last_endorsed_date, pol_period_from) pol_trans_effect_date,
pol_sum_insured,
pol_cus_code,
pk_uw_schedules.fn_get_additional_insured (pol_seq_no, pol_cus_code, 'p')
cus_name,
pol_currency,
pol_transaction_amount,
pol_total_premium,
pol_total_transaction_amount,
pol_bss_bss_code,
prs_name,
pol_marketing_executive_code,
(pk_sm_m_sales_force.fn_get_name (pol_marketing_executive_code)) agent_name,
pol_bparty_bss_code,
pol_bparty_code,
(pk_sm_m_sales_force.fn_get_name (pol_bparty_code)) account_handler_name,
(SELECT   pk_uw_r_financial_interests.fn_get_fin_desc (pfi_fin_code)
FROM   uw_t_pol_fin_interest
WHERE   pfi_pol_seq_no = pol_seq_no AND ROWNUM = 1)
fin_interest, pol_policy_no,POL_PRD_CODE,int_prs_name ,pol_total_transaction_amount,int_claim_no,cus_code,cus_indv_surname,int_initimate_dt,
int_date_loss,int_estimate_amt,int_claimed_amt,
(select sum(ram_payable) from cl_T_loss_report
where ram_int_seq = e.int_seq_no
and ram_active_flag ='Y') ram_payable,
(select sum( ram_claimed) from cl_T_loss_report
where ram_int_seq = e.int_seq_no
and ram_active_flag ='Y') ram_claimed,
int_place_loss,int_cont_no,
int_comments,int_loss_remarks,int_cause_loss_code,(select clo_desc from cl_r_cause_of_loss
where clo_code = int_cause_loss_code
) cause_of_loss,
DECODE(int_status,
'C' , 'CANCEL','N' , 'NO CLAIM','R' , 'REJECT','L' ,'CLOSED CLAIM','P' , 'OPEN CLAIM','S' , 'SETTLED CLAIM',
'O' , 'OUTSTANDING CLAIM') CLAIM_STATUS,int_migrated,
(select sum(rin_risk_rein_premium )
from cl_t_reinstatement
where rin_status <> 9
and rin_int_seq_no =int_seq_no ) reinstatment_amt,
pk_uw_schedules.fn_get_pol_cus_addr_fmt(pol_cus_code) cust_address,
(SELECT 
NVL(pk_cm_r_reference_two.fn_get_description(pif_rft_code,''||UPPER(NVL(pin_char_value,pin_number_value))||''), UPPER(NVL(pin_char_value,pin_number_value))) VALUE
FROM uw_t_pol_information a, uw_m_prod_information b
WHERE A.pin_pif_seq_no = b.pif_seq_no
AND A.pin_pif_prd_code = b.pif_prd_code
AND b.PIF_PRINTED_IN_RECEIPT = 'Y'
AND A.pin_description IN ('MAKE')
AND pin_prs_seq_no = PRS_SEQ_NO) AS MAKE
,(SELECT 
NVL(pk_cm_r_reference_two.fn_get_description(pif_rft_code,''||UPPER(NVL(pin_char_value,pin_number_value))||''), UPPER(NVL(pin_char_value,pin_number_value))) VALUE
FROM uw_t_pol_information a, uw_m_prod_information b
WHERE A.pin_pif_seq_no = b.pif_seq_no
AND A.pin_pif_prd_code = b.pif_prd_code
AND b.PIF_PRINTED_IN_RECEIPT = 'Y'
AND A.pin_description IN ('VEHICLE TYPE')
AND pin_prs_seq_no = PRS_SEQ_NO) AS VEHICLE_TYPE
,(SELECT 
NVL(pk_cm_r_reference_two.fn_get_description(pif_rft_code,''||UPPER(NVL(pin_char_value,pin_number_value))||''), UPPER(NVL(pin_char_value,pin_number_value))) VALUE
FROM uw_t_pol_information a, uw_m_prod_information b
WHERE A.pin_pif_seq_no = b.pif_seq_no
AND A.pin_pif_prd_code = b.pif_prd_code
AND b.PIF_PRINTED_IN_RECEIPT = 'Y'
AND A.pin_description IN ('MODEL')
AND pin_prs_seq_no = PRS_SEQ_NO) AS MODEL,
DEB_POL_SEQ_NO,
DEB_POLICY_NO,
DEB_DEB_NOTE_NO,
DST_DEB_SETTLE_NO,
TRUNC (DST_TRN_DATE) DST_TRN_DATE,
trunc(deb_trn_date)DEB_TRN_DATE,
DST_SETTLED_AMOUNT,
DST_STATUS,
PK_RC_R_PAY_MODE.FN_PAYMENT_MODE_DESC (PDT_PAY_CODE)
PAYMENT_MODE,
CHQ_CHEQUE_NO,
CHQ_CHEQUE_DATE,
CHQ_CHEQUE_AMOUNT
from  cl_t_intimation e,uw_T_policies ,uw_T_pol_risks,uw_m_customers,
RC_T_DEBIT_SETTLE,RC_T_DEBIT_NOTE,RC_T_DEB_SETTL_DET,RC_T_PAYMENTS,
RC_M_CHEQUES
where    pol_policy_no = int_policy_no(+) 
and prs_name = int_prs_name(+)
and pol_seq_no = prs_plc_pol_Seq_no
and cus_code = pol_cus_code
and pol_status not in (9) 
and deb_pol_seq_no =pol_seq_no 
AND RC_T_DEBIT_SETTLE.DST_SEQ_NO = RC_T_DEB_SETTL_DET.SDT_DST_SEQ_NO
AND RC_T_DEB_SETTL_DET.SDT_DEB_SEQ_NO = RC_T_DEBIT_NOTE.DEB_SEQ_NO
AND RC_T_PAYMENTS.PDT_DST_SEQ_NO = RC_T_DEBIT_SETTLE.DST_SEQ_NO
AND RC_T_PAYMENTS.PDT_CHQ_SEQ_NO = RC_M_CHEQUES.CHQ_SEQ_NO(+)