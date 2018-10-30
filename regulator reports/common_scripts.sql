-- CLEAR VIEW --
EXEC PK_STAT_REPORTS.PR_DEL_X_DATA;

EXEC PK_STAT_REPORTS.PR_POP_X_DATA('01-APR-2017', '30-JUN-2017');

EXEC PK_STAT_REPORTS.PR_POP_X_DATA_RC_DATE('22-AUG-2018', '24-AUG-2018');

EXEC PK_STAT_REPORTS.PR_POP_X_DATA_RC_DATE('22-OCT-2018', SYSDATE-1);

-- exec pk_stat_reports.pr_pop_x_data('01-DEC-2017', to_char(SYSDATE, 'DD-MON-YYYY'));

-- exec pk_stat_reports.pr_pop_x_data('01-JUN-2018', SYSDATE);

-- FIRE --
SELECT * FROM VW_FFI_DATA WHERE TO_CHAR(RC_DATE, 'MON') = 'JUN' ORDER BY RC_DATE;

SELECT * FROM VW_FFI_MONTHLY WHERE TO_CHAR(RC_DATE, 'MON') = 'JUN' ORDER BY RC_DATE;

-- MOTOR --
SELECT * FROM VW_MCC_DATA;

SELECT * FROM VW_MCP_DATA;

SELECT * FROM VW_MCH_DATA;

SELECT * FROM VW_MFC_DATA;

SELECT * FROM VW_MFP_DATA;

-- LIFE (HEALTH) --
SELECT * FROM VW_LHI_DATA;

SELECT * FROM VW_LHI_DETAIL;

-- MARINE --
SELECT * FROM VW_MCG_INCOME;

SELECT * FROM VW_MCG_RC;

SELECT * FROM VW_MCG_UW1;

SELECT * FROM VW_MCG_UW2;