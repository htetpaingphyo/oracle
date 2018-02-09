CREATE OR REPLACE PACKAGE BODY SICL.pk_uw_m_customers
IS
----------------------------------------------------------------
--Developer   :   Chandi Fernando
--Modified by : Gireesha Pinnagoda
--Date        :   08/05/2001
--Purpose     :   To populate the customer name
-----------------------------------------------------------------
   PROCEDURE pu_pop_cust_desc (
      cust_code                  IN uw_m_customers.cus_code%TYPE,
      cust_desc                  OUT VARCHAR2 )
   IS                                                            --changed the variable length due to a problem occured
      wk_cust_desc                  VARCHAR2(4000);

      --varchar2(1000) (changed the variable length due to a problem occured);
      CURSOR cur_pop_cust_desc
      IS
         SELECT  decode(cus_indv_other_names, null,cus_indv_surname,cus_indv_other_names||' '||cus_indv_surname)
           FROM uw_m_customers
          WHERE cus_type = 'I'
            AND cus_code = cust_code
         UNION
         SELECT TRIM(cus_corp_name)
           FROM uw_m_customers
          WHERE cus_type = 'C'
            AND cus_code = cust_code;
   BEGIN

     OPEN cur_pop_cust_desc;

      FETCH cur_pop_cust_desc
       INTO wk_cust_desc;

      IF cur_pop_cust_desc%FOUND THEN
         cust_desc        := wk_cust_desc;
      END IF;

      CLOSE cur_pop_cust_desc;

   END;

----------------------------------------------------------------
--Developer :   Suren Nanayakkara
--Date      :   22/05/2001
--Purpose   :   Return the customer address conbimed together to insert to the locations table
-----------------------------------------------------------------
   PROCEDURE pu_get_address_as_location (
      wk_cust_code               IN uw_m_customers.cus_code%TYPE,
      wk_cust_province           OUT uw_m_customers.cus_province%TYPE,
      wk_district                OUT uw_m_customers.cus_district%TYPE,
      wk_post_code               OUT uw_m_customers.cus_postal_code%TYPE,
      wk_address                 OUT uw_r_locations.loc_description%TYPE )
   IS
      CURSOR get_address
      IS
         SELECT    RTRIM ( cus_address_1 )
                || ' '
                || RTRIM ( cus_address_2 )
                || ' '
                || RTRIM ( cus_address_3 ),
                cus_province,
                cus_district,
                cus_postal_code
           FROM uw_m_customers
          WHERE cus_code = wk_cust_code;
   BEGIN
      OPEN get_address;

      FETCH get_address
       INTO wk_address,
            wk_cust_province,
            wk_district,
            wk_post_code;

      CLOSE get_address;
   END;                                                                       -- Function end FN_GET_ADDRESS_AS_LOCATION

----------------------------------------------------------------
--Developer :   Gireesha Pinnagoda
--Date      :   25/09/2003
--Purpose   :   Return the customer address conbimed together to insert to the locations table
-----------------------------------------------------------------
   PROCEDURE pu_get_address_as_location (
      wk_cust_code               IN uw_m_customers.cus_code%TYPE,
      wk_cust_province           OUT uw_m_customers.cus_province%TYPE,
      wk_district                OUT uw_m_customers.cus_district%TYPE,
      wk_post_code               OUT uw_m_customers.cus_postal_code%TYPE,
      wk_address                 OUT uw_r_locations.loc_description%TYPE,
      wk_city                    OUT uw_m_customers.cus_city%TYPE,
      wk_street                  OUT uw_m_customers.cus_street%TYPE,
      wk_building                OUT uw_m_customers.cus_building%TYPE,
      wk_number                  OUT uw_m_customers.cus_number%TYPE )
   IS
      CURSOR get_address
      IS
         SELECT cus_loc_description,
                cus_province,
                cus_district,
                cus_postal_code,
                cus_city,
                cus_street,
                cus_building,
                cus_number
           FROM uw_m_customers
          WHERE cus_code = wk_cust_code;

   BEGIN
      OPEN get_address;

      FETCH get_address
       INTO wk_address,
            wk_cust_province,
            wk_district,
            wk_post_code,
            wk_city,
            wk_street,
            wk_building,
            wk_number;

      CLOSE get_address;
   END;                                                                       -- Function end FN_GET_ADDRESS_AS_LOCATION
----------------------------------------------------------------
--Developer :   Gireesha Pinnagoda
--Date      :   26/10/2004
--Purpose   :   Return the customer address conbimed together to insert to the locations table
--Modified  :   Deshani 01/12/2014 for FORTE UW-SRS #88 address format
--              Number, Street, City [Sangkat], District [Khan], Province, Country
--Modified  : Nadeeshani [09/11/2015 - to fix numeric or value error in postal code]
-----------------------------------------------------------------
   PROCEDURE pu_get_address_as_location1 (
      wk_cust_code               IN uw_m_customers.cus_code%TYPE,
      wk_cust_country            OUT sm_m_geoarea_paramln.gpl_desc%TYPE, -- added for FORTE UW-SRS #88
      wk_cust_province           OUT uw_m_cust_addresses.adr_province%TYPE,
      wk_district                OUT uw_m_cust_addresses.adr_district%TYPE,
      --wk_post_code             OUT uw_m_customers.cus_postal_code%TYPE, --09/11/2015
      wk_post_code               OUT uw_m_cust_addresses.adr_postal_code%TYPE,--09/11/2015
      wk_address                 OUT uw_r_locations.loc_description%TYPE,
      wk_city                    OUT uw_m_customers.cus_city%TYPE,
      wk_street                  OUT uw_m_customers.cus_street%TYPE,
      wk_building                OUT uw_m_customers.cus_building%TYPE,
      wk_number                  OUT uw_m_customers.cus_number%TYPE )
   IS

      CURSOR get_address
      IS
         SELECT adr_loc_description,
                adr_province,
                adr_district,
                adr_postal_code,
                adr_city,
                adr_street,
                adr_building,
                adr_number
           FROM uw_m_cust_addresses
          WHERE adr_cus_code = wk_cust_code
            AND adr_default = 'Y';

      CURSOR cur_country(wk_postal_code SM_M_GEOAREA_DETAILS.SGD_GPL_CODE%TYPE) -- added for FORTE UW-SRS #88 (to get the country)
      IS
            SELECT  PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(SM_M_GEOAREA_DETAILS.SGD_GPL_DET_CODE) country
            FROM    SM_M_GEOAREA_DETAILS, SM_M_GEOAREA_PARAMLN, SM_M_GEOAREA_PARAM
            WHERE   SM_M_GEOAREA_DETAILS.SGD_GPL_CODE = SM_M_GEOAREA_PARAMLN.GPL_CODE
            AND     SM_M_GEOAREA_PARAMLN.GPL_SMG_CODE = SM_M_GEOAREA_PARAM.SMG_CODE
            AND     sgd_gpl_code = wk_postal_code
            AND     sgd_smg_code = (SELECT  smg_code
                                    FROM    SM_M_GEOAREA_PARAM
                                    WHERE   smg_des = 'COUNTRY');
   BEGIN
      OPEN get_address;

      FETCH get_address
       INTO wk_address,
            wk_cust_province,
            wk_district,
            wk_post_code,
            wk_city,
            wk_street,
            wk_building,
            wk_number;

      CLOSE get_address;

      OPEN  cur_country(wk_post_code);  -- added for FORTE UW-SRS #88
      FETCH cur_country INTO wk_cust_country;
      CLOSE cur_country;

      -- added for FORTE UW-SRS #88
      -- commented by deshani on 02/12/2014 as the returned address is used for inserting
      /*wk_address := wk_address||', '||PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(wk_district)
                    ||', '|| PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(wk_cust_province)
                    ||', '||wk_cust_country;*/

   END;                                                                       -- Function end FN_GET_ADDRESS_AS_LOCATION


----------------------------------------------------------------
--Developer :   Gireesha Pinnagoda
--Date      :   26/10/2004
--Purpose   :   Return the customer address conbimed together to insert to the locations table
--Modified  :   Deshani 01/12/2014 for FORTE UW-SRS #88 address format
--              Number, Street, City [Sangkat], District [Khan], Province, Country
--Modified  :   Nadeeshani [09/11/2015 - to fix numeric or value error in postal code]
--Modified  :   Induni [18/12/2016 - using a copy of above pu_get_address_as_location1; to map town or village tract & township
--                      in address for AMI - mapped on to fields eartqk & cyclone]
-----------------------------------------------------------------
   PROCEDURE pu_get_address_as_location1 (
      wk_cust_code               IN uw_m_customers.cus_code%TYPE,
      wk_cust_country            OUT sm_m_geoarea_paramln.gpl_desc%TYPE, -- added for FORTE UW-SRS #88
      wk_cust_province           OUT uw_m_cust_addresses.adr_province%TYPE,
      wk_district                OUT uw_m_cust_addresses.adr_district%TYPE,
      wk_town_level_1            OUT uw_m_cust_addresses.adr_earthqk%TYPE, -- AMI
      wk_town_level_2            OUT uw_m_cust_addresses.adr_cyclone%TYPE, -- AMI
      --wk_post_code             OUT uw_m_customers.cus_postal_code%TYPE, --09/11/2015
      wk_post_code               OUT uw_m_cust_addresses.adr_postal_code%TYPE,--09/11/2015
      wk_address                 OUT uw_r_locations.loc_description%TYPE,
      wk_city                    OUT uw_m_customers.cus_city%TYPE,
      wk_street                  OUT uw_m_customers.cus_street%TYPE,
      wk_building                OUT uw_m_customers.cus_building%TYPE,
      wk_number                  OUT uw_m_customers.cus_number%TYPE )
   IS

      CURSOR get_address
      IS
         SELECT adr_loc_description,
                adr_province,
                adr_district,
                adr_earthqk,
                adr_cyclone,
                adr_postal_code,
                adr_city,
                adr_street,
                adr_building,
                adr_number
           FROM uw_m_cust_addresses
          WHERE adr_cus_code = wk_cust_code
            AND adr_default = 'Y';

      CURSOR cur_country(wk_postal_code SM_M_GEOAREA_DETAILS.SGD_GPL_CODE%TYPE) -- added for FORTE UW-SRS #88 (to get the country)
      IS
            SELECT  PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(SM_M_GEOAREA_DETAILS.SGD_GPL_DET_CODE) country
            FROM    SM_M_GEOAREA_DETAILS, SM_M_GEOAREA_PARAMLN, SM_M_GEOAREA_PARAM
            WHERE   SM_M_GEOAREA_DETAILS.SGD_GPL_CODE = SM_M_GEOAREA_PARAMLN.GPL_CODE
            AND     SM_M_GEOAREA_PARAMLN.GPL_SMG_CODE = SM_M_GEOAREA_PARAM.SMG_CODE
            AND     sgd_gpl_code = wk_postal_code
            AND     sgd_smg_code = (SELECT  smg_code
                                    FROM    SM_M_GEOAREA_PARAM
                                    WHERE   smg_des = 'COUNTRY');
   BEGIN

      OPEN get_address;
      FETCH get_address
       INTO wk_address,
            wk_cust_province,
            wk_district,
            wk_town_level_1,
            wk_town_level_2,
            wk_post_code,
            wk_city,
            wk_street,
            wk_building,
            wk_number;
      CLOSE get_address;

      OPEN  cur_country(wk_post_code);  -- added for FORTE UW-SRS #88
      FETCH cur_country INTO wk_cust_country;
      CLOSE cur_country;

      -- added for FORTE UW-SRS #88
      -- commented by deshani on 02/12/2014 as the returned address is used for inserting
      /*wk_address := wk_address||', '||PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(wk_district)
                    ||', '|| PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(wk_cust_province)
                    ||', '||wk_cust_country;*/

   END;                                                                       -- Function end FN_GET_ADDRESS_AS_LOCATION



