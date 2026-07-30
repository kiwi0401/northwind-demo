-- Claim grain. Joins claim charges to the 835 remittance. is_denied from denial_codes[].
-- payer_id passes through raw (local P0x code). Canonical mapping happens at the org
-- layer via payer_xref, not here. denial_reason = first denial code.
with claims as (
    select * from {{ ref('stg_riverside__claims') }}
),
remit as (
    select * from {{ ref('stg_riverside__remittance') }}
)
select
    claims.claim_id,
    claims.encounter_id,
    claims.client_id,
    claims.claim_format,
    claims.payer_id,
    claims.total_charge_usd,
    remit.paid_amount_usd,
    coalesce(remit.is_denied, false)                                       as is_denied,
    claims.total_charge_usd - coalesce(remit.paid_amount_usd, 0)           as unpaid_usd,
    remit.denial_reason,
    remit.denial_codes_json
from claims
left join remit on claims.claim_id = remit.claim_id
