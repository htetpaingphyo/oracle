prompt
prompt library_cache_hit_ratio.sql. Developed by htetpaing (htet.paing.phyo@panasiatower.net) >>>

select
	sum(pins) pins, sum(reloads) reloads, round((sum(pins) - sum(reloads)) / sum(pins) * 100, 2) "HitRatio"
from v$librarycache;
