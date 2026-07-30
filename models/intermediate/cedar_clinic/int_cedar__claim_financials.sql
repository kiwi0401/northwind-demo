-- Conformed claim grain (one row per claim). Joins claim charges to the payment/remittance.
-- is_denied = paid == 0 for dialect C. denial_reason = first carc[] element.
-- encounter_id is resolved through case_id (charge/payment events carry claim_id, not enc id).
with claims as (
    select * from {{ ref('stg_cedar__claims') }}
),
remit as (
    select * from {{ ref('stg_cedar__remittance') }}
),
enc as (
    select encounter_id, case_id from {{ ref('stg_cedar__encounters') }}
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
