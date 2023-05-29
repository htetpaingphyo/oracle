prompt
prompt check_block_sessions.sql. Developed by htetpaing (htet.paing.phyo@panasiatower.net) >>>

select
	(select username from v$session where sid=a.sid) blocker, a.sid "blocker_id", (select serial# from v$session where sid=a.sid) "blocker_serial",
	' is blocking ' as action_type,
	(select username from v$session where sid=b.sid) blockee, b.sid "blockee_id", (select serial# from v$session where sid=b.sid) "blockee_serial"
from	v$lock a, v$lock b
where	a.block = 1 and b.request > 0 and 
	a.id1=b.id1 and a.id2=b.id2;