------------------------------------------------------------------------------
-- Person             Date        Comments
-- -----------------  ----------  ------------------------------------------
-- Chamila Nalaka    06/05/2002  Initial creation of the package.

   ---------------------------------------------------------------------------

   -- To check the cus nic no is duplicated in the table.
   FUNCTION fn_dup_cus_nic_no (
      nicno                      IN uw_m_customers.cus_indv_nic_no%TYPE )
      RETURN BOOLEAN
   IS
--
-- MODIFICATION HISTORY
-- Person               Date        Comments
-- ---------            ------      -------------------------------------------
-- Chamila Nalaka    06/05/2002   Initial development
      wk_count                      NUMBER;

      CURSOR cus
      IS
         SELECT COUNT ( * )
           FROM uw_m_customers
          WHERE uw_m_customers.cus_indv_nic_no = nicno;
   BEGIN
      OPEN cus;

      FETCH cus
       INTO wk_count;

      IF wk_count > 0 THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END;

     -- Function FN_DUP_CUS_NIC_NO
---------------------------------------------------------------------------

   -- To check the corporate customers is duplicated in the table.
   FUNCTION fn_dup_cor_customer (
      corcus                     IN uw_m_customers.cus_corp_name%TYPE )
      RETURN BOOLEAN
   IS
--
-- MODIFICATION HISTORY
-- Person             Date        Comments
-- -----------------  ----------  -------------------------------------------
-- Chamila Nalaka     08/05/2002  Initial development
      wk_count                      NUMBER;

      CURSOR cus
      IS
         SELECT COUNT ( * )
           FROM uw_m_customers
          WHERE uw_m_customers.cus_corp_name = corcus;
   BEGIN
      OPEN cus;

      FETCH cus
       INTO wk_count;

      IF wk_count > 0 THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END;                                                                                  -- Function FN_DUP_COR_CUSTOMER

---------------------------------------------------------------------------
-- To check the individual customers is duplicated in the table.
   FUNCTION fn_dup_ind_customer (
      custitl                    IN uw_m_customers.cus_indv_title%TYPE,
      cussur                     IN uw_m_customers.cus_indv_surname%TYPE,
      cusini                     IN uw_m_customers.cus_indv_initials%TYPE )
      RETURN BOOLEAN
   IS
      wk_count                      NUMBER;

      CURSOR cus
      IS
         SELECT COUNT ( * )
           FROM uw_m_customers
          WHERE uw_m_customers.cus_indv_title = custitl
            AND uw_m_customers.cus_indv_surname = cussur
            AND uw_m_customers.cus_indv_initials = cusini;
   BEGIN
      OPEN cus;

      FETCH cus
       INTO wk_count;

      IF wk_count > 0 THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END;

---------------------------------------------------------------------------

   -- To check the corporate customers reg no is duplicated in the table.
   FUNCTION fn_dup_cor_cus_reg_no (
      corcusreg                  IN uw_m_customers.cus_corp_reg_no%TYPE )
      RETURN BOOLEAN
   IS
--
-- MODIFICATION HISTORY
-- Person             Date        Comments
-- -----------------  ----------  -------------------------------------------
-- Chamila Nalaka     08/05/2002  Initial development
      wk_count                      NUMBER;

      CURSOR cus
      IS
         SELECT COUNT ( * )
           FROM uw_m_customers
          WHERE uw_m_customers.cus_corp_reg_no = corcusreg;
   BEGIN
      OPEN cus;

      FETCH cus
       INTO wk_count;

      IF wk_count > 0 THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END;                                                                                   -- Function FN_DUP_COR_CUS_REG

---------------------------------------------------------------------------
   FUNCTION fn_chk_forgn_key_cons (
      wkprtseqno                 IN uw_m_customers.cus_code%TYPE )
      RETURN BOOLEAN
   IS
-- Purpose: Check for foreign key constrainsts in other tables
--
-- MODIFICATION HISTORY
-- Person               Date        Comments
-- ---------            ------      -------------------------------------------
-- Chamila Nalaka     09/05/2002    Initial development
      wk_ret_val                    BOOLEAN;
   BEGIN
      IF pk_uw_h_endorsement_history.fn_chk_forgn_cus ( wkprtseqno ) THEN
         RETURN TRUE;                                -- return true if cus code exist in UW_H_ENDORSEMENT_HISTORY table
      ELSIF pk_uw_h_policy_history.fn_chk_forgn_cus ( wkprtseqno ) THEN
         RETURN TRUE;                                     -- return true if cus code exist in UW_H_POLICY_HISTORY table
      ELSIF pk_uw_t_surveys.fn_chk_forgn_cus ( wkprtseqno ) THEN
         RETURN TRUE;                                            -- return true if cus code exist in UW_T_SURVEYS table
      ELSIF pk_uw_t_endorsements.fn_chk_forgn_cus ( wkprtseqno ) THEN
         RETURN TRUE;                                       -- return true if cus code exist in UW_T_ENDORSEMENTS table
      ELSIF pk_uw_t_policies.fn_chk_forgn_cus ( wkprtseqno ) THEN
         RETURN TRUE;                                           -- return true if cus code exist in UW_T_POLICIES table
      ELSIF pk_uw_t_quotations.fn_chk_forgn_cus ( wkprtseqno ) THEN
         RETURN TRUE;                                         -- return true if cus code exist in UW_T_QUOTATIONS table
      ELSIF pk_rc_t_debit_note.fn_chk_forgn_cus ( wkprtseqno ) THEN
         RETURN TRUE;                                         -- return true if cus code exist in RC_T_DEBIT_NOTE table
      ELSIF pk_rc_m_cheques.fn_chk_forgn_cus ( wkprtseqno ) THEN
         RETURN TRUE;                                            -- return true if cus code exist in RC_M_CHEQUES table
      ELSIF pk_rc_t_credit_note.fn_chk_forgn_cus ( wkprtseqno ) THEN
         RETURN TRUE;                                        -- return true if cus code exist in RC_T_CREDIT_NOTE table
      ELSIF pk_rc_t_dir_receipt.fn_chk_forgn_cus ( wkprtseqno ) THEN
         RETURN TRUE;                                        -- return true if cus code exist in RC_T_DIR_RECEIPT table
      ELSIF pk_rc_t_excess_pay.fn_chk_forgn_cus ( wkprtseqno ) THEN
         RETURN TRUE;                                         -- return true if cus code exist in RC_T_EXCESS_PAY table
      ELSIF pk_rc_t_nsundry_receipt.fn_chk_forgn_cus ( wkprtseqno ) THEN
         RETURN TRUE;                                    -- return true if cus code exist in RC_T_NSUNDRY_RECEIPT table
      ELSIF pk_rc_t_ret_cheq_settle.fn_chk_forgn_cus ( wkprtseqno ) THEN
         RETURN TRUE;                                    -- return true if cus code exist in RC_T_RET_CHEQ_SETTLE table
      ELSIF pk_rc_t_sundry_receipt.fn_chk_forgn_cus ( wkprtseqno ) THEN
         RETURN TRUE;                                     -- return true if cus code exist in RC_T_SUNDRY_RECEIPT table
      END IF;

      RETURN FALSE;
   END;

----------------------------------------------------------------------------

   ---------------------------------------------------------------------------
--Developer  : Chamila Nalaka
--Date       : 05/06/2002
--Purpose    : To generate the Customer Code
---------------------------------------------------------------------------
   PROCEDURE pu_gen_customer_code (
      wkbranchcode               IN sm_m_salesloc.slc_brn_code%TYPE,
      cus_code                   OUT uw_m_customers.cus_code%TYPE,
      scr_cus_code               OUT VARCHAR2 )
   IS
   BEGIN
      scr_cus_code     :=
         ( LPAD ( RTRIM ( pk_uw_tab_sequences.fn_customer_next ),
                  (   pk_uw_p_sys_params.fn_get_customer_size - 5 ),
                  '0' ) );
      cus_code         :=
            ( LPAD ( wkbranchcode, 5, '0' ) )
         || ( LPAD ( RTRIM ( scr_cus_code ),
                     (   pk_uw_p_sys_params.fn_get_customer_size
                       - 5 ),
                     '0' ) );
                    -- dbms_output.put_line(scr_cus_code||','||cus_code);
   END;

     -- Procedure PU_GEN_CUSTOMER_CODE
-----------------------------------------------------------------------------------------------
----------------------------------------------------------------
--Developer :   Chamila Nalaka
--Date      :   17/06/2002
--Purpose   :   Return customer name
--Used By   : Indika - 05/09/2002
-----------------------------------------------------------------
   FUNCTION fn_get_cust_name (
      wk_cust_code               IN uw_m_customers.cus_code%TYPE )
      RETURN VARCHAR2
   IS
      wk_name                       VARCHAR2 ( 500 );

      CURSOR get_name
      IS
         SELECT DISTINCT    c.cus_indv_initials
                         || DECODE ( c.cus_indv_initials,
                                     NULL, NULL,
                                     ' ' )
                         || c.cus_indv_surname NAME
                    FROM uw_m_customers c
                   WHERE c.cus_code = wk_cust_code
--and c.cus_type = 'I'
         UNION
         SELECT DISTINCT c.cus_corp_name NAME
                    FROM uw_m_customers c
                   WHERE c.cus_code = wk_cust_code;
--and c.cus_type = 'C';
   BEGIN
      OPEN get_name;

      FETCH get_name
       INTO wk_name;

      CLOSE get_name;

      RETURN wk_name;
   END;                                                                                     -- Function FN_GET_CUST_NAME

---------------------------------------------------------------
--Developer :   Chandi Fernando
--Date      :   04/06/2002
--Purpose   :   Function to check customer group Code(Foreign Key - uw_m_customers) exists in the table
---------------------------------------------------------------
   FUNCTION fn_chk_forgn_group (
      wk_grpcode                 IN uw_r_groups.grp_code%TYPE )
      RETURN BOOLEAN
   IS
      wk_count                      NUMBER;

      CURSOR loc
      IS
         SELECT COUNT ( * )
           FROM uw_m_customers
          WHERE cus_grp_code = wk_grpcode;
   BEGIN
      OPEN loc;

      FETCH loc
       INTO wk_count;

      IF wk_count > 0 THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

      CLOSE loc;
   END;                                                                                   -- Function FN_CHK_FORGN_GROUP

