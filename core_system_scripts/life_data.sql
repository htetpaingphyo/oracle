DROP VIEW SICL.LIFE_DATA;

/* Formatted on 9/6/2018 1:24:59 PM (QP5 v5.313) */
CREATE OR REPLACE FORCE VIEW SICL.LIFE_DATA
AS
    SELECT a.pol_seq_no,
           a.pol_policy_no,
           pol_sum_insured, 
           pol_premium,
           pol_total_premium,
           pol_total_transaction_amount,
           pol_transaction_amount,
           a.pol_authorized_by,
           a.pol_authorized_date,
           a.pol_cus_code,
           c.cus_indv_surname,
           d.adr_loc_description,
           b.prs_nic_no,
           a.pol_period_from,
           a.pol_period_to,
           (SELECT ppr_transaction_amount
              FROM UW_X_pol_perils
             WHERE     ppr_prs_plc_pol_seq_no = a.pol_seq_no
                   AND ppr_prs_seq_no = b.prs_seq_no
                   AND ppr_prs_plc_seq_no = b.prs_plc_seq_no
                   AND ppr_per_prl_code = 'LF')
               BASIC_COVER,
           (SELECT ppr_transaction_amount
              FROM UW_X_pol_perils
             WHERE     ppr_prs_plc_pol_seq_no = a.pol_seq_no
                   AND ppr_prs_seq_no = b.prs_seq_no
                   AND ppr_prs_plc_seq_no = b.prs_plc_seq_no
                   AND ppr_per_prl_code = 'HI02')
               ACCIDENT_DEATH,
           (SELECT ppr_transaction_amount
              FROM UW_X_pol_perils
             WHERE     ppr_prs_plc_pol_seq_no = a.pol_seq_no
                   AND ppr_prs_seq_no = b.prs_seq_no
                   AND ppr_prs_plc_seq_no = b.prs_plc_seq_no
                   AND ppr_per_prl_code = 'HI07')
               CANCER,
           (SELECT ppr_transaction_amount
              FROM UW_X_pol_perils
             WHERE     ppr_prs_plc_pol_seq_no = a.pol_seq_no
                   AND ppr_prs_seq_no = b.prs_seq_no
                   AND ppr_prs_plc_seq_no = b.prs_plc_seq_no
                   AND ppr_per_prl_code = 'HI05')
               SURGICAL,
           (SELECT ppr_transaction_amount
              FROM UW_X_pol_perils
             WHERE     ppr_prs_plc_pol_seq_no = a.pol_seq_no
                   AND ppr_prs_seq_no = b.prs_seq_no
                   AND ppr_prs_plc_seq_no = b.prs_plc_seq_no
                   AND ppr_per_prl_code = 'HI04')
               DISABILITY,
           (SELECT ppr_transaction_amount
              FROM UW_X_pol_perils
             WHERE     ppr_prs_plc_pol_seq_no = a.pol_seq_no
                   AND ppr_prs_seq_no = b.prs_seq_no
                   AND ppr_prs_plc_seq_no = b.prs_plc_seq_no
                   AND ppr_per_prl_code = 'HI03')
               DISEASE,
           (SELECT ppr_transaction_amount
              FROM UW_X_pol_perils
             WHERE     ppr_prs_plc_pol_seq_no = a.pol_seq_no
                   AND ppr_prs_seq_no = b.prs_seq_no
                   AND ppr_prs_plc_seq_no = b.prs_plc_seq_no
                   AND ppr_per_prl_code = 'HI06')
               MISCARRIAGE,
           (SELECT ppr_transaction_amount
              FROM UW_X_pol_perils
             WHERE     ppr_prs_plc_pol_seq_no = a.pol_seq_no
                   AND ppr_prs_seq_no = b.prs_seq_no
                   AND ppr_prs_plc_seq_no = b.prs_plc_seq_no
                   AND ppr_per_prl_code = 'COM')
               COMMISSION,
           DECODE (
               (SELECT NVL (pin_char_value, pin_number_value)
                  FROM UW_X_pol_information
                 WHERE     pin_prs_plc_pol_seq_no = a.pol_seq_no
                       AND pin_prs_seq_no = b.prs_seq_no
                       AND pin_description = 'BASIS'),
               'Y', 'YEARLY',
               'Q', 'QUARTERLY',
               'B', 'BI-ANNUALY',
               'M', 'MONTHLY')
               BASIC,
           (SELECT NVL (pin_number_value, pin_char_value)
              FROM UW_X_pol_information
             WHERE     pin_prs_plc_pol_seq_no = a.pol_seq_no
                   AND pin_prs_seq_no = b.prs_seq_no
                   AND pin_description = 'ADDITIONAL UNITS')
               ADDITIONAL_UNITS,
           (SELECT NVL (pin_number_value, pin_char_value)
              FROM UW_X_pol_information
             WHERE     pin_prs_plc_pol_seq_no = a.pol_seq_no
                   AND pin_prs_seq_no = b.prs_seq_no
                   AND pin_description = 'OPTION 1 UNITS')
               OPTION_1_UNITS,
           (SELECT NVL (pin_number_value, pin_char_value)
              FROM UW_X_pol_information
             WHERE     pin_prs_plc_pol_seq_no = a.pol_seq_no
                   AND pin_prs_seq_no = b.prs_seq_no
                   AND pin_description = 'OPTION 2 UNITS')
               OPTION_2_UNITS,
           int_claim_no,
           int_initimate_dt,
           int_date_loss,
           int_estimate_amt,
           int_claimed_amt,
           int_prs_name,
           (SELECT ram_payable
              FROM cl_T_loss_report
             WHERE ram_int_seq = e.int_seq_no AND ram_active_flag = 'Y')
               ram_payable,
           (SELECT ram_claimed
              FROM cl_T_loss_report
             WHERE ram_int_seq = e.int_seq_no AND ram_active_flag = 'Y')
               ram_claimed
      FROM UW_X_policies        a,
           UW_X_pol_risks       b,
           uw_m_customers       c,
           uw_m_cust_addresses  d,
           cl_T_intimation      e
     WHERE     a.pol_Seq_no = b.prs_plc_pol_seq_no
           AND a.pol_cus_code = c.cus_code
           AND c.cus_code = d.adr_cus_code
           AND e.int_policy_no(+) = a.pol_policy_no
           AND e.int_prs_name(+) = b.prs_name
           AND a.pol_cla_code = 'LF'
           AND a.pol_policy_no IS NOT NULL;
