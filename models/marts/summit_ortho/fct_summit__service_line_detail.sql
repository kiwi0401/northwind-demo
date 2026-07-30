-- Service-line detail fact. One row per (claim, line); charges fan out per encounter,
-- enriched with encounter and claim context so each charge carries its facility, encounter type,
-- primary diagnosis, and the claim-level denial flag.
select
    sl.claim_id,
    sl.encounter_id,
    sl.line_no,
    sl.procedure_code,
    sl.units,
    sl.charge_usd,
    enc.facility_id,
    enc.encounter_type,
    enc.primary_diagnosis_code,
    cf.payer_id,
    cf.is_denied,
    cf.denial_reason
from {{ ref('int_summit__service_lines') }} sl
left join {{ ref('int_summit__encounters') }} enc       on sl.encounter_id = enc.encounter_id
left join {{ ref('int_summit__claim_financials') }} cf  on sl.claim_id = cf.claim_id
