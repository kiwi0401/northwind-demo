-- Conformed claim grain: one row per claim. summit has no per-claim charge on the wire; charges
-- are encounter-level. Charges are attributed to the encounter's primary claim (claim_seq = 1)
-- and 0 to any secondary claim, so a multi-claim encounter never double-counts total_charge_usd.
-- payer_id is null (summit sends none). is_denied per the CO-50/16/11/197 rule (abs of neg adj).
with claims as (
    select * from {{ ref('stg_summit__claims') }}
),
remit as (
    select * from {{ ref('stg_summit__remittance') }}
),
charges as (
    select
        encounter_id,
        sum(charge_usd) as total_charge_usd
    from {{ ref('stg_summit__service_lines') }}
    group by 1
),
claim_charge as (
    select
        c.claim_id,
        c.encounter_id,
        c.client_id,
        c.claim_format,
        c.payer_id,
        case when c.claim_seq = 1 then coalesce(ch.total_charge_usd, 0) else 0 end as total_charge_usd
    from claims c
    left join charges ch on c.encounter_id = ch.encounter_id
)
select
    cc.claim_id,
    cc.encounter_id,
    cc.client_id,
    cc.claim_format,
    cc.payer_id,
    cc.total_charge_usd,
    coalesce(r.paid_amount_usd, 0)                        as paid_amount_usd,
    coalesce(r.is_denied, false)                          as is_denied,
    cc.total_charge_usd - coalesce(r.paid_amount_usd, 0)  as unpaid_usd,
    r.denial_reason
from claim_charge cc
left join remit r on cc.claim_id = r.claim_id