--------------------------------------------------------------------------------
--Developer :   Chamila Nalaka
--Date      :   27/08/2002
--Purpose   :   check if customer code exist for given name
--------------------------------------------------------------------------------
--Modified  : Induni [17/06/14 - changed  LIKE wkcusname to  LIKE '%'||wkcusname||'%' (Chckd with Kalana and updated change from IAT to DEV]
---------------------------------------------------------------------------------
   FUNCTION fn_chk_cus_code (
      wkcusname                  IN VARCHAR2 )
      RETURN BOOLEAN
   IS
      wk_count                      VARCHAR2 ( 20 );

      CURSOR cus
      IS
         SELECT c.cus_code
           FROM uw_m_customers c
          WHERE    c.cus_indv_initials
                || DECODE ( c.cus_indv_initials,
                            NULL, NULL,
                            ' ' )
                || c.cus_indv_surname LIKE '%'||wkcusname||'%'
         UNION
         SELECT c.cus_code
           FROM uw_m_customers c
          WHERE c.cus_corp_name LIKE '%'||wkcusname||'%';

   BEGIN

      OPEN cus;
      FETCH cus INTO wk_count;
      IF cus%FOUND THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

   END;

----------------------------------------------------------------------------
----------------------------------------------------------------
--Developer :   Chamila Nalaka
--Date      :   17/06/2002
--Purpose   :   Return customer name
--Used By   : Indika - 05/09/2002
-----------------------------------------------------------------
   FUNCTION fn_rtn_name (
      wk_cust_code               IN uw_m_customers.cus_code%TYPE )
      RETURN VARCHAR2
   IS
      wk_name                       VARCHAR2 ( 300 );

      CURSOR get_name
      IS
         SELECT DISTINCT    c.cus_indv_title
                         || c.cus_indv_initials
                         || c.cus_indv_surname NAME
                    FROM uw_m_customers c
                   WHERE c.cus_code = wk_cust_code
         UNION
         SELECT DISTINCT c.cus_corp_name NAME
                    FROM uw_m_customers c
                   WHERE c.cus_code = wk_cust_code;
   BEGIN
      OPEN get_name;

      FETCH get_name
       INTO wk_name;

      CLOSE get_name;

      RETURN wk_name;
   END;                                                                                          -- Function FN_RTN_NAME

---------------------------------------------------------------------------
--Developer  : Priyanga Jayathilaka
--Date       : 17/02/2003
--Purpose    : Selects customer name and the address.
--             (Policy Schedule)
---------------------------------------------------------------------------
   PROCEDURE pr_sel_cust_name_addr (
      wk_cust_code               IN uw_m_customers.cus_code%TYPE,
      wk_cust_name               OUT VARCHAR2,
      wk_addr_1                  OUT uw_m_customers.cus_address_1%TYPE,
      wk_addr_2                  OUT uw_m_customers.cus_address_2%TYPE,
      wk_addr_3                  OUT uw_m_customers.cus_address_3%TYPE )
   IS
      CURSOR cur_customer
      IS
         SELECT uw_m_customers.cus_type,
                uw_m_customers.cus_indv_surname,
                uw_m_customers.cus_indv_initials,
                uw_m_customers.cus_corp_name,
                uw_m_customers.cus_address_1,
                uw_m_customers.cus_address_2,
                uw_m_customers.cus_address_3
           FROM uw_m_customers
          WHERE uw_m_customers.cus_code = wk_cust_code;

      wk_cust_type                  uw_m_customers.cus_type%TYPE;
      wk_indv_surname               uw_m_customers.cus_indv_surname%TYPE;
      wk_indv_initial               uw_m_customers.cus_indv_initials%TYPE;
      wk_corp_name                  uw_m_customers.cus_corp_name%TYPE;
   BEGIN
      OPEN cur_customer;

      FETCH cur_customer
       INTO wk_cust_type,
            wk_indv_surname,
            wk_indv_initial,
            wk_corp_name,
            wk_addr_1,
            wk_addr_2,
            wk_addr_3;

      IF cur_customer%FOUND THEN
         IF wk_cust_type = 'I' THEN
            wk_cust_name     :=    wk_indv_initial
                                || ' '
                                || wk_indv_surname;
         ELSIF wk_cust_type = 'C' THEN
            wk_cust_name     := wk_corp_name;
         ELSE
            wk_cust_name     := '';
         END IF;
      ELSE
         wk_cust_name     := '';
         wk_addr_1        := '';
         wk_addr_2        := '';
         wk_addr_3        := '';
      END IF;

      CLOSE cur_customer;
   END;

----------------------------------------------------------------
--Developer :   Chamila Nalaka
--Date      :   25/09/2003
--Purpose   :   Return customer address
-----------------------------------------------------------------
   FUNCTION fn_get_cust_address (
      wkcode                     IN uw_m_customers.cus_code%TYPE )
      RETURN uw_m_customers.cus_loc_description%TYPE
   IS
      CURSOR c1
      IS
         SELECT cus_loc_description
           FROM uw_m_customers
          WHERE cus_code = wkcode;

      wkdesc                        uw_m_customers.cus_loc_description%TYPE;
   BEGIN
      OPEN c1;

      FETCH c1
       INTO wkdesc;

      CLOSE c1;

      RETURN wkdesc;
   END;

----------------------------------------------------------------
--Developer :   Gireesha Pinnagoda
--Date      :   26/10/2004
--Purpose   :   Return customer Default Address
--Modified  :   Deshani 01/12/2014 for FORTE UW-SRS #88 address format
--              Number, Street, City [Sangkat], District [Khan], Province, Country
--Modified  :   Charitha 07/12/2015 - Removed blank lines
--Modified  :   Indu [15/12/16 - Add earthquak & cyclone fields containing Town/Village Tract  Township]
-----------------------------------------------------------------
   PROCEDURE pu_get_cust_default_add (
      wkcode                     IN uw_m_cust_addresses.adr_cus_code%TYPE,
      wkdesc                     OUT varchar2,
      wkseq                      OUT uw_m_cust_addresses.adr_seq_no%TYPE )
   IS

      wk_postal_code            uw_m_cust_addresses.adr_postal_code%TYPE;
      wk_country                VARCHAR2(100);

      CURSOR c1
      IS
         /*SELECT adr_loc_description,
                adr_seq_no
           FROM uw_m_cust_addresses
          WHERE adr_cus_code = wkcode
            AND adr_default = 'Y';*/
/*          SELECT adr_loc_description ||', '|| DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district),'','',PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district)||' ,')
                ||DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province),'','',PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province)) loc_description, --07/12/2015
                adr_postal_code,
                adr_seq_no
           FROM uw_m_cust_addresses
          WHERE adr_cus_code = wkcode
            AND adr_default = 'Y'*/
        SELECT adr_loc_description ||', '||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_cyclone),'','',
        PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_cyclone)||', ')||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_earthqk),'','',
        PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_earthqk)||', ')||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district),'','',
        PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district)||', ')||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province),'','',
           PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province)) loc_description,
           adr_postal_code,
           adr_seq_no
        FROM uw_m_cust_addresses
        WHERE adr_cus_code = wkcode
        AND adr_default = 'Y';

      CURSOR c2(wk_postal_code SM_M_GEOAREA_DETAILS.SGD_GPL_CODE%TYPE) -- added for FORTE UW-SRS #88 (to get the country)
      IS
            SELECT  PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(SM_M_GEOAREA_DETAILS.SGD_GPL_DET_CODE) country
            FROM    SM_M_GEOAREA_DETAILS, SM_M_GEOAREA_PARAMLN, SM_M_GEOAREA_PARAM
            WHERE   SM_M_GEOAREA_DETAILS.SGD_GPL_CODE = SM_M_GEOAREA_PARAMLN.GPL_CODE
            AND     SM_M_GEOAREA_PARAMLN.GPL_SMG_CODE = SM_M_GEOAREA_PARAM.SMG_CODE
            AND     sgd_gpl_code = wk_postal_code
            AND     sgd_smg_code = (SELECT  smg_code
                                    FROM    SM_M_GEOAREA_PARAM
                                    WHERE   smg_des = 'COUNTRY');

   BEGIN
      OPEN c1;

      FETCH c1
       INTO wkdesc,
            wk_postal_code, -- added for FORTE UW-SRS #88
            wkseq;

       OPEN c2(wk_postal_code);-- added for FORTE UW-SRS #88
       FETCH c2
        INTO wk_country;
       CLOSE c2;

       wkdesc := wkdesc ||', '||wk_country; -- added for FORTE UW-SRS #88

      CLOSE c1;
   END;

----------------------------------------------------------------
--Developer :   Gireesha Pinnagoda
--Date      :   26/10/2004
--Purpose   :   Return customer Default Address
--Modified  :   Deshani 01/12/2014 for FORTE UW-SRS #88 address format
--              Number, Street, City [Sangkat], District [Khan], Province, Country
--Modified  :   Charitha 07/12/2015 - Removed blank lines
--Modified  :   Indu [15/12/16 - Add earthquak & cyclone fields containing Town/Village Tract  Township]
-----------------------------------------------------------------
   PROCEDURE pu_get_cust_default_add (
      wkseq                      IN uw_m_cust_addresses.adr_seq_no%TYPE,
      wkdesc                     OUT uw_m_cust_addresses.adr_loc_description%TYPE )
   IS

    wk_postal_code            uw_m_cust_addresses.adr_postal_code%TYPE;
    wk_country                VARCHAR2(100);

      CURSOR c1
      IS
         /*SELECT adr_loc_description
           FROM uw_m_cust_addresses
          WHERE adr_seq_no = wkseq;*/
/*          SELECT adr_loc_description ||', '|| DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district),'','',PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district)||' ,')
                ||DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province),'','',PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province)) loc_description, --07/12/2015
                adr_postal_code
           FROM uw_m_cust_addresses*/
        SELECT adr_loc_description ||', '||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_cyclone),'','',
        PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_cyclone)||', ')||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_earthqk),'','',
        PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_earthqk)||', ')||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district),'','',
        PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district)||', ')||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province),'','',
           PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province)) loc_description,
           adr_postal_code
        FROM uw_m_cust_addresses
        WHERE adr_seq_no = wkseq;

      CURSOR c2(wk_postal_code SM_M_GEOAREA_DETAILS.SGD_GPL_CODE%TYPE) -- added for FORTE UW-SRS #88 (to return the country)
      IS
            SELECT  PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(SM_M_GEOAREA_DETAILS.SGD_GPL_DET_CODE) country
            FROM    SM_M_GEOAREA_DETAILS, SM_M_GEOAREA_PARAMLN, SM_M_GEOAREA_PARAM
            WHERE   SM_M_GEOAREA_DETAILS.SGD_GPL_CODE = SM_M_GEOAREA_PARAMLN.GPL_CODE
            AND     SM_M_GEOAREA_PARAMLN.GPL_SMG_CODE = SM_M_GEOAREA_PARAM.SMG_CODE
            AND     sgd_gpl_code = wk_postal_code
            AND     sgd_smg_code = (SELECT  smg_code
                                    FROM    SM_M_GEOAREA_PARAM
                                    WHERE   smg_des = 'COUNTRY');
   BEGIN
      OPEN c1;

      FETCH c1
       INTO wkdesc,
            wk_postal_code; -- added for FORTE UW-SRS #88
      CLOSE c1;

       OPEN c2(wk_postal_code);-- added for FORTE UW-SRS #88
       FETCH c2
        INTO wk_country;
       CLOSE c2;

       wkdesc := wkdesc ||', '||wk_country;-- added for FORTE UW-SRS #88


   END;

/*FUNCTION FN_GET_CUST_ADDRESS (Wkcode IN UW_M_CUSTOMERS.cus_code%TYPE)
                                RETURN VARCHAR2 IS


CURSOR C1 IS
    SELECT  CUS_ADDRESS_1||','||CUS_ADDRESS_2||','||CUS_ADDRESS_3
    FROM    UW_M_CUSTOMERS
    WHERE   CUS_CODE = Wkcode;

Wkdesc      VARCHAR2(200);

BEGIN
OPEN C1;
    FETCH C1 INTO   Wkdesc;
CLOSE C1;
RETURN Wkdesc;
END;
        */

   ----------------------------------------------------------------
