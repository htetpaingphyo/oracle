set lines 300;

prompt
prompt buffer_hit_ratio.sql. Developed by htetpaing (htet.paing.phyo@panasiatower.net) >>>

select 
	sum(decode(name, 'consistent gets', value, 0)) "ConsistentGets",
	sum(decode(name, 'db block gets', value, 0)) "DbBlockGets",
	sum(decode(name, 'physical reads', value, 0)) "PhysicalReads",
	round( 
		(
		sum(decode(name, 'consistent gets', value, 0)) + 
		sum(decode(name, 'db block gets', value, 0)) - 
		sum(decode(name, 'physical reads', value, 0))
		) / 
		(
		sum(decode(name, 'consistent gets', value, 0)) + 
		sum(decode(name, 'db block gets', value, 0))
		) * 100, 2
	     ) "HitRatio"
from v$sysstat;
		
