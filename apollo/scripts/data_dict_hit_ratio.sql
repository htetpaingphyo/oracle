prompt
prompt data_dict_hit_ratio.sql. Developed by htetpaing (htet.paing.phyo@panasiatower.net) >>>

select
	sum(gets), sum(getmisses), round((1 - (sum(getmisses) / sum(gets))) * 100, 2) "HitRatio"
from v$rowcache;
