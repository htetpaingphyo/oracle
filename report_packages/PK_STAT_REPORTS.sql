CREATE OR REPLACE PACKAGE BODY SICL.pk_stat_reports
/* Formatted on 7/27/2017 6:25:55 PM (QP5 v5.126) */
IS
    ---------------------------------------------------------------------------
    --Developer  : PRIYAN FERNANDO
    --Date       : 08/07/2018
    --Purpose    : insert data to x tables and return new pol_seq_no
    ---------------------------------------------------------------------------

    FUNCTION fn_wrapper (pa_pol_seq IN uw_t_policies.pol_seq_no%TYPE)
        RETURN uw_t_policies.pol_seq_no%TYPE
    IS
        wkdate                DATE;
        wkcnt                 NUMBER;
        wksessionid           NUMBER;
        wkinstype             NUMBER;
        wkpolseqno            VARCHAR2 (30);
        wkpolicyno            VARCHAR2 (30);
        wkpollocseqno         VARCHAR2 (30);
        wknewpolseq           VARCHAR2 (30);
        wkins_locations       VARCHAR2 (1);
        wkins_risks           VARCHAR2 (1);
        wkins_perils          VARCHAR2 (1);
        wkins_sub_perils      VARCHAR2 (1);
        wkins_peril_inv       VARCHAR2 (1);
        wkins_peril_inv_cat   VARCHAR2 (1);
        wkins_inventory       VARCHAR2 (1);
        wkins_inv_det         VARCHAR2 (1);
        wkins_occupations     VARCHAR2 (1);
        wkins_sub_occ         VARCHAR2 (1);
        wkins_funds           VARCHAR2 (1);
        wkins_comm_funds      VARCHAR2 (1);
        wkins_oth_chg         VARCHAR2 (1);
        wkins_taxes           VARCHAR2 (1);
        wkins_tax_funds       VARCHAR2 (1);
        wkins_com_info        VARCHAR2 (1);
        wkins_com_info_det    VARCHAR2 (1);
        wkins_fin_int         VARCHAR2 (1);
        wkins_docs            VARCHAR2 (1);
        wkins_gen_perils      VARCHAR2 (1);
        wkins_risk_fin_int    VARCHAR2 (1);
        wkins_info            VARCHAR2 (1);
        wkins_info_det        VARCHAR2 (1);
        wkins_clauses         VARCHAR2 (1);
        wkins_warranties      VARCHAR2 (1);
        wkins_conditions      VARCHAR2 (1);
        wkins_others          VARCHAR2 (1);
        wkins_commissions     VARCHAR2 (1);
        wkins_targets         VARCHAR2 (1);
        wkins_rel_pol         VARCHAR2 (1);
        wkins_rc_payments     VARCHAR2 (1);
        wkbase                VARCHAR2 (1);
        wk_pol_pay_status     VARCHAR2 (1);
        wk_pol_cover_status   VARCHAR2 (20);
        wk_pol_sche_status    VARCHAR2 (20);
        wk_pol_renw_status    VARCHAR2 (20);
        wk_pol_seq_no         uw_t_policies.pol_seq_no%TYPE;
        wkfromdt              uw_t_policies.pol_period_from%TYPE;
        wkauthby              uw_t_policies.pol_authorized_by%TYPE;
        wktrntype             uw_t_policies.pol_transaction_type%TYPE;
        wkendorseddt          uw_t_policies.pol_last_endorsed_date%TYPE;
        --check inquery for how to get P_POL_SEQ_NO_CUR
        wk_pol_seq_no_cur     uw_t_policies.pol_seq_no%TYPE;
        wk_cnt                INTEGER;
        pa_policy_no          uw_t_policies.pol_policy_no%TYPE;

        CURSOR cur_get_policy_num
        IS
            SELECT   DISTINCT pol_policy_no
              FROM   (SELECT   pol_policy_no
                        FROM   uw_t_policies
                       WHERE   pol_seq_no = pa_pol_seq
                      UNION ALL
                      SELECT   edt_policy_no
                        FROM   uw_t_endorsements
                       WHERE   edt_seq_no = pa_pol_seq
                      UNION ALL
                      SELECT   phs_policy_no
                        FROM   uw_h_policy_history
                       WHERE   phs_seq_no = pa_pol_seq
                      UNION ALL
                      SELECT   nds_policy_no
                        FROM   uw_h_endorsement_history
                       WHERE   nds_seq_no = pa_pol_seq);

        CURSOR cur_get_pol_seq
        IS
            SELECT   pol_seq_no,
                     pol_transaction_type,
                     pol_period_from,
                     pol_last_endorsed_date
              FROM   uw_t_policies
             WHERE   pol_policy_no = pa_policy_no
                     AND pol_status IN
                                (wk_pol_pay_status,
                                 wk_pol_cover_status,
                                 wk_pol_sche_status,
                                 wk_pol_renw_status);

        CURSOR cur_get_cancel_pol_seq
        IS
            SELECT   pol_seq_no
              FROM   uw_t_policies
             WHERE   pol_policy_no = pa_policy_no AND pol_status IN (9);

        CURSOR cur_chk_authorized
        IS
            SELECT   pol_authorized_by
              FROM   uw_t_policies
             WHERE   pol_seq_no = pa_pol_seq;

        CURSOR cur_get_effect_date
        IS
            SELECT   DECODE (a.pol_transaction_type,
            'N', a.pol_period_from,
            'R', a.pol_period_from,
            a.pol_last_endorsed_date),
            pol_authorized_by
              FROM   uw_t_policies a
             WHERE   pol_seq_no = pa_pol_seq
            UNION ALL
            SELECT   DECODE (a.edt_transaction_type,
            'N', a.edt_period_from,
            'R', a.edt_period_from,
            a.edt_last_endorsed_date),
            edt_authorized_by
              FROM   uw_t_endorsements a
             WHERE   edt_seq_no = pa_pol_seq
            UNION ALL
            SELECT   DECODE (a.phs_transaction_type,
            'N', a.phs_period_from,
            'R', a.phs_period_from,
            a.phs_last_endorsed_date),
            phs_authorized_by
              FROM   uw_h_policy_history a
             WHERE   phs_seq_no = pa_pol_seq
            UNION ALL
            SELECT   DECODE (a.nds_transaction_type,
            'N', a.nds_period_from,
            'R', a.nds_period_from,
            a.nds_last_endorsed_date),
            nds_authorized_by
              FROM   uw_h_endorsement_history a
             WHERE   nds_seq_no = pa_pol_seq;

        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        OPEN cur_get_policy_num;

        FETCH cur_get_policy_num INTO pa_policy_no;

        IF NOT cur_get_policy_num%FOUND
        THEN
            ROLLBACK;

            CLOSE cur_get_policy_num;

            RETURN 0;
        END IF;

        wk_cnt := fn_del_policy_x (pa_pol_seq);
        wk_pol_pay_status := pk_uw_p_sys_params.fn_pol_payment_auth_status;
        wk_pol_cover_status := pk_uw_p_sys_params.fn_pol_covernote_auth_status;
        wk_pol_sche_status := pk_uw_p_sys_params.fn_pol_schedule_auth_status;
        wk_pol_renw_status := pk_uw_p_sys_params.fn_pol_quot_renewed_status;
        wkauthby := NULL;


        OPEN cur_get_pol_seq;

        FETCH cur_get_pol_seq
        INTO   wk_pol_seq_no,
               wktrntype,
               wkfromdt,
               wkendorseddt;

        CLOSE cur_get_pol_seq;

        IF wk_pol_seq_no IS NULL
        THEN
            OPEN cur_get_cancel_pol_seq;

            FETCH cur_get_cancel_pol_seq INTO wk_pol_seq_no;

            CLOSE cur_get_cancel_pol_seq;
        END IF;

        OPEN cur_get_effect_date;

        FETCH cur_get_effect_date
        INTO   wkdate, wkauthby;

        CLOSE cur_get_effect_date;

        wkpolseqno := pa_pol_seq;
        wkpolicyno := pa_policy_no;
        wkpollocseqno := NULL;
        wkbase := 'R';
        wkins_locations := 'Y';
        wkins_risks := 'Y';
        wkins_perils := 'Y';
        wkins_sub_perils := 'Y';
        wkins_peril_inv := 'Y';
        wkins_peril_inv_cat := 'Y';
        wkins_inventory := 'Y';
        wkins_inv_det := 'Y';
        wkins_occupations := 'Y';
        wkins_sub_occ := 'Y';
        wkins_funds := 'Y';
        wkins_comm_funds := 'Y';
        wkins_oth_chg := 'Y';
        wkins_taxes := 'Y';
        wkins_tax_funds := 'Y';
        wkins_com_info := 'Y';
        wkins_com_info_det := 'Y';
        wkins_fin_int := 'Y';
        wkins_docs := 'Y';
        wkins_gen_perils := 'Y';
        wkins_risk_fin_int := 'Y';
        wkins_info := 'Y';
        wkins_info_det := 'Y';
        wkins_clauses := 'Y';
        wkins_warranties := 'Y';
        wkins_conditions := 'Y';
        wkins_others := 'Y';
        wkins_commissions := 'Y';
        wkins_targets := 'Y';
        wkins_rel_pol := 'Y';

        pk_uw_wrapper.pu_build_policy_query (wkpolseqno,
                                             wkpolicyno,
                                             wkdate,
                                             wkbase,
                                             wkins_locations,
                                             wkins_risks,
                                             wkins_perils,
                                             wkins_sub_perils,
                                             wkins_peril_inv,
                                             wkins_peril_inv_cat,
                                             wkins_inventory,
                                             wkins_inv_det,
                                             wkins_occupations,
                                             wkins_sub_occ,
                                             wkins_funds,
                                             wkins_comm_funds,
                                             wkins_oth_chg,
                                             wkins_taxes,
                                             wkins_tax_funds,
                                             wkins_com_info,
                                             wkins_com_info_det,
                                             wkins_fin_int,
                                             wkins_docs,
                                             wkins_gen_perils,
                                             wkins_risk_fin_int,
                                             wkins_info,
                                             wkins_info_det,
                                             wkins_clauses,
                                             wkins_warranties,
                                             wkins_conditions,
                                             wkins_others,
                                             wkins_commissions,
                                             wkins_targets,
                                             wkins_rel_pol,
                                             wkins_rc_payments,
                                             wknewpolseq,
                                             wksessionid);

        COMMIT;

        RETURN wknewpolseq;
    END;

    ---------------------------------------------------------------------------
    --Developer  : PRIYAN FERNANDO
    --Date       : 08/07/2018
    --Purpose    : delete specfic pol seq data from x tables for a given pol seq no
    ---------------------------------------------------------------------------

    FUNCTION fn_del_policy_x (wkpolseq IN uw_t_policies.pol_seq_no%TYPE)
        RETURN INTEGER
    IS
        wk_retval   BOOLEAN;
        wk_cnt      INTEGER := 0;

        CURSOR cur_all_x_recs
        IS
            WITH uw_policies
                    AS (SELECT   pol_seq_no FROM uw_t_policies
                        UNION ALL
                        SELECT   edt_seq_no FROM uw_t_endorsements
                        UNION ALL
                        SELECT   phs_seq_no FROM uw_h_policy_history
                        UNION ALL
                        SELECT   nds_seq_no FROM uw_h_endorsement_history)
            SELECT   uw_x_policies.pol_seq_no, uw_x_policies.pol_session_id
              FROM   uw_policies, uw_x_policies
             WHERE   uw_policies.pol_seq_no = uw_x_policies.pol_pol_seq_no
                     AND uw_policies.pol_seq_no = wkpolseq;

        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        FOR pol_rec IN cur_all_x_recs
        LOOP
            BEGIN
                wk_retval :=
                    pk_uw_wrapper.fn_del_policy_x (pol_rec.pol_seq_no,
                                                   pol_rec.pol_session_id);
                wk_cnt := wk_cnt + 1;
            END;
        END LOOP;

        COMMIT;
        RETURN wk_cnt;
    END;


    --------------------------------------------------------------------------------
    --Developer  :  PRIYAN FERNANDO
    --Date       :  08-JUL-2017
    --Purpose    :  truncate all x table data
    --------------------------------------------------------------------------------

    PROCEDURE pr_del_x_data
    IS
    BEGIN
        DELETE FROM   uw_x_policies;

        DELETE FROM   uw_x_pol_certificates;

        DELETE FROM   uw_x_pol_clauses;

        DELETE FROM   uw_x_pol_commissions;

        DELETE FROM   uw_x_pol_common_information;

        DELETE FROM   uw_x_pol_com_breakup;

        DELETE FROM   uw_x_pol_com_info_details;

        DELETE FROM   uw_x_pol_conditions;

        DELETE FROM   uw_x_pol_cover_notes;

        DELETE FROM   uw_x_pol_cover_note_reasons;

        DELETE FROM   uw_x_pol_documents;

        DELETE FROM   uw_x_pol_fin_interest;

        DELETE FROM   uw_x_pol_funds;

        DELETE FROM   uw_x_pol_gen_perils;

        DELETE FROM   uw_x_pol_information;

        DELETE FROM   uw_x_pol_info_details;

        DELETE FROM   uw_x_pol_inventory;

        DELETE FROM   uw_x_pol_inv_details;

        DELETE FROM   uw_x_pol_locations;

        DELETE FROM   uw_x_pol_occupations;

        DELETE FROM   uw_x_pol_others;

        DELETE FROM   uw_x_pol_oth_charges;

        DELETE FROM   uw_x_pol_perils;

        DELETE FROM   uw_x_pol_peril_inv;

        DELETE FROM   uw_x_pol_peril_inv_catogs;

        DELETE FROM   uw_x_pol_rel_policies;

        DELETE FROM   uw_x_pol_risks;

        DELETE FROM   uw_x_pol_risk_class_funds;

        DELETE FROM   uw_x_pol_risk_fin_interest;

        DELETE FROM   uw_x_pol_risk_funds;

        DELETE FROM   uw_x_pol_risk_taxes;

        DELETE FROM   uw_x_pol_risk_tax_funds;

        DELETE FROM   uw_x_pol_sub_occupations;

        DELETE FROM   uw_x_pol_sub_perils;

        DELETE FROM   uw_x_pol_targets;

        DELETE FROM   uw_x_pol_taxes;

        DELETE FROM   uw_x_pol_tax_funds;

        DELETE FROM   uw_x_pol_warranties;

        DELETE FROM   uw_x_pol_coins_info_chrgs;

        DELETE FROM   uw_x_pol_coins_info;

        DELETE FROM   uw_x_rc_payments;

        DELETE FROM   uw_x_pol_excess_types;
    END;

    --------------------------------------------------------------------------------
    --Developer  :  PRIYAN FERNANDO
    --Date       :  27-JUL-2017
    --Purpose    :  populate  x table data
    --------------------------------------------------------------------------------
    PROCEDURE pr_pop_x_data (wkfromdt IN DATE, wktodt IN DATE)
    IS
        wkretval uw_t_policies.pol_seq_no%TYPE;
        CURSOR cur_pol_recs
        IS
            SELECT   pol_seq_no
              FROM   (SELECT   pol_seq_no,
                               pol_period_from,
                               pol_last_endorsed_date,
                               pol_status
                        FROM   uw_t_policies
                      UNION ALL
                      SELECT   edt_seq_no,
                               edt_period_from,
                               edt_last_endorsed_date,
                               edt_status
                        FROM   uw_t_endorsements
                      UNION ALL
                      SELECT   phs_seq_no,
                               phs_period_from,
                               phs_last_endorsed_date,
                               phs_status
                        FROM   uw_h_policy_history
                      UNION ALL
                      SELECT   nds_seq_no,
                               nds_period_from,
                               nds_last_endorsed_date,
                               nds_status
                        FROM   uw_h_endorsement_history) x
             WHERE   1 = 1 AND pol_status > 1 AND pol_status <> 9
                     AND TRUNC(NVL(pol_last_endorsed_date, pol_period_from)) BETWEEN wkfromdt AND wktodt;

    BEGIN
        commit;
        pr_del_x_data;
        commit;
        for rec in cur_pol_recs loop
            wkretval := fn_wrapper(rec.pol_seq_no);
        end loop;
        commit;
    END;

