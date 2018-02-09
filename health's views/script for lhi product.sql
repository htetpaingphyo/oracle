select a.pol_policy_no, a.pol_period_from, a.pol_period_to, b.prs_name,
(
	select listagg('"'||pin_description||'":"'||nvl(pin_char_value,nvl(to_cha pin_number_value),nvl(to_char(pin_date_value),'')))||'"',',')
	within group (order by c.pin_prs_plc_pol_seq_no, pin_prs_seq_no, pin_description)
    from uw_t_pol_information c
    where b.prs_seq_no=c.pin_prs_seq_no
    and a.pol_seq_no=c.pin_prs_plc_pol_seq_no
) "DATA_DESCRIPTION"
from uw_t_policies a, uw_t_pol_risks b
where a.pol_seq_no = b.prs_plc_pol_seq_no
and a.pol_prd_code = 'LHI';