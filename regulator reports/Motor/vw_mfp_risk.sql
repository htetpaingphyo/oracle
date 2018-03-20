select 
    distinct x.pol_policy_no, pol_endorsement_no, prs_name, pol_seq_no, prs_seq_no,
    (select info_value from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_name = x.prs_name and pin_description = 'MAKE') MAKE, 
	(select info_value from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_name = x.prs_name and pin_description = 'MODEL') MODEL, 
	(select info_value from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_name = x.prs_name and pin_description = 'CUBIC CAPACITY (C.C.)') CC, 
	(select info_value from pol_risk_info where pol_policy_no = x.pol_policy_no and prs_name = x.prs_name and pin_description = 'VEHICLE TYPE') VEHICLE_TYPE
from pol_risk_info x 
where x.POL_PRD_CODE='MFP';