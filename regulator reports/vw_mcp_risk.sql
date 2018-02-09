select
    distinct pol_policy_no, pol_endorsement_no, prs_name, pol_seq_no, 
    (select distinct(info_value)  from pol_risk_info where pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and pin_description = 'MAKE') MAKE,
    (select distinct(info_value)  from pol_risk_info where pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and pin_description = 'MODEL') MODEL, 
    (select distinct(info_value)  from pol_risk_info where pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and pin_description = 'CUBIC CAPACITY (C.C.)') CC, 
    (select distinct(info_value)  from pol_risk_info where pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and pin_description = 'VEHICLE TYPE') VEHICLE_TYPE,
    (select distinct(info_value)  from pol_risk_info where pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and pin_description = 'SEATING CAPACITY') SEATING_CAPACITY,
    (select distinct(info_value)  from pol_risk_info where pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and pin_description = 'WINDSCREEN SI') WINDSCREEN,
    (select distinct(info_value)  from pol_risk_info where pol_seq_no = x.pol_seq_no and prs_name = x.prs_name and pin_description = 'TYPE OF BODY') TYPE_OF_BODY
from pol_risk_info x
where x.pol_prd_code='MCP';