--------------------------------------------------------------------------------
    --Developer  :  Lahiru Madushan
    --Date       :  27-NOV-2017
    --Purpose    :  populate  x table data using rc date
    --------------------------------------------------------------------------------
    PROCEDURE pr_pop_x_data_rc_date (wkfromdt IN DATE, wktodt IN DATE)
    IS
        wkretval uw_t_policies.pol_seq_no%TYPE;
        CURSOR cur_pol_recs
        IS
            SELECT   pol_seq_no
              FROM   (SELECT   pol_seq_no,
                               pol_period_from,
                               pol_last_endorsed_date,pol_rc_receipting_date,
                               pol_status
                        FROM   uw_t_policies
                      UNION ALL
                      SELECT   edt_seq_no,
                               edt_period_from,
                               edt_last_endorsed_date,edt_rc_receipting_date,
                               edt_status
                        FROM   uw_t_endorsements
                      UNION ALL
                      SELECT   phs_seq_no,
                               phs_period_from,
                               phs_last_endorsed_date,phs_rc_receipting_date,
                               phs_status
                        FROM   uw_h_policy_history
                      UNION ALL
                      SELECT   nds_seq_no,
                               nds_period_from,
                               nds_last_endorsed_date,nds_rc_receipting_date,
                               nds_status
                        FROM   uw_h_endorsement_history) x
             WHERE   1 = 1 AND pol_status > 1 AND pol_status <> 9
                     AND TRUNC(NVL(pol_rc_receipting_date, pol_period_from)) BETWEEN wkfromdt AND wktodt;

    BEGIN
        commit;
        pr_del_x_data;
        commit;
        for rec in cur_pol_recs loop
            wkretval := fn_wrapper(rec.pol_seq_no);
        end loop;
        commit;
    END;


END;
/