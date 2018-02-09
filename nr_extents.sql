SELECT 
	e.owner, e.segment_type , e.segment_name , count(*) as nr_extents , s.max_extents , to_char ( sum ( e.bytes ) / ( 1024 * 1024 ) , '999,999.90') as MB
FROM dba_extents e , dba_segments s
WHERE e.segment_name = s.segment_name
GROUP BY e.owner, e.segment_type , e.segment_name , s.max_extents
HAVING count(*) > &THRESHOLD 
OR ( ( s.max_extents - count(*) ) < &&THRESHOLD )
ORDER BY count(*) desc