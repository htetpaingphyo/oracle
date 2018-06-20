create or replace view sicl.vw_mcg_income 
(
    SRNO, TYPE, NOS, SI, PREMIUM, STAMPFEE, TOTAL, 
    CONSTRAINT PK_MCG_INC_NO PRIMARY KEY (SRNO) DISABLE NOVALIDATE
)
as
select xyz."SRNO", type, nos, si, premium, stampfee, (premium + stampfee) "TOTAL" from 
(
    (
    select 
        1 AS "SRNO", '75 MILLION' AS "TYPE",count(pol_policy_no) "NOS", sum(pol_sum_insured) "SI", sum(pol_transaction_amount) "PREMIUM",  
--        sum((   select  
--                    round((pol_sum_insured * ppr_percentage / 100) + ((pol_sum_insured * ppr_percentage / 100) * 10 / 100), 2)
--                from pol_data a, pol_risk_perils b 
--                where a.pol_policy_no=b.pol_policy_no 
--                and b.prl_description='BASIC COVER' 
--                and b.pol_policy_no=x.pol_policy_no
--            )) "PREMIUM", 
        sum(( select round(pol_sum_insured * 0.01 / 100, 2) from pol_data 
                where pol_policy_no=x.pol_policy_no and pol_trans_effect_date = (select max(pol_trans_effect_date) from pol_data where pol_policy_no=x.pol_policy_no)
            )) "STAMPFEE"
    from pol_data x where pol_prd_code in ('MCG','MIT') and pol_policy_no like '%YGN%' and pol_sum_insured <= 75000000
    )
    union
    (
    select 
        2 AS "SRNO.", 'BTW 75 ~ 300 MILLION' AS "TYPE", count(pol_policy_no) "NOS", sum(pol_sum_insured) "SI", sum(pol_transaction_amount) "PREMIUM",
--        sum((   select  
--                    round((pol_sum_insured * ppr_percentage / 100) + ((pol_sum_insured * ppr_percentage / 100) * 10 / 100), 2)
--                from pol_data a, pol_risk_perils b 
--                where a.pol_policy_no=b.pol_policy_no 
--                and b.prl_description='BASIC COVER' 
--                and b.pol_policy_no=x.pol_policy_no
--            )) "PREMIUM", 
        sum(( select round(pol_sum_insured * 0.01 / 100, 2) from pol_data 
                where pol_policy_no=x.pol_policy_no and pol_trans_effect_date = (select max(pol_trans_effect_date) from pol_data where pol_policy_no=x.pol_policy_no)
            )) "STAMPFEE"
    from pol_data x where pol_prd_code in ('MCG','MIT') and pol_policy_no like '%YGN%' and pol_sum_insured > 75000000 and pol_sum_insured < 300000000
    )
    union
    (
    select 
        3 AS "SRNO.", 'BTW 300 ~ 1000 MILLION' AS "TYPE", count(pol_policy_no) "NOS", sum(pol_sum_insured) "SI", sum(pol_transaction_amount) "PREMIUM",
--        sum((   select  
--                    round((pol_sum_insured * ppr_percentage / 100) + ((pol_sum_insured * ppr_percentage / 100) * 10 / 100), 2)
--                from pol_data a, pol_risk_perils b 
--                where a.pol_policy_no=b.pol_policy_no 
--                and b.prl_description='BASIC COVER' 
--                and b.pol_policy_no=x.pol_policy_no
--            )) "PREMIUM", 
        sum(( select round(pol_sum_insured * 0.01 / 100, 2) from pol_data 
                where pol_policy_no=x.pol_policy_no and pol_trans_effect_date = (select max(pol_trans_effect_date) from pol_data where pol_policy_no=x.pol_policy_no)
            )) "STAMPFEE"
    from pol_data x where pol_prd_code in ('MCG','MIT') and pol_policy_no like '%YGN%' and pol_sum_insured > 300000000 and pol_sum_insured < 1000000000
    )
    union
    (
    select 
        4 AS "SRNO.", 'ABV 1000 MILLION' AS "TYPE", count(pol_policy_no) "NOS", sum(pol_sum_insured) "SI", sum(pol_transaction_amount) "PREMIUM",
--        sum((   select  
--                    round((pol_sum_insured * ppr_percentage / 100) + ((pol_sum_insured * ppr_percentage / 100) * 10 / 100), 2)
--                from pol_data a, pol_risk_perils b 
--                where a.pol_policy_no=b.pol_policy_no 
--                and b.prl_description='BASIC COVER' 
--                and b.pol_policy_no=x.pol_policy_no
--            )) "PREMIUM", 
        sum(( select round(pol_sum_insured * 0.01 / 100, 2) from pol_data 
                where pol_policy_no=x.pol_policy_no and pol_trans_effect_date = (select max(pol_trans_effect_date) from pol_data where pol_policy_no=x.pol_policy_no)
            )) "STAMPFEE"
    from pol_data x where pol_prd_code in ('MCG','MIT') and pol_policy_no like '%YGN%' and pol_sum_insured > 1000000000
    )
) xyz;