--Developer :   Chamila Nalaka
--Date      :   23/12/2003
--Purpose   :   Return customer phone no
-----------------------------------------------------------------
   FUNCTION fn_get_cust_phone (
      wk_cust_code               IN uw_m_customers.cus_code%TYPE )
      RETURN VARCHAR2
   IS
      wk_phone                      uw_m_customers.cus_phone_1%TYPE;

      CURSOR get_phone
      IS
         SELECT DISTINCT cus_phone_1
                    FROM uw_m_customers c
                   WHERE c.cus_code = wk_cust_code;
   BEGIN
      OPEN get_phone;

      FETCH get_phone
       INTO wk_phone;

      CLOSE get_phone;

      RETURN wk_phone;
   END;                                                                                     -- Function FN_GET_CUST_NAME

----------------------------------------------------------------
--Developer :   Gireesha Pinnagoda
--Date      :   22/10/2005
--Purpose   :   Return customer Default Address
--Modified  :   Deshani 01/12/2014 for FORTE UW-SRS #88 address format
--              Number, Street, City [Sangkat], District [Khan], Province, Country
-----------------------------------------------------------------
   PROCEDURE pu_get_cust_default_add (
      wkcode                     IN uw_m_cust_addresses.adr_cus_code%TYPE,
      wkseq                      OUT uw_m_cust_addresses.adr_seq_no%TYPE,
      wkcountry                  OUT sm_m_geoarea_paramln.gpl_desc%TYPE,-- added for FORTE UW-SRS #88
      wkprovince                 OUT uw_m_cust_addresses.adr_city%TYPE,-- added for FORTE UW-SRS #88
      wkdistrict                 OUT uw_m_cust_addresses.adr_city%TYPE,-- added for FORTE UW-SRS #88
      wkcity                     OUT uw_m_cust_addresses.adr_city%TYPE,
      wkstreet                   OUT uw_m_cust_addresses.adr_street%TYPE,
      wkbuilding                 OUT uw_m_cust_addresses.adr_building%TYPE,
      wknumber                   OUT uw_m_cust_addresses.adr_building%TYPE )
   IS

      wk_postal_code            uw_m_cust_addresses.adr_postal_code%TYPE;
      wk_country                VARCHAR2(100);

      CURSOR cur_cus_add
      IS
         SELECT adr_seq_no,
                adr_postal_code,-- added for FORTE UW-SRS #88
                PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province) province,-- added for FORTE UW-SRS #88
                PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district) district,-- added for FORTE UW-SRS #88
                adr_city,
                adr_street,
                adr_building,
                adr_number
           FROM uw_m_cust_addresses
          WHERE adr_cus_code = wkcode
            AND adr_default = 'Y';

      CURSOR cur_cus_country(wk_postal_code SM_M_GEOAREA_DETAILS.SGD_GPL_CODE%TYPE) -- added for FORTE UW-SRS #88 (to get the country)
      IS
            SELECT  PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(SM_M_GEOAREA_DETAILS.SGD_GPL_DET_CODE) country
            FROM    SM_M_GEOAREA_DETAILS, SM_M_GEOAREA_PARAMLN, SM_M_GEOAREA_PARAM
            WHERE   SM_M_GEOAREA_DETAILS.SGD_GPL_CODE = SM_M_GEOAREA_PARAMLN.GPL_CODE
            AND     SM_M_GEOAREA_PARAMLN.GPL_SMG_CODE = SM_M_GEOAREA_PARAM.SMG_CODE
            AND     sgd_gpl_code = wk_postal_code
            AND     sgd_smg_code = (SELECT  smg_code
                                    FROM    SM_M_GEOAREA_PARAM
                                    WHERE   smg_des = 'COUNTRY');
   BEGIN
      OPEN cur_cus_add;

      FETCH cur_cus_add
       INTO wkseq,
            wk_postal_code,-- added for FORTE UW-SRS #88
            wkprovince,-- added for FORTE UW-SRS #88
            wkdistrict,-- added for FORTE UW-SRS #88
            wkcity,
            wkstreet,
            wkbuilding,
            wknumber;

      CLOSE cur_cus_add;

      OPEN    cur_cus_country(wk_postal_code);-- added for FORTE UW-SRS #88
      FETCH   cur_cus_country
      INTO    wkcountry;
      CLOSE   cur_cus_country;

   END;

---------------------------------------------------------------
--Developer :   Gireesha Pinnagoda
--Date      :   22/10/2005
--Purpose   :   Insert Customer as Debtor
--Modified  :   Kanika on 10.11.2010 - Added insert statment for the ac_m_creditor
--Modified  :   Mihiri - to insert creditor other name and address on 29/09/2011 - Refer 29/09/2011
--Modified  :   Deshani 01/12/2014 for FORTE UW-SRS #88 address format
--              Number, Street, City [Sangkat], District [Khan], Province, Country
--Modified  :   Umasa Fernando - Remove cus_indv_initials,cus_indv_other_name and cus_indv_surname
--              fields were exchanged with respect to the AC_M_CREDITOR and AC_M_DEBTOR    on 23/01/2017
-----------------------------------------------------------------
   PROCEDURE pu_ins_customer_debtor (
      wkcode                     IN uw_m_cust_addresses.adr_cus_code%TYPE )
   IS
      CURSOR cur_cus
      IS
         SELECT cus_code,
                cus_type,
                CUS_BRN_CODE,--Added by Chathuri on 20/11/2014 to get cust barcnch code
                DECODE ( cus_type,
                         'I',--cus_indv_surname --UMASA FERNANDO --2017.01.23
                          cus_indv_other_names,
                         /* || ' '
                          || cus_indv_initials,
                         */
                         'C', cus_corp_name ) cus_name,
                --cus_indv_other_names,
                cus_indv_surname cus_indv_other_names,
                cus_indv_nic_no,
                cus_corp_name,
                cus_phone_1,
                cus_phone_2,
                cus_fax,
                cus_email,
                cus_web_page,
                cus_rlc_rloc_code,
                cus_indv_gender,
                cus_outstand_amt,
                cus_grp_code,
                cus_corp_reg_no,
                cus_indv_title,
                cus_rc_outstand_chq_amt,
                cus_cty_code,
                cus_joint
           FROM uw_m_customers
          WHERE cus_code = wkcode;

      wkcountry                     sm_m_geoarea_paramln.gpl_desc%TYPE;-- added for FORTE UW-SRS #88
      wkprovince                    uw_m_cust_addresses.adr_city%TYPE;-- added for FORTE UW-SRS #88
      wkdistrict                    uw_m_cust_addresses.adr_city%TYPE;-- added for FORTE UW-SRS #88
      wkcity                        uw_m_cust_addresses.adr_city%TYPE;
      wkstreet                      uw_m_cust_addresses.adr_street%TYPE;
      wkbuilding                    uw_m_cust_addresses.adr_building%TYPE;
      wknumber                      uw_m_cust_addresses.adr_building%TYPE;
      wkseq                         uw_m_cust_addresses.adr_seq_no%TYPE;
      wkbrncode                     ac_m_debtor.deb_branch_code%TYPE;
      wk_CR_count                   number;
      WK_CUS_NAME                   UW_M_CUSTOMERS.cus_corp_name%TYPE;
      WK_DEB_NAME_1                 AC_M_DEBTOR.deb_name_1%TYPE;
      WK_DEB_NAME_2                 AC_M_DEBTOR.deb_name_2%TYPE;
   BEGIN
      FOR rec_cus IN cur_cus LOOP
         /*wkbrncode        := LTRIM ( SUBSTR ( rec_cus.cus_code,
                                              1,
                                              5 ), 0 );*/--Commented by Chathuri on 20/11/2014
         wkbrncode          := PK_RC_P_SYS_PARAMS.fn_acct_base_branch(); --Added by Chathuri on 20/11/2014 to get cust barcnch code
         pu_get_cust_default_add ( rec_cus.cus_code,
                                   wkseq,
                                   wkcountry,-- added for FORTE UW-SRS #88
                                   wkprovince,-- added for FORTE UW-SRS #88
                                   wkdistrict,-- added for FORTE UW-SRS #88
                                   wkcity,
                                   wkstreet,
                                   wkbuilding,
                                   wknumber );

         WK_CUS_NAME := LTRIM(RTRIM(rec_cus.cus_name));
         IF LENGTH(WK_CUS_NAME) > 100 THEN
           WK_DEB_NAME_1 := SUBSTR(WK_CUS_NAME,1,100);
           WK_DEB_NAME_2 := SUBSTR(WK_CUS_NAME,101,(LENGTH(WK_CUS_NAME)-100));
         ELSE
           WK_DEB_NAME_1 := WK_CUS_NAME;
           WK_DEB_NAME_2 := '';
         END IF;

--raise_application_error ( -20001, NVL ( pk_sm_m_salesloc.fn_get_profit_center ( wkbrncode ), wkbrncode )||'-'|| SUBSTR ( rec_cus.cus_code, 6 ));
         INSERT INTO ac_m_debtor
                     ( deb_profit_center,
                       deb_branch_code,
                       deb_name_1,
                       deb_name_2,
                       deb_address_1,
                       deb_address_2,
                       deb_address_4,
                       deb_address_3,
                       deb_type,
                       deb_lock_code,
                       deb_tx_inclu,
                       deb_debtor_code,
                       deb_nic_no,
                       --   deb_seq_no,
                       deb_enable )
              VALUES ( NVL ( pk_sm_m_salesloc.fn_get_profit_center ( wkbrncode ), wkbrncode ),
                       wkbrncode,
                       rec_cus.cus_name,
                       rec_cus.cus_indv_other_names,
                       wkcity,
                       wkstreet,
                       wkbuilding,
                       wknumber,
                       '9',
                       'N',
                       0,
                       rec_cus.cus_code,
                       --SUBSTR ( rec_cus.cus_code, 6 ),
                       NVL(rec_cus.cus_indv_nic_no,''),

                       -- pk_ac_seq_common.fn_make_sequence ( pk_ac_tab_sequences.fn_ac_m_debtor_next, wkbrncode ),
                       'Y' );

                           -- insert to ac_m_creditor
                   Begin

                   select count(*)
                   into wk_CR_count
                   from AC_M_CREDITOR
                   where cre_cred_code = rec_cus.cus_code;


                   exception
                   when others then
                   wk_CR_count := 0;
                   end ;
                   If Nvl(wk_CR_count,0) = 0 Then

                 --Start--  29/09/2011 --
                  /*     PK_AC_M_CREDITOR.pu_insert_creditor
                                (rec_cus.cus_code,wkbrncode,
                                        '4' ,--pcd_type,
                                        SUBSTR(WK_CUS_NAME,1,50),
                                        SUBSTR(WK_CUS_NAME,51,50));
                 */
                 -- End -- 29/09/2011

  PK_AC_M_CREDITOR.pu_insert_creditor(rec_cus.cus_code,wkbrncode,
                                                     '4' ,--pcd_type,
                                                     SUBSTR(WK_CUS_NAME,1,50),
                                                     rec_cus.cus_indv_other_names,
                                                     wkcity,
                                                     wkstreet,
                                                     wkbuilding,
                                                    wknumber);

                   end if;

      END LOOP;
   ---EXCEPTION
      --WHEN OTHERS THEN
        ---raise_application_error ( -20010, 'Unknown Error' );
        ---NULL;
   END;

