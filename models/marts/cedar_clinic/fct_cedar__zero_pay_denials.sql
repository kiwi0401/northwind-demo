-- Client-specific mart: paid==0 denial inference for this feed. Every claim with
-- paid_amount_usd = 0 counts as a denial regardless of whether the v2.0 'denial' flag was
-- sent (v1/v3 omit it). unpaid_usd = full charge on a zero-pay.
-- carc_matches_true_denial flags whether the delivered carc is one of the denial CARCs
-- (CO-50/16/11/197) vs a routine adjustment, so the org layer can cross-check both.
select
    claim_id,
    encounter_id,
    client_id,
    total_charge_usd,
    paid_amount_usd,
    unpaid_usd,
    is_denied,
    denial_reason,
    (denial_reason in ('CO-50', 'CO-16', 'CO-11', 'CO-197')) as carc_matches_true_denial
from {{ ref('int_cedar__claim_financials') }}
where paid_amount_usd = 0
