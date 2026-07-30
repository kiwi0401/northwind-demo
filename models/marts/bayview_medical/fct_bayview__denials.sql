-- Denied claims only (true CO-CARC denials). denial_reason carries the CO-<code> that triggered it.
select
    claim_id,
    encounter_id,
    client_id,
    payer_id,
    total_charge_usd,
    paid_amount_usd,
    unpaid_usd,
    denial_reason
from {{ ref('int_bayview__claim_financials') }}
where is_denied