---------------------------------------------------------------
--Developer :   Gireesha Pinnagoda
--Date      :   22/10/2005
--Purpose   :   Insert Customer as Debtor
--Modified  :   Kanika 27.10.2010 added pu_insert_creditor
--Modified  :   Mihiri - to update creditor other name and address on 29/09/2011 - Refer 29/09/2011
--Modified  :   Deshani 01/12/2014 for FORTE UW-SRS #88 address format
--              Number, Street, City [Sangkat], District [Khan], Province, Country
--Modified  :   Umasa Fernando - Remove cus_indv_initials,cus_indv_other_name and cus_indv_surname
--              fields were exchanged with respect to the AC_M_CREDITOR and AC_M_DEBTOR    on 24/01/2017
-----------------------------------------------------------------
   PROCEDURE pu_upd_customer_debtor (
      wkcode                     IN uw_m_cust_addresses.adr_cus_code%TYPE )
   IS
      CURSOR cur_cus
      IS
         SELECT cus_code,
                cus_type,
                DECODE ( cus_type,
                         'I',cus_indv_other_names,
                          --cus_indv_surname
                         /* || ' '
                          || cus_indv_initials,
                          */
                         'C', cus_corp_name ) cus_name,
                 cus_indv_surname cus_indv_other_names,
                --cus_indv_other_names,
                cus_indv_nic_no,
                cus_corp_name,
                cus_phone_1,
                cus_phone_2,
                cus_fax,
                cus_email,
                cus_web_page,
                cus_rlc_rloc_code,
                cus_indv_gender,
                cus_outstand_amt,
                cus_grp_code,
                cus_corp_reg_no,
                cus_indv_title,
                cus_rc_outstand_chq_amt,
                cus_cty_code,
                cus_joint
           FROM uw_m_customers
          WHERE cus_code = wkcode;

      wkcountry                     sm_m_geoarea_paramln.gpl_desc%TYPE;-- added for FORTE UW-SRS #88
      wkprovince                    uw_m_cust_addresses.adr_city%TYPE;-- added for FORTE UW-SRS #88
      wkdistrict                    uw_m_cust_addresses.adr_city%TYPE;-- added for FORTE UW-SRS #88
      wkcity                        uw_m_cust_addresses.adr_city%TYPE;
      wkstreet                      uw_m_cust_addresses.adr_street%TYPE;
      wkbuilding                    uw_m_cust_addresses.adr_building%TYPE;
      wknumber                      uw_m_cust_addresses.adr_building%TYPE;
      wkseq                         uw_m_cust_addresses.adr_seq_no%TYPE;
      wkbrncode                     ac_m_debtor.deb_branch_code%TYPE;

      WK_CUS_NAME                   UW_M_CUSTOMERS.cus_corp_name%TYPE;
      WK_DEB_NAME_1                 AC_M_DEBTOR.deb_name_1%TYPE;
      WK_DEB_NAME_2                 AC_M_DEBTOR.deb_name_2%TYPE;
      wk_CR_count      Number;

   BEGIN
      FOR rec_cus IN cur_cus LOOP
         wkbrncode        := LTRIM ( SUBSTR ( rec_cus.cus_code,
                                              1,
                                              5 ), 0 );
         pu_get_cust_default_add ( rec_cus.cus_code,
                                   wkseq,
                                   wkcountry,-- added for FORTE UW-SRS #88
                                   wkprovince,-- added for FORTE UW-SRS #88
                                   wkdistrict,-- added for FORTE UW-SRS #88
                                   wkcity,
                                   wkstreet,
                                   wkbuilding,
                                   wknumber );

        WK_CUS_NAME := LTRIM(RTRIM(rec_cus.cus_name));
         IF LENGTH(WK_CUS_NAME) > 100 THEN
           WK_DEB_NAME_1 := SUBSTR(WK_CUS_NAME,1,100);
           WK_DEB_NAME_2 := SUBSTR(WK_CUS_NAME,101,(LENGTH(WK_CUS_NAME)-100));
         ELSE
           WK_DEB_NAME_1 := WK_CUS_NAME;
           WK_DEB_NAME_2 := '';
         END IF;

         UPDATE ac_m_debtor
            SET --deb_profit_center = NVL ( pk_sm_m_salesloc.fn_get_profit_center ( wkbrncode ), wkbrncode ),
                --deb_branch_code = wkbrncode,
                deb_name_1 = rec_cus.cus_name,
                deb_name_2 = rec_cus.cus_indv_other_names,
                deb_address_1 = wkcity,
                deb_address_2 = wkstreet,
                deb_address_4 = wkbuilding,
                deb_address_3 = wknumber,
                --deb_type = '9',
                --deb_lock_code = 'N',
                --deb_tx_inclu = 0,
                deb_nic_no = rec_cus.cus_indv_nic_no--,
                --deb_enable = 'Y'
         ----------------------------UPDATED BY UMASA FERNANDO--2017.01.24
          WHERE --deb_debtor_code = SUBSTR ( rec_cus.cus_code, 6 );
                  DEB_DEBTOR_CODE=REC_CUS.CUS_CODE;

          -- insert and update  ac_m_creditor
                   Begin

                   select count(*)
                   into wk_CR_count
                   from AC_M_CREDITOR
                   where cre_cred_code = rec_cus.cus_code;

                   exception
                   when others then
                   wk_CR_count := 0;
                   end ;
                   If Nvl(wk_CR_count,0) = 0 Then

                       PK_AC_M_CREDITOR.pu_insert_creditor
                                ( rec_cus.cus_code,wkbrncode,
                                        '4' ,--pcd_type,
                                        SUBSTR(WK_CUS_NAME,1,50),
                                        SUBSTR(WK_CUS_NAME,51,50));
                    else
                        Update ac_m_creditor
                        set cre_name_1      = SUBSTR(WK_CUS_NAME,1,50),
                            --cre_name_2    = SUBSTR(WK_CUS_NAME,51,50), --29/09/2011
                            cre_name_2      = rec_cus.cus_indv_other_names,
                            cre_full_name   = WK_CUS_NAME
                        where cre_cred_code = rec_cus.cus_code;
                   end if;

      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         raise_application_error ( -20001, 'Unknown Error' );
   END;

----------------------------------------------------------------
--Developer :   Gireesha Pinnagoda
--Date      :   24/11/2005
--Purpose   :   Return customer Default Address
--Modified  :   Deshani 01/12/2014 for FORTE UW-SRS #88 address format
--              Number, Street, City [Sangkat], District [Khan], Province, Country
--Modified  :   Chamara 03/09/2015 - Removed blank lines
--Modified  :   Indu [15/12/16 - Add earthquak & cyclone fields containing Town/Village Tract  Township]
--Modified  :   Indu [09/05/17 - return value changed to VARCHAR, wkdesc length changed from 200 to 1000]
-----------------------------------------------------------------
   FUNCTION fn_get_cust_default_add (

      wkcode           IN uw_m_cust_addresses.adr_cus_code%TYPE
   )
      RETURN VARCHAR2   IS

      wkdesc             VARCHAR2(4000);-- uw_m_cust_addresses.adr_loc_description%TYPE;
      wk_postal_code      uw_m_cust_addresses.adr_postal_code%TYPE;
      wk_country          VARCHAR2(100);

      CURSOR c1
      IS
         /*SELECT adr_loc_description
           FROM uw_m_cust_addresses
          WHERE adr_cus_code = wkcode
            AND adr_default = 'Y';*/
/*         SELECT adr_loc_description ||', '|| DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district),'','',PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district)||' ,')
                ||DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province),'','',PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province)) loc_description,
                adr_postal_code*/
        SELECT adr_loc_description ||', '||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_cyclone),'','',
        PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_cyclone)||', ')||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_earthqk),'','',
        PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_earthqk)||', ')||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district),'','',
        PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district)||', ')||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province),'','',PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province)) loc_description,
                adr_postal_code
           FROM uw_m_cust_addresses
          WHERE adr_cus_code = wkcode
            AND adr_default = 'Y';

      CURSOR c2(wk_gpl_code SM_M_GEOAREA_DETAILS.SGD_GPL_CODE%TYPE) -- added for FORTE UW-SRS #88 (to return the country)
      IS
            SELECT  PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(SM_M_GEOAREA_DETAILS.SGD_GPL_DET_CODE) country
            FROM    SM_M_GEOAREA_DETAILS, SM_M_GEOAREA_PARAMLN, SM_M_GEOAREA_PARAM
            WHERE   SM_M_GEOAREA_DETAILS.SGD_GPL_CODE = SM_M_GEOAREA_PARAMLN.GPL_CODE
            AND     SM_M_GEOAREA_PARAMLN.GPL_SMG_CODE = SM_M_GEOAREA_PARAM.SMG_CODE
            AND     sgd_gpl_code = wk_postal_code
            AND     sgd_smg_code = (SELECT  smg_code
                                    FROM    SM_M_GEOAREA_PARAM
                                    WHERE   smg_des = 'COUNTRY');
   BEGIN
      OPEN c1;

      FETCH c1
       INTO wkdesc,
            wk_postal_code; -- added for FORTE UW-SRS #88
      CLOSE c1;

      OPEN  c2(wk_postal_code); -- added for FORTE UW-SRS #88
      FETCH c2
       INTO wk_country;
      CLOSE c2;

      wkdesc := wkdesc ||', '||wk_country; -- added for FORTE UW-SRS #88

      RETURN wkdesc;
   END;
----------------------------------------------------------------
--Developer :   Priyanga Jayathilaka
--Date      :   12/03/2008
--Purpose   :   Return customer name
-----------------------------------------------------------------
--Modified  :   Induni [15/05/08 - increase length of cust name var]
-----------------------------------------------------------------
  FUNCTION fn_get_cust_name_full (wk_cust_code  IN uw_m_customers.cus_code%TYPE ) RETURN VARCHAR2 IS

    wk_name   VARCHAR2(300);

    CURSOR get_name IS
      SELECT DISTINCT c.cus_indv_other_names || DECODE(c.cus_indv_other_names,NULL,NULL,' ') || c.cus_indv_surname NAME
      FROM uw_m_customers c
      WHERE c.cus_code = wk_cust_code
      --and c.cus_type = 'I'
      UNION
      SELECT DISTINCT c.cus_corp_name NAME
      FROM uw_m_customers c
      WHERE c.cus_code = wk_cust_code;
      --and c.cus_type = 'C';

  BEGIN

    OPEN get_name;
    FETCH get_name INTO wk_name;
    CLOSE get_name;
    RETURN wk_name;

  END; -- Function FN_GET_CUST_NAME

 ----------------------------------------------------------------
--Developer :   Chamila Nalaka
--Date      :   06/09/2007
--Purpose   :   Return customer id
-----------------------------------------------------------------
   FUNCTION fn_get_id (wk_cust_code               IN uw_m_customers.cus_code%TYPE )
      RETURN uw_m_customers.cus_indv_nic_no%TYPE
   IS
      wk_id                       uw_m_customers.cus_indv_nic_no%TYPE;

      CURSOR get_id
      IS
         SELECT cus_indv_nic_no
         FROM   uw_m_customers
         WHERE  cus_code = wk_cust_code;
   BEGIN
      OPEN get_id;

      FETCH get_id
       INTO wk_id;

      CLOSE get_id;

      RETURN wk_id;
   END; -- Function FN_GET_CUST_NAME





