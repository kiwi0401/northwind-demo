-- Facility dimension. One row per distinct facility seen for plains_regional,
-- with encounter volume and payer mix context for downstream slicing.
select
    enc.facility_id,
    enc.client_id,
    count(*)                                    as encounter_count,
    count(distinct enc.encounter_type)          as encounter_type_count,
    min(enc.admit_ts)                           as first_admit_ts,
    max(enc.admit_ts)                           as last_admit_ts
from {{ ref('int_plains__encounters') }} enc
group by enc.facility_id, enc.client_id
