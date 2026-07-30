-- Denied claims only (is_denied = true). denial_reason = first denial CARC code.
select
    claim_id,
    encounter_id,
    client_id,
    payer_id,
    total_charge_usd,
    paid_amount_usd,
    unpaid_usd,
    denial_reason
from {{ ref('int_plains__claim_financials') }}
where is_denied
