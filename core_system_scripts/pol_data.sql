DROP VIEW SICL.POL_DATA;

/* Formatted on 9/6/2018 11:19:35 AM (QP5 v5.313) */
CREATE OR REPLACE FORCE VIEW SICL.POL_DATA
AS
    SELECT pol_pol_seq_no pol_seq_no,
           pol_cla_code,
           pol_prd_code,
           pol_proposal_no,
           pol_policy_no,
           DECODE (pol_transaction_type,
                   'N', 'NEW BUSINESS',
                   'R', 'RENEWAL',
                   'A', 'ADDITIONAL ENDORSEMENT',
                   'S', 'SPECIAL ENDORSEMENT',
                   'F', 'REFUND')
               pol_transaction_type,
               pol_period_from,
               pol_period_to,
           NVL (uw_x_policies.pol_last_endorsed_date,
                uw_x_policies.pol_period_from)
               pol_trans_effect_date,
           pol_authorized_date,
           pol_sum_insured,
           pol_cus_code,
           pk_uw_schedules.fn_get_additional_insured (pol_seq_no,
                                                      pol_cus_code,
                                                      'p')
               cus_name,
           REPLACE (pk_uw_schedules.fn_get_pol_cus_addr_str (pol_seq_no),
                    CHR (10),
                    '')
               cus_address,
           pol_currency,
           pol_transaction_amount,
           pol_total_premium,
           pol_total_transaction_amount,
           pol_bss_bss_code,
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
           pcm_per_code
               agent_code,
           pcm_amount
               commission_amt,
           NVL (
               (SELECT 'Y'
                  FROM uw_X_pol_FUNDS
                 WHERE     pfd_fun_code = '02'
                       AND pfd_transaction_amount <> 0
                       AND PFD_POL_SEQ_NO = pol_seq_no
                       AND ROWNUM = 1),
               'N')
               REINSTATEMENT_TRANSACTION,
           NVL (
               (SELECT SUM (pfd_transaction_amount)
                  FROM uw_X_pol_FUNDS
                 WHERE     pfd_fun_code = '02'
                       AND pfd_transaction_amount <> 0
                       AND PFD_POL_SEQ_NO = pol_seq_no),
               0)
               REINSTATEMENT_AMT
      FROM uw_x_policies, uw_x_pol_commissions
     WHERE pol_seq_no = pcm_pol_seq_no(+);


CREATE OR REPLACE PUBLIC SYNONYM POL_DATA FOR SICL.POL_DATA;

GRANT SELECT ON SICL.POL_DATA TO INFOINS;