----------------------------------------------------------------
--Developer :   Chamila Nalaka
--Date      :   06/09/2007
--Purpose   :   Return customer pid
-----------------------------------------------------------------
   FUNCTION fn_get_pid (wk_cust_code               IN uw_m_customers.cus_code%TYPE )
      RETURN uw_m_customers.cus_indv_pp_no%TYPE
   IS
      wk_pid                       uw_m_customers.cus_indv_pp_no%TYPE;

      CURSOR get_pid
      IS
         SELECT cus_indv_pp_no
         FROM   uw_m_customers
         WHERE  cus_code = wk_cust_code;
   BEGIN
      OPEN get_pid;

      FETCH get_pid
       INTO wk_pid;

      CLOSE get_pid;

      RETURN wk_pid;
   END; -- Function FN_GET_CUST_NAME

----------------------------------------------------------------
--Developer :   Nadeeshani Jayathilaka
--Date      :   20/04/2009
--Purpose   :   Return full name of a customer
-----------------------------------------------------------------
  FUNCTION fn_get_customer_full_name (wk_cust_code  IN uw_m_customers.cus_code%TYPE )
  RETURN VARCHAR2 IS

    wk_name         VARCHAR2(330);
    wk_corp_name    VARCHAR2(330);

    CURSOR get_name IS
      SELECT DISTINCT c.cus_indv_initials || ' ' || cus_indv_other_names || DECODE(c.cus_indv_other_names,NULL,NULL,' ') || c.cus_indv_surname , c.cus_corp_name
      FROM uw_m_customers c
      WHERE c.cus_code = wk_cust_code;

  BEGIN

    OPEN get_name;
    FETCH get_name INTO wk_name, wk_corp_name;
    IF wk_corp_name IS NULL THEN
        wk_corp_name := wk_name;
    END IF;
    CLOSE get_name;
    RETURN wk_corp_name;

  END;--fn_get_customer_full_name
----------------------------------------------------------------
--Developer :   Thanuja Peries
--Date      :   10/10/2008
--Purpose   :   Return customer name with title
--Modified  :   26/10/2015 [Chamara - Assign Null when title code = 'NO']
--Modified  :   29/11/2016[Charitha - trim customer name] -- copied for AMI on 24/01/17 - Indu
--Modified  :   02/06/2017 [Lahiru - Assign Null when title code = 'NA']
----------------------------------------------------------------
  FUNCTION fn_get_cust_name_with_title (wk_cust_code  IN uw_m_customers.cus_code%TYPE ) RETURN VARCHAR2 IS

    wk_name   VARCHAR2(300);

    CURSOR get_name IS

    SELECT CUS_NAME FROM
             (SELECT DISTINCT trim(DECODE(c.cus_indv_title,'NO',NULL,'NA',NULL,c.cus_indv_title)|| DECODE(cus_indv_title,NULL,NULL,' ') || c.cus_indv_other_names || DECODE(c.cus_indv_other_names,NULL,NULL,' ') || c.cus_indv_surname) cus_NAME --29/11/2016
               FROM uw_m_customers c
              WHERE c.cus_code = wk_cust_code
              --and c.cus_type = 'I'
              UNION
             SELECT DISTINCT c.cus_corp_name cus_NAME
               FROM uw_m_customers c
              WHERE c.cus_code = wk_cust_code)
     WHERE CUS_NAME IS NOT NULL;
              --and c.cus_type = 'C';
  BEGIN

    OPEN get_name;
    FETCH get_name INTO wk_name;
    CLOSE get_name;
    RETURN wk_name;

  END;--fn_get_cust_name_with_title
----------------------------------------------------------------
--Developer :   Thanuja Peries
--Date      :   22/07/2008
--Purpose   :   Return customer type
-----------------------------------------------------------------
   FUNCTION fn_get_cust_type (wk_cust_code  IN uw_m_customers.cus_code%TYPE )
      RETURN varchar2
   IS
      wk_cus_type         uw_m_customers.cus_type%TYPE;

      CURSOR get_cus_type
      IS
         SELECT cus_type
         FROM   uw_m_customers
         WHERE  cus_code = wk_cust_code;

   BEGIN
      OPEN get_cus_type;

      FETCH get_cus_type
       INTO wk_cus_type;

      CLOSE get_cus_type;

      RETURN wk_cus_type;

   END; -- Function fn_get_cust_type
 ---------------------------------------------------------------------------
  --Developer  : Priyanga Jayathilaka
  --Date       : 11/12/2007
  --Purpose    : Validates Client's NID.
  ---------------------------------------------------------------------------
  FUNCTION FN_CUST_NID_VALIDATION (WK_SURNAME      IN     UW_M_CUSTOMERS.cus_indv_surname%TYPE,
                                   WK_MAIDEN_NAME  IN     UW_M_CUSTOMERS.cus_fathers_name%TYPE,
                                   WK_GENDER       IN     UW_M_CUSTOMERS.cus_indv_gender%TYPE,
                                   WK_DOB          IN     UW_M_CUSTOMERS.cus_indv_dob%TYPE,
                                   WK_NID          IN     UW_M_CUSTOMERS.cus_indv_nic_no%TYPE,
                                   WK_ERROR_TYPE   IN OUT VARCHAR2) RETURN BOOLEAN IS

    WK_NID_FIRST_CHR      VARCHAR2(1);
    WK_COUNT              NUMBER(2);
    WK_DIGIT              NUMBER(1);
    WK_TOT_SUM_DIGITS     NUMBER(5);
    WK_REST_VAL           NUMBER(2);
    WK_CHK_DGT            CHAR(1);

  BEGIN

    IF WK_NID IS NOT NULL THEN

      IF LENGTH(WK_NID) <> 14 THEN

        WK_ERROR_TYPE := 'L';  --Length of the National Identity should be 14.
        RETURN FALSE;

      ELSE

        ----- Validates First Digit against the Surname or Maiden Name ---------
        WK_NID_FIRST_CHR := SUBSTR(WK_NID,1,1);
        IF WK_SURNAME IS NOT NULL THEN
          IF WK_NID_FIRST_CHR <> SUBSTR(WK_SURNAME,1,1) THEN
            IF (WK_GENDER = 'F') AND (WK_MAIDEN_NAME IS NOT NULL) THEN
              IF WK_NID_FIRST_CHR <> SUBSTR(WK_MAIDEN_NAME,1,1) THEN
                WK_ERROR_TYPE := 'N';  --First Character of the National Identity does not match with either Surname or Maiden Name.
                RETURN FALSE;
              ELSE
                NULL;  --Validation Successfull
              END IF;
            ELSE
              WK_ERROR_TYPE := 'N';  --First Character of the National Identity does not match with either Surname or Maiden Name.
              RETURN FALSE;
            END IF;
          ELSE
            NULL;  --Validation Successfull
          END IF;
        ELSE
          WK_ERROR_TYPE := 'O';  --National Identity Validation Failed; Some Mandatory Fields are missing.
          RETURN FALSE;
        END IF;

        ----- NID Check Digit Validation ---------
        WK_TOT_SUM_DIGITS := 0;
        FOR WK_COUNT IN 2 .. 13 LOOP
          WK_DIGIT          := TO_NUMBER(SUBSTR(WK_NID, WK_COUNT, 1));
          WK_TOT_SUM_DIGITS := WK_TOT_SUM_DIGITS + (WK_DIGIT * (15 - WK_COUNT));
        END LOOP;
        WK_TOT_SUM_DIGITS := WK_TOT_SUM_DIGITS + ((ASCII(SUBSTR(WK_NID, 1, 1)) - 55) * 14);
        WK_REST_VAL       := 17 - MOD(WK_TOT_SUM_DIGITS, 17);
        IF WK_REST_VAL = 17 THEN
          WK_CHK_DGT := '0';
        ELSIF (WK_REST_VAL > 0) AND (WK_REST_VAL < 10) THEN
          WK_CHK_DGT := TO_CHAR(WK_REST_VAL);
        ELSE
          WK_CHK_DGT := CHR(WK_REST_VAL + 55);
        END IF;
        IF NOT (SUBSTR(WK_NID, 14, 1) = WK_CHK_DGT) THEN
          WK_ERROR_TYPE := 'G';  --Invalid National Identity; Check Digit Validation Failed.
          RETURN FALSE;
        ELSE
          NULL;  --Validation Successfull
        END IF;

      END IF;

    END IF;

    WK_ERROR_TYPE := NULL;
    RETURN TRUE;

  EXCEPTION WHEN OTHERS THEN
    WK_ERROR_TYPE := 'V';  --Invalid National Identity.
    RETURN FALSE;

  END;

----------------------------------------------------------------
--Developer :   Thanuja Peries
--Date      :   28/05/2008
--Purpose   :   Return customer type
-----------------------------------------------------------------
   FUNCTION fn_get_customer_type (wk_cust_code  IN uw_m_customers.cus_code%TYPE )
      RETURN varchar2
   IS
      wk_cus_type         uw_m_customers.cus_type%TYPE;
      wk_cus_type_desc    varchar2(20);

      CURSOR get_cus_type
      IS
         SELECT cus_type
         FROM   uw_m_customers
         WHERE  cus_code = wk_cust_code;

   BEGIN
      OPEN get_cus_type;

      FETCH get_cus_type
       INTO wk_cus_type;

       IF wk_cus_type = 'I' THEN
          wk_cus_type_desc := 'Individual';
       ELSIF wk_cus_type = 'C' THEN
          wk_cus_type_desc := 'Company';
       ELSE
          wk_cus_type_desc := '';
       END IF;

      CLOSE get_cus_type;

      RETURN wk_cus_type_desc;

   END;

---------------------------------------------------------------------------
-- To check the individual customers is duplicated in the table.
   FUNCTION fn_dup_ind_customer_1 (
      custitl                    IN uw_m_customers.cus_indv_title%TYPE,
      cussur                     IN uw_m_customers.cus_indv_surname%TYPE)
      RETURN BOOLEAN
   IS
      wk_count                      NUMBER;

      CURSOR cus
      IS
         SELECT COUNT ( * )
           FROM uw_m_customers
          WHERE uw_m_customers.cus_indv_title = custitl
            AND uw_m_customers.cus_indv_surname = cussur;

   BEGIN
      OPEN cus;

      FETCH cus
       INTO wk_count;

      IF wk_count > 0 THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END;

