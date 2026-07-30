-- Client-level claim fact. One row per claim, enriched with encounter context.
select
    cf.claim_id,
    cf.encounter_id,
    cf.client_id,
    cf.claim_format,
    cf.payer_id,
    cf.total_charge_usd,
    cf.paid_amount_usd,
    cf.unpaid_usd,
    cf.is_denied,
    cf.denial_reason,
    enc.facility_id,
    enc.encounter_type,
    enc.drg_code,
    enc.primary_diagnosis_code
from {{ ref('int_plains__claim_financials') }} cf
left join {{ ref('int_plains__encounters') }} enc on cf.encounter_id = enc.encounter_id
