-- The raw adj amount is negative on the wire; the reported magnitude must be its abs() value.
-- Fails if abs() was dropped (adj_amount_usd should always be >= 0 and equal abs(raw)).
select
    claim_id,
    adj_amount_raw,
    adj_amount_usd
from {{ ref('fct_summit__adjustments') }}
where adj_amount_usd < 0
   or adj_amount_usd <> abs(adj_amount_raw)