----------------------------------------------------------------
--Developer :   Thanuja Peries
--Date      :   11/11/2009
--Purpose   :   Return customer Address
--Modified  :   Deshani 01/12/2014 for FORTE UW-SRS #88 address format
--              Number, Street, City [Sangkat], District [Khan], Province, Country
-----------------------------------------------------------------
   PROCEDURE pu_get_customer_address (
      wkadrseq                   IN uw_m_cust_addresses.adr_seq_no%TYPE,
      wknumber                  OUT uw_m_cust_addresses.adr_number%TYPE,
      wkbuilding                OUT uw_m_cust_addresses.adr_building%TYPE,
      wkstreet                  OUT uw_m_cust_addresses.adr_street%TYPE,
      wkcity                    OUT uw_m_cust_addresses.adr_city%TYPE,
      wkdistrict                OUT uw_m_cust_addresses.adr_city%TYPE, -- added for FORTE UW-SRS #88
      wkprovince                OUT uw_m_cust_addresses.adr_city%TYPE, -- added for FORTE UW-SRS #88
      wkcountry                 OUT sm_m_geoarea_paramln.gpl_desc%TYPE) -- added for FORTE UW-SRS #88
   IS
      wk_postal_code            uw_m_cust_addresses.adr_postal_code%TYPE;

      CURSOR cur_address
      IS
         SELECT adr_postal_code, -- added for FORTE UW-SRS #88
                adr_number,
                adr_building,
                adr_street,
                adr_city,
                PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district) district,-- added for FORTE UW-SRS #88
                PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province) province -- added for FORTE UW-SRS #88
           FROM uw_m_cust_addresses
          WHERE adr_seq_no = wkadrseq;

      CURSOR cur_cus_country(wk_postal_code SM_M_GEOAREA_DETAILS.SGD_GPL_CODE%TYPE) -- added for FORTE UW-SRS #88 (to get the country)
      IS
            SELECT  PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(SM_M_GEOAREA_DETAILS.SGD_GPL_DET_CODE) country
            FROM    SM_M_GEOAREA_DETAILS, SM_M_GEOAREA_PARAMLN, SM_M_GEOAREA_PARAM
            WHERE   SM_M_GEOAREA_DETAILS.SGD_GPL_CODE = SM_M_GEOAREA_PARAMLN.GPL_CODE
            AND     SM_M_GEOAREA_PARAMLN.GPL_SMG_CODE = SM_M_GEOAREA_PARAM.SMG_CODE
            AND     sgd_gpl_code = wk_postal_code
            AND     sgd_smg_code = (SELECT  smg_code
                                    FROM    SM_M_GEOAREA_PARAM
                                    WHERE   smg_des = 'COUNTRY');

   BEGIN
      OPEN cur_address;

      FETCH cur_address
       INTO wk_postal_code, -- added for FORTE UW-SRS #88
            wknumber,
            wkbuilding,
            wkstreet,
            wkcity,
            wkdistrict, -- added for FORTE UW-SRS #88
            wkprovince; -- added for FORTE UW-SRS #88

      CLOSE cur_address;

      OPEN  cur_cus_country(wk_postal_code);  -- added for FORTE UW-SRS #88
      FETCH cur_cus_country INTO wkcountry;
      CLOSE cur_cus_country;

   END;

---------------------------------------------------------------------------
--Developer  : Thanuja Peries
--Date       : 23/05/2008
--Purpose    : To get the customer address by customer code
--Modified   : Deshani 01/12/2014 for FORTE UW-SRS #88 address format
--             Number, Street, City [Sangkat], District [Khan], Province, Country
---------------------------------------------------------------------------
FUNCTION fu_get_cust_address (
      wk_cust_code           IN uw_m_cust_addresses.adr_cus_code%TYPE
   )
      RETURN uw_m_cust_addresses.adr_loc_description%TYPE

   IS
      wk_cust_address       varchar2(300);
      wk_postal_code        uw_m_cust_addresses.adr_postal_code%TYPE;
      wk_country            VARCHAR2(100);

      CURSOR get_address
      IS
       SELECT
            initcap ( DECODE ( RTRIM ( LTRIM ( d.adr_number ) ),NULL,'',RTRIM ( LTRIM ( d.adr_number ))||CHR(32)))||
            initcap ( DECODE ( RTRIM ( LTRIM ( d.adr_building ) ),NULL,'',RTRIM ( LTRIM ( d.adr_building ))||CHR(10)))||
            initcap ( DECODE ( RTRIM ( LTRIM ( d.adr_street ) ),NULL,'',RTRIM ( LTRIM ( d.adr_street ))||CHR(10)))||
            --initcap ( DECODE ( RTRIM ( LTRIM ( d.adr_city ) ),NULL,'',RTRIM ( LTRIM ( d.adr_city )))) customer_address
            initcap ( DECODE ( RTRIM ( LTRIM ( d.adr_city ) ),NULL,'',RTRIM ( LTRIM ( d.adr_city ))||CHR(10)))||
            initcap ( DECODE ( RTRIM ( LTRIM ( PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district))), -- added for FORTE UW-SRS #88
            NULL,'',RTRIM ( LTRIM (PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district) ))||CHR(10)))||
            initcap ( DECODE ( RTRIM ( LTRIM ( PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province))), -- added for FORTE UW-SRS #88
            NULL,'',RTRIM ( LTRIM ( PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province) ))))customer_address,
            adr_postal_code
         FROM uw_m_cust_addresses d
        WHERE d.adr_cus_code = wk_cust_code
          AND d.adr_default = 'Y';

      CURSOR cur_country(wk_postal_code SM_M_GEOAREA_DETAILS.SGD_GPL_CODE%TYPE) -- added for FORTE UW-SRS #88 (to get the country)
      IS
            SELECT  initcap(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(SM_M_GEOAREA_DETAILS.SGD_GPL_DET_CODE)) country
            FROM    SM_M_GEOAREA_DETAILS, SM_M_GEOAREA_PARAMLN, SM_M_GEOAREA_PARAM
            WHERE   SM_M_GEOAREA_DETAILS.SGD_GPL_CODE = SM_M_GEOAREA_PARAMLN.GPL_CODE
            AND     SM_M_GEOAREA_PARAMLN.GPL_SMG_CODE = SM_M_GEOAREA_PARAM.SMG_CODE
            AND     sgd_gpl_code = wk_postal_code
            AND     sgd_smg_code = (SELECT  smg_code
                                    FROM    SM_M_GEOAREA_PARAM
                                    WHERE   smg_des = 'COUNTRY');

   BEGIN
      OPEN get_address;

      FETCH get_address  INTO wk_cust_address,
                              wk_postal_code; -- added for FORTE UW-SRS #88

      CLOSE get_address;

      OPEN  cur_country(wk_postal_code);  -- added for FORTE UW-SRS #88
      FETCH cur_country INTO wk_country;
      CLOSE cur_country;

      wk_cust_address := wk_cust_address ||CHR(10)||wk_country; -- added for FORTE UW-SRS #88

      RETURN wk_cust_address;

   END; -- Function end fu_get_cust_address

----------------------------------------------------------------
--Developer :   Thanuja Peries
--Date      :   15/02/2010
--Purpose   :   Return customer name with initials
--Modified  :   26/10/2015 [Chamara - Assign Null when title code = 'NO']
----------------------------------------------------------------
  FUNCTION fn_get_cust_name_with_init (wk_cust_code  IN uw_m_customers.cus_code%TYPE ) RETURN VARCHAR2 IS

    wk_name   VARCHAR2(300);

    CURSOR get_name IS

    SELECT CUS_NAME FROM
            (SELECT DISTINCT DECODE(c.cus_indv_title,'NO',NULL,c.cus_indv_title) || DECODE(cus_indv_title,NULL,NULL,' ') || c.cus_indv_initials || DECODE(c.cus_indv_initials,NULL,NULL,' ') || c.cus_indv_surname cus_NAME
               FROM uw_m_customers c
              WHERE c.cus_code = wk_cust_code
              --and c.cus_type = 'I'
              UNION
             SELECT DISTINCT c.cus_corp_name cus_NAME
               FROM uw_m_customers c
              WHERE c.cus_code = wk_cust_code)
     WHERE CUS_NAME IS NOT NULL;
              --and c.cus_type = 'C';
  BEGIN

    OPEN get_name;
    FETCH get_name INTO wk_name;
    CLOSE get_name;
    RETURN wk_name;

  END;--fn_get_cust_name_with_title

 -------------------------------------------------------------------
--Developer :   Mihiri Vithanage
--Date      :   29/09/2011
--Purpose   :   Function to check customer NIC or Company Reg No
--------------------------------------------------------------------
   FUNCTION fn_chk_nic_or_compregno (wk_cuscode IN uw_m_customers.cus_code%TYPE )
   RETURN BOOLEAN  IS
      wk_nic                     uw_m_customers.cus_corp_reg_no%TYPE;
      wk_cus_type                uw_m_customers.cus_type%TYPE;

      CURSOR cur_nic IS
         SELECT decode(a.cus_type, 'I', a.cus_indv_nic_no , 'C' ,a.cus_corp_reg_no) cus_reg_no
           FROM uw_m_customers a
          WHERE cus_code = wk_cuscode;
   BEGIN
      OPEN cur_nic;
      FETCH cur_nic INTO wk_nic;

      IF wk_nic is null THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;

      CLOSE cur_nic;
   END;

 -------------------------------------------------------------------
--Developer :   Mihiri Vithanage
--Date      :   29/09/2011
--Purpose   :   Function to get customer status
--------------------------------------------------------------------
   FUNCTION fn_get_cus_status (wk_cuscode IN uw_m_customers.cus_code%TYPE )
   RETURN BOOLEAN  IS
      wk_status                  uw_m_customers.cus_corp_reg_no%TYPE;

      CURSOR cur_status IS
         SELECT NVL(cus_status ,'A') status
           FROM uw_m_customers a
          WHERE cus_code = wk_cuscode;
   BEGIN
      OPEN cur_status;
      FETCH cur_status INTO wk_status;

      IF wk_status = 'A' THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

      CLOSE cur_status;
   END;

   ----------------------------------------------------------------
--Developer :   Gayathri Perera
--Date      :   26/06/2012
--Purpose   :   Return Company Reg. No
-----------------------------------------------------------------
   FUNCTION fn_get_RegNo (wk_cust_code               IN uw_m_customers.cus_code%TYPE )
      RETURN uw_m_customers.cus_corp_reg_no%TYPE
   IS
      wk_id                       uw_m_customers.cus_indv_nic_no%TYPE;

      CURSOR get_id
      IS
         SELECT cus_corp_reg_no
         FROM   uw_m_customers
         WHERE  cus_code = wk_cust_code;
   BEGIN
      OPEN get_id;

      FETCH get_id
       INTO wk_id;

      CLOSE get_id;

      RETURN wk_id;
   END;
---------------------------------------------------------------------------
--Developer  : Mihiri Vithanage
--Date       : 29/11/2012
--Purpose    : To get the customer address by customer code
--Modified   : Deshani 01/12/2014 for FORTE UW-SRS #88 address format
--             Number, Street, City [Sangkat], District [Khan], Province, Country
---------------------------------------------------------------------------
FUNCTION fu_get_cust_address_1 (
      wk_cust_code           IN uw_m_cust_addresses.adr_cus_code%TYPE
   )
      RETURN uw_m_cust_addresses.adr_loc_description%TYPE

   IS
      wk_cust_address       varchar2(300);
      wk_postal_code        uw_m_cust_addresses.adr_postal_code%TYPE;
      wk_country            VARCHAR2(100);

      CURSOR get_address
      IS
       SELECT
            initcap ( DECODE ( RTRIM ( LTRIM ( d.adr_number ) ),NULL,'',RTRIM ( LTRIM ( d.adr_number ))||', '))||
            initcap ( DECODE ( RTRIM ( LTRIM ( d.adr_building ) ),NULL,'',RTRIM ( LTRIM ( d.adr_building ))||', '))||
            initcap ( DECODE ( RTRIM ( LTRIM ( d.adr_street ) ),NULL,'',RTRIM ( LTRIM ( d.adr_street ))||', '))||
            -- initcap ( DECODE ( RTRIM ( LTRIM ( d.adr_city ) ),NULL,'',RTRIM ( LTRIM ( d.adr_city )))) customer_address
            initcap ( DECODE ( RTRIM ( LTRIM ( d.adr_city ) ),NULL,'',RTRIM ( LTRIM ( d.adr_city ))||', '))||
            initcap ( DECODE ( RTRIM ( LTRIM ( PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district))),
            NULL,'',RTRIM ( LTRIM ( PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district)))||', '))||
            initcap ( DECODE ( RTRIM ( LTRIM ( PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province))),
            NULL,'',RTRIM ( LTRIM ( PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province))))) customer_address,
            adr_postal_code
         FROM uw_m_cust_addresses d
        WHERE d.adr_cus_code = wk_cust_code
          AND d.adr_default = 'Y';

      CURSOR cur_country(wk_gpl_code SM_M_GEOAREA_DETAILS.SGD_GPL_CODE%TYPE) -- added for FORTE UW-SRS #88 (to get the country)
      IS
            SELECT  initcap(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(SM_M_GEOAREA_DETAILS.SGD_GPL_DET_CODE)) country
            FROM    SM_M_GEOAREA_DETAILS, SM_M_GEOAREA_PARAMLN, SM_M_GEOAREA_PARAM
            WHERE   SM_M_GEOAREA_DETAILS.SGD_GPL_CODE = SM_M_GEOAREA_PARAMLN.GPL_CODE
            AND     SM_M_GEOAREA_PARAMLN.GPL_SMG_CODE = SM_M_GEOAREA_PARAM.SMG_CODE
            AND     sgd_gpl_code = wk_postal_code
            AND     sgd_smg_code = (SELECT  smg_code
                                    FROM    SM_M_GEOAREA_PARAM
                                    WHERE   smg_des = 'COUNTRY');

   BEGIN
      OPEN get_address;

      FETCH get_address  INTO wk_cust_address,
                              wk_postal_code; -- added for FORTE UW-SRS #88

      CLOSE get_address;

      OPEN  cur_country(wk_postal_code);  -- added for FORTE UW-SRS #88
      FETCH cur_country INTO wk_country;
      CLOSE cur_country;

      wk_cust_address := wk_cust_address ||', '||wk_country; -- added for FORTE UW-SRS #88

      RETURN wk_cust_address;

   END; -- Function end fu_get_cust_address

