exec pk_stat_reports.pr_del_x_data;

exec pk_stat_reports.pr_pop_x_data('01-AUG-2017', '31-AUG-2017');

select * from
(
    select to_char(pol_created_date,'YYYY') "YEAR", to_char(pol_created_date,'MM') "MONTH", count(*) "NO.OF.POLICIES"
    from uw_x_policies 
    where pol_status <> 9 
    and pol_transaction_type in ('N','R','E')
    group by to_char(pol_created_date,'YYYY'), to_char(pol_created_date,'MM')
    order by 1, 2
) abc where abc.YEAR='2017'; /*5421*/

select created_date, sum(policies) "NO.OF.POLICIES" from
(
    select to_char(pol_created_date, 'YYYY-MM-DD') "CREATED_DATE", count(*) "POLICIES"
    from uw_x_policies 
    where pol_status <> 9 
    and pol_transaction_type in ('N','R','E')
    and to_char(pol_created_date, 'YYYY')='2017'
    group by pol_created_date 
    order by 1
) group by created_date order by 1; /*5421*/


select 
    pol_cla_code "CLASSES", to_char(pol_created_date, 'YYYY-MM-DD') "CREATED_DATE", count(*) "POLICIES" 
from uw_t_policies
where pol_status <> 9 
and pol_transaction_type in ('N','R','E')
and to_char(pol_created_date, 'YYYY')='2017'
group by pol_cla_code, pol_created_date 
order by 1;