DROP VIEW SICL.UW_RC_CLAIM_DET_X;

/* Formatted on 6/21/2018 2:02:04 PM (QP5 v5.300) */
CREATE OR REPLACE FORCE VIEW SICL.UW_RC_CLAIM_DET_X
(
    POL_SEQ_NO,
    POL_CLA_CODE,
    POL_PRD_CODE,
    POL_PROPOSAL_NO,
    POL_TRANSACTION_TYPE,
    POL_TRANS_EFFECT_DATE,
    POL_SUM_INSURED,
    POL_CUS_CODE,
    CUS_NAME,
    POL_CURRENCY,
    POL_TRANSACTION_AMOUNT,
    POL_TOTAL_PREMIUM,
    POL_TOTAL_TRANSACTION_AMOUNT,
    POL_BSS_BSS_CODE,
    PRS_NAME,
    POL_MARKETING_EXECUTIVE_CODE,
    AGENT_NAME,
    POL_BPARTY_BSS_CODE,
    POL_BPARTY_CODE,
    ACCOUNT_HANDLER_NAME,
    FIN_INTEREST,
    POL_POLICY_NO,
    INT_PRS_NAME,
    INT_CLAIM_NO,
    INT_INITIMATE_DT,
    INT_DATE_LOSS,
    INT_ESTIMATE_AMT,
    INT_CLAIMED_AMT,
    RAM_PAYABLE,
    RAM_CLAIMED,
    INT_PLACE_LOSS,
    INT_CONT_NO,
    INT_COMMENTS,
    INT_LOSS_REMARKS,
    INT_CAUSE_LOSS_CODE,
    CAUSE_OF_LOSS,
    CLAIM_STATUS,
    INT_MIGRATED,
    REINSTATMENT_AMT,
    CUST_ADDRESS,
    MAKE,
    VEHICLE_TYPE,
    MODEL,
    DEB_POL_SEQ_NO,
    DEB_POLICY_NO,
    DEB_DEB_NOTE_NO,
    DST_DEB_SETTLE_NO,
    DST_TRN_DATE,
    DEB_TRN_DATE,
    /*DST_SETTLED_AMOUNT,*/
    DST_STATUS,
    PAYMENT_MODE,
    CHQ_CHEQUE_NO,
    CHQ_CHEQUE_DATE,
    CHQ_CHEQUE_AMOUNT,
    REQ_REQUISITION_NO,
    PAYMENT_VOUCHER_NO,
    PV_AMT,
    PV_DATE,
    REQUESTION_TYPE,
    REQ_COMMENTS
)
    BEQUEATH DEFINER
