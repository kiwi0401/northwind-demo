-- Money-unit sanity check: no client should have an avg charge/claim wildly out of band (a ~100x
-- outlier means a client's cents/string money was not normalized to USD). Fails if any client's
-- avg is >150k (real avg is a few thousand).
select client_id, avg(total_charge_usd) as avg_charge
from {{ ref('fct_org_claims') }}
group by 1
having avg(total_charge_usd) > 150000
