-- Org denial summary at client grain. Older sibling of fct_org_denial_rate_by_payer, which is
-- the same idea at payer grain. Both are internally correct for their own grain; the name here
-- gives no hint which one is canonical.
select
    client_id,
    count(*)                                               as claim_count,
    sum(case when is_denied then 1 else 0 end)             as denied_count,
    round(sum(case when is_denied then 1 else 0 end) * 1.0 / count(*), 4) as denial_rate,
    sum(total_charge_usd)                                  as total_charge_usd,
    sum(case when is_denied then total_charge_usd else 0 end) as denied_charge_usd
from {{ ref('fct_org_claims') }}
group by 1
order by claim_count desc
