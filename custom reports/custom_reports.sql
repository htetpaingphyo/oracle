/*Total Policy No. for Class wise (with 90 days)*/
select pol_cla_code,count(pol_policy_no) from uw_T_policies 
where pol_status <> 9 
and created_date > trunc(sysdate -90) 
and pol_policy_no is not null 
group by pol_cla_code;

/*Total Policy No. for Class wise (with 90 days)*/
select pol_cla_code,count(pol_policy_no) from uw_T_policies
where pol_status <> 9
and pol_policy_no is not null
group by pol_cla_code

/*Total Policy Number (Branch, Class, Month, Year)*/
select 
pol_slc_brn_code,pol_cla_code,to_char(pol_date,'MONTH'),to_char(pol_date,'yyyy'),count(pol_policy_no) cnt
 from uw_T_policies
where pol_status <> 9
and pol_policy_no is not null
group by pol_slc_brn_code,pol_cla_code,to_char(pol_date,'MONTH'),to_char(pol_date,'yyyy');

/*Public Life */
select count(distinct pol_number) from life.il_m_policy

/* CLEAR DATA */
exec pk_stat_reports.pr_del_x_data;

/* POPULATE DATA */
exec pk_stat_reports.pr_pop_x_data('02-JUN-2016', to_char(SYSDATE, 'DD-MON-YYYY'));

/* AVERAGE POLICIES by MONTH WISE */
select to_char(pol_created_date - 7/24,'YYYY') "YEAR", to_char(pol_created_date - 7/24,'MM') "MONTH", count(*) "TOTAL POLICIES"
from uw_x_policies 
where pol_transaction_type in ('N','R','E')
group by to_char(pol_created_date - 7/24,'YYYY'), to_char(pol_created_date - 7/24,'MM')
order by 1 desc;

select * from claims_data;

select * from claims_data where to_char(INT_INITIMATE_DT, 'MON')='AUG' and INT_STATUS='P' order by INT_INITIMATE_DT;

select count(*) from claims_data where to_char(INT_INITIMATE_DT, 'MON')='AUG' and INT_STATUS='O' order by INT_INITIMATE_DT;

select to_char(INT_INITIMATE_DT,'month'),to_char(INT_INITIMATE_DT,'yyyy'),count(INT_CLAIM_NO) cnt
from claims_data where INT_STATUS='P' and INT_CLAIM_NO is not null
order by INT_INITIMATE_DT;

select pol_slc_brn_code,pol_cla_code,to_char(pol_date,'month'),to_char(pol_date,'yyyy'),count(pol_policy_no) cnt
 from uw_T_policies
where pol_status <> 9
and pol_policy_no is not null
group by pol_slc_brn_code,pol_cla_code,to_char(pol_date,'month'),to_char(pol_date,'yyyy')

/*Total Policy No. for Class wise (all data)*/
select pol_cla_code,count(pol_policy_no) from uw_T_policies
where pol_status <> 9
and pol_policy_no is not null
group by pol_cla_code

/* Active Policy Holder */
select count (distinct cus_indv_surname) from uw_M_customers
where nvl (cus_status,'I') = 'A'

select count (*) from uw_M_customers
where nvl (cus_status,'I') = 'A'

select count (*) from uw_M_customers
where nvl (cus_status,'I') = 'A'
and cus_type ='I'

/*.................................................*/
select count (cus_corp_name) from uw_M_customers
where nvl (cus_status,'I') = 'A'
and cus_type ='C'

select count (distinct decode (cus_type,'I',cus_indv_surname,cus_corp_name)) from uw_M_customers
where nvl (cus_status,'I') = 'A'
and cus_type ='C'

select pol_cla_code,count(pol_policy_no) from uw_T_policies
where pol_status <> 9
and pol_policy_no is not null
group by pol_cla_code

/*Average*/
select 
pol_slc_brn_code,pol_cla_code,to_char(pol_date,'month'),to_char(pol_date,'yyyy'),count(pol_policy_no) cnt
 from uw_T_policies
where pol_status <> 9
and pol_policy_no is not null
group by pol_slc_brn_code,pol_cla_code,to_char(pol_date,'month'),to_char(pol_date,'yyyy')


/* Active User Session*/
SELECT count(*) session_count 
FROM V$SESSION
WHERE USERNAME NOT IN ('SYS','SYSTEM','SYSMAN','DBSNMP')
AND PROGRAM LIKE 'frmweb%';