--------------------------------------------------------------------------------
-- Developer : Induni Wijayasiri
-- Date      : 01/06/2014
-- Purpose   : Check wheter a default address already exists in the DB for the given customer - RT - 22886
-- Reference : Customer Maintenance fn (UW 8.1.4)
--------------------------------------------------------------------------------
FUNCTION fn_def_adr_exsts (wkCusCode IN UW_M_CUSTOMERS.cus_code%TYPE,
                           wkAdrSeq  IN UW_M_CUST_ADDRESSES.adr_seq_no%TYPE) RETURN BOOLEAN IS

wkCnt NUMBER;

CURSOR cur_chk_def_adr IS
    SELECT COUNT(*)
    FROM UW_M_CUST_ADDRESSES
    WHERE adr_default = 'Y'
    AND adr_seq_no <> wkAdrSeq
    AND adr_cus_code = wkCusCode;

BEGIN

    OPEN cur_chk_def_adr;
    FETCH cur_chk_def_adr INTO wkCnt;
    CLOSE cur_chk_def_adr;

    IF NVL(wkCnt,0) = 0 THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;

END;

----------------------------------------------------------------
--Developer :   Gireesha Pinnagoda
--Date      :   26/10/2004
--Purpose   :   Return customer Default Address
--Modified  :   Deshani 01/12/2014 for FORTE UW-SRS #88 address format
--              Number, Street, City [Sangkat], District [Khan], Province, Country
--Taken     :   pu_get_cust_default_add procedure and modified it as a function by Nadeeshani [16/12/2014 - Forte - For policy customer address LOV]
--Modified  :   Chamara 03/09/2015 - Removed blank lines
--Modified  :   Indu [15/12/16 - Add earthquak & cyclone fields containing Town/Village Tract  Township]
--Modified  :   Indu [09/05/17 - return value changed to VARCHAR, wkdesc length changed from 200 to 1000]
-----------------------------------------------------------------
   FUNCTION fn_get_cust_default_add (
      wkcode                     IN uw_m_cust_addresses.adr_cus_code%TYPE,
      wkaddrseq                  IN uw_m_cust_addresses.adr_seq_no%TYPE )
   RETURN VARCHAR2 IS

      wk_postal_code            uw_m_cust_addresses.adr_postal_code%TYPE;
      wk_country                VARCHAR2(100);
      wkdesc                    VARCHAR2(1000);--uw_m_cust_addresses.adr_loc_description%TYPE;

      CURSOR c1
      IS
         /*SELECT adr_loc_description,
                adr_seq_no
           FROM uw_m_cust_addresses
          WHERE adr_cus_code = wkcode
            AND adr_default = 'Y';*/
/*          SELECT adr_loc_description ||', '|| DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district),'','',PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district)||' ,')
                ||DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province),'','',PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province)) loc_description,
                adr_postal_code*/
        SELECT adr_loc_description ||', '||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_cyclone),'','',
        PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_cyclone)||', ')||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_earthqk),'','',
        PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_earthqk)||', ')||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district),'','',
        PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_district)||', ')||
        DECODE(PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province),'','',PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(adr_province)) loc_description,
                adr_postal_code
        FROM uw_m_cust_addresses
          WHERE adr_cus_code = wkcode
            AND adr_seq_no = wkaddrseq;

      CURSOR c2(wk_postal_code SM_M_GEOAREA_DETAILS.SGD_GPL_CODE%TYPE) -- added for FORTE UW-SRS #88 (to get the country)
      IS
            SELECT  PK_SM_M_GEOAREA_PARAM.fn_get_paramln_desc(SM_M_GEOAREA_DETAILS.SGD_GPL_DET_CODE) country
            FROM    SM_M_GEOAREA_DETAILS, SM_M_GEOAREA_PARAMLN, SM_M_GEOAREA_PARAM
            WHERE   SM_M_GEOAREA_DETAILS.SGD_GPL_CODE = SM_M_GEOAREA_PARAMLN.GPL_CODE
            AND     SM_M_GEOAREA_PARAMLN.GPL_SMG_CODE = SM_M_GEOAREA_PARAM.SMG_CODE
            AND     sgd_gpl_code = wk_postal_code
            AND     sgd_smg_code = (SELECT  smg_code
                                    FROM    SM_M_GEOAREA_PARAM
                                    WHERE   smg_des = 'COUNTRY');

   BEGIN
      OPEN c1;

      FETCH c1
       INTO wkdesc,
            wk_postal_code; -- added for FORTE UW-SRS #88;

       OPEN c2(wk_postal_code);-- added for FORTE UW-SRS #88
       FETCH c2
        INTO wk_country;
       CLOSE c2;

       wkdesc := wkdesc ||', '||wk_country; -- added for FORTE UW-SRS #88

      CLOSE c1;
      RETURN wkdesc;
   END;

  ------------------------------------------------------------------------------
  --Developer   : Dileepa Karunarathna
  --Date        : 18/1/2015
  --Purpose     : Get the account handler according to the selected customer
  ------------------------------------------------------------------------------
  FUNCTION fn_get_account_handler (
      wk_cus_code                 IN uw_m_customers.cus_code%TYPE)
  RETURN uw_m_customers.cus_bparty_code%TYPE
  IS
   wk_bparty_code    uw_m_customers.cus_bparty_code%TYPE;

    CURSOR cur_get_accnt_handler IS
        SELECT uw_m_customers.cus_bparty_code
        FROM uw_m_customers
        WHERE uw_m_customers.cus_code=wk_cus_code;
  BEGIN
    OPEN cur_get_accnt_handler;
    FETCH cur_get_accnt_handler INTO wk_bparty_code;
    IF cur_get_accnt_handler%notfound THEN
        wk_bparty_code := NULL;
    END IF;
    CLOSE cur_get_accnt_handler;

    RETURN wk_bparty_code;

  END;

  --------------------------------------------------------------------------------
--Developer :   Charitha Wijenayake
--Date      :   28/08/2015
--Purpose   :   Return Title of Non Cooperate customer
--------------------------------------------------------------------------------

FUNCTION fn_title  (WkCusCode IN UW_M_CUST_CONTACTS.CCT_CUS_CODE%TYPE)
                            RETURN VARCHAR2 IS


    CURSOR cur_title IS
        SELECT  cus_indv_title
        FROM    uw_m_customers
        WHERE   cus_code = WkCusCode;

    wkCctTitle  uw_m_customers.cus_indv_title%TYPE;

BEGIN

    OPEN cur_title;
    FETCH cur_title INTO wkCctTitle;
    CLOSE cur_title;

 RETURN wkCctTitle;

END;


---------------------------------------------------------------------------
-- Developer : Induni Wijayasiri [ based on above fn_dup_cor_customer with new param added for cus code]
-- Date      : 05/12/15
-- Purpose   : Check duplicate status avoding self validation of record [   -- To check the corporate customers is duplicated in the table.]
---------------------------------------------------------------------------
   FUNCTION fn_dup_cor_customer (corcus   IN uw_m_customers.cus_corp_name%TYPE,
                                 corCusCd IN UW_M_CUSTOMERS.cus_code%TYPE) RETURN BOOLEAN IS

      wk_count                      NUMBER;

      CURSOR cus IS
         SELECT COUNT ( * )
           FROM uw_m_customers
          WHERE (corCusCd IS NULL OR cus_code <> corCusCd)
          AND uw_m_customers.cus_corp_name = corcus;

   BEGIN

      OPEN cus;
      FETCH cus INTO wk_count;
      CLOSE cus;

      IF wk_count > 0 THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END;                                                                                  -- Function FN_DUP_COR_CUSTOMER

---------------------------------------------------------------------------
-- Developer : Induni Wijayasiri [ based on above fn_dup_cor_cus_reg_no with new param added for cus code]
-- Date      : 05/12/15
-- Purpose   : Check duplicate status avoding self validation of record [   -- To check the cus_corp_reg_no is duplicated in the table.]
---------------------------------------------------------------------------
   FUNCTION fn_dup_cor_cus_reg_no (corcusreg    IN uw_m_customers.cus_corp_reg_no%TYPE,
                                   corCusCd     IN UW_M_CUSTOMERS.cus_code%TYPE)
                                   RETURN BOOLEAN  IS

      wk_count                      NUMBER;

      CURSOR cus IS
         SELECT COUNT ( * )
         FROM uw_m_customers
         WHERE (corCusCd IS NULL OR cus_code <> corCusCd)
         AND uw_m_customers.cus_corp_reg_no = corcusreg;

   BEGIN

      OPEN cus;
      FETCH cus INTO wk_count;
      CLOSE cus;

      IF wk_count > 0 THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

   END;

--------------------------------------------------------------------------------
--Developer :   Umasa Fernando
--Date      :   21/12/2016
--Purpose   :   Validate Active/Inactive Customers
--------------------------------------------------------------------------------

FUNCTION FN_CHECK_ACTIVE_CUSTOMERS(WK_CUST IN VARCHAR2)
--UW_M_CUSTOMERS.SCR_CUS_CODE%TYPE
RETURN BOOLEAN AS

WK_CUST_TYPE VARCHAR(3);

 CURSOR GET_CUST_ACT
 IS
 SELECT CUS_STATUS FROM  UW_M_CUSTOMERS WHERE UW_M_CUSTOMERS.CUS_CODE=WK_CUST;

BEGIN
 OPEN GET_CUST_ACT;
      FETCH GET_CUST_ACT
       INTO WK_CUST_TYPE;

 IF (WK_CUST_TYPE='A') THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
 END IF;

CLOSE  GET_CUST_ACT;
END FN_CHECK_ACTIVE_CUSTOMERS;



                                                                                  -- Function FN_DUP_COR_CUS_REG

END;-- Package Body PK_UW_M_CUSTOMERS
/