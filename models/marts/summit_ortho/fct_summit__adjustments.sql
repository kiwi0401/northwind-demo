-- Adjustment fact. One row per adj[] entry. The wire
-- amount is negative (adj_amount_raw); adj_amount_usd is its abs() magnitude. is_denial_code
-- separates true denials (CO-50/16/11/197) from routine contractual/patient adjustments.
select
    a.encounter_id,
    a.claim_id,
    a.adj_group,
    a.adj_reason,
    a.carc_code,
    a.adj_amount_raw,
    a.adj_amount_usd,
    a.is_denial_code,
    enc.facility_id,
    enc.encounter_type
from {{ ref('stg_summit__adjustments') }} a
left join {{ ref('int_summit__encounters') }} enc on a.encounter_id = enc.encounter_id
