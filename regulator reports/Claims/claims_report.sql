select rownum, x.* from uw_rc_claim_details x where x.pol_prd_code='MCC' --and rownum between 1 and 10;

select * from uw_rc_claim_det_x;    /* without containing payment */

select * from claim_det_x;          /* containing payment */