AS
    SELECT pol_seq_no,
           pol_cla_code,
           pol_prd_code,
           pol_proposal_no,
           DECODE (pol_transaction_type,
                   'n', 'new business',
                   'r', 'renewal',
                   'a', 'additional endorsement',
                   's', 'special endorsement',
                   'f', 'refund')
               pol_transaction_type,
           NVL (pol_last_endorsed_date, pol_period_from)
               pol_trans_effect_date,
           pol_sum_insured,
           pol_cus_code,
           pk_uw_schedules.fn_get_additional_insured (pol_seq_no,
                                                      pol_cus_code,
                                                      'P')
               cus_name,
           pol_currency,
           pol_transaction_amount,
           pol_total_premium,
           pol_total_transaction_amount,
           pol_bss_bss_code,
           prs_name,
           pol_marketing_executive_code,
           (pk_sm_m_sales_force.fn_get_name (pol_marketing_executive_code))
               agent_name,
           pol_bparty_bss_code,
           pol_bparty_code,
           (pk_sm_m_sales_force.fn_get_name (pol_bparty_code))
               account_handler_name,
           (SELECT pk_uw_r_financial_interests.fn_get_fin_desc (pfi_fin_code)
              FROM uw_x_pol_fin_interest
             WHERE pfi_pol_seq_no = pol_seq_no AND ROWNUM = 1)
               fin_interest,
           pol_policy_no,
           int_prs_name,
           int_claim_no,
           int_initimate_dt,
           int_date_loss,
           int_estimate_amt,
           int_claimed_amt,
           (SELECT SUM (ram_payable)
              FROM cl_t_loss_report
             WHERE ram_int_seq = e.int_seq_no AND ram_active_flag = 'y')
               ram_payable,
           (SELECT SUM (ram_claimed)
              FROM cl_t_loss_report
             WHERE ram_int_seq = e.int_seq_no AND ram_active_flag = 'y')
               ram_claimed,
           int_place_loss,
           int_cont_no,
           int_comments,
           int_loss_remarks,
           int_cause_loss_code,
           (SELECT clo_desc
              FROM cl_r_cause_of_loss
             WHERE clo_code = int_cause_loss_code)
               cause_of_loss,
           DECODE (int_status,
                   'C', 'CANCEL',
                   'N', 'NO CLAIM',
                   'R', 'REJECT',
                   'L', 'CLOSED CLAIM',
                   'P', 'OPEN CLAIM',
                   'S', 'SETTLED CLAIM',
                   'O', 'OUTSTANDING CLAIM')
               claim_status,
           int_migrated,
           (SELECT SUM (rin_risk_rein_premium)
              FROM cl_t_reinstatement
             WHERE rin_status <> 9 AND rin_int_seq_no = int_seq_no)
               reinstatment_amt,
           pk_uw_schedules.fn_get_pol_cus_addr_fmt (pol_cus_code)
               cust_address,
           (SELECT NVL (
                       pk_cm_r_reference_two.fn_get_description (
                           pif_rft_code,
                              ''
                           || UPPER (NVL (pin_char_value, pin_number_value))
                           || ''),
                       UPPER (NVL (pin_char_value, pin_number_value)))
                       VALUE
              FROM uw_x_pol_information a, uw_m_prod_information b
             WHERE     a.pin_pif_seq_no = b.pif_seq_no
                   AND a.pin_pif_prd_code = b.pif_prd_code
                   AND b.pif_printed_in_receipt = 'y'
                   AND a.pin_description IN ('MAKE')
                   AND pin_prs_seq_no = prs_seq_no)
               AS make,
           (SELECT NVL (
                       pk_cm_r_reference_two.fn_get_description (
                           pif_rft_code,
                              ''
                           || UPPER (NVL (pin_char_value, pin_number_value))
                           || ''),
                       UPPER (NVL (pin_char_value, pin_number_value)))
                       VALUE
              FROM uw_x_pol_information a, uw_m_prod_information b
             WHERE     a.pin_pif_seq_no = b.pif_seq_no
                   AND a.pin_pif_prd_code = b.pif_prd_code
                   AND b.pif_printed_in_receipt = 'y'
                   AND a.pin_description IN ('VEHICLE TYPE')
                   AND pin_prs_seq_no = prs_seq_no)
               AS vehicle_type,
           (SELECT NVL (
                       pk_cm_r_reference_two.fn_get_description (
                           pif_rft_code,
                              ''
                           || UPPER (NVL (pin_char_value, pin_number_value))
                           || ''),
                       UPPER (NVL (pin_char_value, pin_number_value)))
                       VALUE
              FROM uw_x_pol_information a, uw_m_prod_information b
             WHERE     a.pin_pif_seq_no = b.pif_seq_no
                   AND a.pin_pif_prd_code = b.pif_prd_code
                   AND b.pif_printed_in_receipt = 'y'
                   AND a.pin_description IN ('MODEL')
                   AND pin_prs_seq_no = prs_seq_no)
               AS model,
           deb_pol_seq_no,
           deb_policy_no,
           deb_deb_note_no,
           dst_deb_settle_no,
           TRUNC (dst_trn_date)                                 dst_trn_date,
           TRUNC (deb_trn_date)                                 deb_trn_date,
           dst_settled_amount,
           dst_status,
           pk_rc_r_pay_mode.fn_payment_mode_desc (pdt_pay_code) payment_mode,
           chq_cheque_no,
           chq_cheque_date,
           chq_cheque_amount,
           req_requisition_no,
           (SELECT pmt_pvoucher_no
              FROM py_m_payment
             WHERE     pmt_cancel_date IS NULL
                   AND pmt_tvoucher_no IN
                           (SELECT pdt_tvoucher_no
                              FROM py_t_paydet
                             WHERE     pdt_ref_no1 = req_requisition_no
                                   AND ROWNUM = 1))
               PAYMENT_VOUCHER_NO,
           (SELECT SUM (pmt_total)
              FROM py_m_payment
             WHERE     pmt_cancel_date IS NULL
                   AND ROWNUM = 1
                   AND pmt_tvoucher_no IN
                           (SELECT pdt_tvoucher_no
                              FROM py_t_paydet
                             WHERE pdt_ref_no1 = req_requisition_no))
               PV_AMT,
           (SELECT pmt_voucher_date
              FROM py_m_payment
             WHERE     ROWNUM = 1
                   AND pmt_cancel_date IS NULL
                   AND pmt_tvoucher_no IN
                           (SELECT pdt_tvoucher_no
                              FROM py_t_paydet
                             WHERE pdt_ref_no1 = req_requisition_no))
               PV_DATE,
           (SELECT BYP_DESCRIPTION
              FROM CL_P_BEYOND_PERIL_PARAM
             WHERE BYP_CODE = req_pay_type)
               REQUESTION_TYPE,
           req_comments
      FROM cl_t_intimation  e,
           uw_x_policies,
           uw_x_pol_risks,
           uw_m_customers,
           rc_t_debit_settle,
           rc_t_debit_note,
           rc_t_deb_settl_det,
           rc_t_payments,
           rc_m_cheques,
           cl_t_requisition
     WHERE     pol_policy_no = int_policy_no(+)
           AND prs_name = int_prs_name(+)
           AND pol_seq_no = prs_plc_pol_seq_no
           AND cus_code = pol_cus_code
           AND pol_status NOT IN (9)
           AND deb_pol_seq_no = pol_pol_seq_no
           AND rc_t_debit_settle.dst_seq_no =
                   rc_t_deb_settl_det.sdt_dst_seq_no
           AND rc_t_deb_settl_det.sdt_deb_seq_no = rc_t_debit_note.deb_seq_no
           AND rc_t_payments.pdt_dst_seq_no = rc_t_debit_settle.dst_seq_no
           AND rc_t_payments.pdt_chq_seq_no = rc_m_cheques.chq_seq_no(+)
           AND INT_SEQ_NO = req_int_seq(+);
