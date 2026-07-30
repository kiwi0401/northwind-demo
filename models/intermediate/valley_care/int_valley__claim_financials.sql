-- Conformed claim grain (one row per claim). Joins synthesized claim charges to the payment
-- remittance by claim_id, and maps the claim back to its encounter via case_id -> encounter_id.
-- is_denied = paid == 0 (dialect C ground truth). denial_reason = carc[0]. Money USD dollars.
with claims as (
    select * from {{ ref('stg_valley__claims') }}
),
remit as (
    select * from {{ ref('stg_valley__remittance') }}
),
enc as (
    select case_id, encounter_id from {{ ref('stg_valley__encounters') }}
)
select
    claims.claim_id,
    enc.encounter_id,
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
left join enc   on claims.case_id  = enc.case_id
