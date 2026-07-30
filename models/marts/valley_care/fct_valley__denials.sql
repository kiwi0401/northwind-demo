-- Denied claims only (is_denied = paid==0). Retains denial_reason (carc[0]) for the org denial rate.
select
    claim_id,
    encounter_id,
    client_id,
    payer_id,
    total_charge_usd,
    paid_amount_usd,
    unpaid_usd,
    denial_reason
from {{ ref('int_valley__claim_financials') }}
where is_denied
