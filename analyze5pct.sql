BEGIN
dbms_utility.analyze_schema ( '&OWNER', 'ESTIMATE', NULL, 5 ) ;
END ;
/