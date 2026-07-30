-- Claim grain (conformed contract). Joins claim charges to the 835 remittance.
-- is_denied + denial_reason come from the dialect-B CARC rule (grp=CO, code in 50/16/11/197).
with claims as (
    select * from {{ ref('stg_metro__claims') }}
),
remit as (
    select * from {{ ref('stg_metro__remittance') }}
)
select
    claims.claim_id,
    claims.encounter_id,
    claims.client_id,
    claims.claim_format,
    claims.payer_id,
    claims.total_charge_usd,
    remit.paid_amount_usd,
    coalesce(remit.is_denied, false)                              as is_denied,
    claims.total_charge_usd - coalesce(remit.paid_amount_usd, 0)  as unpaid_usd,
    remit.denial_reason
from claims
left join remit on claims.claim_id = remit.claim_id
