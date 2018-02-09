SELECT s.sid, s.username, s.status, u.tablespace, u.segfile#, u.contents, u.extents, u.blocks 
FROM v$session s, v$sort_usage u 
WHERE s.sad =u.session_addr 
ORDER BY u.tablespace, u.segfile#, u.segblk#, u.blocks;