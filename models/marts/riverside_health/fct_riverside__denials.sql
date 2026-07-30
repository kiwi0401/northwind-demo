-- Denied claims only (is_denied = true), with the denial reason and raw code payload.
select
    claim_id,
    encounter_id,
    client_id,
    payer_id,
    total_charge_usd,
    paid_amount_usd,
    unpaid_usd,
    denial_reason,
    denial_codes_json
from {{ ref('int_riverside__claim_financials') }}
where is_denied
