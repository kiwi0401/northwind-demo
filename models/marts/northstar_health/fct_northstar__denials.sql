-- Denied claims only, with the raw denial code payload for downstream reason parsing.
select
    claim_id,
    encounter_id,
    client_id,
    payer_id,
    total_charge_usd,
    paid_amount_usd,
    unpaid_usd,
    denial_reason
from {{ ref('int_northstar__claim_financials') }}
where is_denied
