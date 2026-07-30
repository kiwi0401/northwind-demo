-- Distinct local payer codes with claim counts, none of which exist in seed_payers.
-- Joining riverside claims to seed_payers on payer_id with an inner join drops all of these
-- rows, so this mart quantifies what would be lost. Resolve each via the org-layer payer_xref
-- seed before any payer-level rollup.
with claims as (
    select
        payer_id,
        total_charge_usd
    from {{ ref('int_riverside__claim_financials') }}
)
select
    payer_id                                    as local_payer_code,
    'riverside_health'                          as client_id,
    count(*)                                    as claim_count,
    sum(total_charge_usd)                       as total_charge_usd,
    false                                       as exists_in_payer_seed  -- always false: P0x is local-only
from claims
group by 1
order by claim_count desc
