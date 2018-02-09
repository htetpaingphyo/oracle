CREATE OR REPLACE PACKAGE BODY SICL.pk_uw_schedules  IS
--------------------------------------------------------------------------------
-- Developer : Priyan Fernando
-- Date      : 26/09/2015
-- Purpose   : Package for quotations and schedules
--------------------------------------------------------------------------------

FUNCTION fn_get_qot_remark ( p_qot_seq  uw_t_quotations.qot_seq_no%TYPE)
                             RETURN VARCHAR2 IS

    wkPRDCode    uw_m_products.prd_code%TYPE;
    wkQotRemarks VARCHAR2(1200 CHAR);


    CURSOR cur_qot_rem IS
        SELECT QOT_REMARKS
        FROM   uw_t_quotations
        WHERE  qot_seq_no = p_qot_seq;


BEGIN

    wkPRDCode    := pk_uw_t_quotations.fn_get_prod_code(p_qot_seq);

    OPEN cur_qot_rem;
    FETCH cur_qot_rem INTO wkQotRemarks;
    CLOSE cur_qot_rem;

    wkQotRemarks := 'THIS QUOTATION IS SUBJECT TO '||fn_get_qot_valid_period(p_qot_seq)||' DAYS VALIDITY.'||CHR(10)||wkQotRemarks;


    RETURN wkQotRemarks;

END fn_get_qot_remark;


FUNCTION fn_get_qot_valid_period(p_qot_seq uw_t_quotations.qot_seq_no%TYPE) RETURN NUMBER IS

    wkQotvalidp NUMBER;

    CURSOR cur_qot_valid_p IS
        SELECT trunc(qot_valid_to) - trunc(qot_valid_from)
        FROM   uw_t_quotations
        WHERE  qot_seq_no = p_qot_seq;

BEGIN

    OPEN cur_qot_valid_p;
    FETCH cur_qot_valid_p INTO wkQotvalidp;
    CLOSE cur_qot_valid_p;

RETURN wkQotvalidp;

END fn_get_qot_valid_period;

FUNCTION fn_get_pol_period_str(p_pol_seq uw_t_policies.pol_seq_no%TYPE) RETURN VARCHAR2 IS

    wkpolperiod VARCHAR2(300 CHAR);
    wkPRDCode uw_m_products.prd_code%TYPE := pk_uw_t_policies.fn_get_prod_code(p_pol_seq);
    wkPCchk VARCHAR2(1 CHAR);
    wkpolinfochar VARCHAR2(25 CHAR):= PK_UW_P_SYS_PARAMS.FN_GET_ANY_CHR_VALUE('000.0002');
    wkpolinfov VARCHAR2(1000 CHAR) := PK_UW_T_POL_COMMON_INFORMATION.fn_get_common_info(p_pol_seq,wkpolinfochar);
    wkpolwording VARCHAR2(2000 CHAR);
    WkPeriod VARCHAR(2000 CHAR);
    wkPeriodStart uw_t_policies.pol_period_from%TYPE;
    wkPeriodEnd uw_t_policies.pol_period_to%TYPE;
    wkPrdRefCode    UW_M_PRODUCTS.prd_ref_code%TYPE;


    CURSOR cur_pol_cover_p IS
        SELECT pol_period_from,pol_period_to
        FROM   uw_x_policies
        WHERE  pol_seq_no = p_pol_seq;

    CURSOR cur_prod_chk IS
        SELECT 'X'
        FROM (SELECT PK_UW_P_SYS_PARAMS.FN_GET_ANY_CHR_VALUE('000.0001') str FROM DUAL), xmltable(('"' || REPLACE(str, ',', '","') || '"'))
        WHERE trim(COLUMN_VALUE) = wkPRDCode ;

BEGIN

    OPEN cur_pol_cover_p;
    FETCH cur_pol_cover_p INTO wkPeriodStart, wkPeriodEnd;
    CLOSE cur_pol_cover_p;

  wkPrdRefCode := pk_uw_m_products.fn_get_prd_rdf_code(wkPRDCode);

  IF wkPrdRefCode = 'DNO' THEN --30/09/2015
    WkPeriod:=trim(to_char(TRUNC(wkPeriodStart), 'DD MONTH')) || ' ' || to_char(TRUNC(wkPeriodStart),'YYYY')||' '||''||' '||'TO'||' '||''||' '||trim(to_char(TRUNC(wkPeriodEnd), 'DD MONTH')) || ' ' || to_char(TRUNC(wkPeriodEnd),'YYYY')||' '||'BOTH DAYS INCLUSIVE, LOCAL STANDARD TIME AT THE'||CHR(10)||'INSUREDS ADDRESS';
  ELSIF  wkPrdRefCode IN ('MBD','EML') THEN --30/09/2015
    WkPeriod:=trim(to_char(TRUNC(wkPeriodStart), 'DD MONTH')) || ' ' || to_char(TRUNC(wkPeriodStart),'YYYY')||' '||''||' '||'TO'||' '||''||' '||trim(to_char(TRUNC(wkPeriodEnd), 'DD MONTH')) || ' ' || to_char(TRUNC(wkPeriodEnd),'YYYY')||' '||'(BOTH DAYS INCLUSIVE)';
  ELSIF wkPrdRefCode = 'CON' THEN --30/09/2015
    WkPeriod:=trim(to_char(TRUNC(wkPeriodStart), 'DD MONTH')) || ' ' || to_char(TRUNC(wkPeriodStart),'YYYY')||' '||''||' '||'TO'||' '||''||' '||trim(to_char(TRUNC(wkPeriodEnd), 'DD MONTH')) || ' ' || to_char(TRUNC(wkPeriodEnd),'YYYY')||' '||'  INCLUDING 3 MONTHS TESTING AND COMMISSIONING PERIOD. (40MONTHS)';
  ELSE
    WkPeriod:=trim(to_char(TRUNC(wkPeriodStart), 'DD MONTH')) || ' ' || to_char(TRUNC(wkPeriodStart),'YYYY')||' '||''||' '||'TO'||' '||''||' '||trim(to_char(TRUNC(wkPeriodEnd), 'DD MONTH')) || ' ' || to_char(TRUNC(wkPeriodEnd),'YYYY');
  END IF;


    --close cur_prod_chk;
    wkpolwording := WkPeriod;

    RETURN wkpolwording;

