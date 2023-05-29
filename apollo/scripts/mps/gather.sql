exec dbms_stats.gather_database_stats( -
cascade => TRUE, -
degree => 32, -
method_opt => 'FOR ALL COLUMNS SIZE AUTO' );
