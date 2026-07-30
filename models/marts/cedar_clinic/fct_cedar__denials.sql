-- Denied claims only (is_denied = paid==0 for this zero-pay dialect). Retains denial_reason
-- (first carc[]) for downstream reason breakdown. Feeds the org denial rate.
select
    claim_id,
    encounter_id,
    client_id,
    payer_id,
    total_charge_usd,
    paid_amount_usd,
    unpaid_usd,
    denial_reason
from {{ ref('int_cedar__claim_financials') }}
where is_denied