END fn_get_pol_period_str;

--------------------------------------------------------------------------------
-- Developer : Priyan Fernando
-- Date      : 26/09/2015
-- Purpose   : return customer address for schedules
--------------------------------------------------------------------------------
-- Modified  : Lahiru [20/02/17 - change address format (get address from  pkg pk_common.fn_get_cus_addr)
--------------------------------------------------------------------------------
-- Modified  : Lahiru [28/08/17 - change address format to upper case
--------------------------------------------------------------------------------
FUNCTION fn_get_pol_cus_addr_str(p_pol_seq uw_t_policies.pol_seq_no%TYPE) RETURN VARCHAR2 IS

    WkAddress                  VARCHAR2(2000);
    wk_cust_code               uw_m_customers.cus_code%TYPE;
    /*wk_num_build               VARCHAR2(100);
    wk_cust_country            sm_m_geoarea_paramln.gpl_desc%TYPE; -- added for FORTE UW-SRS #88
    wk_cust_prvcode            uw_m_cust_addresses.adr_province%TYPE;
    wk_cust_province           sm_m_geoarea_paramln.gpl_desc%TYPE;
    wk_dist_code               uw_m_cust_addresses.adr_district%TYPE;
    wk_district                sm_m_geoarea_paramln.gpl_desc%TYPE;
    wk_post_code               uw_m_customers.cus_postal_code%TYPE;
    wk_address                 uw_r_locations.loc_description%TYPE;
    wk_city                    uw_m_customers.cus_city%TYPE;
    wk_street                  uw_m_customers.cus_street%TYPE;
    wk_building                uw_m_customers.cus_building%TYPE;
    wk_number                  uw_m_customers.cus_number%TYPE;



     CURSOR cur_get_adr_fmtd IS
            SELECT DECODE(wk_number,'','',wk_number ||', ')||TRIM(DECODE(wk_building,'','',wk_building ||', ')|| DECODE(wk_street,'','',wk_street||', ')||decode(wk_number||wk_building||wk_street,'','',chr(10))||DECODE(wk_city,'','',wk_city||','||chr(10))||pk_common.fn_get_fmtd_adr(
                DECODE(wk_district,'','',wk_district||' ,')||DECODE(wk_cust_province,'','',wk_cust_province||' ,')||DECODE(wk_cust_country,'','',wk_cust_country)))
           FROM DUAL;*/

BEGIN

    SELECT cus_code INTO wk_cust_code
    FROM (SELECT pol_cus_code AS cus_code FROM
    uw_x_policies WHERE pol_seq_no=p_pol_seq
    UNION
    SELECT qot_cus_code AS cus_code FROM
    uw_t_quotations WHERE qot_seq_no=p_pol_seq);

    WkAddress :=  pk_common.fn_get_cus_addr(wk_cust_code);

    WkAddress := replace(WkAddress, chr(46)||chr(44)||chr(10),''); -- ADDED BY PRIYAN N. FERNANDO on 06-JUN-2017 to remove lines with a dot and a comma
    /*pk_uw_m_customers.pu_get_address_as_location1(  wk_cust_code,
                                                    wk_cust_country,
                                                    wk_cust_prvcode,
                                                    wk_dist_code,
                                                    wk_post_code,
                                                    wk_address,
                                                    wk_city,
                                                    wk_street,
                                                    wk_building,
                                                    wk_number);

    wk_district := PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(wk_dist_code);
    wk_cust_province := PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(wk_cust_prvcode);

    IF wk_building IS NULL THEN
        wk_num_build := wk_number;
    ELSE
        wk_num_build := wk_number||' ,'|| wk_building;
    END IF;

    OPEN cur_get_adr_fmtd;
    FETCH cur_get_adr_fmtd INTO WkAddress;
    CLOSE cur_get_adr_fmtd;
*/
  RETURN upper(WkAddress);

END fn_get_pol_cus_addr_str;

PROCEDURE pr_err_log ( p_desc IN uw_t_log.log_desc%TYPE) IS

    PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

    INSERT INTO uw_t_log(log_time,log_desc)
    VALUES(SYSDATE,p_desc);
    COMMIT;

END pr_err_log;

PROCEDURE pr_err_log ( p_desc IN uw_t_log.log_desc%TYPE,p_long IN uw_t_log.log_long%TYPE) IS

    PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

    INSERT INTO uw_t_log
    VALUES(SYSDATE,p_desc,p_long);
    COMMIT;

END pr_err_log;

FUNCTION fn_get_cvr_issue_date ( p_pol_seq uw_t_policies.pol_seq_no%TYPE) RETURN DATE IS

BEGIN

    RETURN trunc(SYSDATE);


END fn_get_cvr_issue_date;


FUNCTION fn_get_pol_cus_addr_fmt ( p_cus_code uw_m_customers.cus_code%TYPE) RETURN VARCHAR2 IS


WkAddress                  VARCHAR2(2000);
wk_num_build               VARCHAR2(100);
wk_cust_country            sm_m_geoarea_paramln.gpl_desc%TYPE; -- added for FORTE UW-SRS #88
wk_cust_prvcode            uw_m_cust_addresses.adr_province%TYPE;
wk_cust_province           sm_m_geoarea_paramln.gpl_desc%TYPE;
wk_dist_code               uw_m_cust_addresses.adr_district%TYPE;
wk_district                sm_m_geoarea_paramln.gpl_desc%TYPE;
wk_post_code               uw_m_customers.cus_postal_code%TYPE;
wk_address                 uw_r_locations.loc_description%TYPE;
wk_city                    uw_m_customers.cus_city%TYPE;
wk_street                  uw_m_customers.cus_street%TYPE;
wk_building                uw_m_customers.cus_building%TYPE;
wk_number                  uw_m_customers.cus_number%TYPE;
wk_cust_code               uw_m_customers.cus_code%TYPE;


    CURSOR cur_get_adr_fmtd IS
         SELECT DECODE(wk_number,'','',wk_number ||', ')||TRIM(DECODE(wk_building,'','',wk_building ||', ')|| DECODE(wk_street,'','',wk_street||', ')||decode(wk_number||wk_building||wk_street,'','',chr(10))||pk_common.fn_get_fmtd_adr(DECODE(wk_city,'','',wk_city||' ,')||
                DECODE(wk_district,'','',wk_district||' ,')||DECODE(wk_cust_province,'','',wk_cust_province||' ,')||DECODE(wk_cust_country,'','',wk_cust_country)))
           FROM DUAL;

BEGIN

    pk_uw_m_customers.pu_get_address_as_location1(  p_cus_code,
                                                    wk_cust_country,
                                                    wk_cust_prvcode,
                                                    wk_dist_code,
                                                    wk_post_code,
                                                    wk_address,
                                                    wk_city,
                                                    wk_street,
                                                    wk_building,
                                                    wk_number);

    wk_district      := PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(wk_dist_code);
    wk_cust_province := PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(wk_cust_prvcode);

    IF wk_building IS NULL THEN
        wk_num_build := wk_number;
    ELSE
        wk_num_build := wk_number||' ,'|| wk_building;
    END IF;

  OPEN cur_get_adr_fmtd;
  FETCH cur_get_adr_fmtd INTO WkAddress;
  CLOSE cur_get_adr_fmtd;

  RETURN WkAddress;

END fn_get_pol_cus_addr_fmt;

--------------------------------------------------------------------------------
-- Developer : Priyan Fernando
-- Date      : 26/09/2015
-- Purpose   : insert data to x tables for Policies
--------------------------------------------------------------------------------
-- Modified  : Lahiru [10/02/17 - data duplicating error fixed
--------------------------------------------------------------------------------

PROCEDURE pu_wrapper_simulator ( wkpolseq      IN  uw_t_policies.pol_seq_no%TYPE,
                                 wknewpolseq   OUT uw_t_policies.pol_seq_no%TYPE,
                                 wksessionid   OUT NUMBER) AS

    p_int       NUMBER;
    p_pol_seq   uw_t_policies.pol_seq_no%TYPE;
    clmstr      VARCHAR2(20000);
    qrystr      VARCHAR2(20000);
    pol_seq_col VARCHAR2(1000);


    CURSOR cur1 IS
        SELECT substr(table_name,6) table_name FROM all_tables a
        WHERE  table_name  LIKE 'UW_T_POL%' OR table_name LIKE 'UW_X_POL%'
        GROUP BY substr(table_name,6)
        HAVING COUNT(*) = 2;


    CURSOR cur2(tabn all_tables.table_name%TYPE) IS
        SELECT COLUMN_NAME
        FROM all_tab_columns
        WHERE table_name = 'UW_T_'||tabn OR table_name = 'UW_X_'||tabn
        GROUP BY COLUMN_NAME
        HAVING COUNT(*) =2;


    CURSOR cur3(tabn all_tables.table_name%TYPE) IS
        SELECT MAX(column_name) clmn_name FROM all_tab_columns
        WHERE  table_name = 'UW_T_'||tabn AND column_name LIKE '%POL_SEQ%' AND column_name NOT LIKE '%PREV%'
        AND column_name IN (SELECT MAX(column_name) clmn_name FROM all_tab_columns
        WHERE  table_name = 'UW_X_'||tabn AND column_name LIKE '%POL_SEQ%' AND column_name NOT LIKE '%PREV%');

BEGIN

    wknewpolseq := pk_uw_wrapper.fn_gen_x_polseqno('101');
    wksessionid := pk_sm_common.fn_session_id;

    p_int := 1;

    FOR tab1 IN cur1 LOOP
        clmstr := NULL;
        OPEN cur3(tab1.table_name);
        FETCH cur3 INTO pol_seq_col;

            FOR col1 IN cur2(tab1.table_name) LOOP

                IF col1.column_name <> pol_seq_col THEN

                    IF clmstr IS NULL THEN
                        clmstr := col1.column_name;
                    ELSE
                        clmstr := clmstr||','||col1.column_name;
                    END IF;

                END IF;

            END LOOP;

            IF cur3%notfound OR pol_seq_col IS NULL THEN
                qrystr := NULL;
            ELSIF tab1.table_name = 'POLICIES' THEN
                qrystr := 'INSERT INTO UW_X_'||tab1.table_name||'('||clmstr||',POL_SESSION_ID,POL_SEQ_NO,POL_POL_SEQ_NO'||')'||' SELECT '||clmstr||','||wksessionid||','||wknewpolseq||','''||wkpolseq||''' FROM '||'UW_T_'||tab1.table_name||' WHERE '||pol_seq_col||'='''||wkpolseq||'''';
                EXECUTE IMMEDIATE qrystr;
            ELSE
                qrystr := 'INSERT INTO UW_X_'||tab1.table_name||'('||clmstr||','||pol_seq_col||')'||' SELECT '||clmstr||','''||wknewpolseq||''''||' FROM '||'UW_T_'||tab1.table_name||' WHERE '||pol_seq_col||'='''||wkpolseq||'''';
                EXECUTE IMMEDIATE qrystr;
            END IF;

        CLOSE cur3;

      --  pk_uw_schedules.pr_err_log(wkpolseq||' '||p_int,qrystr);
          p_int := p_int+1;


    END LOOP;

END pu_wrapper_simulator;

--------------------------------------------------------------------------------
-- Developer : Priyan Fernando
-- Date      : 26/09/2015
-- Purpose   : insert data to x tables for quotations
--------------------------------------------------------------------------------
-- Modified  : Lahiru [10/02/17 - data duplicating error fixed
--------------------------------------------------------------------------------

PROCEDURE pu_wrapper_qsimulator( wkqotseq      IN  uw_t_quotations.qot_seq_no%TYPE,
                                 wknewqotseq   OUT uw_t_quotations.qot_seq_no%TYPE,
                                 wksessionid   OUT NUMBER) AS

    q_int           NUMBER;
    q_qot_seq       uw_t_policies.pol_seq_no%TYPE;
    clmstr          VARCHAR2(32000);
    qrystr          VARCHAR2(32000);
    finstr          VARCHAR2(32000);
    qot_seq_col     VARCHAR2(1000);
    pol_x_seq_col   VARCHAR2(1000);
    wkpolxtable     all_tables.table_name%TYPE;
    wkdatatype      all_tab_columns.data_type%TYPE;
    clmcolval       VARCHAR2(500 CHAR);
    qrycolval       VARCHAR2(500 CHAR);
    wkcolval        VARCHAR2(1 CHAR); --(all_cons_columns%type;

    CURSOR cur1 IS
        SELECT DISTINCT qot_table_name
        FROM uw_r_qot_to_pol_x;

    CURSOR cur2(p_tab_name1 uw_r_qot_to_pol_x.qot_table_name%TYPE) IS
        SELECT DISTINCT pol_x_table_name
        FROM uw_r_qot_to_pol_x
        WHERE qot_table_name = p_tab_name1;

    CURSOR cur3(p_tab_name2 uw_r_qot_to_pol_x.qot_table_name%TYPE) IS
        SELECT qot_column_name, pol_x_column_name
        FROM uw_r_qot_to_pol_x
        WHERE qot_table_name = p_tab_name2
        AND pol_x_column_name IS NOT NULL;

    CURSOR cur4(p_tab_name3 uw_r_qot_to_pol_x.qot_table_name%TYPE) IS
        SELECT MAX(column_name) clmn_name
        FROM all_tab_columns
        WHERE table_name =p_tab_name3
        AND column_name LIKE '%QOT_SEQ_NO%'
        AND column_name NOT LIKE '%PREV%';

    CURSOR cur5(p_tab_name4 uw_r_qot_to_pol_x.qot_table_name%TYPE) IS
        SELECT MAX(column_name) clmn_name
        FROM all_tab_columns
        WHERE table_name =p_tab_name4
        AND column_name LIKE '%POL_SEQ_NO%'
        AND column_name NOT LIKE '%PREV%';

    CURSOR cur6 IS SELECT column_name
        FROM all_cons_columns
        WHERE constraint_name IN (SELECT constraint_name
        FROM all_constraints
        WHERE table_name = 'UW_X_POLICIES'AND constraint_type = 'C');

    CURSOR cur7(tab_name all_tab_columns.table_name%TYPE,col_name all_tab_columns.column_name%TYPE) IS
        SELECT  data_type
        FROM all_tab_columns
        WHERE table_name = tab_name
        AND column_name = col_name;

    CURSOR cur8(tab_name all_tab_columns.table_name%TYPE,col_name all_tab_columns.column_name%TYPE) IS
        SELECT  data_type FROM all_tab_columns
        WHERE table_name = tab_name
        AND column_name = col_name
        AND column_name IN (SELECT column_name
                            FROM all_constraints
                            WHERE table_name = tab_name
                            AND constraint_type = 'C');

    CURSOR cur9(colval all_cons_columns.column_name%TYPE) IS
        SELECT 'x'
        FROM all_constraints a,all_cons_columns b
        WHERE  a.constraint_name = b.constraint_name
        AND  a.table_name = 'UW_X_POLICIES'
        AND a.constraint_type = 'C'
        AND b.column_name = colval;

BEGIN

    wknewqotseq := pk_uw_wrapper.fn_gen_x_polseqno('101');
    wksessionid := pk_sm_common.fn_session_id;

    q_int := 1;

    FOR tab1 IN cur1 LOOP
        clmstr := NULL;

        OPEN cur2(tab1.qot_table_name);
        FETCH cur2 INTO wkpolxtable;
        CLOSE cur2;

        OPEN cur4(tab1.qot_table_name);
        FETCH cur4 INTO qot_seq_col;

        OPEN cur5(wkpolxtable);
        FETCH cur5 INTO pol_x_seq_col;
        CLOSE cur5;


        FOR col1 IN cur3(tab1.qot_table_name) LOOP
            IF col1.qot_column_name<> qot_seq_col AND col1.pol_x_column_name <> pol_x_seq_col AND NOT (tab1.qot_table_name='UW_T_QUOTATIONS' AND col1.pol_x_column_name IN ('POL_POL_SEQ_NO', 'POL_SEQ_NO','POL_ANY_ENDORSEMENTS','POL_PROPOSAL_NO')) THEN

               clmcolval := col1.pol_x_column_name;
               qrycolval := col1.qot_column_name;

               OPEN cur8(wkpolxtable,col1.pol_x_column_name);
               FETCH cur8 INTO wkdatatype;
               IF cur8%notfound THEN
                    wkdatatype := NULL;
               END IF;
               CLOSE cur8;

               IF tab1.qot_table_name = 'UW_T_QUOTATIONS' THEN
               OPEN cur9(clmcolval);
               FETCH cur9 INTO wkcolval;
               IF cur9%FOUND  THEN
                   IF wkdatatype = 'VARCHAR2' THEN
                        dbms_output.put_line(tab1.qot_table_name||' '||'VARCHAR2'||' '||qrycolval);
                        qrycolval := 'NVL('||qrycolval||',''y'')';
                   ELSIF
                      wkdatatype = 'DATE' THEN
                        qrycolval := 'NVL('||qrycolval||',''12-Dec-12'')';
                   ELSIF
                       wkdatatype = 'NUMBER' THEN
                        qrycolval := 'NVL('||qrycolval||',0)';
                   ELSE
                        NULL;
                   END IF;
               END IF;
               CLOSE cur9;
            END IF;


                IF clmstr IS NULL THEN
                    clmstr := clmcolval;
                    qrystr := qrycolval;
                ELSE
                    clmstr := clmstr||','||clmcolval;
                    qrystr := qrystr||','||qrycolval;
                END IF;

          END IF;
        END LOOP;

        FOR rec3 IN cur6 LOOP

            IF tab1.qot_table_name = 'UW_T_QUOTATIONS' AND instr(clmstr,rec3.column_name)=0 AND rec3.column_name NOT IN ('POL_SESSION_ID','POL_SEQ_NO','POL_POL_SEQ_NO')THEN
                clmstr := clmstr||','||rec3.column_name;
                qrystr := qrystr||','||'''x''';
            END IF;

        END LOOP;

            IF cur4%notfound OR qot_seq_col IS NULL THEN
                finstr:= NULL;
            ELSIF tab1.qot_table_name = 'UW_T_QUOTATIONS' THEN
                finstr := 'INSERT INTO '||wkpolxtable||'('||clmstr||',POL_SESSION_ID,POL_SEQ_NO,POL_POL_SEQ_NO'||')'||' SELECT '||qrystr||','||wksessionid||','||wknewqotseq||','''||wkqotseq||''' FROM '||tab1.qot_table_name||' WHERE '||qot_seq_col||'='''||wkqotseq||'''';
                EXECUTE IMMEDIATE finstr;
            ELSE
                finstr := 'INSERT INTO '||wkpolxtable||'('||clmstr||','||pol_x_seq_col||')'||' SELECT '||qrystr||','''||wknewqotseq||''''||' FROM '||tab1.qot_table_name||' WHERE '||qot_seq_col||'='''||wkqotseq||'''';
                EXECUTE IMMEDIATE finstr;
            END IF;

        CLOSE cur4;
        q_int := q_int+1;

    END LOOP;

END pu_wrapper_qsimulator;


--------------------------------------------------------------------------------
-- Developer : Charitha Wijenayake
-- Date      : 04/10/2015
-- Purpose   : Get vehicle no
--------------------------------------------------------------------------------
FUNCTION FN_GET_VEHICLE_NO( WK_DESC     IN      uw_t_pol_risks.prs_name%TYPE,
                            WK_VALUE    IN      NUMBER)
                             RETURN VARCHAR2 IS



    Wk_STRING   VARCHAR2(500);
    wk_count    NUMBER;
    wk_cont     NUMBER;

  BEGIN
        WK_COUNT := 1;

    IF instr(WK_DESC, ' ', 1, WK_COUNT) > 0 THEN

        LOOP
            WK_CONT := instr(WK_DESC, ' ', 1, WK_COUNT);

            IF WK_CONT = 0 THEN
                IF length(WK_DESC) < WK_VALUE OR length(WK_DESC) = WK_VALUE THEN
                    Wk_STRING := WK_DESC;
                    EXIT;
                ELSE
                    EXIT;
                END IF;

            ELSIF WK_CONT < WK_VALUE OR WK_CONT = WK_VALUE THEN
                Wk_STRING := SUBSTR(WK_DESC, 1,WK_CONT );
                WK_COUNT := WK_COUNT + 1;
            ELSE
                EXIT;
            END IF;

         END LOOP;

    ELSE
        Wk_STRING := WK_DESC;
    END IF;

        Wk_STRING := Wk_STRING || chr(10)||SUBSTR(WK_DESC, (length(Wk_STRING)+1));

     RETURN Wk_STRING;


  END FN_GET_VEHICLE_NO;

--------------------------------------------------------------------------------
-- Developer : Priyan Fernando
-- Date      : 04/10/2015
-- Purpose   : Get Item No related info
--------------------------------------------------------------------------------
FUNCTION FN_GET_ITM_DESC(wkpolseqno uw_t_policies.pol_seq_no%TYPE,
                         wkitmno uw_t_pol_information.pin_number_value%TYPE,
                         wkflag VARCHAR2)
                             RETURN VARCHAR2 IS

    insured_desc  uw_t_pol_information.pin_char_value%TYPE;
    amt_generated uw_t_pol_information.pin_char_value%TYPE;

    CURSOR cur_1 IS
        SELECT
        pk_uw_x_pol_information.fn_get_risk_common_info(prs_plc_pol_seq_no,prs_plc_seq_no,prs_seq_no,'INSURED DESCRIPTION','X') INSURED_DESCRIPTION,
        pk_uw_x_pol_information.fn_get_risk_common_info(prs_plc_pol_seq_no,prs_plc_seq_no,prs_seq_no,'AMOUNT GUARANTEED','X') AMOUNT_GUARANTED
        FROM UW_R_SECTIONS,UW_X_POL_RISKS
        WHERE SEC_CODE = PRS_PSC_SEC_CODE
        AND PRS_PSC_SEC_CODE = PK_UW_P_SYS_PARAMS.FN_GET_ANY_CHR_VALUE(98)
        AND PRS_PLC_POL_SEQ_NO = wkpolseqno
        AND pk_uw_x_pol_information.fn_get_risk_common_info(prs_plc_pol_seq_no,prs_plc_seq_no,prs_seq_no,'ITEM NO.','X') = wkitmno
        ORDER BY prs_r_seq ASC;

BEGIN

    FOR rec IN cur_1 LOOP
        IF insured_desc IS NULL THEN
            insured_desc := rec.INSURED_DESCRIPTION;
        END IF;

        IF amt_generated IS NULL THEN
            amt_generated := rec.AMOUNT_GUARANTED;
        END IF;

        IF insured_desc IS NOT NULL AND amt_generated IS NOT NULL THEN
            EXIT;
        END IF;

    END LOOP;

    IF wkflag ='I' THEN
        RETURN insured_desc;
    ELSIF wkflag ='A'THEN
        RETURN amt_generated;
    END IF;

END FN_GET_ITM_DESC;

--------------------------------------------------------------------------------
-- Developer : lahiru Madushan
-- Date      : 07/10/2015
-- Purpose   : Get Item No related info For Quotation
--------------------------------------------------------------------------------
FUNCTION FN_GET_ITM_DESC_QOT(WKQOTSEQNO IN uw_t_quotations.qot_seq_no%TYPE,
                             WKITMNO    IN uw_t_quot_information.qin_number_value%TYPE,
                             WKFLAG     IN VARCHAR2) RETURN VARCHAR2 IS

  insured_desc  uw_t_quot_information.qin_char_value%TYPE;
  amt_generated uw_t_quot_information.qin_char_value%TYPE;

  CURSOR cur_1 IS
      SELECT pk_uw_t_quot_information.fn_get_risk_common_info(qrs_qlc_qot_seq_no,qrs_qlc_seq_no,qrs_seq_no,'INSURED DESCRIPTION') INSURED_DESCRIPTION,
             pk_uw_t_quot_information.fn_get_risk_common_info(qrs_qlc_qot_seq_no,qrs_qlc_seq_no,qrs_seq_no,'AMOUNT GUARANTEED') AMOUNT_GUARANTED
      FROM UW_R_SECTIONS,UW_T_QUOT_RISKS
      WHERE SEC_CODE = QRS_PSC_SEC_CODE
      AND QRS_PSC_SEC_CODE = PK_UW_P_SYS_PARAMS.FN_GET_ANY_CHR_VALUE(98)
      AND qrs_qlc_qot_seq_no = WKQOTSEQNO
      AND pk_uw_t_quot_information.fn_get_risk_common_info(qrs_qlc_qot_seq_no,qrs_qlc_seq_no,qrs_seq_no,'ITEM NO.') = WKITMNO
      ORDER BY qrs_r_seq ASC;

  BEGIN

  FOR rec IN cur_1 LOOP

      IF insured_desc IS NULL THEN
          insured_desc := rec.INSURED_DESCRIPTION;
      END IF;

      IF amt_generated IS NULL THEN
          amt_generated := rec.AMOUNT_GUARANTED;
      END IF;

      IF insured_desc IS NOT NULL AND amt_generated IS NOT NULL THEN
          EXIT;
      END IF;

  END LOOP;

  IF WKFLAG ='I' THEN
      RETURN insured_desc;
  ELSIF WKFLAG ='A'THEN
      RETURN amt_generated;
  END IF;

END FN_GET_ITM_DESC_QOT;

--------------------------------------------------------------------------------
-- Developer : Chamara Morawatte
-- Date      : 08/10/2015
-- Purpose   : Get Additional Insured info
--------------------------------------------------------------------------------
FUNCTION FN_GET_ADDITIONAL_INSURED(wkpolseqno uw_t_policies.pol_seq_no%TYPE,
                                   wkcuscode  uw_t_policies.pol_cus_code%TYPE,
                                   wktype     VARCHAR2)
                                   RETURN VARCHAR2 IS

WkAddi_Insured uw_x_pol_common_information.pci_char_value%TYPE;

    CURSOR CUR_ADDI_INSURED IS
        SELECT pci_char_value
        FROM(
            SELECT pci_char_value
            FROM uw_x_pol_common_information
            WHERE UPPER(pci_description) = 'ADDITIONAL INSURED'
            AND pci_pol_seq_no = wkpolseqno
            UNION ALL
            SELECT qci_char_value
            FROM uw_t_quot_common_information
            WHERE UPPER(qci_description) = 'ADDITIONAL INSURED'
            AND qci_qot_seq_no = wkpolseqno
            UNION ALL
            SELECT pci_char_value
            FROM uw_t_pol_common_information
            WHERE UPPER(pci_description) = 'ADDITIONAL INSURED'
            AND pci_pol_seq_no = wkpolseqno)
        WHERE pci_char_value IS NOT NULL;

BEGIN

    WkAddi_Insured := '';

    OPEN CUR_ADDI_INSURED;
    FETCH CUR_ADDI_INSURED INTO WkAddi_Insured;

    IF CUR_ADDI_INSURED%NOTFOUND THEN
       WkAddi_Insured := pk_uw_m_customers.fn_get_cust_name_full(wkcuscode);
    END IF;

    CLOSE CUR_ADDI_INSURED;

    RETURN WkAddi_Insured;
END;

--------------------------------------------------------------------------------
-- Developer : Chathuri Nisansala
-- Date      : 11/10/2015
-- Purpose   :
--------------------------------------------------------------------------------
FUNCTION FN_GET_MIN_PERCENTAGE(wkpolseqno uw_t_policies.pol_seq_no%TYPE,
                               wkRiskSeq  uw_t_pol_perils.ppr_prs_seq_no%TYPE,
                               wkLocSeq   uw_t_pol_perils.ppr_prs_plc_seq_no%TYPE,
                               wkPrdCode  VARCHAR2 )RETURN VARCHAR2 IS

    Wk_Perc uw_t_pol_perils.ppr_percentage%TYPE;

    CURSOR Cur_Perc IS
        SELECT  NVL(ppr_percentage,0)
          FROM uw_x_pol_perils a,uw_r_perils d,uw_m_prod_perils e
         WHERE a.ppr_per_prl_code = d.prl_code
           AND a.ppr_per_prl_code = e.ppl_per_prl_code
           AND ppl_prc_prd_code = wkPrdCode
           AND ppr_prs_plc_pol_seq_no = wkpolseqno
           AND ppr_prs_plc_seq_no = wkRiskSeq
           AND ppr_prs_seq_no = wkLocSeq
           AND ppl_p_seq IN  (SELECT MIN(ppl_p_seq)
                                FROM uw_x_pol_perils a,uw_r_perils d,uw_m_prod_perils e
                               WHERE a.ppr_per_prl_code = d.prl_code
                                 AND a.ppr_per_prl_code = e.ppl_per_prl_code
                                 AND ppl_prc_prd_code = wkPrdCode
                                 AND ppr_prs_plc_pol_seq_no = wkpolseqno
                                 AND ppr_prs_plc_seq_no = wkRiskSeq
                                 AND ppr_prs_seq_no = wkLocSeq);

BEGIN

    Wk_Perc := 0;

    OPEN Cur_Perc;
    FETCH Cur_Perc INTO Wk_Perc;
    CLOSE Cur_Perc;

    RETURN Wk_Perc;
END;

--------------------------------------------------------------------------------
-- Developer : Chathuri Nisansala
-- Date      : 28/10/2015
-- Purpose   :
--------------------------------------------------------------------------------
FUNCTION FN_GET_MIN_QOT_PERCENT(wkQotseqno uw_t_policies.pol_seq_no%TYPE,
                               wkRiskSeq   uw_t_pol_perils.ppr_prs_seq_no%TYPE,
                               wkLocSeq    uw_t_pol_perils.ppr_prs_plc_seq_no%TYPE,
                               wkPrdCode   VARCHAR2 )RETURN VARCHAR2 IS

    Wk_Perc uw_t_pol_perils.ppr_percentage%TYPE;

    CURSOR Cur_Perc IS
        SELECT  NVL(qpr_percentage,0)
          FROM uw_t_quot_perils a,uw_r_perils d,uw_m_prod_perils e
         WHERE a.qpr_per_prl_code = d.prl_code
           AND a.qpr_per_prl_code = e.ppl_per_prl_code
           AND ppl_prc_prd_code = wkPrdCode
           AND qpr_qrs_qlc_qot_seq_no = wkQotseqno
           AND qpr_qrs_qlc_seq_no = wkRiskSeq
           AND qpr_qrs_seq_no = wkLocSeq
           AND ppl_p_seq IN  (SELECT MIN(ppl_p_seq)
                                FROM uw_t_quot_perils a,uw_r_perils d,uw_m_prod_perils e
                               WHERE a.qpr_per_prl_code = d.prl_code
                                 AND a.qpr_per_prl_code = e.ppl_per_prl_code
                                 AND ppl_prc_prd_code = wkPrdCode
                                 AND qpr_qrs_qlc_qot_seq_no = wkQotseqno
                                 AND qpr_qrs_qlc_seq_no = wkRiskSeq
                                 AND qpr_qrs_seq_no = wkLocSeq);

BEGIN

    Wk_Perc := 0;

    OPEN Cur_Perc;
    FETCH Cur_Perc INTO Wk_Perc;
    CLOSE Cur_Perc;

    RETURN Wk_Perc;
END;
--------------------------------------------------------------------------------
-- Developer : Priyan Fernando
-- Date      : 26/09/2015
-- Purpose   : return customer address for renewal notices
--------------------------------------------------------------------------------
-- Modified  : Lahiru [20/02/17 - change address format (get address from  pkg pk_common.fn_get_cus_addr)
--------------------------------------------------------------------------------
FUNCTION fn_get_rennot_cus_addr(p_pol_seq uw_t_policies.pol_seq_no%TYPE) RETURN VARCHAR2 IS


    WkAddress                  VARCHAR2(2000);
    wk_cust_code               uw_m_customers.cus_code%TYPE;
    /*wk_cust_country            sm_m_geoarea_paramln.gpl_desc%TYPE; -- added for FORTE UW-SRS #88
    wk_cust_prvcode            uw_m_cust_addresses.adr_province%TYPE;
    wk_cust_province           sm_m_geoarea_paramln.gpl_desc%TYPE;
    wk_dist_code               uw_m_cust_addresses.adr_district%TYPE;
    wk_district                sm_m_geoarea_paramln.gpl_desc%TYPE;
    wk_post_code               uw_m_customers.cus_postal_code%TYPE;
    wk_address                 uw_r_locations.loc_description%TYPE;
    wk_city                    uw_m_customers.cus_city%TYPE;
    wk_street                  uw_m_customers.cus_street%TYPE;
    wk_building                uw_m_customers.cus_building%TYPE;
    wk_number                  uw_m_customers.cus_number%TYPE;
    wk_num_build               VARCHAR2(100);



    CURSOR cur_get_adr_fmtd IS
            SELECT DECODE(wk_number,'','',wk_number ||', ')||TRIM(DECODE(wk_building,'','',wk_building ||', ')|| DECODE(wk_street,'','',wk_street||', ')||decode(wk_number||wk_building||wk_street,'','',chr(10))||DECODE(wk_city,'','',wk_city||','||chr(10))||pk_common.fn_get_fmtd_adr(
                DECODE(wk_district,'','',wk_district||' ,')||DECODE(wk_cust_province,'','',wk_cust_province||' ,')||DECODE(wk_cust_country,'','',wk_cust_country)))
           FROM DUAL;
*/
BEGIN


    SELECT cus_code INTO wk_cust_code
    FROM (SELECT pol_cus_code AS cus_code FROM
    uw_t_policies WHERE pol_seq_no=p_pol_seq
    UNION
    SELECT qot_cus_code AS cus_code FROM
    uw_t_quotations WHERE qot_seq_no=p_pol_seq);

     WkAddress :=  pk_common.fn_get_cus_addr(wk_cust_code);
     /*
    pk_uw_m_customers.pu_get_address_as_location1(wk_cust_code,wk_cust_country,wk_cust_prvcode,wk_dist_code,
                                                  wk_post_code,wk_address,wk_city,wk_street,wk_building, wk_number);

    wk_district := PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(wk_dist_code);
    wk_cust_province := PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(wk_cust_prvcode);

    IF wk_building IS NULL THEN
        wk_num_build := wk_number;
    ELSE
        wk_num_build := wk_number||' ,'|| wk_building;
    END IF;


  OPEN cur_get_adr_fmtd;
  FETCH cur_get_adr_fmtd INTO WkAddress;
  CLOSE cur_get_adr_fmtd;
*/
  RETURN WkAddress;

END fn_get_rennot_cus_addr;

--------------------------------------------------------------------------------
-- Developer : Chathuri Nisansala
-- Date      : 12/11/2015
-- Purpose   : To get member category for EMC Product
--------------------------------------------------------------------------------

FUNCTION fn_get_mem_cat( wk_Prs_seq_no      IN UW_T_POL_RISKS.prs_r_seq%TYPE,
                         wk_prs_pol_seq     IN UW_T_POL_RISKS.prs_plc_pol_seq_no%TYPE)RETURN  VARCHAR2 IS

wkSpcFnd    VARCHAR2(1);
wkChldFnd   VARCHAR2(1);
wkCategory  VARCHAR2(100);

CURSOR cur_get_rsk IS
    SELECT a.prs_r_seq,
    (CASE WHEN val IS NULL THEN 'EMPLOYEE ONLY' ELSE 'EMPLOYEES AND DEPENDANT ONLY' END)EMP_TYPE FROM
    (SELECT *
    FROM UW_X_POL_RISKS
    WHERE prs_plc_pol_seq_no = wk_prs_pol_seq
    AND prs_relationship_seq IS NULL
    AND prs_seq_no = wk_Prs_seq_no) a,
    (SELECT prs_relationship_seq,COUNT (*) val
    FROM UW_X_POL_RISKS
    WHERE prs_plc_pol_seq_no = wk_prs_pol_seq
    AND prs_relationship_seq IS NOT NULL
    GROUP BY prs_relationship_seq) b
    WHERE a.prs_r_seq=b.prs_relationship_seq(+);


BEGIN

    wkSpcFnd    := 'N';
    wkChldFnd   := 'N';

    FOR recs IN cur_get_rsk LOOP

    wkCategory := recs.EMP_TYPE;


    END LOOP;


    RETURN wkCategory;
END;

--------------------------------------------------------------------------------
-- Developer : Lahiru Madushan
-- Date      : 28/06/2016
-- Purpose   : To get member category for EMC Product for Policy schedule
--------------------------------------------------------------------------------
    FUNCTION fn_get_mem_cat_emc( wk_Prs_seq_no      IN UW_T_POL_RISKS.prs_r_seq%TYPE,
                                 wk_prs_pol_seq     IN UW_T_POL_RISKS.prs_plc_pol_seq_no%TYPE)RETURN  VARCHAR2 IS

    wkSpcFnd    VARCHAR2(1);
    wkChldFnd   VARCHAR2(1);
    wkCategory  VARCHAR2(100);

        CURSOR cur_get_rsk IS
            SELECT a.prs_r_seq,
            (CASE WHEN val IS NULL THEN 'EMPLOYEE ONLY' ELSE 'EMPLOYEES AND DEPENDANT ONLY' END)EMP_TYPE FROM
            (SELECT *
            FROM UW_X_POL_RISKS
            WHERE prs_plc_pol_seq_no = wk_prs_pol_seq
            AND prs_relationship_seq IS NULL
            AND prs_r_seq = wk_Prs_seq_no) a,
            (SELECT prs_relationship_seq, SUM(decode(prs_relationship_type,'SPOUSE',9999,'CHILDREN',1,'DAUGHTER',1,'CHILD',1)) val
            FROM UW_X_POL_RISKS
            WHERE prs_plc_pol_seq_no = wk_prs_pol_seq
            AND prs_relationship_seq IS NOT NULL
            GROUP BY prs_relationship_seq) b
            WHERE a.prs_r_seq=b.prs_relationship_seq(+);


    BEGIN

        wkSpcFnd    := 'N';
        wkChldFnd   := 'N';

        FOR recs IN cur_get_rsk LOOP

        wkCategory := recs.EMP_TYPE;

        END LOOP;

        RETURN wkCategory;

    END;
--------------------------------------------------------------------------------
-- Developer : lahiru Madushan
-- Date      : 08/02/2016
-- Purpose   : Get situation of risk for  Renewal Notice
--------------------------------------------------------------------------------
    FUNCTION fn_get_rennot_situ_risk(p_pol_seq uw_t_policies.pol_seq_no%TYPE) RETURN VARCHAR2 IS


        WkAddress           VARCHAR2(4000);
        wk_num_build        VARCHAR2(100);
        wk_cust_country     sm_m_geoarea_paramln.gpl_desc%TYPE;
        wk_cust_prvcode     uw_m_cust_addresses.adr_province%TYPE;
        wk_cust_province    sm_m_geoarea_paramln.gpl_desc%TYPE;
        wk_dist_code        uw_m_cust_addresses.adr_district%TYPE;
        wk_district         sm_m_geoarea_paramln.gpl_desc%TYPE;
        wk_post_code        uw_m_customers.cus_postal_code%TYPE;
        wk_address          uw_r_locations.loc_description%TYPE;
        wk_city             uw_m_customers.cus_city%TYPE;
        wk_street           uw_m_customers.cus_street%TYPE;
        wk_building         uw_m_customers.cus_building%TYPE;
        wk_number           uw_m_customers.cus_number%TYPE;
        wk_cust_code        uw_m_customers.cus_code%TYPE;


        CURSOR cur_get_adr_fmtd IS
                SELECT DECODE(wk_number,'','',wk_number ||', ')||TRIM(DECODE(wk_building,'','',wk_building ||', ')|| DECODE(wk_street,'','',wk_street||', ')||decode(wk_number||wk_building||wk_street,'','')||DECODE(wk_city,'','',wk_city||',')||
                       DECODE(wk_district,'','',wk_district||' ,')||DECODE(wk_cust_province,'','',wk_cust_province||' ,')||DECODE(wk_cust_country,'','',wk_cust_country))
               FROM DUAL;

 BEGIN

    SELECT cus_code
    INTO wk_cust_code
    FROM (SELECT pol_cus_code AS cus_code
          FROM  uw_t_policies
          WHERE pol_seq_no=p_pol_seq
          UNION
          SELECT qot_cus_code AS cus_code
          FROM  uw_t_quotations
          WHERE qot_seq_no=p_pol_seq);

    pk_uw_m_customers.pu_get_address_as_location1(wk_cust_code,wk_cust_country,wk_cust_prvcode,wk_dist_code,
                                                  wk_post_code,wk_address,wk_city,wk_street,wk_building, wk_number);

    wk_district      := PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(wk_dist_code);
    wk_cust_province := PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(wk_cust_prvcode);

     IF wk_building IS NULL THEN
         wk_num_build := wk_number;
     ELSE
         wk_num_build := wk_number||' ,'|| wk_building;
     END IF;

   OPEN cur_get_adr_fmtd;
   FETCH cur_get_adr_fmtd INTO WkAddress;
   CLOSE cur_get_adr_fmtd;

   RETURN WkAddress;

 END ;

END pk_uw_schedules;
/
