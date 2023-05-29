prompt
prompt library_cache_miss_ratio.sql. Developed by htetpaing (htet.paing.phyo@panasiatower.net) >>>

select
	sum(pins) executions, sum(reloads) cache_misses, (sum(reloads) / sum(pins)) "MissRatio"
from v$librarycache;
