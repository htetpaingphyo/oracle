/** CLEAR DATA **/
exec pk_stat_reports.pr_del_x_data;

/** POPULATE DATA **/
exec pk_stat_reports.pr_pop_x_data('01-JUN-2017', '31-AUG-2017');

/** GET POLICIES BY MONTH **/
select to_char(pol_created_date,'YYYY') "YEAR", to_char(pol_created_date,'MM') "MONTH", count(*) "TOTAL POLICIES"
from uw_x_policies 
where pol_status <> 9 
and pol_transaction_type in ('N','R','E')
group by to_char(pol_created_date,'YYYY'), to_char(pol_created_date,'MM')
order by 1, 2;

/** GET POLICIES BY CLASS **/
select pol_cla_code,count(pol_policy_no) from uw_t_policies
where pol_status <> 9
and created_date > trunc(sysdate -90)
and pol_policy_no is not null
group by pol_cla_code;

select pol_cla_code,count(pol_policy_no) from uw_t_policies
where pol_status <> 9
and pol_policy_no is not null
group by pol_cla_code;

select count(distinct pol_number) from life.il_m_policy;

select 
pol_slc_brn_code,pol_cla_code,to_char(pol_date,'MON') "MONTH",to_char(pol_date,'yyyy') "YEAR", count(pol_policy_no) cnt 
from uw_t_policies 
where pol_status <> 9 
and pol_policy_no is not null 
group by pol_slc_brn_code, pol_cla_code, to_char(pol_date,'MON'), to_char(pol_date,'yyyy');