-- Denied claims only (is_denied = true), with the CARC denial reason for downstream reporting.
select
    claim_id,
    encounter_id,
    client_id,
    payer_id,
    total_charge_usd,
    paid_amount_usd,
    unpaid_usd,
    denial_reason
from {{ ref('int_harbor__claim_financials') }}
where is_denied
