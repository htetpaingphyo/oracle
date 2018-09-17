EXEC PK_STAT_REPORTS.PR_DEL_X_DATA;

EXEC PK_STAT_REPORTS.PR_POP_X_DATA('01-AUG-2018', '31-AUG-2018');

select rownum, x.* from uw_rc_claim_details x where x.pol_prd_code='MCC' --and rownum between 1 and 10;

select * from uw_rc_claim_det_x;    /* without containing payment */

select * from claim_det_x;          /* containing payment */

SELECT 
    POL_POLICY_NO,
    INT_CLAIM_NO,
    POL_CLA_CODE,
    POL_PRD_CODE,
    POL_TRANS_EFFECT_DATE,
    POL_SUM_INSURED,
    CUS_NAME,
    POL_TRANSACTION_AMOUNT,
    POL_TOTAL_PREMIUM,
    POL_TOTAL_TRANSACTION_AMOUNT,
    PRS_NAME,
    AGENT_NAME,
    ACCOUNT_HANDLER_NAME,
    INT_DATE_LOSS,
    INT_PLACE_LOSS,
    INT_LOSS_REMARKS,
    CAUSE_OF_LOSS,
    CLAIM_STATUS
FROM UW_RC_CLAIM_DET_X WHERE POL_CLA_CODE='MT' ORDER BY POL_PRD_CODE;