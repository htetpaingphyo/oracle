select sid, serial#, username, status, server, schemaname, osuser, program, machine, type, module, seconds_in_wait "WAITING"
from v$session v 
where type='USER' order by seconds_in_wait desc;