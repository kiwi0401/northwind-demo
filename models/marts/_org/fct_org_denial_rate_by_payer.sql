-- Denial rate by canonical payer across all clients. Assumes is_denied was derived per each
-- client's own source rule (array / CO-CARC / paid==0 / explicit flag).
select
    coalesce(canonical_payer_id, 'UNKNOWN')       as canonical_payer_id,
    payer_name,
    count(*)                                       as claim_count,
    sum(case when is_denied then 1 else 0 end)     as denied_count,
    round(sum(case when is_denied then 1 else 0 end) * 1.0 / count(*), 4) as denial_rate,
    sum(total_charge_usd)                          as total_charge_usd,
    sum(case when is_denied then total_charge_usd else 0 end) as denied_charge_usd
from {{ ref('fct_org_claims') }}
group by 1, 2
order by claim_count desc
