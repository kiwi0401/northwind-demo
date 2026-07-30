-- Denied claims only (is_denied = true), with the CARC denial_reason for reason breakdown.
-- Feeds the org denial rate.
select
    claim_id,
    encounter_id,
    client_id,
    payer_id,
    total_charge_usd,
    paid_amount_usd,
    unpaid_usd,
    denial_reason
from {{ ref('int_metro__claim_financials') }}
where is_denied
