-- Total and average charges by client (USD). Standard finance rollup.
select
    client_id,
    count(*)                                   as claim_count,
    sum(total_charge_usd)                      as total_charge_usd,
    sum(paid_amount_usd)                       as total_paid_usd,
    sum(unpaid_usd)                            as total_unpaid_usd,
    round(avg(total_charge_usd), 2)            as avg_charge_per_claim,
    round(sum(paid_amount_usd) * 1.0 / nullif(sum(total_charge_usd), 0), 4) as collection_rate
from {{ ref('fct_org_claims') }}
group by 1
order by total_charge_usd desc
